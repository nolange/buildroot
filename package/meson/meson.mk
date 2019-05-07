################################################################################
#
# meson
#
################################################################################

MESON_VERSION = 0.54.0
MESON_SITE = https://github.com/mesonbuild/meson/releases/download/$(MESON_VERSION)
MESON_LICENSE = Apache-2.0
MESON_LICENSE_FILES = COPYING
MESON_SETUP_TYPE = setuptools

HOST_MESON_NEEDS_HOST_PYTHON = python3

$(eval $(host-python-package))
