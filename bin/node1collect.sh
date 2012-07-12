#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : node1collect.sh
	        
	        node1collect.sh [ [34;1m-d target_dirname_suffix[m ] user node cp2_dir
	        node1collect.sh [ [34;1m-h[m ]
	
	EOF

}

########################################
# function HelpMsg
########################################
function HelpMsg(){
    #PAGER変数の設定取り込み
    source $(cd ${CURRENT_SCRIPT%/*};pwd)/"common_def.sh"
    LANG=ja_JP.utf8
    ${=PAGER} <<-EOF
	
	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: node1collect.sh [m  -- 1ノードに対してのcollect処理のSSH呼び出し
	
	       node1collect.sh [ [34;1m-d target_dirname_suffix[m ] user node cp2_dir
	       node1collect.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1muser[m : ログインユーザ
	       
	       [35;1mnode[m : 名前解決可能なノード名 or IPアドレス
	       
	       [35;1mcp2_dir[m : コピー先ディレクトリ
	
	
	[36;1m[Options] : [m

	       [34;1m-d[m : collect時の収集対象ディレクトリ名サフィックス。
	            ctrlresstat.shにそのまま渡すオプションとなる。

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       対象ノードに対してsshで接続し、ctrlresstat.sh collectを起動する。
	       実行後はscpコマンドでcollect結果をカレントノードに取得し、
	       さらにそのファイルをtarコマンドで展開する。
	       tarコマンドでは、実行オプションをxfしか指定していないので、
	       圧縮形態と拡張子のマッピングをどう処理するかはtarに任せている。
	
	
	[36;1m[Author & Copyright] : [m
	        
	        resstat version ${RESSTAT_VERSION}.
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.
	
	
	EOF

}

########################################
# function Error_clean
########################################
#Error_clean() {
    #割り込み時のシグナルハンドリング用（未実装）
    #start後に割り込まれたらstopすべき
    
#}


########################################
#
# zshスクリプト
# node1collect.sh
#
# [概要]
#    1ノードに対するcollect処理のssh呼び出し。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
# [改善案]
#  ★output機能のうち、HTML作成くらいまで埋め込んでおくとより良い？
#
########################################

#非シグナルハンドリング

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

########################################
# オプション/引数設定
########################################
# コマンドラインオプションチェック
while getopts :d:h ARG
do
    case "${ARG}" in
        d)
          COLLECT_TDIR_SUFFIX="${OPTARG%/}"
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
# コマンドライン引数チェック（1st、2nd、3rd Args必須）
if [[ -z "$1" || -z "$2" || -z "$3" ]];then
    UsageMsg
    exit 4
fi

LOGIN_USER="$1"
NODE="$2"
CPTODIR="$3"


#共通の変数が未取り込みなら取り込む
if [[ -z "${COMMON_DEF_ON}" ]];then
    #スクリプト格納ディレクトリ(絶対パス)
    BIN_PWD=($(cd ${0%/*};pwd))
    export BIN_DIR=${BIN_PWD}
    COMMON_DEF="common_def.sh"
    source ${BIN_DIR}/${COMMON_DEF}
fi

#共通関数スクリプトの取り込み（全スクリプト共通）
COMMON_SCRIPT="common.sh"
source ${BIN_DIR}/${COMMON_SCRIPT}


##############################################################################
# 処理の実行
##############################################################################
# 各ノードでcollectを実行。
if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
    ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH} -q -d ${COLLECT_TDIR_SUFFIX}"' collect > /dev/null'
else
    ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH}"' -q collect > /dev/null'
fi

if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
    # -d の場合、最新ファイルを予測する必要がある。作成されていなければ何もしない。
    NEW_FILE=$(ssh ${LOGIN_USER}@${NODE} 'cd '"${ARCHIVE_DIR}"';ls -1t '"${OUTPUT_DIR_PREFIX}_"'$(uname -n)'"_${COLLECT_TDIR_SUFFIX}."'* | head -n 1 2> /dev/null')
else
    # 各ノードのARCHIVE_DIR内の最新ファイルを取得し、collect処理で作成されたものみなす。
    NEW_FILE=$(ssh ${LOGIN_USER}@${NODE} 'cd '"${ARCHIVE_DIR}"';ls -1t | head -n 1 2> /dev/null')
fi
if [[ -z "${NEW_FILE}" ]];then
    echo "Error : node1collect.sh : [ ctrl_resstat.sh collect ] cannot create collected archive. "
    exit 10
fi

# カレントノードコピー先ディレクトリの作成
if [[ ! -d "${CPTODIR}" ]];then
    if [[ -e "${CPTODIR}" ]];then
        echo -e "${CPTODIR}:: already link name exists. please use other name for that directory."
        exit 4
    else
        mkdir -p "${CPTODIR}"
    fi
fi

# collect結果をカレントノードに転送。（重いと考えられるかもだが、OUTPUTレベルを0にしておけば、画像しか転送されない。そっちで調整）
scp -p ${NODE}:"${ARCHIVE_DIR}/${NEW_FILE}" ${CPTODIR}/ > /dev/null

# 転送成功時は、コピーディレクトリ内でtarコマンドを使用してアーカイブ展開する。
# 展開後は元ファイルを削除。
# 【注意】
# tarでの展開時はxf指定で、tarの頭の良さに任せて圧縮/解凍用オプションを指定していない。
# tbz2やtar.bz2、tgzやtar.gzなどはこれで一気に解凍してくれる。
if [[ -s "${CPTODIR}/${NEW_FILE}" ]];then
    CURRENT=$(pwd)
    cd "${CPTODIR}"
    tar xf "${NEW_FILE}"
    rm -f "${NEW_FILE}"
    cd ${CURRENT}
fi

# HTMLはある程度ここで作成してしまう？並列化させたいっちゃーさせたいが。


exit 0

