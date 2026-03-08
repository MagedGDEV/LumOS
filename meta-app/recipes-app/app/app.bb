SUMMARY = "Light Control Qt application"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${TOPDIR}/../app:"

SRC_URI = " \
    file://CMakeLists.txt;subdir=git        \
    file://src/main.cpp;subdir=git          \
    file://Main.qml;subdir=git              \
    file://app.service                      \
"

S ="${WORKDIR}/git"

inherit cmake qt6-cmake systemd

DEPENDS += "qtbase qttools qtdeclarative qtdeclarative-native qtwayland"

RDEPENDS:${PN} += "qtwayland"

SYSTEMD_SERVICE:${PN} = "app.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/LumOS ${D}${bindir}

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/app.service ${D}${systemd_system_unitdir}
}