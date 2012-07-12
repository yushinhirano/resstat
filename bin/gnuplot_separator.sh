#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : gnuplot_separator.sh
	        
	        gnuplot_separator.sh sourcefile configfile outputroot_dir separator_type
	        gnuplot_separator.sh [ [34;1m-h[m ]
	        
	            [35;1mseparator_type[m : network | cpu | iostat_device | 
	                             sar_device | process | cprocess | tty | interrupts
	
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
	
	
	[36;1mUsage: gnuplot_separator.sh [m  -- ソースファイル分割型グラフ作成スクリプト
	
	       gnuplot_separator.sh sourcefile configfile outputroot_dir separator_type
	       gnuplot_separator.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1msourcefile[m : グラフ化対象ファイル
	       
	       [35;1mconfigfile[m : [35;1msourcefile[mをグラフ化するためのコンフィグファイル
	       
	       [35;1moutputroot_dir[m : グラフ出力先ルートディレクトリ
	       
	       [35;1mseparator_type[m : 分割方式のタイプ。{ network | cpu | iostat_device | sar_device | 
	                                            process | cprocess | tty | interrupts }のいずれか。
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       指定されたグラフ化ソースファイルを、
	       [35;1mseparator_type[mの方式に従って分割し、
	       その分割されたファイルそれぞれに対してgnuplot_normal.shを呼び出してグラフ化する。
	       
	       分割方法は次の通りである。
	       
	       ・conf/resstat.confから、[35;1mseparator_type[mに応じた計測対象値を取得。
	       ・conf/graph.confから、[35;1mseparator_type[mに応じた
	         ソースファイルの分割フィールド名を取得。
	       
	       [35;1mseparator_type[mとconfファイル内のパラメータ名の対応は以下の通り。
	         ・conf/resstat.conf
	           network         : NETWORK_INTERFACES
	           cpu             : CPU_CORES
	           iostat_device   : BLOCK_DEVICES
	           sar_device      : BLOCK_DEVICES
	           process         : ATTACH_PID
	           cprocess        : ATTACH_PID
	           tty             : TTY_NUMBER
	           interrupts      : INTR_NUMBER
	         
	         ・conf/graph.conf
	           network         : NET_IFACE_FIELD_NAME
	           cpu             : CPU_FIELD_NAME
	           iostat_device   : IOSTAT_DEVICE_FIELD_NAME
	           sar_device      : SAR_DEVICE_FIELD_NAME
	           process         : PID_FIELD_NAME
	           cprocess        : CHILD_PID_FIELD_NAME
	           tty             : TTY_FIELD_NAME
	           interrupts      : INTR_FIELD_NAME
	       
	       
	       上記の様にパラメータを取得後、
	       ソースファイルヘッダのフィールド名が取得フィールド名と同じカラムに対し、
	       取得した計測対象名の完全一致でgrepを掛ける。（grep結果が存在しなければスキップ）
	       これを、計測対象名の全てについて繰り返す。
	       
	       また、分割前後で、conf/{SYSKBN}/all_header.confからヘッダ行を取得し、
	       ヘッダ部分を除いて分割を行い、分割後にまたヘッダを連結する。
	       これにより、gnuplot_normal.shが受け付けるソースファイルフォーマットとなる。
	       
	       さらに、gnuplot_normal.shが認識する環境変数GRAPH_FILE_NAME_PREFIX、
	       GRAPH_TITLE_NAME_PREFIX、GRAPH_DIR_NAME_PREFIXを、
	       それぞれ分割値に応じてセットし、[34;1m分割後のグラフの出力先ディレクトリ、[m
	       [34;1mファイル名、グラフタイトル名のプレフィックス[mを設定している。
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m２．入力データダンプファイル[m
	           このスクリプトでは、指定される引数[35;1msourcefile[mの内容を
	           gnuplot_normal.shで受け入れる形に分割することが主な役割である。
	           
	           このスクリプトを呼ぶ主な例としては、
	           mpstat -P ALLやiostat -xkなど、
	           
	           ----------------------------------------------------------------------------------------------
	           Linux 2.6.18-128.el5xen (node11)        07/11/11

	           07:48:36     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
	           07:48:36     all    0.01    0.00    0.01    0.03    0.00    0.00    0.00   99.95     21.52
	           07:48:36       0    0.01    0.00    0.02    0.11    0.00    0.00    0.00   99.86      8.39
	           07:48:36       1    0.01    0.00    0.01    0.00    0.00    0.00    0.00   99.98      4.61
	           07:48:36       2    0.00    0.00    0.01    0.00    0.00    0.00    0.00   99.98      4.48
	           07:48:36       3    0.00    0.00    0.01    0.00    0.00    0.00    0.00   99.98      4.05
	           ----------------------------------------------------------------------------------------------
	           
	           上記の様に、１度の出力で複数行、複数の計測対象が出力されるものである。
	           この様なフォーマットのダンプファイルの場合、
	           「CPU」フィールドのall、0、1、2、3で分割してグラフ化するため、このスクリプトを使用する。
	           尚、ヘッダ行数はconf/{SYSKBN}/all_header.confに該当するヘッダ行フォーマットでなければならない。
	           
	           
	[36;1m[Related ConfigFiles] : [m
	
	        ・conf/resstat.conf
	        ・conf/graph.conf
	        ・conf/{SYSKBN}/all_header.conf
	
	[36;1m[Related Parameters] : [m
	        
	        [35;4;1mresstat.conf[m
	            ・NETWORK_INTERFACES
	            ・CPU_CORES
	            ・BLOCK_DEVICES
	            ・ATTACH_PID
	            ・TTY_NUMBER
	            ・INTR_NUMBER

	        [35;4;1mgraph.conf[m
	            ・NET_IFACE_FIELD_NAME
	            ・CPU_FIELD_NAME
	            ・IOSTAT_DEVICE_FIELD_NAME
	            ・SAR_DEVICE_FIELD_NAME
	            ・PID_FIELD_NAME
	            ・CHILD_PID_FIELD_NAME
	            ・TTY_FIELD_NAME
	            ・INTR_FIELD_NAME
	
	
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
# gnuplot_separator.sh
#
# [概要]
#    指定された元ファイル、設定ファイル、出力ディレクトリに対し、パフォーマンス計測データを集計してグラフ化する。
#    グラフ化の実行にはファイル名に応じたconfigファイルが必要。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
########################################

#非シグナルハンドリング
#非エラーチェック

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
# コマンドライン引数チェック（1st、2nd、3rd、4th Args必須）
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]];then
    UsageMsg
    exit 4
fi

if [[ ! -r "$1" ]];then
    echo -e "Error : gnuplot_separator.sh : source file is not readable [$1]"
    exit 4
fi
SOURCE="$1"

if [[ ! -r "$2" ]];then
    echo -e "Error : gnuplot_separator.sh : config file is not readable [$1]"
    exit 4
fi
GRAPH_CONF="$2"

if [[ -e "$3" ]];then
    if [[ ! -d "$3" ]];then
       echo -e "Error : gnuplot_separator.sh : this output directory [$3] , already used for other file name"
       exit 4
   fi
else
    mkdir -m 0777 "$3"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : gnuplot_separator.sh : make directory output miss [$3]"
        exit 4
    fi
fi
OUTPUT_DIR="${3%/}"

# 先行変数定義
SET_TYPE_NETWORK=network
SET_TYPE_CPU=cpu
SET_TYPE_IOSTAT_DEVICE=iostat_device
SET_TYPE_SAR_DEVICE=sar_device
SET_TYPE_PROCESS=process
SET_TYPE_CHILD_PROCESS=cprocess
SET_TYPE_TTY=tty
SET_TYPE_INTERRUPTS=interrupts

case "$4" in
    "${SET_TYPE_NETWORK}"|\
    "${SET_TYPE_CPU}"|\
    "${SET_TYPE_IOSTAT_DEVICE}"|\
    "${SET_TYPE_SAR_DEVICE}"|\
    "${SET_TYPE_PROCESS}"|\
    "${SET_TYPE_CHILD_PROCESS}"|\
    "${SET_TYPE_TTY}"|\
    "${SET_TYPE_INTERRUPTS}")
    ;;
    *)
        UsageMsg
        exit 4
    ;;
esac

SEP_TYPE="$4"

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

SOURCE_TMP="${SOURCE}.tmp"

echo -e "Info : gnuplot_separator.sh : File [${SOURCE}] Graph making start"

##############################################################################
# ソースファイルの変換
##############################################################################
unset GREP_TARGET
unset SEPNAME_FIELD
case "${SEP_TYPE}" in
    "${SET_TYPE_NETWORK}")
        # セパレータタイプ：networkの処理
        # 【注意】
        #  resstat.confのNETWORK_INTERFACESから、グラフ化対象のネットワークインタフェース名を取得。
        RESSTATCONF_SEP_FIELD="NETWORK_INTERFACES"
        
        # 【注意】
        # graph_separator.confのNET_IFACE_FIELD_NAMEフィールドから、
        # ネットワークインタフェースフィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="NET_IFACE_FIELD_NAME"
    ;;
    "${SET_TYPE_CPU}")
        RESSTATCONF_SEP_FIELD="CPU_CORES"
        # 【注意】
        # graph.confのCPU_FIELD_NAMEフィールドから、
        # CPUコアフィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="CPU_FIELD_NAME"
    ;;
    "${SET_TYPE_IOSTAT_DEVICE}")
        RESSTATCONF_SEP_FIELD="BLOCK_DEVICES"
        # 【注意】
        # graph.confのIOSTAT_DEVICE_FIELD_NAMEフィールドから、
        # iostat -xk -p 用デバイス名フィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="IOSTAT_DEVICE_FIELD_NAME"
    ;;
    "${SET_TYPE_SAR_DEVICE}")
        RESSTATCONF_SEP_FIELD="BLOCK_DEVICES"
        # 【注意】
        # graph.confのSAR_DEVICE_FIELD_NAMEフィールドから、
        # sar -dp 用デバイス名フィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="SAR_DEVICE_FIELD_NAME"
    ;;
    "${SET_TYPE_PROCESS}")
        RESSTATCONF_SEP_FIELD="ATTACH_PID"
        # 【注意】
        # graph.confのPID_FIELD_NAMEフィールドから、
        # sar -x、sar -X、pidstat 用PID名フィールド名の取得。
        GRAPHCONF_SEPNAME_FIELD="PID_FIELD_NAME"
    ;;
    "${SET_TYPE_CHILD_PROCESS}")
        RESSTATCONF_SEP_FIELD="ATTACH_PID"
        # 【注意】
        # graph.confのCHILD_PID_FIELD_NAMEフィールドから、
        # sar -X 用PID名フィールド名の取得。
        GRAPHCONF_SEPNAME_FIELD="CHILD_PID_FIELD_NAME"
    ;;
    "${SET_TYPE_TTY}")
        RESSTATCONF_SEP_FIELD="TTY_NUMBER"
        
        # 【注意】
        # graph.confのTTY_FIELD_NAMEフィールドから、
        # sar -y 用デバイス名フィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="TTY_FIELD_NAME"
    ;;
    "${SET_TYPE_INTERRUPTS}")
        RESSTATCONF_SEP_FIELD="INTR_NUMBER"
        
        # 【注意】
        # graph.confのINTR_FIELD_NAMEフィールドから、
        # sar -I 用デバイス名フィールド名の取得
        GRAPHCONF_SEPNAME_FIELD="INTR_FIELD_NAME"
    ;;
    *)
        echo -e "Error : gnuplot_separator.sh : separator type miss [${SEP_TYPE}]"
    ;;
esac


# 分割項目の取得
GREP_TARGET=$(getParamFromConf "${RESSTATCONF_SEP_FIELD}")
CMDRET=$?
if [[ ${CMDRET} -ne 0 ]];then
    echo -e "Error : resstat.sh : call getParamFromConf \"${RESSTATCONF_SEP_FIELD}\""
    exit 4
fi

# 分割項目フィールド名の取得
SEPNAME_FIELD=$(getParamFromGraphConf "${GRAPHCONF_SEPNAME_FIELD}")
CMDRET=$?
if [[ ${CMDRET} -ne 0 ]];then
    echo -e "Error : resstat.sh : call getParamFromGraphConf \"${GRAPHCONF_SEPNAME_FIELD}\""
    exit 4
fi

# ソースファイル名称によって、all_header.confからの取得パラメータを分割。
case "${SOURCE##*/}" in
    "${SAR_DATA_PREFIX}"*."${SAR_DATA_SUFFIX}"*)
        AHCONF_PARAM="SAR"
        ;;
    "${MPSTAT_DATA_PREFIX}"*."${MPSTAT_DATA_SUFFIX}"*)
        AHCONF_PARAM="MPSTAT"
        ;;
    "${VMSTAT_DATA_PREFIX}"*."${VMSTAT_DATA_SUFFIX}"*)
        AHCONF_PARAM="VMSTAT"
        ;;
    "${IOSTAT_DATA_PREFIX}"*."${IOSTAT_DATA_SUFFIX}"*)
        AHCONF_PARAM="IOSTAT"
        ;;
    "${PIDSTAT_DATA_PREFIX}"*."${PIDSTAT_DATA_SUFFIX}"*)
        AHCONF_PARAM="PIDSTAT"
        ;;
esac


# 特殊処理：ヘッダ取得する前に、特別なケースへの対応を行う。
# ソースファイルから、「先頭#」を除く。行を削除するのではなく、#という文字のみ半角空白に変換する。
# これは、-h指定時に、ヘッダ行の先頭に余計な#が付くのを消すため。
# どうせ単語分割するんだから変換じゃなく消してもいいが、デバッグ時とかに中間ファイルを見る時見栄えが悪くて気持ち悪いので変換。
# gnuplot_normalでも実行するが、こちらでもヘッダを読むので変換が必要。
# このバグはマジでいい加減にしろ。
if [[ "${SOURCE##*/}" == "${PIDSTAT_DATA_PREFIX}"*."${PIDSTAT_DATA_SUFFIX}"* ]];then
    sed -e 's/^#/ /g' "${SOURCE}" > "${SOURCE_TMP}"
    mv -f "${SOURCE_TMP}" "${SOURCE}"
fi

# all_header.confからパラメータを取得。[ヘッダ行数],[グラフ化用項目ヘッダ行]。
ALLHEADER_CONTENTS=$(getParamFromAllHeaderConf ${AHCONF_PARAM})
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_separator.sh : call function getParamFromAllHeaderConf miss ret [${FUNC_RET}] \n[${ALLHEADER_CONTENTS}]"
    exit 4
fi

# ヘッダ行数を取得
HEADER_NUM=${ALLHEADER_CONTENTS%,*}
# グラフ化用項目ヘッダ行を取得
PARAMLINE_NUM=${ALLHEADER_CONTENTS#*,}

# ソースファイルのヘッダ行を取得
SOURCE_HEAD_CONTENTS=$(head -n ${HEADER_NUM} ${SOURCE})
# ソースファイルのヘッダ行からグラフ化項目ヘッダ行を取得
SOURCE_HEADER=$(getLines "${SOURCE_HEAD_CONTENTS}" ${PARAMLINE_NUM})
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_separator.sh : call function getLines miss ret [${FUNC_RET}] \n[${SOURCE_HEADER}]"
    exit 4
fi

# ソースファイルのヘッダから分割項目フィールド番号を取得
SEP_FIELD_NUM=$(getParamFieldsNum "${SOURCE_HEADER}" "${SEPNAME_FIELD}")
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_separator.sh : call function getParamFieldsNum miss ret [${FUNC_RET}] \n[${SEP_FIELD_NUM}]"
    exit 4
fi

# グラフターゲット分割。GREP_TARGETをカンマ区切りして、その各フィールドでgrepした単位を元に分割する。
for TARGET_FIELD in ${=${GREP_TARGET//,/ }}
do
    # 分割項目フィールド番号の内容が分割対象文字列である行を全て取得し、ヘッダと共にグラフ化対象ファイルに書き込む。
    echo -e "${SOURCE_HEAD_CONTENTS}" > "${SOURCE_TMP}"
    cat "${SOURCE}" | awk '{ if ( $'"${SEP_FIELD_NUM}"' == "'"${TARGET_FIELD}"'" ) {
                                               print $0;
                                             } 
                                           }' >> "${SOURCE_TMP}"
    
    # 分割した内容が存在しなければこのグラフ化はスキップする。
    if [[ ${HEADER_NUM} -eq $(cat "${SOURCE_TMP}" | wc -l) ]];then
        echo -e "Warning : gnuplot_separator.sh : this target field [${TARGET_FIELD}] contents is none. Skipping. ( for ${AHCONF_PARAM} )"
        rm -f "${SOURCE_TMP}"
        continue
    fi
    
    ##############################################################################
    # Normalタイプへ処理を投げる
    ##############################################################################
    # 【注意】
    # gnuplot_normal.shが認識する環境変数により、グラフ名称や出力ディレクトリを変える。
    # GRAPH_FILE_NAME_PREFIX：グラフファイル名
    # GRAPH_TITLE_NAME_PREFIX：グラフタイトル名
    # GRAPH_DIR_NAME_PREFIX：出力ディレクトリプレフィックス
    
    # グラフファイル名プレフィックス環境変数をセット。
    export GRAPH_FILE_NAME_PREFIX="${TARGET_FIELD}"
    # グラフタイトル名プレフィックス環境変数をセット。
    export GRAPH_TITLE_NAME_PREFIX="${SEPNAME_FIELD}_${TARGET_FIELD}"
    # 出力ディレクトリプレフィックス環境変数セット。
    export GRAPH_DIR_NAME_PREFIX="${TARGET_FIELD}"
    
    # NormalTypeグラフ作成起動
    ${GNUPLOT_NORMAL_SH} "${SOURCE_TMP}" "${GRAPH_CONF}" "${OUTPUT_DIR}"
    
    # 実行後、環境変数解除
    unset GRAPH_FILE_NAME_PREFIX
    unset GRAPH_TITLE_NAME_PREFIX
    unset GRAPH_DIR_NAME_PREFIX
    
    #一時ファイルの削除
    rm -f "${SOURCE_TMP}"
    
    # 【DEBUG】
#    mv "${SOURCE_TMP}" "${SOURCE_TMP}.${TARGET_FIELD}"
done

exit 0

