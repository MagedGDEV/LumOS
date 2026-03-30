# Append our app on top of the standard weston image
IMAGE_INSTALL:append = " app systemd vosk-model voice alsa-lib alsa-utils alsa-plugins"

DISTRO_FEATURES:append = " wayland"

MACHINE_EXTRA_RRECOMMENDS += "kernel-module-snd-usb-audio"

inherit extrausers

# Allow accessing GPIO through weston user
EXTRA_USERS_PARAMS = "\
    groupadd -r gpio; \
    usermod -a -G gpio weston; \
"