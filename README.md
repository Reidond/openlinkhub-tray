# openlinkhub-tray
Linux system tray application for OpenLinkHub

### 1. Build & install
```bash
$ git clone https://github.com/jurkovic-nikola/openlinkhub-tray.git
$ cd openlinkhub-tray/
$ go build .
```

### 2. Running it
```bash
$ ./openlinkhub_tray
```

### 3. If OpenLinkHub listen on different address / port
```bash
$ ./openlinkhub_tray -ip 127.0.0.1 -port 27003
```

This app needs to run under your desktop session to display the menu. You can place this binary anywhere and have it auto-start when you log in. 