#!/usr/bin/env python3
import argparse
import os
import random
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, override

import gi
from gi.repository.GLib import Variant

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Graphene", "1.0")
from gi.repository import Gdk, GdkPixbuf, Gio, GLib, Graphene, Gtk

BUS = "org.gnome.Mutter.IdleMonitor"
PATH = "/org/gnome/Mutter/IdleMonitor/Core"
IFACE = "org.gnome.Mutter.IdleMonitor"


@dataclass
class Config:
    image_dirs: list[Path]
    idle_ms: int
    slide_seconds: int
    max_zoom: float
    min_zoom: float
    max_pan: float
    min_pan: float
    fps: int
    debug: bool


def parse_args(argv: list[str] | None = None) -> Config:
    parser = argparse.ArgumentParser(description="Photo frame screensaver.")
    parser.add_argument(
        "--image-dir",
        default=None,
        type=Path,
        action="append",
        help="Directory of photos to display.",
    )
    parser.add_argument(
        "--idle-seconds",
        type=int,
        default=180,
        help="Idle time before the screensaver starts.",
    )
    parser.add_argument(
        "--slide-seconds",
        type=int,
        default=12,
        help="Seconds to show each photo.",
    )

    parser.add_argument(
        "--max-zoom", type=float, default=1.2, help="Maximum amount to zoom on a photo"
    )
    parser.add_argument(
        "--min-zoom", type=float, default=1.05, help="Minimum amount to zoom on a photo"
    )

    parser.add_argument(
        "--max-pan", type=float, default=0.6, help="Maximum amount to pan on a photo"
    )
    parser.add_argument(
        "--min-pan", type=float, default=-0.6, help="Minimum amount to pan on a photo"
    )

    parser.add_argument("--fps", type=int, default=30, help="Animation frame rate.")
    parser.add_argument(
        "--debug", action="store_true", help="Log start/stop/tick to stderr."
    )
    args = parser.parse_args(argv)

    if args.idle_seconds <= 0:
        parser.error("--idle-seconds must be positive")
    if args.slide_seconds <= 0:
        parser.error("--slide-seconds must be positive")
    if args.max_zoom <= args.min_zoom:
        parser.error("--max-zoom must be greater than --min-zoom")
    if args.max_pan <= args.min_pan:
        parser.error("--max-pan must be greater than --min-pan")
    if args.fps <= 0:
        parser.error("--fps must be positive")

    image_dirs = args.image_dir if args.image_dir is not None else [Path("/mnt/Photo_Frame")]
    
    return Config(
        image_dirs=image_dirs,
        idle_ms=args.idle_seconds * 1000,
        slide_seconds=args.slide_seconds,
        max_zoom=args.max_zoom,
        min_zoom=args.min_zoom,
        max_pan=args.max_pan,
        min_pan=args.min_pan,
        fps=args.fps,
        debug=args.debug,
    )


def load_images(dirs: list[Path]) -> list[str]:
    names: list[str] = []
    for dir in dirs:
        try:
            entries = sorted(os.listdir(dir))
        except OSError:
            continue # dir doesn't exist, try the others
        for name in entries:
            if name.lower().endswith((".jpg", ".jpeg", ".png")):
                names.append(str(dir / name))
    random.shuffle(names)
    return names


def load_texture(path: os.PathLike[str]) -> Gdk.Texture | None:
    pixbuf = GdkPixbuf.Pixbuf.new_from_file(os.fspath(path))
    if pixbuf is None:
        return None
    rotated = pixbuf.apply_embedded_orientation()
    if rotated is not None:
        pixbuf = rotated
    return Gdk.Texture.new_for_pixbuf(pixbuf)


