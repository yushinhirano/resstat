#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : date_stamp.sh
	        
	        date_stamp.sh interval_sec freq_num total_time(minutes) output_dir
	        date_stamp.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: date_stamp.sh [m  -- 実行日付と時間、及び起動回数の記録
	
	       date_stamp.sh interval_sec freq_num total_time(minutes) output_dir
	       date_stamp.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1minterval_sec[m : パフォーマンスレポート起動間隔（秒）
	       
	       [35;1mfreq_num[m : パフォーマンスレポート起動回数
	       
	       [35;1mtotal_time(minutes)[m : パフォーマンスレポート起動時間（分）
	       
	       [35;1moutput_dir[m : 日付、時間、起動回数情報の出力ディレクトリ
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       現在日時、起動間隔、起動回数情報を、
	       time_stamp.txtというファイル名でテキスト出力する。
	       格納ディレクトリは引数で指定する。
	       フォーマットは以下の通り。（1行のみ）
	       [現在日時(YYYY/MM/DD HH24:MI:SS)] [起動間隔] [起動回数]
	       
	       また、現在日時と起動時間から算出した、「跨ぐ可能性のある日付」を、
	       date_stamp.txtというファイル名でテキスト出力する。
	       フォーマットは、YYYY/MM/DD形式で1行に1日ずつ出力していく。
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．呼び出し元と使用先[m
	           このスクリプトはresstat.shの起動時に自動的に呼び出される。
	           ユーザが自ら実行しなくともよい。
	           出力された起動情報は、gnuplot_normal.shで使用されている。
	           出力フォーマットを修正する際はこのスクリプトとの整合性を取る必要がある。
	
	
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
# date_stamp.sh
#
# [概要]
#    指定された時間（単位：分）を元に、現在時刻から指定時間の間に変わりうる日付を順にdate_stamp.txtに出力する。
#    また、指定されたインターバル秒数と起動回数、さらに現在時刻を半角スペースで区切ってtime_stamp.txtに出力する。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
########################################

#非エラーハンドリング

#非シグナルハンドリング

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
# コマンドライン引数チェック（1st Args、2nd Args、3rd Args、4th Args必須）
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4"  ]];then
    UsageMsg
    exit 4
fi

INTERVAL_SEC="$1"

FREQ="$2"

TOTAL_TIME="$3"

if [[ -e "$4" ]];then
    if [[ ! -d "$4" ]];then
       echo -e "Error : date_stamp.sh : this output directory [$4] , already used for other file name"
       exit 4
   fi
else
    mkdir -m 0777 "$4"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : date_stamp.sh : make directory output miss [$4]"
        exit 4
    fi
fi
OUTPUT_DIR="${4%/}"


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

########################################
# 現在日付、インターバル時間、起動回数の出力
########################################
# 【注意】
# gnuplot_normal.shに出力フォーマットが直接関わっている。修正時にはそちらも同期を取ること。
echo $(date "+%Y/%m/%d %H:%M:%S") ${INTERVAL_SEC} ${FREQ} > "${OUTPUT_DIR}/${TIME_STAMP_FNAME}"

########################################
# 必要な日付の出力
########################################
# 実行日付取得
TODAYS_DATE=$(date "+%Y/%m/%d")

# 可能性のある日数を取得
DATE_RANGE=$(( ( TOTAL_TIME / 1440 ) + 1 ))

# 現在の日時から指定日数分まで先の日付をテキストファイルに出力する。
CNT=0
while [[ ${CNT} -le ${DATE_RANGE} ]]
do
    date -d "${CNT}"' days' "+%Y/%m/%d" >> "${OUTPUT_DIR}/${DATE_STAMP_FNAME}"
    CNT=$(( CNT + 1 ))
done

exit 0

