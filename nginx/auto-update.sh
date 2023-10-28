#!/bin/bash

NGINX_CONF_PATH=/etc/nginx/conf.d
NGINX_FILE=fusiji.tk.conf

RMOTE_NGINX_CONF_URL=https://raw.githubusercontent.com/tianxyb/fusiji-template/master/nginx/fusiji.tk.conf

upgrade_file(){
        local filepath=$1
        local filename=$2
        local remote_url=$3
        mkdir -p $filepath

        [ -f $filepath/$filename ] && {
                echo ">>> backup $filename first ..."
                cp $filepath/$filename $filepath/$filename.bk
        }   

        echo ">>> download $filename ..." 
        local http_code=$(curl -L -w "%{http_code}" -H "Authorization: token $token" -o /tmp/tmpfile "$remote_url") 
	rtn=$?
        if [ "$rtn" == 0 -a "$http_code" == 200 ]; then
                if [ -f  $filepath/$filename.bk ]; then
                	local diffresult=$(diff /tmp/tmpfile $filepath/$filename.bk)
                	[ -z "$diffresult" ] && 
				echo "upgrade success, but the file is already up to date." 
			|| { 
                		mv /tmp/tmpfile $filepath/$filename; 
				echo "upgrade success, diff:"; 
				echo "$diffresult"; 
			}
		else
                	mv /tmp/tmpfile $filepath/$filename; 
		       	echo "upgrade success!"
		fi
                return 0
	else  
		echo "***Error: download file error[$http_code]: $(cat /tmp/tmpfile) "; 
		rm -f /tmp/tmpfile; 
		return 1; 
	fi
}

upgrade_proxy_conf(){
        upgrade_file "$NGINX_CONF_PATH" "$NGINX_FILE" "$RMOTE_NGINX_CONF_URL"
}

upgrade_proxy_conf
