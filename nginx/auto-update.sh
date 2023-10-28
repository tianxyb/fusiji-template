#!/bin/bash

NGINX_CONF_PATH=/etc/nginx/conf.d
NGINX_FILE=fusiji.tk.conf

RMOTE_NGINX_CONF_URL=https://raw.githubusercontent.com/tianxyb/fusiji-template/master/nginx/fusiji.tk.conf

log()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') $@"
}

info()
{
	log "[INFO] $@"
}

error()
{
	log "[ERROR] $@"
}

upgrade_file(){
        local filepath=$1
        local filename=$2
        local remote_url=$3

	local reload_cmd=$4
        mkdir -p $filepath

        [ -f $filepath/$filename ] && {
                info ">>> backup $filename first ..."
                cp $filepath/$filename $filepath/$filename.bk
        }   

        info ">>> download $filename ..." 
        local http_code=$(curl -L -w "%{http_code}" -o /tmp/tmpfile "$remote_url") 
	rtn=$?
        if [ "$rtn" == 0 -a "$http_code" == 200 ]; then
                if [ -f  $filepath/$filename.bk ]; then
                	local diffresult=$(diff /tmp/tmpfile $filepath/$filename.bk)
                	[ -z "$diffresult" ] && {
				info "upgrade success, but the file is already up to date." 
			} || { 
                		mv /tmp/tmpfile $filepath/$filename; 
				info "upgrade success, diff:"; 
				info "$diffresult"; 
				[ "$reload_cmd" ] && bash -c "$reload_cmd"
			}
		else
                	mv /tmp/tmpfile $filepath/$filename; 
		       	info "upgrade success!"
		fi
                return 0
	else  
		error "***Error: download file error[$http_code]: $(cat /tmp/tmpfile) "; 
		rm -f /tmp/tmpfile; 
		return 1; 
	fi
}

upgrade_proxy_conf(){
        upgrade_file "$NGINX_CONF_PATH" "$NGINX_FILE" "$RMOTE_NGINX_CONF_URL" "systemctl restart nginx"
}

upgrade_proxy_conf
