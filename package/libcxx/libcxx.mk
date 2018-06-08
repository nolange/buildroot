################################################################################
#
# libc++
#
################################################################################


LIBCXX_VERSION = 10.0.0
LIBCXX_SITE = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(LIBCXX_VERSION)
LIBCXX_SOURCE = llvm-$(LIBCXX_VERSION).src.tar.xz
LIBCXX_LICENSE = MIT
#LIBCXX_LICENSE_FILES = COPYRIGHT
LIBCXX_SUPPORTS_IN_SOURCE_BUILD = NO
LIBCXX_INSTALL_STAGING = YES

LIBCXX_EXTRA_DOWNLOADS = $(patsubst %,$(LIBCXX_SITE)/%-$(LIBCXX_VERSION).src.tar.xz,libcxx libcxxabi)

define LIBCXX_EXTRA_EXTRACT
	$(foreach arch,$(LIBCXX_EXTRA_DOWNLOADS), \
		TDIR=projects/$(patsubst $(LIBCXX_SITE)/%-$(LIBCXX_VERSION).src.tar.xz,%,$(arch)); \
		mkdir -p $(@D)/$$TDIR && \
		$(call suitable-extractor,$(notdir $(arch))) $(LIBCXX_DL_DIR)/$(notdir $(arch)) | \
		$(TAR) --strip-components=1 -C $(@D)/$$TDIR $(TAR_OPTIONS) -
	)
endef

LIBCXX_POST_EXTRACT_HOOKS += LIBCXX_EXTRA_EXTRACT

# Before libcxx is configured, we must have the first stage
# cross-compiler and the clibrary
LIBCXX_DEPENDENCIES = $(if $(BR2_TOOLCHAIN_BUILDROOT),host-gcc-initial)

ifeq ($(BR2_PACKAGE_LIBCXX_ABI_CXXABI),y)
_LIBCXX_ABI_TARGET = cxxabi
endif

_LIBCXX_ABI-$(BR2_PACKAGE_LIBCXX_ABI_CXXABI) = libcxxabi
_LIBCXX_ABI-$(BR2_PACKAGE_LIBCXX_ABI_SUPCXX) = libsupc++

_LIBCXX_ABI_LINK-$(BR2_PACKAGE_LIBCXX_ABI_CXXABI) = c++abi
_LIBCXX_ABI_LINK-$(BR2_PACKAGE_LIBCXX_ABI_SUPCXX) = supc++

LIBCXX_MAKE_OPTS = $(_LIBCXX_ABI_TARGET) cxx

LIBCXX_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) $(addprefix install-,$(_LIBCXX_ABI_TARGET) cxx)

LIBCXX_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) $(addprefix install-,$(_LIBCXX_ABI_TARGET) cxx)


#LIBCXXABI_SYSROOT LIBCXX_SYSROOT
# TODO: potentially depend on threading library?
# allow using gccs libsupc++
# consider whether its better to statically link libc++-abi
# USe this library to build the remaining C++ packages?

# llvm does not recommend using this
LIBCXX_CONF_OPTS += -DBUILD_SHARED_LIBS:BOOL=OFF

LIBCXX_CONF_OPTS += -DLIBCXXABI_INCLUDE_TESTS=OFF -DLIBCXXABI_ENABLE_ASSERTIONS=OFF -DLIBCXXABI_ENABLE_NEW_DELETE_DEFINITIONS=OFF -DLIBCXX_ENABLE_NEW_DELETE_DEFINITIONS=ON

ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
LIBCXX_CONF_OPTS += -DLIBCXX_HAS_MUSL_LIBC:BOOL=ON
endif

ifeq ($(BR2_SHARED_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LIBCXX_CONF_OPTS += -DLIBCXXABI_ENABLE_SHARED:BOOL=ON -DLIBCXX_ENABLE_SHARED:BOOL=ON
else
LIBCXX_CONF_OPTS += -DLIBCXXABI_ENABLE_SHARED:BOOL=OFF -DLIBCXX_ENABLE_SHARED:BOOL=OFF
endif

ifeq ($(BR2_STATIC_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LIBCXX_CONF_OPTS += -DLIBCXXABI_ENABLE_STATIC:BOOL=ON -DLIBCXX_ENABLE_STATIC:BOOL=ON
else
LIBCXX_CONF_OPTS += -DLIBCXXABI_ENABLE_STATIC:BOOL=OFF -DLIBCXX_ENABLE_STATIC:BOOL=OFF
endif

ifeq ($(BR2_SHARED_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LIBCXX_CONF_OPTS += -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=ON
endif

#LIBCXX_CONF_OPTS += -DLLVM_PATH:PATH=$(@D)/llvm

#LIBCXX_CONF_OPTS += -DLIBCXX_CXX_ABI:STRING=default

# libc++ needs to be massaged to pick header and libs
LIBCXX_CONF_OPTS += -DLIBCXX_CXX_ABI:STRING=$(_LIBCXX_ABI-y)

ifneq ($(_LIBCXX_ABI_TARGET),)
LIBCXX_CONF_OPTS += -DLIBCXX_CXX_ABI_INCLUDE_PATHS:PATH=$(@D)/projects/libcxxabi/include \
					-DLIBCXX_CXX_ABI_LIBRARY_PATH:PATH=../../../lib
endif


#LIBCXX_CONF_OPTS += -DLIBCXX_INCLUDE_BENCHMARKS:BOOL=OFF
#LIBCXX_CONF_OPTS += -DLIBCXX_INCLUDE_DOCS:BOOL=OFF
#LIBCXX_CONF_OPTS += -DLIBCXX_INCLUDE_TESTS:BOOL=OFF

cxx_libs="-lc++ @link_abi@"
c_libs="-lc @link_comrt@"

# Create a g++ wrapper to add the necessary aguments for building with libc++
define LIBCXX_CREATE_GXXWRAPPER_TARGET
	sed -e 's,@TARGET_CROSS@,$(notdir $(TARGET_CROSS)),g' \
	  -e 's,@link_abi@,$(addprefix -l,$(_LIBCXX_ABI_LINK-y)),g' \
	  -e 's,@link_comrt@,-lgcc_s,g' \
	  $(LIBCXX_PKGDIR)g++-libc++.in > $(LIBCXX_BUILDDIR)gxxwrap.tmp
	install -D -m755 $(LIBCXX_BUILDDIR)gxxwrap.tmp $(TARGET_CROSS)g++-libc++
endef
LIBCXX_POST_INSTALL_TARGET_HOOKS = LIBCXX_CREATE_GXXWRAPPER_TARGET

$(eval $(cmake-package))
