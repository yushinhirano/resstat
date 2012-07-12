#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
UsageMsg(){
    echo -e "!!!!!ERROR!!!!\n"
    echo -e "Usage: sumgraph_network.sh summary_conf output_root source_dir1 source_dir2 source_dir3 .....\n"
}

########################################
# function Error_clean
########################################
#Error_clean() {
    # 割り込み時のシグナルハンドリング用（未実装）
    
#}


########################################
#
# bash/zshスクリプト
# sumgraph_network.sh
#
# [概要]
#    指定されたディレクトリの下階層からネットワーク情報ソース(sar_n_DEV.out)を全て抽出し、
#    コンフィグファイルに従ってインタフェースを合算したファイルを作成してグラフ化する。
#    サマリ対象は指定されたコンフィグを使い、グラフ化には通常のsar_n_DEV.outグラフ化用コンフィグを用いる。
#    当然ながら抽出したsar_n_DEV.outのフォーマットはどのファイルも完全一致でなければならない。
#
# [起動条件、仕様]
#    後付け的に足したスクリプト。ちょっと仕様が汚いのはご了承ください。
#
#    version0.2 :: もう使う機会が無いと思われるので、version0.2への移行時にキレイにしません。動くだけで充分でしょう。
#
# [引数]
#   sumgraph_network.sh summary_conf output_root source_dir1 source_dir2 source_dir3 .....
#
########################################

#非シグナルハンドリング

########################################
# コマンドラインオプションチェック（1st、2nd、3rd Option必須）
if [[ -z "$1" || -z "$2" || -z "$3" ]];then
    UsageMsg
    exit 4
fi

# 1st Option：サマリ用コンフィグ（内容のチェックはここではしない）
if [[ ! -s "$1" ]];then
    UsageMsg
    exit 4
fi
SUMMARY_CONF="$1"

# 2nd Option：出力ディレクトリ
if [[ -e "$2" ]];then
    if [[ ! -d "$2" ]];then
       echo -e "Error : sumgraph_network.sh : this output directory [$2] , already used for other file name"
       exit 4
    fi
else
    mkdir -p -m 0777 "$2"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : sumgraph_network.sh : make directory output miss [$2]"
        exit 4
    fi
fi
OUTPUT_DIR="$2"

# 出力一時領域を作成しておく。(エラー無視)
OUTPUT_DIR_TMP="${OUTPUT_DIR}/tmp"
rm -rf "${OUTPUT_DIR_TMP}"
mkdir -m 0777 "${OUTPUT_DIR_TMP}"

# 以降の引数を全て抽出対象ターゲットディレクトリとする。
shift 2
TARGET_DIRS=($*)

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

# gnuplot作成元ファイル
SUM_DMP_SOURCE="${OUTPUT_DIR}/${SAR_DATA_PREFIX}_n_DEV.${SAR_DATA_SUFFIX}"

##############################################################################
# サマリ用コンフィグから内容抽出（1stField：対象ノード|ALL、2ndField：IFACE,IFACE,IFACE ....）
##############################################################################
CONFCNT=1
CONF_NODES_CNT=1
CONF_IFACE_CNT=1
unset CONF_NODES
unset CONF_IFACES
CONF_CONTENTS=$(sed -e 's/^  *//g' "${SUMMARY_CONF}" | awk '(/^[^#]/){ print $0; }')

LINECNT=$(echo -e "${CONF_CONTENTS}" | wc -l)
while [[ ${CONFCNT} -le ${LINECNT} ]]
do
    CONF_LINE=$(echo -e "${CONF_CONTENTS}" | awk '( NR == '${CONFCNT}' ){print $0;exit 0;}')
    # 第一フィールド取得
    NODE_BUFF=$(echo "${CONF_LINE}" | awk '{print $1}')
    CONF_NODES[${CONF_NODES_CNT}]="${NODE_BUFF}"
    CONF_NODES_CNT=$(( CONF_NODES_CNT + 1 ))
    
    # 第二フィールド取得
    IFACE_BUFF=$(echo "${CONF_LINE}" | awk '{print $2}')
    CONF_IFACES[${CONF_IFACE_CNT}]="${IFACE_BUFF}"
    CONF_IFACE_CNT=$(( CONF_IFACE_CNT + 1 ))
    
    CONFCNT=$(( CONFCNT + 1 ))
