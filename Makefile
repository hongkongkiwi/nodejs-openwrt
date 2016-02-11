##############################################
# OpenWrt Makefile for nodejs program
#
##############################################
include $(TOPDIR)/rules.mk

# Name and release number of this package
PKG_NAME:=nodejs
PKG_VERSION:=v4.2.6
PKG_RELEASE:=1

PKG_SOURCE:=node-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nodejs.org/dist/$(PKG_VERSION)/
PKG_MD5SUM:=b1287c356e904954da7e0c6435ff9948
PKG_MAINTAINER:=Richard-Qian

PKG_INSTALL:=1


PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=nodejs.
	DEPENDS:=+libpthread +librt +libstdcpp +libuv
	MENU:=1

ifeq ($(CONFIG_NODEJS_WITH_SSL),y)
	DEPENDS += +libopenssl
endif
endef

define Package/$(PKG_NAME)/description
  Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses
  an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js'
   package ecosystem, npm, is the largest ecosystem of open source libraries in the world.
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

define Package/nodejs/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS= \
	--dest-cpu=$(CPU) \
	--dest-os=linux \
	--prefix=/usr

ifeq ($(CONFIG_NODEJS_SHARED_ZLIB),y)
	CONFIGURE_ARGS += --shared-zlib
endif
ifeq ($(CONFIG_NODEJS_SHARED_LIBUV),y)
        CONFIGURE_ARGS += --shared-libuv
endif
ifeq ($(NODEJS_SHARED_HTTP_PARSER),y)
	CONFIGURE_ARGS += --shared-http-parser
endif
ifeq ($(CONFIG_NODEJS_WITH_SSL),y)
	ifeq ($(CONFIG_NODEJS_SHARED_OPENSSL),y)
		CONFIGURE_ARGS += --shared-openssl
	endif
else
	CONFIGURE_ARGS += --without-ssl
endif
ifeq ($(CONFIG_NODEJS_BUILD_WITH_NPM),n)
	CONFIGURE_ARGS += --without-npm
endif
ifeq ($(CONFIG_NODEJS_DEBUG_BUILD_ENABLED),n)
        CONFIGURE_ARGS += --debug
endif
# This one is untested, does it need an additional dependency?
ifeq ($(CONFIG_NODEJS_GDB_SUPPORT_ENABLED),n)
        CONFIGURE_ARGS += --gdb
endif

# Set any additional User defined v8 engine options
ifneq ($(CONFIG_NODEJS_V8_OPTIONS),)
	CONFIGURE_ARGS += --v8-options=$(CONFIG_NODEJS_V8_OPTIONS)
endif

# Configure Additional CPU Type Options
ifneq ($(CONFIG_NODEJS_CPU_TYPE_DEFAULT),y)
  ifeq ($(CONFIG_NODEJS_CPU_TYPE_MIPS),y)
    ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_LOONSON),y)
	CONFIGURE_ARGS += --with-mips-arch-variant=loongson
    else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R1),y)
        CONFIGURE_ARGS += --with-mips-arch-variant=r1
    else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R2),y)
        CONFIGURE_ARGS += --with-mips-arch-variant=r2
    else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R6),y)
        CONFIGURE_ARGS += --with-mips-arch-variant=r6
    else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_RX),y)
        CONFIGURE_ARGS += --with-mips-arch-variant=rx
    endif
    ifeq ($(CONFIG_NODEJS_ABI_MIPS_TYPE_SOFT),y)
        CONFIGURE_ARGS += --with-mips-float-abi=soft
    else ifeq ($(CONFIG_NODEJS_ABI_MIPS_TYPE_HARD),y)
        CONFIGURE_ARGS += --with-mips-float-abi=hard
    endif
    ifeq ($(CONFIG_NODEJS_FPU_MIPS_FP32),y)
        CONFIGURE_ARGS += --with-mips-fpu-mode=fp32
    else ifeq ($(CONFIG_NODEJS_FPU_MIPS_FP64),y)
        CONFIGURE_ARGS += --with-mips-fpu-mode=fp64
    else ifeq ($(CONFIG_NODEJS_FPU_MIPS_FPXX),y)
        CONFIGURE_ARGS += --with-mips-fpu-mode=fpxx
    endif
  else ifeq ($(CONFIG_NODEJS_CPU_TYPE_ARM),y)
    ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFP),y)
        CONFIGURE_ARGS += --with-arm-fpu=vfp
    else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFPV3),y)
        CONFIGURE_ARGS += --with-arm-fpu=vfpv3
    else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFPV3_D16),y)
        CONFIGURE_ARGS += --with-arm-fpu=vfpv3-d16
    else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_NEON),y)
        CONFIGURE_ARGS += --with-arm-fpu=neon
    endif
    ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_SOFT),y)
        CONFIGURE_ARGS += --with-arm-float-abi=soft
    else ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_SOFTFP),y)
        CONFIGURE_ARGS += --with-arm-float-abi=softfp
    else ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_HARD),y)
        CONFIGURE_ARGS += --with-arm-float-abi=hard
    endif
  endif
endif


define Package/$(PKG_NAME)/install
	mkdir -p $(1)/usr/bin

ifeq ($(CONFIG_NODEJS_BUILD_WITH_NPM),y)
	mkdir -p $(1)/usr/lib/node_modules/npm/{bin,lib,node_modules}
endif

	$(CP) -rf  $(PKG_BUILD_DIR)/out/Release/node $(1)/usr/bin/
endef

# build a package.
$(eval $(call BuildPackage,$(PKG_NAME)))

