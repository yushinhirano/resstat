#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : multinode_dist.sh
	        
	        multinode_dist.sh [ [34;1m-f hostsfile[m ]
	        multinode_dist.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: multinode_dist.sh [m  -- resstatパッケージ複数ノード配布
	
	       multinode_dist.sh [ [34;1m-f hostsfile[m ]
	       multinode_dist.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m

	       [34;1m-f[m : 配布対象ノード記述ファイルを指定する。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       カレントノードのresstatパッケージを、
	       配布対象ノード記述ファイルに記述された全てのノードに転送する。
	       
	       転送元ファイルは、[33;1mwork/distribute.sh[mを使用して作成する。
	       
	       転送先は、scpコマンドによりこのスクリプトの起動ユーザで、
	       かつパッケージの格納ディレクトリパスと同じディレクトリにコピーする。
	       （コピー先が既に存在していた場合は削除して再作成）
	       対象ノードは全てスクリプト起動ユーザと同じユーザが存在して、
	       ssh接続時にパスワードが要求されず、
	       また、起動ノードのresstatパッケージ格納ディレクトリと
	       同じディレクトリ構成が存在しなければならない。
	       
	       尚、配布対象ノード記述ファイルは、
	       オプションで指定しなければconf/targethostを使用する。
	       このファイルは、1行に1ノードを記述し、
	       空行と先頭[#]を読み飛ばす。


	[31;1m[Caution] : [m
	
	       [35;1m１．起動条件[m
	           上述した起動条件は、つまりresstatツールの複数ノード起動条件の
	           「resstatツールの配布」以外全てである。
	           そのため、このスクリプトは他の複数ノード起動条件を整えて
	           最後に行うべきものである。
	
	       [35;1m２．スクリプト記述構成[m
	           スクリプトの記述はresstatパッケージのディレクトリ構成に頼っており、
	           workディレクトリやパッケージルートディレクトリの指定が
	           相対的な指定となっている。
	           スクリプト格納場所を変える際には意識して修正に注意すること。

	
	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/targethost


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
# multinode_dist.sh
#
# [概要]
#    resstatパッケージの複数ノード配布。
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

HOSTSFILE="${BIN_PWD}/../../conf/targethost"

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

########################################

if [[ ! -s "${HOSTSFILE}" ]];then
    echo -e "Error target host file is not readble or don't exists or has no contents.\n"
    exit 4
fi

WORK_DIR="${BIN_PWD}/../../work/"

# アーカイブ作成
${WORK_DIR}/distribute.sh

# アーカイブファイル名抽出。
TARGETARCH_FILE=($(cd ${BIN_PWD}/../../work/;ls -t resstat*.tar.bz2 | head -n 1))

# コピー先ディレクトリ（multisetup/binから三階層上）
COPY_TO_DIR=($(cd ${BIN_PWD}/../../../;pwd))

# パッケージディレクトリ（削除対象。multisetup/binから二階層上）
RESSTAT_OLD_DIR=($(cd ${BIN_PWD}/../../;pwd))

# 全体にコピー及び削除展開

for HOST in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [ "${HOST}" != "${MYHOST}" ];then
        echo -e "---------------- to ${HOST}"
        # コピー先ディレクトリが存在しなければ階層ごと作成。また、旧resstatツールは削除。
        ssh ${HOST} 'if [[ ! -d '"${COPY_TO_DIR}"' ]];then mkdir -p '"${COPY_TO_DIR}"';fi ;rm -rf '"${RESSTAT_OLD_DIR}/ ${COPY_TO_DIR}/${TARGETARCH_FILE}"
        # scpでコピー
        scp -p "${WORK_DIR}/${TARGETARCH_FILE}" ${HOST}:"${COPY_TO_DIR}/"
        # 展開
        ssh ${HOST} 'tar xf '"${COPY_TO_DIR}/${TARGETARCH_FILE} -C ${COPY_TO_DIR}/"
    fi
done

echo -e "\n  ##---- All targethost distribute complete. \n"

exit 0

