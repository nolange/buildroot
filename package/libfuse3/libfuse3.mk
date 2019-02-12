################################################################################
#
# libfuse
#
################################################################################

LIBFUSE3_VERSION = 3.9.0
LIBFUSE3_SOURCE = fuse-$(LIBFUSE3_VERSION).tar.xz
LIBFUSE3_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE3_VERSION)
LIBFUSE3_LICENSE = LGPL-2.1 (library), GPL-2.0 (rest)
LIBFUSE3_LICENSE_FILES = GPL2.txt LGPL2.txt LICENSE
LIBFUSE3_INSTALL_STAGING = YES
LIBFUSE3_DEPENDENCIES = $(if $(BR2_PACKAGE_LIBICONV),libiconv)
LIBFUSE3_CONF_OPTS = \
	-Dexamples=false \
	-Dutils=true \
	-Dudevrulesdir=/lib/udev/rules.d

define LIBFUSE3_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/fusermount3 $(TARGET_DIR)/usr/bin/
	$(if $(filter y,$(BR2_STATIC_LIBS)),,cp -dpf $(STAGING_DIR)/usr/lib/libfuse3.so* $(TARGET_DIR)/usr/lib/)
	mkdir -p $(TARGET_DIR)/lib/udev/rules.d
	$(INSTALL) -m 0644 $(STAGING_DIR)/lib/udev/rules.d/*-fuse3.rules $(TARGET_DIR)/lib/udev/rules.d
endef

define LIBFUSE3_INSTALL_TARGET_POST
	ln -sf fusermount3 $(TARGET_DIR)/usr/bin/fusermount
endef

LIBFUSE3_POST_INSTALL_TARGET_HOOKS += LIBFUSE3_INSTALL_TARGET_POST

define LIBFUSE3_DEVICES
	/dev/fuse  c  666  0  0  10  229  0  0  -
endef

define LIBFUSE3_PERMISSIONS
	/usr/bin/fusermount3 f 4755 0 0 - - - - -
endef

$(eval $(meson-package))