done

CONF_NODES_MAX=$(( CONF_NODES_CNT - 1 ))
CONF_IFACES_MAX=$(( CONF_IFACE_CNT - 1 ))


##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "ノード名配列[${CONF_NODES_MAX}]:"
#echo ${CONF_NODES[*]}
#echo "インタフェース名配列[${CONF_IFACES_MAX}]"
#echo ${CONF_IFACES[*]}
#echo -e "\n"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


##############################################################################
# ソース抽出ディレクトリから対象ファイルを取得し、サマリ対象データを抽出する。
##############################################################################
# sar n DEV出力のネットワークインタフェースフィールドを取得
SEPNAME_FIELD=$(getParamFromGraphConf "NET_IFACE_FIELD_NAME")

# sar_n_DEV.outを抽出する。
SOURCE_DMPS=$(find ${TARGET_DIRS[*]} -name "${SAR_DATA_PREFIX}_n_DEV.${SAR_DATA_SUFFIX}")


SOURCE_CNT=1
LINECNT=$(echo -e "${SOURCE_DMPS}" | wc -l)
SUM_SOURCE_CNT=1

while [[ ${SOURCE_CNT} -le ${LINECNT} ]]
do
    SOURCE_PATH=$(echo -e "${SOURCE_DMPS}" | awk '( NR == '${SOURCE_CNT}' ){print $0;exit 0;}')
    

##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D1:SOURCE_PATH:${SOURCE_PATH}"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


    # ソースファイルの先頭３行を取得
    SOURCE_HEAD_CONTENTS=$(cat "${SOURCE_PATH}" | head -n 3)
    # ソースファイルの先頭から3行目を取得
    SOURCE_HEADER=$(echo -e "${SOURCE_HEAD_CONTENTS}" | tail -n 1)
    # ソースファイルのヘッダから分割項目フィールド番号を取得
    SEP_FIELD_NUM=$(getParamFieldsNum "${SOURCE_HEADER}" "${SEPNAME_FIELD}")
    
    # ソースファイルの先頭行から起動したNODEを取得。
    SOURCE_NODE_NAME=$(head -1 "${SOURCE_PATH}" | sed -e 's/.*(//g' -e 's/).*//g')

##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D2:SOURCE_NODE_NAME:${SOURCE_NODE_NAME}"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    
    # ソース１ファイルに対しコンフィグの内容を全捜査
    CONFCNT=1
    while [[ ${CONFCNT} -le ${CONF_NODES_MAX} ]]
    do
        # 対象Nodeを取得
        TARGET_NODE="${CONF_NODES[${CONFCNT}]}"
        
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D3:TARGET_NODE:${TARGET_NODE}"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


        # TARGETがALLの場合(ALLというホスト名のつもりだったら君の頭の中を疑う(笑))、
        # 又はターゲットNODEと起動NODEが一致する場合
        if [[ ${TARGET_NODE} == "ALL" || "${SOURCE_NODE_NAME}" == "${TARGET_NODE}" ]];then

##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D4:SOURCE_NODE_NAME:HIT! OR ALL"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

            # 対象インタフェース取得
            TARGET_IFACE="${CONF_IFACES[${CONFCNT}]}"
            
            # 対象インタフェース分解
            # フィールド数取得
            LINE_FIELD_CNT=$(echo "${TARGET_IFACE}" | awk -F ',' '{print NF}')
            IFACECNT=1

