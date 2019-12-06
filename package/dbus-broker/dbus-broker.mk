################################################################################
#
# dbus-broker
#
# Launching services is delegated to systemd so there is very little else
# needed. No separate user is necessary and no helper for launching.
#
# Service + Config files were copied over from dbus,
# uneeded / unecessary entries removed for clarity.
#
################################################################################

DBUS_BROKER_VERSION = 23
DBUS_BROKER_SOURCE = dbus-broker-$(DBUS_BROKER_VERSION).tar.xz
DBUS_BROKER_SITE = https://github.com/bus1/dbus-broker/releases/download/v$(DBUS_BROKER_VERSION)
DBUS_BROKER_LICENSE = \
	Apache-2.0, \
	Apache-2.0 and/or LGPL-2.1+ (c-dvar, c-ini, c-list, c-rbtree, c-shquote, c-stdaux, c-utf8)
DBUS_BROKER_LICENSE_FILES = \
	LICENSE \
	subprojects/c-dvar/AUTHORS subprojects/c-dvar/README.md \
	subprojects/c-ini/AUTHORS subprojects/c-ini/README.md \
	subprojects/c-list/AUTHORS subprojects/c-list/README.md \
	subprojects/c-rbtree/AUTHORS subprojects/c-rbtree/README.md \
	subprojects/c-shquote/AUTHORS subprojects/c-shquote/README.md \
	subprojects/c-stdaux/AUTHORS subprojects/c-stdaux/README.md \
	subprojects/c-utf8/AUTHORS subprojects/c-utf8/README.md

ifeq ($(BR2_PACKAGE_DBUS_BROKER_LAUNCH),y)
DBUS_BROKER_DEPENDENCIES += expat systemd
DBUS_BROKER_CONF_OPTS += -Dlauncher=true
else
DBUS_BROKER_CONF_OPTS += -Dlauncher=false
endif

ifeq ($(BR2_TOOLCHAIN_HEADERS_AT_LEAST_4_17),y)
DBUS_BROKER_CONF_OPTS += -Dlinux-4-17=true
else
DBUS_BROKER_CONF_OPTS += -Dlinux-4-17=false
endif

ifeq ($(BR2_PACKAGE_AUDIT),y)
DBUS_BROKER_DEPENDENCIES += audit
DBUS_BROKER_CONF_OPTS += -Daudit=true
else
DBUS_BROKER_CONF_OPTS += -Daudit=false
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
DBUS_BROKER_DEPENDENCIES += libselinux
DBUS_BROKER_CONF_OPTS += -Dselinux=true
else
DBUS_BROKER_CONF_OPTS += -Dselinux=false
endif

# Only install config and service files if dbus is not available
ifeq ($(BR2_PACKAGE_DBUS)X$(BR2_PACKAGE_DBUS_BROKER_LAUNCH),Xy)
define DBUS_BROKER_INSTALL_CONFIG_FILES
	$(INSTALL) -D -m644 $(DBUS_BROKER_PKGDIR)/dbus.socket \
		$(TARGET_DIR)/usr/lib/systemd/system/dbus.socket
	$(INSTALL) -D -m644 $(DBUS_BROKER_PKGDIR)/session.conf \
		$(TARGET_DIR)/usr/share/dbus-1/session.conf
	$(INSTALL) -D -m644 $(DBUS_BROKER_PKGDIR)/system.conf \
		$(TARGET_DIR)/usr/share/dbus-1/system.conf
	ln -sf ../dbus.socket \
		$(TARGET_DIR)/usr/lib/systemd/system/sockets.target.wants/dbus.socket
endef

DBUS_BROKER_POST_INSTALL_TARGET_HOOKS += DBUS_BROKER_INSTALL_CONFIG_FILES
endif

$(eval $(meson-package))
