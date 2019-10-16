# Set this to either 3.8 or higher, depending on the highest minimum
# version required by any of the packages bundled in Buildroot. If a
# package is bumped or a new one added, and it requires a higher
# version, our cmake infra will catch it and build its own.
#
BR2_FAKEROOT_VERSION_MIN = 1.24

BR2_FAKEROOT_CANDIDATES ?= fakeroot
BR2_FAKEROOT ?= $(call suitable-host-package,fakeroot,\
	$(BR2_FAKEROOT_VERSION_MIN) $(BR2_FAKEROOT_CANDIDATES))
ifeq ($(BR2_FAKEROOT),)
BR2_FAKEROOT = $(HOST_DIR)/bin/fakeroot
BR2_FAKEROOT_HOST_DEPENDENCY = host-fakeroot
endif
