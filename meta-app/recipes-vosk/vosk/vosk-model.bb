SUMMARY = "Vosk small English model for voice recognition"
LICENSE = "CLOSED"

SRC_URI = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
SRC_URI[sha256sum] = "30f26242c4eb449f948e42cb302dd7a686cb29a3423a8367f99ff41780942498"

S = "${WORKDIR}/vosk-model-small-en-us-0.15"

do_install() {
    install -d ${D}/usr/share/vosk/
    cp -r ${S} ${D}/usr/share/vosk/model
}

FILES:${PN} = "/usr/share/vosk/model"