##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D5:TARGET_IFACE:${TARGET_IFACE}"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


            # 第一フィールド以降を取得しつつgrepして出力一時ディレクトリへ。
            while [[ ${IFACECNT} -le ${LINE_FIELD_CNT} ]]
            do
                GREP_IFACE=$(echo -e "${TARGET_IFACE}" | awk -F ',' '{print $'${IFACECNT}';}')
                
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D6:GREP_IFACE:${GREP_IFACE}"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                
                # 分割項目フィールド番号の内容が分割対象文字列である行を全て取得する。
                SOURCE_GREP=$(cat ${SOURCE_PATH} | awk '{ if ( $'"${SEP_FIELD_NUM}"' == "'"${GREP_IFACE}"'" ) {
                                                              print $0;
                                                          }
                                                        }')
                # 取得内容が存在する場合のみ一時ファイル出力
                if [[ -n "${SOURCE_GREP}" ]];then
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "D7:SOURCE_GREP:HIT!!"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                    SOURCE_TMP="${OUTPUT_DIR_TMP}/${SUM_SOURCE_CNT}_${SOURCE_PATH##*/}"
                    SUM_SOURCE_CNT=$(( SUM_SOURCE_CNT + 1 ))
                    echo -e "${SOURCE_HEAD_CONTENTS}\n${SOURCE_GREP}" > "${SOURCE_TMP}"
                fi
                IFACECNT=$(( IFACECNT + 1 ))
            done
        fi
        CONFCNT=$(( CONFCNT + 1 ))
    done
    
    SOURCE_CNT=$(( SOURCE_CNT + 1 ))
done




##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "SUM対象ファイル数[${SUM_SOURCE_CNT}]:"
#echo -e "\n"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



##############################################################################
# 取得したデータの合算
##############################################################################
# 一時領域のターゲットファイルパスを取得
# （ls *は危ういのでfindを使う）
SUM_TARGETS=$(find "${OUTPUT_DIR_TMP}" -type f)

##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "合算対象ファイル:"
#echo ${SUM_TARGETS[*]}
#echo -e "\n"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


# SUM_TARGETSの最初のパスを正として合算対象フィールドを取得する。
# 1行目取得
MAIN_SUM_TARGET=$(echo -e "${SUM_TARGETS}" | head -n 1)

# ヘッダ3行を省く。
SOURCE_HEAD_CONTENTS=$(cat "${MAIN_SUM_TARGET}" | head -n 3)
# 3行目を取得
SOURCE_HEADER=$(echo -e "${SOURCE_HEAD_CONTENTS}" | tail -n 1)

# ソースファイルのヘッダから分割項目フィールド番号を取得
SEP_FIELD_NUM=$(getParamFieldsNum "${SOURCE_HEADER}" "${SEPNAME_FIELD}")

# 時間項目フィールドを取得（Normal グラフ設定用を拝借）
TIME_FIELD_NUM=$(getParamFromGraphConf "TIME_FIELD")

# 合算フィールド数を取得
SUM_T_FIELDS_MAX=$(echo -e "${SOURCE_HEADER}" | awk '{print NF}')

# 合算対象行数を取得（全ファイルの中で行数が最も小さいものを採用する）
SUM_T_CNT=1
SUM_T_MAX=$(echo -e "${SUM_TARGETS}" | wc -l)
SUM_T_MINLINE=""
while [[ ${SUM_T_CNT} -le ${SUM_T_MAX} ]]
do
    SOURCE_PATH=$(echo -e "${SUM_TARGETS}" | awk '( NR == '${SUM_T_CNT}' ){print $0;exit 0;}')
    
    # 行数取得
    LINE_NUM_BUFF=$(cat "${SOURCE_PATH}" | wc -l )
    
    # 最小行数との比較
    if [[ -z "${SUM_T_MINLINE}" ]];then
        SUM_T_MINLINE="${LINE_NUM_BUFF}"
    elif [[ ${LINE_NUM_BUFF} -lt ${SUM_T_MINLINE} ]];then
        SUM_T_MINLINE="${LINE_NUM_BUFF}"
    fi
    
    SUM_T_CNT=$(( SUM_T_CNT + 1 ))
done


##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "時間フィールド:${TIME_FIELD_NUM}"
#echo "分割フィールド:${SEP_FIELD_NUM}"
#echo "全体フィールド:${SUM_T_FIELDS_MAX}"
#echo "最終行:${SUM_T_MINLINE}"
#echo -e "\n"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


