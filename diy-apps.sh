#!/bin/bash
echo "execute diy-apps_luci_23.05.sh"
##  ======该脚本主要是拉取Apps============
# 移除不需要的包
rm -rf feeds/luci/themes/{luci-theme-argon,luci-theme-netgear}
rm -rf feeds/packages/net/{mosdns,smartdns,v2ray-geodata}
rm -rf feeds/luci/applications/{luci-app-vlmcsd,luci-app-accesscontrol,luci-app-ddns,luci-app-wol,luci-app-kodexplorer}
rm -rf feeds/luci/applications/{luci-app-smartdns,luci-app-v2raya,luci-app-mosdns,luci-app-serverchan,luci-app-passwall2}

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

function remove_package() {
   packages="$@"
   for package in $packages; do 
      pkg_path=$(find . -name "$package")
      if [[ ! "$pkg_path" == "" ]]; then
         rm -rvf $pkg_path
      fi
   done
}

# 添加额外插件
git_sparse_clone small-package  https://github.com/caiwx86/openwrt-packages \
  luci-app-npc luci-app-syncthing
#  luci-app-homeassistant luci-lib-taskd taskd luci-lib-xterm
#   luci-app-homebridge

# 添加额外插件
remove_package daed luci-app-daed
git_sparse_clone master https://github.com/QiuSimons/luci-app-daed \
   daed luci-app-daed
# 解决luci-app-daed 依赖问题
mkdir -p package/libcron && wget -O package/libcron/Makefile https://raw.githubusercontent.com/immortalwrt/packages/refs/heads/master/libs/libcron/Makefile

# 科学上网插件
# passwall2 xray v2raya mosdns luci-app-ssr-plus luci-app-amlogic luci-app-smartdns luci-theme-argon
# git_sparse_clone main https://github.com/caiwx86/openwrt-packages small
git clone --depth=1  https://github.com/kenzok8/openwrt-packages package/kenzok8
git clone --depth=1  https://github.com/kenzok8/small package/small
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns,geoview}
rm -rf feeds/packages/utils/v2dat

# 在线用户
git_sparse_clone main https://github.com/danchexiaoyang/luci-app-onliner luci-app-onliner 

if [[ $AMLOGIC == "true" ]]; then
# 晶晨宝盒
# git_sparse_clone main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
sed -i "s|firmware_repo.*|firmware_repo 'https://github.com/caiwx86/OpenWrt'|g" package/kenzok8/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|kernel_path.*|kernel_path 'https://github.com/ophub/kernel'|g" package/kenzok8/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|shared_fstype.*|shared_fstype 'btrfs'|g" package/kenzok8/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8_PLUS|g" package/luci-app-amlogic/root/etc/config/amlogic
echo CONFIG_PACKAGE_luci-app-amlogic=y >>  $OPENWRT_PATH/.config
fi

# adguardhome
bash $GITHUB_WORKSPACE/scripts/preset-adguardhome.sh