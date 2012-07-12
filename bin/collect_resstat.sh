#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : collect_resstat.sh
	        
	        collect_resstat.sh [ [34;1m-q[m ] target_dir
	        collect_resstat.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: collect_resstat.sh [m  -- パフォーマンス計測結果集計/グラフ化の呼び出しとアーカイブ
	
	       collect_resstat.sh [ [34;1m-q[m ] target_dir
	       collect_resstat.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1mtarget_dir[m : 集計対象ダンプファイルを格納したディレクトリ
	
	
	[36;1m[Options] : [m

	       [34;1m-q[m : quietモード。終了メッセージ、アーカイブファイル、
	            及びこのスクリプトが起動するグラフ作成スクリプトの標準出力/標準エラー出力を捨てる。
	            危険なので、複数ノード自動実行の場合以外は行わないこと。

	      [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       引数として指定されたディレクトリ内のダンプファイルに対して、
	       draw_graph.shでグラフ作成を指示する。
	       また、ダンプファイルとグラフを纏めてアーカイブし、
	       archiveディレクトリに格納する。
	       以下はその方法である。
	       
	       [35;1m１．sarレポートの作成[m
	         指定されたディレクトリ内から、sadc*.dmpにヒットするファイルを
	         sadcダンプとみなし、
	         [34;1msar -f [sadc ダンプ] [オプション][m
	         を実行して、
	         sar_[オプション].outファイルにその出力を格納する。
	         [34;1m[オプション]は、conf/{SYSKBN}/command.conf[mに記述されている
	         sarグラフ化対象に従い、必要なもののみ行う。
	         具体的には、ファイルから先頭が[sar_]で始まる行を抽出し、
	         [sar_?]、[sar__?]、[sar_?_*]にヒットする行をそれぞれ
	         小文字オプション、大文字オプション、パラメータ付きオプションとして取得する。
	         
	         出力ファイル名は、[オプション]が小文字ならsar_[オプション].out、
	         大文字ならsar__[オプション].out（Windowsでは小文字/大文字の名称の区別がつかないため）、
	         オプション名 + パラメータ名の場合、
	         sar_[オプション]_[パラメータ].outとなる。
	         
	       [35;1m２．グラフ化スクリプトの呼び出し[m
	         conf/command.confファイルを読み込み、
	         その各行に記述されたターゲットをグラフ化対象レポートとする。
	         そのグラフ化対象レポートに存在し、
	         かつ指定されたディレクトリ内に「グラフ化対象レポート*」に
	         マッチするファイルがある場合のみ、
	         そのファイルを引数にして[33;1mbin/draw_graph.sh[mを起動する。
	         
	         尚、グラフ化対象レポート（つまりconf/command.confファイルの各行）は、
	         その名称.confにヒットするconf/{SYSKBN}/以下の
	         グラフ化コンフィグファイルが存在する必要がある。
	         
	       [35;1m３．出力ファイルアーカイブ[m
	         resstat.confファイルのOUTPUT_LEVELパラメータから、ログ保存レベルを取得する。
	         これは、出力するアーカイブファイルにどこまでのファイルを含めるかを定義している。
	         現在のところ、1以上であれば、
	         sadcレポート以外の全て（sarダンプを含む）をアーカイブしている。
	         （sar*（正確にはSADC_DATA_PREFIX環境変数*）にマッチするファイルを除いている）
	         0の場合は何も出力していない。
	         
	         アーカイブファイル名は、output_引数指定ディレクトリ名.tbz2となり、
	         archiveディレクトリに格納される。
	         [32;1m拡張子が示す通り、bzip2圧縮を行っている。[m
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．ファイル名、出力先、形式の固定化[m
	           このスクリプトはファイルパスや出力形式を多くの部分で固定化している。
	           sarのオプションが大文字の場合はアンダースコアを二つ付ける、
	           アーカイブファイルの出力先はarchive固定、またプレフィックスがoutputとなり、
	           かつbzip2圧縮をデフォルトでかけるなど、様々な仕様に注意する。
	
	       [35;1m２．sar形式ファイル名[m
	           sadcから作成するsarファイル形式は、sar_{オプション名}.outである。
	           draw_graph.shでは、先頭がsarで始まるファイルについては、
	           そのファイルの拡張子をconfにしたファイルが
	           conf/{システム区分}/ディレクトリに存在し、
	           そのファイルがグラフ化用コンフィグファイルとして認識している。
	           このフォーマットを変える場合にはこの部分との連携を取ること。

	
	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/resstat.conf
	        ・conf/{SYSKBN}/command.conf
	
	
	[36;1m[Related Parameters] : [m
	        
	        [35;4;1mresstat.conf[m
	            ・OUTPUT_LEVEL
	
	
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
# collect_resstat.sh
#
# [概要]
# [起動条件、仕様]
# [引数]
#   UsageMsg()、HelpMsg()参照。
#
# [改善案]
#    ・output内は圧縮のON/OFF、また圧縮方式をサポートする。（現在は固定）
#    ・output先の指定はコンフィグで指定可能とする。（そのディレクトリにoutput以下そのままを入れる）
#      少々困難だが、scpを使った転送を可能とする。対象ディレクトリの指定はuser@host:絶対パス。
#      また、scpにはパスワードオプションを付ける。
#
########################################

#非シグナルハンドリング

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

########################################
# オプション/引数設定
########################################
# コマンドラインオプションチェック
# プログレスechoやコマンド表示を抑制するモード。
MODE_QUIET=false
while getopts :qh ARG
do
    case "${ARG}" in
        q)
          MODE_QUIET=true
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
# コマンドライン引数チェック（1st Args必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi
TARGET_DIR="${1%/}"

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

# ロケールを英語に変更
export LANG=C

##############################################################################
# sysstatバージョンの取得
##############################################################################
SYSSTAT_VERSION=$(getSysstatVersion)
checkReturnErrorFatal $? "${SYSSTAT_VERSION}"

##############################################################################
# 処理の実行
##############################################################################

# 出力ディレクトリ作成(デフォルト位置。存在すれば削除して再作成)
OUTPUT_DIR="${TARGET_DIR}/${OUTPUT_DIR_PREFIX}_${TARGET_DIR##*/}"
#OUTPUT_DIR=${TARGET_DIR}/${OUTPUT_DIR_PREFIX}
if [[ -e "${OUTPUT_DIR}" ]];then
    # エラーチェックしない
    rm -rf "${OUTPUT_DIR}"
fi

mkdir -m 0777 ${OUTPUT_DIR}
CMDRET=$?
if [[ ${CMDRET} -ne 0 ]];then
    echo -e "Error : collect_resstat.sh : make directory output miss"
    exit 4
fi

##---------------------------------------------
# sarのレポート出力（存在している場合）
##---------------------------------------------

# 【注意】 ここで出力されるsarダンプの名称は、draw_graph.shで判定する conf/プラットフォーム名 以下のグラフ化コンフィグ存在判定に利用される。
#          具体的には、[sar_][オプション].dmpから、前方最小一致で.*を抜いた後、[その名称].confが conf/プラットフォーム名 に存在しなければならない。

# sadcダンプの検出
SADC_DMP=$(find ${TARGET_DIR}/* -maxdepth 0 -type f -name "${SADC_DATA_PREFIX}*.${SADC_DATA_SUFFIX}")

# sadcが出力されている場合のみ、sarのレポートを出力する。
if [[ -n "${SADC_DMP}" ]];then
    # command.confから、空白行と先頭#を除き、さらに[sar_]で始まる行を取得。
    unset LOWER_OPTS
    unset UPPER_OPTS
    unset PARAM_OPTS
    unset PARAM_STRS
    for LINE in ${(M)${${(@f)"$(<${COMMAND_CONFFILE})"}:#[#]*}:#sar_*}
    do
        # [sar_?]は１文字オプション
        if [[ "${LINE}" == "sar_"? ]];then
            # sar_を抜いた文字（最後の１文字）をセット
            LOWER_OPTS=(${LOWER_OPTS[*]} ${LINE#sar_})
        # [sar__?]は大文字オプション
        elif [[ "${LINE}" == "sar__"? ]];then
            UPPER_OPTS=(${UPPER_OPTS[*]} ${LINE#sar__})
        # [sar_?_*]はパラメータ付きオプション
        elif [[ "${LINE}" == "sar_"?"_"* ]];then
            PARAM_OPTS=(${PARAM_OPTS[*]} ${${LINE#sar_}%_*})
            PARAM_STRS=(${PARAM_STRS[*]} ${LINE#sar_?_})
        fi
    done
    
    for OPT in ${LOWER_OPTS[*]}
    do
        case ${OPT} in
        d)
            # sar -d には、同時に-pも必要。sysstat 8.1.3までは、sadc に-dを付加しておかなければならない。
            sar -${OPT} -p -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${OPT}.${SAR_DATA_SUFFIX}
            ;;
        u)
            # sar -u には、ALLを付ける。
            # 8.1.3以上の場合、-u ALL -P ALL。
            if compVersion ${COMPVERSION_LARGE} ${SYSSTAT_VERSION} 8.1.3;then
                sar -${OPT} ALL -P ALL -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${OPT}.${SAR_DATA_SUFFIX}
            else
            # 8.1.3以下の場合、-u -P ALL。
                sar -${OPT} -P ALL -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${OPT}.${SAR_DATA_SUFFIX}
            fi
            ;;
        m)
            # 小文字オプションのみのsar -m には、-P ALLを付ける。（後にsar -m CPUとなる項目）
            sar -${OPT} -P ALL -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${OPT}.${SAR_DATA_SUFFIX}
            ;;
        x)
            # sar -xの場合、sadcからsarに出すことは不可能。
            # sadcとは別にsar又はpidstatコマンドを起動時に実行し、既に存在していなければならない。
            ;;
        *)
            sar -${OPT} -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${OPT}.${SAR_DATA_SUFFIX}
            ;;
        esac
    done
    
    for OPT in ${UPPER_OPTS[*]}
    do
        case ${OPT} in
        I)
            # sar -I では、同時に割り込み番号を付加する。
            # 指定する割り込み番号はresstat.confから取得。
            # sysstat 8.1.3までは、sadcに-Iを付加しておかなければならない。
            INTR_NUMS=$(getParamFromConf "INTR_NUMBER")
            sar -I ${INTR_NUMS} -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}__${OPT}.${SAR_DATA_SUFFIX}
            ;;
        X)
            # sar -Xの場合、sadcからsarに出すことは不可能。
            # sadcとは別にsar又はpidstatコマンドを起動時に実行し、既に存在していなければならない。
            ;;
        *)
            sar -${OPT} -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}__${OPT}.${SAR_DATA_SUFFIX}
            ;;
        esac
        
    done
    # 上記はwindows上に展開する場合を想定したため。__を二つに増やしてファイル名同一の回避。
    # 大体Winodwsは大文字と小文字を区別しないとは、誰も喜ばない仕様だと思うが。
    
    SPCNT=1
    while [[ ${SPCNT} -le ${#PARAM_OPTS[*]} ]]
    do
        case ${PARAM_OPTS[$SPCNT]} in
        m)
            if [[ ${PARAM_STRS[$SPCNT]} == "CPU" ]];then
                # sar -m CPUには、-P ALLを付けて全てのプロセッサから取得。
                sar -${PARAM_OPTS[$SPCNT]} ${PARAM_STRS[$SPCNT]} -P ALL -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${PARAM_OPTS[$SPCNT]}_${PARAM_STRS[$SPCNT]}.${SAR_DATA_SUFFIX}
            else
                sar -${PARAM_OPTS[$SPCNT]} ${PARAM_STRS[$SPCNT]} -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${PARAM_OPTS[$SPCNT]}_${PARAM_STRS[$SPCNT]}.${SAR_DATA_SUFFIX}
            fi
            ;;
        *)
            sar -${PARAM_OPTS[$SPCNT]} ${PARAM_STRS[$SPCNT]} -f "${SADC_DMP}" > ${TARGET_DIR}/${SAR_DATA_PREFIX}_${PARAM_OPTS[$SPCNT]}_${PARAM_STRS[$SPCNT]}.${SAR_DATA_SUFFIX}
            ;;
        esac
        SPCNT=$(( SPCNT + 1 ))
    done
fi


##---------------------------------------------
# グラフ化実行
##---------------------------------------------
# 実行コマンド対象/グラフ化対象定義ファイルを読み、まとめてdraw_graph.shの引数に入れて起動する。
# 先頭#、空行を除いて取得し、ループ。
# 【注意】：空白やタブのみの行、及び空白後に#が付いた行は除けない。ゆえにawkでの取得版より若干機能が劣る。
for LINE in ${${(@f)"$(<${COMMAND_CONFFILE})"}:#[#]*}
do
    case "${LINE}" in
    sar*)
        # sarのみ、${LINE}.outに決め打つ。*を挟み検索する余地なし。
        T_GRAPH_FILE=$(find "${TARGET_DIR}" -maxdepth 1 -name "${LINE}.${SAR_DATA_SUFFIX}" 2>/dev/null)
        ;;
    mpstat*)
        T_GRAPH_FILE=$(find "${TARGET_DIR}" -maxdepth 1 -name "${LINE}*.${MPSTAT_DATA_SUFFIX}" 2>/dev/null)
        ;;
    vmstat*)
        T_GRAPH_FILE=$(find "${TARGET_DIR}" -maxdepth 1 -name "${LINE}*.${VMSTAT_DATA_SUFFIX}" 2>/dev/null)
        ;;
    iostat*)
        T_GRAPH_FILE=$(find "${TARGET_DIR}" -maxdepth 1 -name "${LINE}*.${IOSTAT_DATA_SUFFIX}" 2>/dev/null)
        ;;
    pidstat*)
        T_GRAPH_FILE=$(find "${TARGET_DIR}" -maxdepth 1 -name "${LINE}*.${PIDSTAT_DATA_SUFFIX}" 2>/dev/null)
        ;;
    esac
    
    # デフォルトグラフ化ファイルにあって、実ファイルが無い場合。警告だけ残してcontinue。実際、警告することでもないけど。
    if [[ -z "${T_GRAPH_FILE}" ]];then
        echo -e "Warn : collect_resstat.sh : draw_graph target [${LINE}] file not exists."
        continue
    fi
    
    TARGET_GRAPHS=(${TARGET_GRAPHS[*]} "${T_GRAPH_FILE##*/}")
done

# draw_graph.shの起動。quietモードの場合、出力は捨てる。
if ${MODE_QUIET};then
    ${DRAW_GRAPH_SH} "${TARGET_DIR}" "${OUTPUT_DIR}" ${TARGET_GRAPHS[*]} &> /dev/null
else
    ${DRAW_GRAPH_SH} "${TARGET_DIR}" "${OUTPUT_DIR}" ${TARGET_GRAPHS[*]}
fi

##---------------------------------------------
# sarファイルの削除
##---------------------------------------------
# レポートダンプを軽くするため、sarグラフ化に使用したsarダンプは削除する。（sar -x、sar -Xを除く）
# レポートの出力にはsadcさえあれば充分であるため。
find "${TARGET_DIR}/"* -maxdepth 0 -type f -name "${SAR_DATA_PREFIX}_*.${SAR_DATA_SUFFIX}" | grep -v -E "(sar_x|sar__X)" | xargs rm -f

##---------------------------------------------
# 出力対象の保存とアーカイブ（現在tbz2固定）
##---------------------------------------------
# パラメータファイルからログ保存レベルの取得。
# レベル0でも、グラフファイルだけは存在。
OUTPUT_LEVEL=$(getParamFromConf "OUTPUT_LEVEL")
if [[ ${OUTPUT_LEVEL} -ge 1 ]];then
    # レベル１以上：outputディレクトリへコピーする。
    for LINE in ${(@f)"$(find ${TARGET_DIR}/ -maxdepth 1 -type f)"}
    do
        cp -p ${LINE} ${OUTPUT_DIR}/
    done
fi


# output圧縮、archiveディレクトリへ。
ARCHIVE_OUTPUT="${ARCHIVE_DIR}/${OUTPUT_DIR##*/}.tbz2"
if [[ -e "${ARCHIVE_OUTPUT}" ]];then
    rm -f "${ARCHIVE_OUTPUT}"
fi

# cdを行うが、ARCHIVE_OUTPUTは絶対パスなので問題なし。
cd "${TARGET_DIR}"
tar jcf "${ARCHIVE_OUTPUT}" ${OUTPUT_DIR##*/}

# quietモードでない場合はアーカイブ先をechoする。
if ! ${MODE_QUIET};then
    echo -e "\n    ##---- collected : [ ${ARCHIVE_OUTPUT} ]  -- \n"
fi

exit 0

