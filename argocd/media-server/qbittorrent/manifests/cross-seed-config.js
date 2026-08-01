module.exports = {
  torznab: [
    "http://prowlarr:9696/1/api?apikey=12345",
    "http://prowlarr:9696/2/api?apikey=12345",
  ],
  torrentClients: [
    "qbittorrent:http://user:pass@localhost:8080",
    "deluge:http://:pass@localhost:8112/json",
    "transmission:readonly:http://user:pass@localhost:9091/transmission/rpc",
    "rtorrent:http://user:pass@localhost:8080/RPC2",
  ],
  linkDirs: ["/data/torrents/SomeLinkDirName"],
};
