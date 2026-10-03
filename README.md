# IPAudioPlus Releases

[![Release](https://img.shields.io/badge/Release-v2.4.1-blue.svg)](#)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-green.svg)](#)
[![Enigma2](https://img.shields.io/badge/Platform-Enigma2-orange.svg)](#)

Official release repository for **IPAudioPlus** v2.4.1 — the high-performance audio synchronization and streaming plugin for Enigma2 set-top boxes.

---

## ⚡ Quick One-Line Installation

Run the following command directly on your Enigma2 box terminal via SSH or Telnet:

```bash
wget -q "--no-check-certificate" https://raw.githubusercontent.com/<YOUR_GH_USER>/IPAudioPlus-Releases/refs/heads/main/installer.sh -O - | /bin/bash
```

Or using `curl`:

```bash
curl -k -s -L https://raw.githubusercontent.com/<YOUR_GH_USER>/IPAudioPlus-Releases/refs/heads/main/installer.sh | /bin/bash
```

The installer will automatically:
1. Detect your Python version (`3.11`, `3.12`, `3.13`, or `3.14`).
2. Detect your box architecture (`cortexa15hf`, `cortexa9hf`, `cortexa7hf`, `armv7ahf`, `aarch64`, `mips32el`).
3. Detect your installed FFmpeg version (`6.1`, `7.1`, or `8.0`).
4. Download and install the exact matching `.ipk` package without needing `--force-architecture`.
5. Restart Enigma2 GUI.

---

## 📦 Directory Structure

```
IPAudioPlus-Releases/
├── installer.sh
├── README.md
├── LICENSE
├── SHA256SUMS.txt
└── v2.4.1/
    ├── python3.11/
    │   ├── arm/
    │   ├── aarch64/
    │   └── mipsel/
    ├── python3.12/
    │   ├── arm/
    │   ├── aarch64/
    │   └── mipsel/
    ├── python3.13/
    │   ├── arm/
    │   ├── aarch64/
    │   └── mipsel/
    └── python3.14/
        ├── arm/
        └── aarch64/
```

Package naming scheme:
`enigma2-plugin-extensions-ipaudioplus_<VERSION>_<OPKG_ARCH>_py<PY_VER>_ff<FF_VER>.ipk`
