# IPAudioPlus Releases

[![Release](https://img.shields.io/badge/Release-v2.5.1%20Beta-orange.svg)](#)
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

## 🆕 2.5.1 Beta

- Auto-Sync v3.1: measures while the commentary keeps playing, handles weak stadium sound and stream dropouts,
  confirms weak matches with a second measurement before applying.
- Drift guard: keeps picture and commentary together after satellite glitches.
- Green key after Auto-Sync: review and fine-tune the last result without measuring again.
- Fixed correction per commentary channel (blue key).
- Live Info: real TV channels and commentators (jdwel.com) with team flags.
- Programme of each audio channel (beIN schedule) with a progress bar.
- ipa_core 1.0.6 audio engine, no dependency on the image's FFmpeg libraries.

## 📦 Layout

```
installer.sh
version.json
v2.5.1/python<ver>/<arm|aarch64|mipsel>/enigma2-plugin-extensions-ipaudioplus_2.5.1_<arch>_py<ver>.ipk
v2.4.1/...   (previous release)
```

MIPS + Python 3.14: no package yet.
