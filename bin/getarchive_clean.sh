#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : getarchive_clean.sh
	        
	        getarchive_clean.sh [ [34;1m-d output_dir[m ] output_archive
	        getarchive_clean.sh [ [34;1m-h[m ]
	
	EOF

}

########################################
# function HelpMsg
########################################
function HelpMsg(){
    #PAGER変数の設定取り込み
    source $(cd ${CURRENT_SCRIPT%/*};pwd)/"common_def.sh"
    export LC_ALL=ja_JP.utf8
    ${=PAGER} <<-EOF
	
	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: getarchive_clean.sh [m  -- 計測結果のWindows閲覧用整形（１ノード対象）
	
	       getarchive_clean.sh [ [34;1m-d output_dir[m ] output_archive
	       getarchive_clean.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [34;1m-d[m : 出力先ディレクトリの指定。デフォルトはarchive。
	
	       [35;1moutput_archive[m : collect結果アーカイブファイル
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       collectを行ってグラフ化/アーカイブされた結果を、
	       Windowsで閲覧し易い様に以下の様に整形する。
	       
	       ・pngファイルのみ抽出
	       ・グラフ画像参照用HTMLの作成（make_html.shの呼び出し）
	       
	       整形されたファイル群は、zip形式に圧縮され、
	       ファイル名にresdist_というプレフィックスを付けて
	       archiveディレクトリに作成される。
	       （出力先ディレクトリはオプションで変更可能）
	       
	       
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
    # 割り込み時のシグナルハンドリング用（未実装）
    
#}


########################################
#
# zshスクリプト
# getarchive_clean.sh

# [概要]
#    ctrl_resstat.sh collectで作成したarchiveファイルに対し、
#    その中身からpngのみを抽出し、かつ参照用HTMLファイルを作成して置き換え、Windowsでの閲覧用にzip圧縮する。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
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
          GETARCHIVE_OUTPUTDIR="${OPTARG%/}"
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
# コマンドライン引数チェック（1stArgs必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

# 1st Option：アーカイブファイル
if [[ ! -f "$1" ]];then
    UsageMsg
    exit 4
fi
IN_ARCHIVE_FILE="$1"

########################################
# 変数定義
########################################
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

# 出力アーカイブファイル名_プレフィックス
DIST_PREFIX="resdist_"

# パスと拡張子を抜く(tbz2想定。tar.bz2だと後のロジックで失敗する。tarで展開した際に、消える拡張子が一つでなければならない)
ARCH_DIR_NAME=${${IN_ARCHIVE_FILE##*/}%.*}
# 最初の「output_」を抜く。
DIST_NAME_FOOT=${${ARCH_DIR_NAME}#*_}
# プレフィックスと結合してディレクトリ名を作成
DISTNAME="${DIST_PREFIX}${DIST_NAME_FOOT}"


########################################
# 変換実行
########################################
# 出力先ディレクトリ（デフォルトはarchive）
: ${GETARCHIVE_OUTPUTDIR:=${ARCHIVE_DIR}}

# 出力ディレクトリ生成
if [[ -e "${DIST_DIR::=${GETARCHIVE_OUTPUTDIR}/${DISTNAME}}" ]];then
    if [[ ! -d "${DIST_DIR}" ]];then
       echo -e "Error : getarchive_clean.sh : this output directory [${DIST_DIR}] , already used for other file name"
       exit 4
   fi
else
    mkdir -p -m 0777 "${DIST_DIR}"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : getarchive_clean.sh : make directory output miss [${DIST_DIR}]"
        exit 4
    fi
fi

# 対象ファイル展開（archiveディレクトリで行う）
tar xf ${IN_ARCHIVE_FILE} -C "${GETARCHIVE_OUTPUTDIR}"
CMDRET=$?
if [[ ${CMDRET} -ne 0 ]];then
    echo "Error : getarchive_clean.sh : could not [tar bz2] expand   : [${IN_ARCHIVE_FILE}]"
    exit 4
fi

# 展開ディレクトリルートに移動
cd "${GETARCHIVE_OUTPUTDIR}/${ARCH_DIR_NAME}"

# pngファイルのみ、ディレクトリ階層ごとコピー（だからcpioをやめろって……）
find ./ -name "*.png" | cpio -pdmu "${DIST_DIR}"

# HTML作成シェルを使用する。
${MAKE_HTML_SH} -x ${HTML_NOT_TARGET} "${DIST_DIR}"

# 階層を戻る
cd -

# 出力ディレクトリへ。
cd ${GETARCHIVE_OUTPUTDIR}/

# 作成したディレクトリを元にzip圧縮。
if [[ -e "${DISTNAME}.zip" ]];then
    rm -f "${DISTNAME}.zip"
fi
zip -q -r ${DISTNAME}.zip ${DISTNAME}

# 階層を戻る
cd -

# 元ファイルを削除
rm -rf ${DIST_DIR} ${GETARCHIVE_OUTPUTDIR}/${ARCH_DIR_NAME} ${IN_ARCHIVE_FILE}

echo -e "\n    ##---- archive output complete to : [ ${GETARCHIVE_OUTPUTDIR}/${DISTNAME}.zip ]\n"

exit 0

