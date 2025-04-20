#!/bin/bash
clear

### Basic Section ###
# Use O2 level optimization
sed -i 's/Os/O2/g' include/target.mk

# Update Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Remove SNAPSHOT tags
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

# nginx - latest version
rm -rf feeds/packages/net/nginx
cp -rf ../nginx ./feeds/packages/net/nginx
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 300;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - config
curl -s https://raw.githubusercontent.com/oppen321/OpenWrt/refs/heads/main/ngnix/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://raw.githubusercontent.com/oppen321/OpenWrt/refs/heads/main/ngnix/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# Switch to bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://git.kejizero.online/zhao/files/raw/branch/main/root/.bash_profile
curl -so files/root/.bashrc https://git.kejizero.online/zhao/files/raw/branch/main/root/.bashrc

# Switch to ImmortalWrt Uboot and Target
rm -rf target/linux/qualcommax
cp -rf ../immortalwrt/target/linux/qualcommax target/linux/qualcommax
rm -rf package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
cp -rf ../immortalwrt/package/boot/uboot-rockchip package/boot/uboot-rockchip
cp -rf ../immortalwrt/package/boot/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
sed -i '/REQUIRE_IMAGE_METADATA/d' target/linux/qualcommax/armv8/base-files/lib/upgrade/platform.sh

# Disable Mitigations
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/qualcommax/image/default.bootscript
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/qualcommax/image/grub-efi.cfg
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/qualcommax/image/grub-iso.cfg
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/qualcommax/image/grub-pc.cfg

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# Change Name
sed -i 's/OpenWrt/DotyWRT/' package/base-files/files/bin/config_generate

# Banner
cp -rf ../openwrt-package/banner  ./package/base-files/files/etc/banner

### FW4 ###
rm -rf ./package/network/config/firewall4
cp -rf ../openwrt_main/package/network/config/firewall4 ./package/network/config/firewall4
