################################################################################
#
# dbusbroker
#
# Launching services is delegated to systemd so there is very little else
# needed. No separate user is necessary and no helper for launching.
#
# Service + Config files were copied over from dbus,
# uneeded / unecessary entries removed for clarity.
#
################################################################################

DBUSBROKER_VERSION = 22
DBUSBROKER_SOURCE = dbus-broker-$(DBUSBROKER_VERSION).tar.xz
DBUSBROKER_SITE = https://github.com/bus1/dbus-broker/releases/download/v$(DBUSBROKER_VERSION)

DBUSBROKER_LICENSE = Apache-2.0
DBUSBROKER_LICENSE_FILES = LICENSE
# Compatibility Launcher requires this
DBUSBROKER_DEPENDENCIES += expat systemd

ifeq ($(BR2_TOOLCHAIN_HEADERS_AT_LEAST_4_17),y)
DBUSBROKER_CONF_OPTS += -Dlinux-4-17=true
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
DBUSBROKER_DEPENDENCIES += libselinux
DBUSBROKER_CONF_OPTS += -Dselinux=true
else
DBUSBROKER_CONF_OPTS += -Dselinux=false
endif

# Only install config and service files if dbus is not available
ifeq ($(BR2_PACKAGE_DBUS),)
define DBUSBROKER_INSTALL_TARGET_POST
	$(INSTALL) -D -m644 $(DBUSBROKER_PKGDIR)/dbus.socket $(TARGET_DIR)/usr/lib/systemd/system/dbus.socket
	ln -sf ../dbus.socket $(TARGET_DIR)/usr/lib/systemd/system/sockets.target.wants/dbus.socket
	$(INSTALL) -D -m644 $(DBUSBROKER_PKGDIR)/session.conf $(TARGET_DIR)/usr/share/dbus-1/session.conf
	$(INSTALL) -D -m644 $(DBUSBROKER_PKGDIR)/system.conf $(TARGET_DIR)/usr/share/dbus-1/system.conf
endef

DBUSBROKER_POST_INSTALL_TARGET_HOOKS += DBUSBROKER_INSTALL_TARGET_POST
endif

$(eval $(meson-package))
