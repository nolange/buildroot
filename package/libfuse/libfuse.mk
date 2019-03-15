################################################################################
#
# libfuse
#
################################################################################

LIBFUSE_VERSION = 2.9.9
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VERSION).tar.gz
LIBFUSE_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VERSION)
LIBFUSE_LICENSE = GPL-2.0, LGPL-2.1
LIBFUSE_LICENSE_FILES = COPYING COPYING.LIB
LIBFUSE_INSTALL_STAGING = YES
LIBFUSE_DEPENDENCIES = $(if $(BR2_PACKAGE_LIBICONV),libiconv) $(if $(BR2_PACKAGE_LIBFUSE3),libfuse3)
LIBFUSE_CONF_OPTS = \
	--disable-example \
	--enable-lib \
	--enable-util \
	UDEV_RULES_PATH=/lib/udev/rules.d

# From libfuse3 README:
# libfuse 3 is designed to be co-installable with libfuse 2. However, some
# files will be installed by both libfuse 2 and libfuse 3
# (e.g. /etc/fuse.conf, the udev and init scripts, and the mount.fuse(8) manpage).
# These files should be taken from libfuse 3. The format/content is guaranteed
# to remain backwards compatible with libfuse 2.
#
# The way we handle this is to let libfuse3 install as usual,
# but libfuse has to be carefull to not overwrite any common files.
# Also some files are named diferently (udev-rules),
# but only the newer is needed.
# To ensure this, we install in a temporary directory and
# hand-pick the few unique files

LIBFUSE_INSTALL_TARGET_OPTS = install DESTDIR=$(@D)/tmpinstall

define LIBFUSE_INSTALL_TARGET_POST
	cp -dpf $(@D)/tmpinstall/usr/lib/libfuse.so* $(TARGET_DIR)/usr/lib/
endef

LIBFUSE_POST_INSTALL_TARGET_HOOKS += LIBFUSE_INSTALL_TARGET_POST

ifeq ($(BR2_PACKAGE_LIBFUSE3),)

define LIBFUSE_INSTALL_TARGET_POST_COMMON
	$(INSTALL) -D -m 0755 $(@D)/tmpinstall/usr/bin/fusermount $(TARGET_DIR)/usr/bin/fusermount
	mkdir -p $(TARGET_DIR)/lib/udev/rules.d
	cp $(@D)/tmpinstall/lib/udev/rules.d/*-fuse.rules $(TARGET_DIR)/lib/udev/rules.d
endef

LIBFUSE_POST_INSTALL_TARGET_HOOKS += LIBFUSE_INSTALL_TARGET_POST_COMMON

define LIBFUSE_DEVICES
	/dev/fuse  c  666  0  0  10  229  0  0  -
endef

define LIBFUSE_PERMISSIONS
	/usr/bin/fusermount f 4755 0 0 - - - - -
endef
endif

$(eval $(autotools-package))
