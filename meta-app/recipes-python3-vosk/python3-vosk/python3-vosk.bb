SUMMARY = "Vosk offline speech recognition Python bindings"
LICENSE = "CLOSED"


SRC_URI = "https://github.com/alphacep/vosk-api/releases/download/v0.3.42/vosk-0.3.42-py3-none-linux_armv7l.whl"
SRC_URI[sha256sum] = "cb7c157b837d6d09991382045d3d8577eb1a0beb8cf16c6f66a8f3a04ce70a26"

S = "${WORKDIR}"

inherit python3-dir

DEPENDS += "unzip-native"

# Skip QA checks for prebuilt binary
INSANE_SKIP:${PN} = "already-stripped ldflags"

do_install() {
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    cd ${S}
    unzip -o vosk-0.3.42-py3-none-linux_armv7l.whl -d ${D}${PYTHON_SITEPACKAGES_DIR}
}

FILES:${PN} += " \
    ${PYTHON_SITEPACKAGES_DIR}/vosk \
    ${PYTHON_SITEPACKAGES_DIR}/vosk/* \
    ${PYTHON_SITEPACKAGES_DIR}/vosk-0.3.42.dist-info \
    ${PYTHON_SITEPACKAGES_DIR}/vosk-0.3.42.dist-info/* \
"

RDEPENDS:${PN} += "python3 python3-cffi python3-requests python3-tqdm"