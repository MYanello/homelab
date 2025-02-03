#!/usr/bin/env python3
import sys
import subprocess
subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
import requests

def check_camera_fps():
    try:
        # Make request to Frigate API
        response = requests.get('https://frigate.yanello.net/api/stats')
        response.raise_for_status()  # Raise exception for non-200 status codes
        
        data = response.json()
        cameras = data.get('cameras', {})
        
        # Check if any camera has non-zero FPS
        all_zero = True
        zero_fps_cameras = []
        
        for camera_name, stats in cameras.items():
            if stats.get('camera_fps', 0) == 0:
                zero_fps_cameras.append(camera_name)
            else:
                all_zero = False
        
        if all_zero:
            print(f"CRITICAL: All cameras have 0 FPS. Affected cameras: {', '.join(zero_fps_cameras)}")
            sys.exit(2)
        elif zero_fps_cameras:
            print(f"WARNING: Some cameras have 0 FPS: {', '.join(zero_fps_cameras)}")
            sys.exit(1)
        else:
            print("OK: All cameras are receiving frames")
            sys.exit(0)
            
    except requests.exceptions.RequestException as e:
        print(f"CRITICAL: Failed to connect to Frigate API: {str(e)}")
        sys.exit(2)
    except Exception as e:
        print(f"UNKNOWN: An error occurred: {str(e)}")
        sys.exit(3)

if __name__ == "__main__":
    check_camera_fps()