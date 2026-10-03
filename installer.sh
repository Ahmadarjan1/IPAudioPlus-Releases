#!/bin/sh
# ------------------------------------------------------------------
# IPAudioPlus - installer / updater for Enigma2 boxes
#   wget -q -O - https://raw.githubusercontent.com/Ahmadarjan1/IPAudioPlus-Releases/main/installer.sh | /bin/sh
# POSIX sh (works with BusyBox ash and bash). The installed plugin is only replaced after the new
# package was downloaded and checked; if opkg fails, the old plugin stays as it was.
# ------------------------------------------------------------------
VERSION="2.5.1"
CHANNEL="Beta"
BASE_URL="https://raw.githubusercontent.com/Ahmadarjan1/IPAudioPlus-Releases/main"
PKG="enigma2-plugin-extensions-ipaudioplus"
SUPPORTED_PY="3.9 3.11 3.12 3.13 3.14"
LOG="/tmp/ipaudioplus_install.log"

G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; R='\033[0;31m'; N='\033[0m'
say()  { printf "%b\n" "$*"; }
fail() { say "${R}ERROR: $*${N}"; say "${C}Details: $LOG${N}"; rm -f "$TMP_IPK"; exit 1; }

say "${C}##################################################${N}"
say "${Y}###   IPAudioPlus v${VERSION} ${CHANNEL} - Setup               ###${N}"
say "${C}##################################################${N}"
: > "$LOG"

# ---- Python ------------------------------------------------------------------------------
PYBIN=""
for p in python3 python; do
    if command -v "$p" >/dev/null 2>&1; then PYBIN="$p"; break; fi
done
[ -n "$PYBIN" ] || fail "Python 3 not found on this image."
PY_VER=$("$PYBIN" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>>"$LOG")
PY_BITS=$("$PYBIN" -c 'import struct; print(struct.calcsize("P") * 8)' 2>>"$LOG")
say "Python: ${G}${PY_VER}${N} (${PY_BITS}-bit)"
case " $SUPPORTED_PY " in
    *" $PY_VER "*) ;;
    *) fail "Python $PY_VER is not supported (supported: $SUPPORTED_PY)." ;;
esac

# ---- CPU ---------------------------------------------------------------------------------
RAW=$(uname -m 2>/dev/null)
case "$RAW" in
    aarch64|arm64)
        # some boxes run a 64-bit kernel with a 32-bit system: follow Python, not the kernel
        if [ "$PY_BITS" = "32" ]; then BUCKET="arm"; else BUCKET="aarch64"; fi ;;
    arm*)  BUCKET="arm" ;;
    mips*) BUCKET="mipsel" ;;
    *)     fail "Unsupported CPU: $RAW" ;;
esac
say "CPU: ${G}${RAW}${N} -> package ${G}${BUCKET}${N}"
if [ "$BUCKET" = "mipsel" ] && [ "$PY_VER" = "3.14" ]; then
    fail "No package for MIPS boxes with Python 3.14 yet (supported on MIPS: 3.9 3.11 3.12 3.13)."
fi

IPK="${PKG}_${VERSION}_${BUCKET}_py${PY_VER}.ipk"
URL="${BASE_URL}/v${VERSION}/python${PY_VER}/${BUCKET}/${IPK}"
TMP_IPK="/tmp/${IPK}"

# ---- installed version -------------------------------------------------------------------
OLD=$(opkg status "$PKG" 2>/dev/null | sed -n 's/^Version: *//p' | head -n1)
if [ -n "$OLD" ]; then say "Installed: ${Y}${OLD}${N}"; else say "Installed: none"; fi

# ---- download ----------------------------------------------------------------------------
rm -f "$TMP_IPK"
if [ -n "${IPA_LOCAL_IPK:-}" ]; then          # test before publishing: IPA_LOCAL_IPK=/tmp/x.ipk sh installer.sh
    say "Using local package: ${C}${IPA_LOCAL_IPK}${N}"
    cp "$IPA_LOCAL_IPK" "$TMP_IPK" 2>>"$LOG"
else
say "Downloading: ${C}${URL}${N}"
wget -q -O "$TMP_IPK" "$URL" >>"$LOG" 2>&1 \
  || wget -q --no-check-certificate -O "$TMP_IPK" "$URL" >>"$LOG" 2>&1 \
  || { command -v curl >/dev/null 2>&1 && curl -k -s -L -f -o "$TMP_IPK" "$URL" >>"$LOG" 2>&1; }
fi
[ -s "$TMP_IPK" ] || fail "Download failed. Check the internet connection of the box (and the date/time), then try again."
SIZE=$(wc -c < "$TMP_IPK")
MAGIC=$(head -c 7 "$TMP_IPK" 2>/dev/null)
if [ "$SIZE" -lt 100000 ] || [ "$MAGIC" != "!<arch>" ]; then
    fail "The downloaded file is not a valid package (${SIZE} bytes). No package for Python ${PY_VER} on ${BUCKET}?"
fi
say "Downloaded ${G}$((SIZE / 1024)) KB${N}"

# ---- install (the old plugin is only replaced when this works) ---------------------------
# --nodeps: some images list another "ipaudioplus-pyX.Y" package in their feed that opkg then tries
# to pull in (and fails to download, exit 255). Our package needs nothing but Python.
say "${G}Installing...${N}"
opkg install --nodeps --force-reinstall --force-overwrite "$TMP_IPK" >>"$LOG" 2>&1
RC=$?
if [ $RC -ne 0 ] && grep -qiE "unrecognized option|invalid option|unknown option" "$LOG"; then
    opkg install --force-reinstall --force-overwrite --force-depends "$TMP_IPK" >>"$LOG" 2>&1
    RC=$?
fi
rm -f "$TMP_IPK"
NEW=$(opkg status "$PKG" 2>/dev/null | sed -n 's/^Version: *//p' | head -n1)
PDIR="/usr/lib/enigma2/python/Plugins/Extensions/IPAudioPlus"
if [ "$NEW" = "$VERSION" ] && [ -f "$PDIR/plugin.py" ] && [ -f "$PDIR/ipa_version.py" ]; then
    [ $RC -eq 0 ] || say "${Y}opkg reported $RC, but IPAudioPlus $VERSION is installed (see $LOG).${N}"
else
    say "${R}Installation failed (opkg exit code $RC). Last messages:${N}"
    tail -n 15 "$LOG"
    say "${C}Your previous IPAudioPlus (if any) was not removed.${N}"
    [ $RC -ne 0 ] || RC=1
    exit $RC
fi
say "${G}IPAudioPlus ${NEW:-$VERSION} ${CHANNEL} installed successfully.${N}"
say "${C}Restarting Enigma2...${N}"
sleep 2
if command -v systemctl >/dev/null 2>&1 && systemctl is-active enigma2 >/dev/null 2>&1; then
    systemctl restart enigma2
else
    killall -9 enigma2 >/dev/null 2>&1
fi
exit 0
