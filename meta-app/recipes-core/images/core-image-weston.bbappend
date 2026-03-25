# Append our app on top of the standard weston image
IMAGE_INSTALL:append = " app systemd"

DISTRO_FEATURES:append = " wayland"

inherit extrausers

# Allow accessing GPIO through weston user
EXTRA_USERS_PARAMS = "\
    groupadd -r gpio; \
    usermod -a -G gpio weston; \
"