#!/bin/bash

#LOG_FILE=/var/log/fusiji_update.log
LOG_FILE=/dev/stdout
INSTALL_PATH=${GEO_DATA_PATH:-/var/run/geodata}

info(){
	echo "$(date +'%Y-%m-%d %H:%M:%S') Info $*" >> $LOG_FILE
}

error(){
	echo "$(date +'%Y-%m-%d %H:%M:%S') Error $*" >> $LOG_FILE
}


info ">>> begin update geoip..."
#curl -sL -o /tmp/geoip.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" && {
#	sha_remote=$(curl -sL "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat.sha256sum" | awk '{ print $1 }')
#curl -sL -o /tmp/geoip.dat "https://sjcp.fusiji.site/geoip/geoip.dat" && {
#	sha_remote=$(curl -sL "https://sjcp.fusiji.site/geoip/geoip.dat.sha256sum" | awk '{ print $1 }')
curl -sL -o /tmp/geoip.dat "https://openwrt.fusiji.site/geoip/geoip.dat" && {
	sha_remote=$(curl -sL "https://openwrt.fusiji.site/geoip/geoip.dat.sha256sum" | awk '{ print $1 }')
	sha_local=$(sha256sum /tmp/geoip.dat | awk '{ print $1 }')
	[ "${sha_remote}" == "${sha_local}" -a "${sha_local}" ] && {
		sha_orig=$(sha256sum "${INSTALL_PATH}"/geoip.dat | awk '{ print $1 }')
		[ "$sha_orig" != "$sha_local" ] && {
			cp /tmp/geoip.dat "${INSTALL_PATH}"/geoip.dat
			info "update geoip success!"
		} || {
			info "geoip.dat is already up to date!"
		}
		true
	} || {
		error "*** sha2456sum check error!"
	}
} || {
	error "*** download geoip error: $(cat /tmp/geoip.dat)"
}

info ">>> begin update geosite..."
curl -sL -o /tmp/geosite.dat "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" && {
	sha_remote=$(curl -sL "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat.sha256sum" | awk '{ print $1 }')
	sha_local=$(sha256sum /tmp/geosite.dat | awk '{ print $1 }')
	[ "${sha_remote}" == "${sha_local}" -a "${sha_local}" ] && {
		sha_orig=$(sha256sum "${INSTALL_PATH}"/geosite.dat | awk '{ print $1 }')
		[ "$sha_orig" != "$sha_local" ] && {
			cp /tmp/geosite.dat "${INSTALL_PATH}"/geosite.dat
			info "update geosite success!"
		} || {
			info "geosite.dat is already up to date!"
		}
		true
	} || {
		error "*** geosite.dat sha2456sum check error!"
	}
} || {
	error "*** download geosite.dat error: $(cat /tmp/geosite.dat)"
}

#/etc/init.d/fusiji restart
brew services restart fusijid
rm /tmp/geosite.dat
rm /tmp/geoip.dat
