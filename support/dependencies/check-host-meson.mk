# Set this to a valid version like  0.49, depending on the highest minimum
# version required by any of the packages bundled in Buildroot.
# An empty version will never match a system executable
#
# BR2_MESON_VERSION_MIN = 0.49

BR2_MESON_CANDIDATES ?= meson
BR2_MESON ?= $(call suitable-host-package,meson,\
	$(BR2_MESON_VERSION_MIN) $(BR2_MESON_CANDIDATES))
ifeq ($(BR2_MESON),)
BR2_MESON = $(HOST_DIR)/bin/meson
BR2_MESON_HOST_DEPENDENCY = host-meson $(BR2_NINJA_HOST_DEPENDENCY)
else
BR2_MESON_HOST_DEPENDENCY = $(BR2_NINJA_HOST_DEPENDENCY)
endif
