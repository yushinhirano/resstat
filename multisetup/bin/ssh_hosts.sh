#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : ssh_hosts.sh
	        
	        ssh_hosts.sh [ [34;1m-f hostsfile[m ] cmd [ args1 args2 ...... ]
	        ssh_hosts.sh [ [34;1m-h[m ]
	
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
	
	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: ssh_hosts.sh [m  -- 複数ノード一斉ssh
	
	       ssh_hosts.sh [ [34;1m-f hostsfile[m ] cmd [ args1 args2 ...... ]
	       ssh_hosts.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mcmd[m : 実行コマンド
	       
	       [35;1margsN[m : 実行コマンド引数（必要時のみ）
	
	
	[36;1m[Options] : [m
	
	       [34;1m-f[m : 起動対象ノード記述ファイルの指定。デフォルトは、conf/targethosts。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       起動対象ノード記述ファイルに掛かれた全てのノードに対し、
	       指定のコマンドと引数でシェルに解釈させて実行させる。
	       
	       起動対象ノード記述ファイルは、先頭[#]の行及び空行を読み飛ばし、
	       1行1ノード名と認識する。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。
	       というより、単なるツールとして
	       個人的にいつも使うから入れているだけのこと。
	       
	       他環境に移す場合、デフォルトHOSTSFILEの指定変更と、
	       マニュアルのVERSION読み込み/表示削除を行えば良い。


	[31;1m[Caution] : [m
	
	       [35;1m１．sshコマンドの注意[m
	           注意はssh実行時と同じ。
	           標準入出力の閉じられるタイミングや、
	           sshで実行するコマンドにはシェル解釈が二回走ることや、
	           メタキャラクタの使用に充分注意してコマンド発行すること。
	           このスクリプトのバグだと言われても責任は持てません。
	           sshで単独ノードに発行しても同じ目に遭うかどうかを確認してから文句をどうぞ。
	           
	
	[36;1m[Author & Copyright] : [m
	        
	        resstat version ${RESSTAT_VERSION}.
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.
	
	
	EOF

}


########################################
# 
# zshスクリプト
# ssh_hosts.sh
#
# ホストファイル指定で対象全ノードにsshコマンドを送信する。
# 
########################################

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

# ホストファイル指定のバージョン。
BIN_PWD=($(cd ${0%/*};pwd))

HOSTSFILE="${BIN_PWD}/../../conf/targethost"

########################################
# オプション/引数設定
########################################
# コマンドラインオプションチェック
while getopts :f:h ARG
do
    case "${ARG}" in
        f)
          HOSTSFILE="${OPTARG}"
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

# コマンドライン引数チェック
CMD="$*"

if [ -z "${CMD}" ];then
    UsageMsg
    exit 4
fi

MYHOST=$(uname -n)

for HOST in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
#    if [ "${HOST}" != "${MYHOST}" ];then
        echo -e "---------------- on ${HOST}"
        ssh ${HOST} "${CMD}"
#        echo -e "\n"
#    fi
done

exit 0