# 合算開始（データ量によってはかなりの時間を要すると思われる。awkは複数ファイルを並行して扱うのが苦手だ……）
# 最初にヘッダ３行を出力しておく。
echo -e "${SOURCE_HEAD_CONTENTS}" > "${SUM_DMP_SOURCE}"
# ターゲットは４行目から
LINE_T_CNT=4
while [[ ${LINE_T_CNT} -lt ${SUM_T_MINLINE} ]]
do
    
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ -- DEBUG
#echo "実行行:${LINE_T_CNT}"
#echo -e "\n"
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    # 各行に対して各ファイル内の値を合算していく。
    
    # 各ファイルの指定行を全取得して配列へ
    unset FILE_LINE_CONTS
    FILE_LINE_CNT=1
    SUM_T_CNT=1
    while [[ ${SUM_T_CNT} -le ${SUM_T_MAX} ]]
    do
        SOURCE_PATH=$(echo -e "${SUM_TARGETS}" | awk '( NR == '${SUM_T_CNT}' ){print $0;exit 0;}')
        
        # ソースから指定行を取得
        FILE_LINE_CONTS[${FILE_LINE_CNT}]=$(awk '( NR == '${LINE_T_CNT}' ){print $0;exit 0;}' "${SOURCE_PATH}")
        
        FILE_LINE_CNT=$(( FILE_LINE_CNT + 1 ))
        SUM_T_CNT=$(( SUM_T_CNT + 1 ))
    done
    
    BUFF_LINE=""
    # フィールド数でループ
    FIELD_CNT=1
    while [[ ${FIELD_CNT} -le ${SUM_T_FIELDS_MAX} ]]
    do
        if [[ ${FIELD_CNT} -eq ${SEP_FIELD_NUM} || ${FIELD_CNT} -eq ${TIME_FIELD_NUM} ]];then
            # 分割フィールド（IFACE）、または時間フィールドなら最初のファイルをそのまま出力
            FIELD_BUFF=$(echo -e "${FILE_LINE_CONTS[1]}" | awk '{print $'${FIELD_CNT}'}')
            BUFF_LINE="${BUFF_LINE}${BUFF_LINE:+ }${FIELD_BUFF}"
        else
            # 各行同一フィールドを合算
            SUM_BUFF=0
            BC_SCRIPT="scale=2;0 "
            for LINE in ${FILE_LINE_CONTS[*]}
            do
                FIELD_BUFF=$(echo -e "${LINE}" | awk '{print $'${FIELD_CNT}'}')
                # 算術式展開で小数点を受け入れるのはzshのみであり、そのzshもまだ小数点演算にはバグがある。
                # ここの足し込みにはbc（電卓コマンド）を使う。有効数字は２ケタ。
                #SUM_BUFF=$(( ${SUM_BUFF} + ${FIELD_BUFF} ))
                BC_SCRIPT="${BC_SCRIPT} + ${FIELD_BUFF}"
            done
            
            SUM_BUFF=$( echo "${BC_SCRIPT}" | bc )
            
            BUFF_LINE="${BUFF_LINE}${BUFF_LINE:+ }${SUM_BUFF}"
        fi
        
        FIELD_CNT=$(( FIELD_CNT + 1 ))
    done
    
    # １行出力
    echo -e "${BUFF_LINE}" >> "${SUM_DMP_SOURCE}"

    LINE_T_CNT=$(( LINE_T_CNT + 1 ))
done

# タイムスタンプファイルがあればコピーする。
DATE_STAMP_TARGET=$(find ${TARGET_DIRS[1]} -name "${DATE_STAMP_FNAME}" | head -n 1)
if [[ -n "${DATE_STAMP_TARGET}" ]];then
    cp -p "${DATE_STAMP_TARGET}" "${OUTPUT_DIR}/"
fi


##############################################################################
# gnuplotスクリプト起動
##############################################################################
${GNUPLOT_NORMAL_SH} "${SUM_DMP_SOURCE}" "${GRAPH_CONF_DIR}/sar_n_DEV.conf" "${OUTPUT_DIR}"

##############################################################################
# 一時ディレクトリ・一時ファイル削除
##############################################################################
rm -rf "${OUTPUT_DIR_TMP}"
rm -f "${SUM_DMP_SOURCE}"
rm -f "${OUTPUT_DIR}/${DATE_STAMP_FNAME}"

exit 0