class Slide(Gtk.Widget):
    def __init__(self) -> None:
        super().__init__()
        self.texture: Gdk.Texture | None = None
        self.progress: float = 0.0
        self.zoom_from: float = 1.0
        self.zoom_to: float = 1.15
        self.pan_x: float = 0.0
        self.pan_y: float = 0.0

    def set_texture(
        self,
        texture: Gdk.Texture | None,
        zoom_from: float,
        zoom_to: float,
        pan_x: float,
        pan_y: float,
    ) -> None:
        self.texture = texture
        self.progress = 0.0
        self.zoom_from = zoom_from
        self.zoom_to = zoom_to
        self.pan_x = pan_x
        self.pan_y = pan_y
        self.queue_draw()

    def set_progress(self, progress: float) -> None:
        self.progress = progress
        self.queue_draw()

    @override
    def do_snapshot(self, snapshot: Gtk.Snapshot) -> None:
        if self.texture is None:
            return
        width = self.get_width()
        height = self.get_height()
        tex_w = self.texture.get_width()
        tex_h = self.texture.get_height()
        if width <= 0 or height <= 0 or tex_w <= 0 or tex_h <= 0:
            return
        cover = max(width / tex_w, height / tex_h)
        zoom = cover * (
            self.zoom_from + (self.zoom_to - self.zoom_from) * self.progress
        )
        draw_w = tex_w * zoom
        draw_h = tex_h * zoom
        offset_x = (width - draw_w) * (0.5 + self.pan_x * (self.progress - 0.5))
        offset_y = (height - draw_h) * (0.5 + self.pan_y * (self.progress - 0.5))
        snapshot.save()
        snapshot.translate(Graphene.Point().init(offset_x, offset_y))
        snapshot.scale(zoom, zoom)
        snapshot.append_texture(self.texture, Graphene.Rect().init(0, 0, tex_w, tex_h))
        snapshot.restore()


class PhotoScreensaver(Gtk.Application):
    def __init__(self, config: Config) -> None:
        super().__init__(application_id="net.yanello.photo-screensaver")
        self.config: Config = config
        self.watches: dict[str, Any] = {"idle": None, "active": None}
        self.timer: int | None = None
        self.frames_left: int = 0
        self.index: int = 0
        self.images: list[str] = []

    @override
    def do_activate(self) -> None:
        self.window: Gtk.ApplicationWindow = Gtk.ApplicationWindow(application=self)
        self.window.set_decorated(False)
        self.slide: Slide = Slide()
        self.window.set_child(self.slide)
        self.window.set_visible(False)
        self.conn: Gio.DBusConnection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        self.conn.signal_subscribe(
            BUS,
            IFACE,
            "WatchFired",
            PATH,
            None,
            Gio.DBusSignalFlags.NONE,
            self.on_fired,
        )
        self.hold()
        self.arm_idle()

    def call(self, method: str, params: GLib.Variant | None) -> Variant:
        return self.conn.call_sync(
            BUS, PATH, IFACE, method, params, None, Gio.DBusCallFlags.NONE, -1, None
        )

    def arm_idle(self) -> None:
        self.watches["idle"] = self.call(
            "AddIdleWatch", GLib.Variant("(t)", (self.config.idle_ms,))
        ).unpack()[0]

    def arm_active(self) -> None:
        self.watches["active"] = self.call("AddUserActiveWatch", None).unpack()[0]

    def on_fired(
        self,
        conn: Gio.DBusConnection,
        sender: str | None,
        path: str,
        iface: str,
        signal: str,
        params: GLib.Variant,
    ) -> None:
        fired = params.unpack()[0]
        if fired == self.watches["idle"]:
            self.watches["idle"] = None
            self.start()
            self.arm_active()
        elif fired == self.watches["active"]:
            self.watches["active"] = None
            self.stop()
            self.arm_idle()

    def start(self) -> None:
        self.images = load_images(self.config.image_dirs)
        self.index = 0
        if not self.images:
            return
        if self.config.debug:
            print("start", file=sys.stderr)
        self.show_next()
        self.window.fullscreen()
        self.window.present()
        if self.timer is None:
            self.timer = GLib.timeout_add(1000 // self.config.fps, self.animate)

    def stop(self) -> None:
        if self.config.debug:
            print("stop", file=sys.stderr)
        if self.timer is not None:
            GLib.source_remove(self.timer)
            self.timer = None
        self.window.set_visible(False)

    def show_next(self) -> None:
        self.frames_left = self.config.slide_seconds * self.config.fps
        path = self.images[self.index % len(self.images)]
        self.index += 1
        try:
            texture = load_texture(Path(path))
        except GLib.Error:
            return
        self.slide.set_texture(
            texture=texture,
            zoom_from=random.uniform(self.config.min_zoom, self.config.max_zoom),
            zoom_to=random.uniform(self.config.min_zoom, self.config.max_zoom),
            pan_x=random.uniform(self.config.min_pan, self.config.max_pan),
            pan_y=random.uniform(self.config.min_pan, self.config.max_pan),
        )

    def animate(self) -> bool:
        total = self.config.slide_seconds * self.config.fps
        self.frames_left -= 1
        if self.config.debug and self.frames_left % 30 == 0:
            print("tick", self.frames_left, file=sys.stderr)
        self.slide.set_progress(max(0.0, 1.0 - self.frames_left / total))
        if self.frames_left <= 0:
            self.show_next()
        return True


if __name__ == "__main__":
    PhotoScreensaver(parse_args()).run([])
