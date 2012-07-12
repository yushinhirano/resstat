#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : service_stop.sh
	        
	        service_stop.sh [ [34;1m-f service_file[m ]
	        service_stop.sh [ [34;1m-h[m ]
	
	EOF

}

########################################
# function HelpMsg
########################################
function HelpMsg(){
    #PAGER変数は手動でセット。このスクリプトはresstat packageとは独立している。
    PAGER="/usr/bin/less -RFX"
    export LC_ALL=ja_JP.utf8
    case "`uname`" in
        CYGWIN*) 
            export PAGER="/usr/bin/less -FX"
            ;;
    esac

    if [[ -s "${VERSION_TXT::=${CURRENT_SCRIPT%/*}/../../VERSION}" ]];then
        RESSTAT_VERSION=$(awk -F ' *= *' '(NF > 0){if ($1 == "VERSION") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_AUTHOR=$(awk -F ' *= *' '(NF > 0){if ($1 == "AUTHOR") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_REPORT_TO=$(awk -F ' *= *' '(NF > 0){if ($1 == "REPORT_TO") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_LASTUPDATE=$(awk -F ' *= *' '(NF > 0){if ($1 == "LAST_UPDATE") { print $2; exit; } }' "${VERSION_TXT}")
    fi

    ${=PAGER} <<-EOF

	
	[32;1;4m#### utility script manual ####[m
	
	
	[36;1mUsage: service_stop.sh [m  -- 特定Linuxサービス以外の停止
	
	       service_stop.sh [ [34;1m-f service_file[m ]
	       service_stop.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m

	       [34;1m-f[m : 停止しないサービスの記述ファイルを指定
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       rootユーザのみ実行可能。
	       サービス記述ファイルに記述されたサービス以外、
	       全てのサービスをstopし、かつchkconfigによって自動起動をOFFにする。
	       （chkconfig未登録、管理対象外のサービスには無効なので注意）

	       サービス記述ファイルは、デフォルトではスクリプト格納ディレクトリのservicesというファイルを使う。
	       （-fオプションで指定することも可能）
	       サービス名は1行に1サービスずつ記述し、空行と先頭[#]は読み飛ばす。


	[31;1m[Caution] : [m
	
	       [35;1m１．危険度[m
	           下手なことをするとRESCUREしない限り起動しないLinuxが出来上がります。
	           残すサービスについてよくご理解の上で実行しましょう。

	
	[36;1m[Related ConfigFiles] : [m
	        
	        ・services


	[36;1m[Author & Copyright] : [m
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.

	
	EOF

}

########################################
#
# zshスクリプト
# service_stop.sh
#
# [概要]
#    サービス記述ファイル以外の全サービスを停止、またchkconfigによって自動起動をOFFにする。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
########################################

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

########################################
# オプション/引数設定
########################################
# 起動対象ノード記述ファイル
BIN_PWD=($(cd ${0%/*};pwd))
MYHOST=$(uname -n)

SERVICEFILE="${BIN_PWD}/services"

# コマンドラインオプションチェック
while getopts :f:h ARG
do
    case "${ARG}" in
        f)
          SERVICEFILE="${OPTARG}"
        ;;
        h)
          HelpMsg
          exit 0
        ;;
        \?)
          # 解析失敗時に与えられるのは「?」。
          UsageMsg
          exit 4
        ;;
    esac
done

shift $(( OPTIND - 1 ))

########################################

if [[ $(whoami) != "root" ]];then
    echo -e "Sorry, this script is root user only."
    exit 4
fi


if [[ ! -s "${SERVICEFILE}" ]];then
    echo -e "Error target service file is not readble or don't exists or has no contents.\n"
    exit 4
fi


# サービス記述ファイルを配列に取り込む。空行及び先頭#は無視。
: ${(A)SERVICES::=${${(@f)"$(<${SERVICEFILE})"}:#[#]*}}
chkconfig --list | while read line
do
    if [[ ${#${=line}[*]} -eq 8 ]];then
        CNT=1
        CHECK=true
        while [[ ${CNT} -le ${#SERVICES[*]} ]]
        do
            if [[ ${SERVICES[$CNT]} == ${${=line}[1]} ]];then
                CHECK=false
                break 1
            fi
            CNT=$((CNT + 1))
        done
        if ${CHECK};then
            echo -e "===== Info : Stop Service [${${=line}[1]}] ===="
            service ${${=line}[1]} stop
            chkconfig ${${=line}[1]} off
        fi
    fi
done

exit 0

