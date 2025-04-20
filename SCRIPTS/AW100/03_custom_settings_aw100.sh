#!/bin/bash

# Set optimization for ARM Cortex-A53 or similar
sed -i 's/O2/O2 -mcpu=cortex-a53/g' include/target.mk

# Fix libsodium for non-MIPS targets
sed -i 's,no-mips16 no-lto,no-mips16,g' feeds/packages/libs/libsodium/Makefile

# Custom rc.local modifications
cat > ./package/base-files/files/etc/rc.local <<'EOF'
#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

if ! grep "Default string" /tmp/sysinfo/model > /dev/null; then
    echo should be fine
else
    echo "Arcadyan AW1000" > /tmp/sysinfo/model
fi

# IPQ807x doesn’t use intel_pstate, skip CPU governor settings

exit 0
EOF

chmod +x ./package/base-files/files/etc/rc.local

# Fetch vermagic hash for IPQ807x
curl -s https://downloads.openwrt.org/releases/24.10.1/targets/qualcommax/ipq807x/openwrt-24.10.1-qualcommax-ipq807x.manifest \
| grep "^kernel -" \
| awk '{print $3}' \
| sed -n 's/.*~\([a-f0-9]\+\)-r[0-9]\+/\1/p' > vermagic

# Patch .vermagic copying
sed -i 's#grep '\''=\[ym\]'\'' \$(LINUX_DIR)/\.config\.set | LC_ALL=C sort | \$(MKHASH) md5 > \$(LINUX_DIR)/\.vermagic#cp \$(TOPDIR)/vermagic \$(LINUX_DIR)/.vermagic#g' include/kernel-defaults.mk

# Clean up leftover patch rejections
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

# Clone default settings
git clone --depth=1 -b openwrt-24.10 https://github.com/iFHaxx/default-settings package/default-settings

# distfeeds.conf for IPQ807x (ARM Cortex-A53)
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/telephony
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/targets/qualcommax/ipq807x/kmods/6.6.86-1-$(cat vermagic)
EOF

# ZeroWrt custom UI/tools (optional)
mkdir -p files/bin
curl -L -o files/bin/ZeroWrt https://git.kejizero.online/zhao/files/raw/branch/main/bin/ZeroWrt
chmod +x files/bin/ZeroWrt

mkdir -p files/root
curl -L -o files/root/version.txt https://git.kejizero.online/zhao/files/raw/branch/main/bin/version.txt
chmod +x files/root/version.txt

exit 0
