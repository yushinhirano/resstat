#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : scp_hosts.sh
	        
	        scp_hosts.sh [ [34;1m-f hostsfile[m ] copy_src_dist_path
	        scp_hosts.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: scp_hosts.sh [m  -- 複数ノード一斉scp
	
	       scp_hosts.sh [ [34;1m-f hostsfile[m ] copy_src_dist_path
	       scp_hosts.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mcopy_src_dist_path[m : コピー対象ファイルパス（絶対/相対のどちらでも可能）
	
	
	[36;1m[Options] : [m
	
	       [34;1m-f[m : 起動対象ノード記述ファイルの指定。デフォルトは、conf/targethosts。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       指定された（絶対/相対）パスに存在するファイルを、
	       起動対象ノード記述ファイルに書かれた全ノードの同じパスに向かって
	       scpコマンドで転送コピーする。
	       
	       起動対象ノード記述ファイルは、先頭[#]と空行を読み飛ばし、
	       1行1ノードで記述する。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。
	       というより、単なるツールとして
	       個人的にいつも使うから入れているだけのこと。
	       
	       他環境に移す場合、デフォルトHOSTSFILEの指定変更と、
	       マニュアルのVERSION読み込み/表示削除を行えば良い。


	[31;1m[Caution] : [m
	
	       [35;1m１．コピー先の制限[m
	           コピー元ファイルとコピー先ファイルパスは同じである。
	           つまり、起動対象全ノードで、
	           カレントノードのコピー元ファイル格納ディレクトリと
	           同じディレクトリ構成が存在していなければならない。
	           
	
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
# scp_hosts.sh
#
# ホストファイル指定で対象全ノードにscpコマンドを実行する。
# 
########################################

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

# ホストファイル指定のバージョン。
BIN_PWD=($(cd ${0%/*};pwd))

# デフォルトは、resstatツールのconf/targethost
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
TARGET="$1"

if [[ -z "${TARGET}" || ! -f "${TARGET}" ]];then
    UsageMsg
    exit 4
fi

if [[ ! -s "${HOSTSFILE}" || ! -r "${HOSTSFILE}" ]];then
    UsageMsg
    exit 4
fi

# カレントディレクトリパス。シンボリックリンクはそのまま認識させる。（相対で書かれている場合怖い）
CURRENTDIR=$(pwd)

# コピー対象パスを絶対パスへ変換。
if [[ -n "${TARGET%%/*}" ]];then
    # /から先を前方最長一致で抜いた場合に文字が残っていれば、相対指定と判断する。
    # 絶対パスは先頭/なので全て消える。
    
    # カレントディレクトリと連結する
    TARGET="${CURRENTDIR}/${TARGET}"
fi

MYHOST=$(uname -n)

for HOST in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    # 自ノード以外にコピー
    if [[ "${HOST}" != "${MYHOST}" ]];then
        echo -e "---------------- to ${HOST}"
        scp -p "${TARGET}" ${HOST}:"${TARGET}"
    fi
done

exit 0

