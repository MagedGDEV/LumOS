SUMMARY = "LumOS Voice Recognition"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${TOPDIR}/../voice/:"

SRC_URI = " \
    file://voice.py      \
    file://voice.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "voice.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} += " \
    python3 \
    python3-vosk \
    python3-pyaudio \
    vosk-model \
"

do_install() {
    # Install script
    install -d ${D}/usr/share/lumos
    install -m 0755 ${WORKDIR}/voice.py ${D}/usr/share/lumos/voice.py

    # Install service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/voice.service ${D}${systemd_system_unitdir}
}

FILES:${PN} += " \
    /usr/share/lumos/voice.py \
    ${systemd_system_unitdir}/voice.service \
"
