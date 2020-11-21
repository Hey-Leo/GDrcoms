include $(TOPDIR)/rules.mk

PKG_NAME:=gdut-drcom
PKG_VERSION:=3.1.3
PKG_RELEASE:=168

PKG_LICENSE:=GPL-3.0+

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/chenhaowen01/gdut-drcom.git
PKG_SOURCE_VERSION:=171c434e94749a55cb4803d386ba3aa151b162bf

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR)-$(PKG_RELEASE).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

#PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
MAKE_PATH:=src

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A third party drcom client openwrt.
endef

define Package/$(PKG_NAME)/description
	gdut-drcom for openwrt is a third party drcom client openwrt.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/src/gdut-drcom $(1)/usr/bin	
	$(INSTALL_DIR) $(1)/
	$(CP) ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/gdut-drcom.po $(1)/usr/lib/lua/luci/i18n/gdut-drcom.zh-cn.lmo
endef

# define Package/$(PKG_NAME)/postinst
# #!/bin/sh
# echo "post install: patching ppp.sh"
# sed -i '/#added by gdut-drcom/d' /lib/netifd/proto/ppp.sh
# sed -i '/proto_run_command/i username=$$(echo -e "\\r\\n$$username")    #added by gdut-drcom!' /lib/netifd/proto/ppp.sh
# echo "patched!"
# endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
echo "pre remove: unpatching ppp.sh!"
sed -i '/#added by gdut-drcom/d' /lib/netifd/proto/ppp.sh
echo "unpatched!"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
