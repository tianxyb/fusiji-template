#!/bin/bash

TEMPLATE_FILE=/usr/bin/fusiji/traffic.html.template
TMP_FILE=/tmp/traffic.html
OUT_FILE=/usr/share/nginx/html/traffic.html

cp -f $TEMPLATE_FILE $TMP_FILE

STATUS=stopped
running=$(ps -ef | grep "/usr/bin/fusiji/fusiji run -config /etc/fusiji/config.json" | grep -v grep | wc -l)
[ "$running" != 0 ] && {
STATUS=running
/usr/bin/fusiji/fusiji api stats --server=localhost:10085 | awk -F'[ >]*' '$3=="user" && $6=="downlink" { uout[$4]=$2 } $3=="user" && $6=="uplink" { uin[$4]=$2 } $3=="inbound" && $6=="downlink" && $4 != "api" { pout[$4]=$2 } $3=="inbound" && $6="uplink" && $4 != "api" { pin[$4]=$2 } END { for(p in pin) { printf "protocal:<tr><td>%s</td><td>%s</td><td>%s</td><tr>\n", p, pin[p], pout[p]} for (u in uin) printf "user:<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n", u, uin[u], uout[u]; }' | while read line; do
	if [ "${line%:*}" == user ]; then
		sed -i -e 's|<!--USER-BODY-TEMPLATE-->|&\n'"${line#user:}"'|' $TMP_FILE	
	elif [ "${line%:*}" == protocal ]; then
		sed -i -e 's|<!--PROTOCAL-BODY-TEMPLATE-->|&\n'"${line#protocal:}"'|' $TMP_FILE	
	fi
done
}

TIME=$(date)
sed -i -e "s/{{STATUS}}/$STATUS/g" -e "s/{{TIME}}/$TIME/g" $TMP_FILE

mv $TMP_FILE $OUT_FILE
