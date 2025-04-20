#!/bin/bash

# This script clones OpenWrt related code from different repositories and performs some processing.

# Define a function to clone the specified repository and branch
clone_repo() {
  # Argument 1 is the repository URL, Argument 2 is the branch name, Argument 3 is the target directory
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # Clone the repository to the target directory, specify the branch name and depth 1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# Define variables to store repository URLs and branch names
openwrt_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
immortalwrt_release="$(curl -s https://github.com/immortalwrt/immortalwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
openwrt_repo="https://github.com/openwrt/openwrt.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
lean_repo="https://github.com/coolsnowwolf/lede" 
openwrt_add_repo="https://github.com/oppen321/openwrt-package"
dockerman_repo="https://github.com/oppen321/luci-app-dockerman"
golang_repo="https://github.com/sbwml/packages_lang_golang"
node_repo="https://github.com/sbwml/feeds_packages_lang_node-prebuilt"
nginx_repo="https://github.com/oppen321/feeds_packages_net_nginx"
default_settings="https://github.com/iFHaxx/default-settings"
miniupnpd_repo="https://git.kejizero.online/zhao/miniupnpd"
upnp_repo="https://git.kejizero.online/zhao/luci-app-upnp"
docker_repo="https://git.kejizero.online/zhao/packages_utils_docker"
dockerd_repo="https://git.kejizero.online/zhao/packages_utils_dockerd"
containerd_repo="https://git.kejizero.online/zhao/packages_utils_containerd"
runc_repo="https://git.kejizero.online/zhao/packages_utils_runc"
fstools_repo="https://github.com/sbwml/package_system_fstools"
util_linux_repo="https://github.com/sbwml/package_utils_util-linux"
nghttp3_repo="https://github.com/sbwml/package_libs_nghttp3"
ngtcp2_repo="https://github.com/sbwml/package_libs_ngtcp2"
curl_repo="https://github.com/sbwml/feeds_packages_net_curl"
urngd_repo="https://github.com/sbwml/package_system_urngd"
samba4_repo="https://github.com/sbwml/feeds_packages_net_samba4"
liburing_repo="https://github.com/sbwml/feeds_packages_libs_liburing"
ATC0M="https://github.com/iFHaxx/luci-app-atcommands"
INFO3G="https://github.com/iFHaxx/luci-app-3ginfo-lite"
MBAN="https://github.com/iFHaxx/luci-app-modemband"
SMSJS="https://github.com/iFHaxx/luci-app-sms-tool-js"
CTTL="https://github.com/iFHaxx/luci-app-ttl"

# Start cloning repositories and execute in parallel
clone_repo $openwrt_repo $openwrt_release openwrt &
clone_repo $immortalwrt_repo $immortalwrt_release immortalwrt &
clone_repo $openwrt_repo main openwrt_main
clone_repo $openwrt_repo openwrt-24.10 openwrt_24
clone_repo $lean_repo master lede 
clone_repo $openwrt_add_repo v24.10 openwrt-package
clone_repo $openwrt_add_repo helloworld helloworld
clone_repo $dockerman_repo main luci-app-dockerman
clone_repo $golang_repo 24.x golang
clone_repo $nginx_repo openwrt-24.10 nginx
clone_repo $node_repo packages-24.10 node
clone_repo $default_settings openwrt-24.10 default_settings
clone_repo $miniupnpd_repo v2.3.7 miniupnpd
clone_repo $upnp_repo master luci-app-upnp
clone_repo $docker_repo main docker
clone_repo $dockerd_repo main dockerd
clone_repo $containerd_repo main containerd
clone_repo $runc_repo main runc
clone_repo $fstools_repo openwrt-24.10 fstools
clone_repo $util_linux_repo openwrt-24.10 util-linux
clone_repo $nghttp3_repo main nghttp3
clone_repo $ngtcp2_repo main ngtcp2
clone_repo $curl_repo main curl
clone_repo $urngd_repo main urngd
clone_repo $samba4_repo main samba4
clone_repo $liburing_repo main liburing
clone_repo $MTCOM main luci-app-atcommands
clone_repo $INFO3G main luci-app-3ginfo-lite
clone_repo $MBAN main luci-app-modemband
clone_repo $SMSJS main luci-app-sms-tool-js
clone_repo $CTTL main luci-app-ttl

# Wait for all background tasks to complete
wait

# Perform some processing
find openwrt/package/* -maxdepth 0 ! -name 'firmware' ! -name 'kernel' ! -name 'base-files' ! -name 'Makefile' -exec rm -rf {} +
rm -rf ./openwrt_24/package/firmware ./openwrt_snap/package/kernel ./openwrt_snap/package/base-files ./openwrt_snap/package/Makefile
cp -rf ./openwrt_24/package/* ./openwrt/package/
cp -rf ./openwrt_24/feeds.conf.default ./openwrt/feeds.conf.default

# Exit the script
exit 0
