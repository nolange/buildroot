# Set this to a valid version like 1.8.2, depending on the highest
# minimum version required by any of the packages bundled in Buildroot.
# An empty version will never match a system executable
#
# BR2_NINJA_VERSION_MIN = 1.8.2

BR2_NINJA_CANDIDATES ?= ninja
BR2_NINJA ?= $(call suitable-host-package,ninja,\
	$(BR2_NINJA_VERSION_MIN) $(BR2_NINJA_CANDIDATES))
ifeq ($(BR2_NINJA),)
BR2_NINJA = $(HOST_DIR)/bin/ninja
BR2_NINJA_HOST_DEPENDENCY = host-ninja
endif
