# IPAudioPlus Releases

[![Release](https://img.shields.io/badge/Release-v2.6.0%20Beta-orange.svg)](#)
[![Enigma2](https://img.shields.io/badge/Platform-Enigma2-blue.svg)](#)

Official release repository for **IPAudioPlus** — live commentary audio for Enigma2 boxes, with automatic
picture/commentary synchronisation.

## ⚡ Install / update (one line)

Run on the box (SSH / Telnet):

```sh
wget -q -O - https://raw.githubusercontent.com/Ahmadarjan1/IPAudioPlus-Releases/main/installer.sh | /bin/sh
```

or with curl:

```sh
curl -k -s -L https://raw.githubusercontent.com/Ahmadarjan1/IPAudioPlus-Releases/main/installer.sh | /bin/sh
```

The installer:
1. Detects Python (`3.9`, `3.11`, `3.12`, `3.13`, `3.14`) and the CPU (`arm`, `aarch64`, `mipsel`).
2. Downloads the matching package and checks it.
3. Installs it with `opkg` — **the installed plugin is not removed if anything fails**.
4. Restarts Enigma2.

Problems? The full log is in `/tmp/ipaudioplus_install.log` — please send it with your report.

Already on 2.4.1? The plugin offers the update by itself.

## 🆕 2.6.0 Beta

- New interface: dark and light mode, 4 accent colours, optional horizontal layout, large text and high contrast.
- Server list inside the main panel (AUDIO key), with server and channel icons.
- beIN SPORTS programme guide next to every audio channel (1-9, XTRA, EN, FR, MAX).
- Sync notification, goal alerts and match reminders.
- "No sound?" diagnostics, QR code for the mobile remote, sync history, version history with rollback.
- ipa_core 1.0.7 audio engine: works with the sound cards of older MIPS boxes (e.g. Vu+ Zero).
- First package for MIPS boxes with Python 3.14 (openATV 8).

## 📦 Layout

```
installer.sh
version.json
v2.6.0/python<ver>/<arm|aarch64|mipsel>/enigma2-plugin-extensions-ipaudioplus_2.6.0_<arch>_py<ver>.ipk
v2.5.1/...   (previous release)
```

