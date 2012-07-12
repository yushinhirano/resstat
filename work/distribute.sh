#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : distribute.sh
	        
	        distribute.sh 
	        distribute.sh [ [34;1m-h[m ]
	
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

    if [[ -s "${VERSION_TXT::=${CURRENT_SCRIPT%/*}/../VERSION}" ]];then
        RESSTAT_VERSION=$(awk -F ' *= *' '(NF > 0){if ($1 == "VERSION") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_AUTHOR=$(awk -F ' *= *' '(NF > 0){if ($1 == "AUTHOR") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_REPORT_TO=$(awk -F ' *= *' '(NF > 0){if ($1 == "REPORT_TO") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_LASTUPDATE=$(awk -F ' *= *' '(NF > 0){if ($1 == "LAST_UPDATE") { print $2; exit; } }' "${VERSION_TXT}")
    fi

    ${=PAGER} <<-EOF

	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: distribute.sh [m  -- resstatパッケージアーカイブ作成
	
	       distribute.sh 
	       distribute.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       現在展開されているresstatパッケージから、
	       他のノードで起動するために必要な資材のみアーカイブして、
	       bzip2形式に圧縮したファイルを生成する。
	       作成先はwork/resstat-{VERSION}.tar.bz2。
	       
	       既に同名ファイルがある場合は削除して再作成する。
	       
	       アーカイブ対象は、resstatパッケージ中の以下のファイルを除く全て。
	         ・resstat.tbz2
	         ・resstat.*.tar.bz2
	         ・resstat.*.tar（作成途中となる自分自身の回避）
	         ・archive、data、output、proc_idディレクトリ内の全て（ディレクトリ自身は含める）


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
# distribute.sh
#
# [概要]
#    resstatパッケージのアーカイブ。
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
# コマンドラインオプションチェック
while getopts :h ARG
do
    case "${ARG}" in
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

BIN_PWD=($(cd ${0%/*};pwd))

if [[ -s "${VERSION_TXT::=${BIN_PWD}/../VERSION}" ]];then
    RESSTAT_VERSION=$(awk -F ' *= *' '(NF > 0){if ($1 == "VERSION") { print $2; exit; } }' "${VERSION_TXT}")
    OUTPUTFILE=${BIN_PWD}/resstat-${RESSTAT_VERSION}.tar.bz2
else
    OUTPUTFILE=${BIN_PWD}/resstat.tar.bz2
fi

if [[ -f ${OUTPUTFILE} ]];then
    rm -f "${OUTPUTFILE}"
fi

TARGET_DIRNAME=${${BIN_PWD%/*}##*/}

cd ${BIN_PWD}/../../


# findとgrepで検索&弾いて、cpioで作成する。
# 元々tarコマンドで実装していたが、展開する必要のないデータディレクトリが入ってしまうこと、
# 及び作成途中の自分自身が不正なファイルとして残ってしまうことと、
# 他のディレクトリに一時作成するのことによる弊害をうまく回避する方法が思い浮かばないので、便利なcpioに頼っている。

# アーカイブ対象としないもの↓
#   .git
#   resstat.tbz2、
#   resstat.*\.tar\.bz2$
#   resstat.*\.tar$（作成途中となる自分自身の回避）、
#   archive、data、output、proc_idディレクトリ内の全て（ディレクトリ自身は含める）
find ./"${TARGET_DIRNAME}" | grep -E -v "(\.git.*|resstat.*\.tar$|resstat.*\.tar\.bz2$|resstat.tbz2$|archive/.*|data/.*|output/.*|proc_id/.*)" | cpio -o -H tar > "${OUTPUTFILE%.*}"
bzip2 "${OUTPUTFILE%.*}"

echo -e "\n  ##---- archive create: ${OUTPUTFILE}\n"

exit 0

