#!/bin/bash

# 更新和安装依赖
sudo -E apt-get -y install rename $(curl -fsSL is.gd/cXklVO)

# 选择源码
echo "请选择源码："
echo "1) OpenWrt 官方源码"
echo "2) ImmortalWrt"
echo "3) LEDE"
echo "4) Lionel"
read -p "输入选项（1-4）: " src_choice

# 选择分支
case $src_choice in
    1)
        echo "请选择分支："
        echo "1) main"
        echo "2) master"
        echo "3) openwrt-23.05"
        echo "4) openwrt-22.03"
        read -p "输入分支选项（1-4）: " branch_choice
        case $branch_choice in
            1) branch_name="main";;
            2) branch_name="master";;
            3) branch_name="openwrt-23.05";;
            4) branch_name="openwrt-22.03";;
            *) echo "无效选择"; exit 1;;
        esac
        repo_url="https://git.openwrt.org/openwrt/openwrt.git";;
    2)
        echo "请选择分支："
        echo "1) master"
        echo "2) openwrt-23.05"
        read -p "输入分支选项（1-2）: " branch_choice
        case $branch_choice in
            1) branch_name="master";;
            2) branch_name="openwrt-23.05";;
            *) echo "无效选择"; exit 1;;
        esac
        repo_url="https://github.com/ImmortalWrt/ImmortalWrt.git";;
    3)
        echo "请选择分支："
        echo "1) master"
        read -p "输入分支选项（1）: " branch_choice
        branch_name="master"
        repo_url="https://github.com/coolsnowwolf/lede.git";;
    4)
        echo "请选择分支："
        echo "1) employ"
        echo "2) main"
        echo "3) 23.05"
        echo "4) 22.03"
        read -p "输入分支选项（1-4）: " branch_choice
        case $branch_choice in
            1) branch_name="employ";;
            2) branch_name="main";;
            3) branch_name="23.05";;
            4) branch_name="22.03";;
            *) echo "无效选择"; exit 1;;
        esac
        repo_url="https://github.com/Lionel/LEDE.git";;
    *) echo "无效选择"; exit 1;;
esac

# 克隆源码
git clone -b $branch_name $repo_url openwrt_src
cd openwrt_src || exit

# 选择插件源
echo "请选择插件源："
echo "1) OpenWrt 官方插件源"
echo "2) LEDE 插件源"
read -p "输入选项（1-2）: " feed_choice

if [ "$feed_choice" -eq 1 ]; then
    echo "添加 OpenWrt 官方插件源..."
    echo "src-git packages https://git.openwrt.org/feed/packages.git" >> feeds.conf.default
elif [ "$feed_choice" -eq 2 ]; then
    echo "添加 LEDE 插件源..."
    echo "src-git packages https://git.lede-project.org/feed/packages.git" >> feeds.conf.default
else
    echo "无效选择"; exit 1
fi

# 更新和安装插件源
./scripts/feeds update -a
./scripts/feeds install -a

# 如果选择了 LEDE 源码，执行清理和克隆操作
if [ "$src_choice" -eq 3 ]; then
    echo "执行额外清理和克隆操作..."
    rm -rf feeds/packages/net/mosdns
    rm -rf feeds/packages/net/msd_lite
    rm -rf feeds/luci/themes/luci-theme-argon
    rm -rf feeds/luci/themes/luci-theme-netgear
    rm -rf feeds/luci/applications/luci-app-mosdns
    rm -rf feeds/luci/applications/luci-app-mosdns
    rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
    rm -rf feeds/packages/utils/v2dat
    rm -rf feeds/luci/applications/luci-app-netdata # golang 1.22 依赖
    git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

    rm -rf feeds/luci/applications/luci-app-serverchan
    rm -rf feeds/packages/lang/golang
    find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
    find ./ | grep Makefile | grep mosdns | xargs rm -f
fi

# 配置菜单
make menuconfig

# 提示用户手动完成配置
read -p "配置完成后按任意键继续... "

# 下载编译依赖
make download -j8

# 编译选项
echo "请选择编译方式："
echo "1) 单线程编译"
echo "2) 全速编译"
read -p "输入选项（1-2）: " build_choice

if [ "$build_choice" -eq 1 ]; then
    make V=s -j1
else
    make V=s -j$(nproc)
fi
