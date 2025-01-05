#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_RULES="surge"
	HP_PATCH="homeproxy/root/etc/homeproxy"
 
	rm -rf ./$HP_PATCH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULES/
	cd ./$HP_RULES/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATCH/resources/

	cd .. && rm -rf ./$HP_RULES/

	cd $PKG_PATH && echo "homeproxy date has been updated!"
fi

#修复argon主题进度条颜色不同步
if [ -d *"luci-theme-argon"* ]; then
	sed -i 's/(--bar-bg)/(--primary)/g' $(find ./luci-theme-argon -type f -iname "cascade.*")

	cd $PKG_PATH && echo "theme-argon has been fixed!"
fi

#移除Shadowsocks组件
PW_FILE=$(find ./ -maxdepth 3 -type f -wholename "*/luci-app-passwall/Makefile")
if [ -f "$PW_FILE" ]; then
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/x86_64/d' $PW_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/default n/d' $PW_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $PW_FILE

	cd $PKG_PATH && echo "passwall has been fixed!"
fi

SP_FILE=$(find ./ -maxdepth 3 -type f -wholename "*/luci-app-ssr-plus/Makefile")
if [ -f "$SP_FILE" ]; then
	sed -i '/default PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/libev/d' $SP_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/x86_64/d' $SP_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $SP_FILE

	cd $PKG_PATH && echo "ssr-plus has been fixed!"
fi

#修复TailScale配置文件冲突
TS_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/tailscale/Makefile")
if [ -f "$TS_FILE" ]; then
	sed -i '/\/files/d' $TS_FILE
	cd $PKG_PATH && echo "tailscale has been fixed!"
fi

#修复Socat配置文件冲突
SOCAT_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/socat/Makefile")
if [ -f "$SOCAT_FILE" ]; then
	sed -i '/\/files/d' $SOCAT_FILE
	cd $PKG_PATH && echo "socat has been fixed!"
fi

# 修复 OpenVPN 和 Easy-RSA 配置文件冲突
OPENVPN_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/openvpn/Makefile")
if [ -f "$OPENVPN_FILE" ]; then
    sed -i '/INSTALL_CONF/{N;d;}' $OPENVPN_FILE
    cd $PKG_PATH && echo "OpenVPN conflict has been fixed!"
fi

EASY_RSA_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/openvpn-easy-rsa/Makefile")
if [ -f "$EASY_RSA_FILE" ]; then
    sed -i '/vars.example/d' $EASY_RSA_FILE
    cd $PKG_PATH && echo "Easy-RSA conflict has been fixed!"
fi
