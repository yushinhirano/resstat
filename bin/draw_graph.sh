#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : draw_graph.sh
	        
	        draw_graph.sh target_dir outputroot_dir filename1 filename2 filename3 .....
	        draw_graph.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: draw_graph.sh [m  -- グラフ作成統合スクリプト
	
	       draw_graph.sh target_dir outputroot_dir filename1 filename2 filename3 .....
	       draw_graph.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1mtarget_dir[m : targetfile1 targetfile2 targetfile3 ..... で指定するファイル群の
	                    レポートダンプファイルを格納しているディレクトリ
	       
	       [35;1moutputroot_dir[m : グラフ出力先ルートディレクトリ
	       
	       [35;1mfilename1 filename2 filename3 .....[m : [35;1mtarget_dir[mに格納されている、
	                                             グラフ化対象のレポートコマンドダンプファイル名
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       指定されたファイルを元に、グラフ作成スクリプトである
	       [32;1mgnuplot_normal.shとgnuplot_separator.sh[mを呼び出して
	       グラフ出力を促すためのスクリプト。
	       
	       このスクリプトの責任範囲は、[32;1mnormalタイプなのかseparatorタイプなのかを判断して[m
	       どちらのスクリプトを呼ぶかを判断することと、
	       指定されたファイル名を元に、
	       [32;1mconf/{システム区分}/ディレクトリ内からグラフ化コンフィグファイルを検索して[m、
	       グラフ化可能な形で次のスクリプトを呼ぶことである。
	       タイプ判断不能な場合や、グラフ化コンフィグファイルが存在しない場合には、
	       そのファイルのグラフ化をスキップする。
	       
	       出力ディレクトリは引数で指定してスクリプトで作成するが、
	       既に存在していた場合にはそのディレクトリをそのまま使用する。
	       
	       ・conf/{システム区分}/ディレクトリのグラフ化コンフィグ検索
	         [35;1mfilenameN[mに引数で指定されたファイル名を元に行う。
	         先頭がsarで始まる形式の場合、{ファイル名%.*}.confで、
	         拡張子以降を抜いてconfを付けたファイルとしている。
	         
	         ※半角ピリオドはハードコーディングである。
	           collect_resstat.shでsar_{オプション}.outというファイルで出力されていることが前提で、
	           検索されるファイル名はconf/{システム区分}/sar_{オプション}.confとなる。
	           （{オプション}が大文字の場合にはsar__{オプション}.conf）
	       
	         先頭がsarでない形式の場合、{ファイル名%%_*}.confで、
	         最初のアンダースコア以降を抜いてconfを付加したファイルとしている。
	         ※アンダースコアはハードコーディングである。
	           resstat.shで{コマンド名}_{ホスト名}_{日付}.dmpというファイル名で
	           出力されていることが前提で、
	           検索されるファイル名はconf/{システム区分}/{コマンド名}.confとなる。
	       
	       ・タイプ判断
	         グラフ化コンフィグファイルから、[No.]カラムが[0]の行をヘッダ行として取得し、
	         その第二フィールドが"normal"か"separator:{sep_type}"かを判断する。
	         "separator"の場合、その{sep_type}値もgnuplot_separator.shの引数に送る。
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．ファイル名の整合性[m
	           Overviewの通り、sarのファイル名形式のピリオドや、mpstatダンプなどのアンダースコア、
	           また各ダンプファイル名とconf/{システム区分}/ディレクトリ内のコンフィグは
	           密接に結びついている。
	           これらの出力フォーマットを変更するのは要注意である。
	           mpstat、vmstat、iostat系はresstat.shのファイル出力形式を、
	           sar系はcollect_resstat.shのファイル出力形式を参照し、
	           かついずれもconf/{システム区分}/ディレクトリ内のコンフィグファイル名と
	           同期が取れているかを確認する必要がある。
	
	
	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/{SYSKBN}/sar_*.conf
	        ・conf/{SYSKBN}/mpstat.conf
	        ・conf/{SYSKBN}/vmstat.conf
	        ・conf/{SYSKBN}/iostat.conf
	        ・conf/{SYSKBN}/pidstat-*.conf
	        ・conf/resstat.conf
	
	
	[36;1m[Related Parameters] : [m
	        
	        [35;4;1mresstat.conf[m
	            ・AUTO_CONFIG
	
	
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
# draw_graph.sh
#
# [概要]
#    指定されたファイルに対し、パフォーマンス計測データを集計してグラフ化する。
#    グラフ化の実行にはファイル名に応じたconfigファイルが必要です。
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
# コマンドライン引数チェック（1st、2nd、3rd Args必須）
if [[ -z "$1" || -z "$2" || -z "$3" ]];then
    UsageMsg
    exit 4
fi

if [[ ! -d "$1" ]];then
    UsageMsg
    exit 4
fi

TARGET_DIR="${1%/}"

if [[ -e "$2" ]];then
    if [[ ! -d "$2" ]];then
       echo -e "Error : draw_graph.sh : this output directory [$2] , already used for other file name"
       exit 4
   fi
else
    mkdir -m 0777 "$2"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : draw_graph.sh : make directory output miss [$2]"
        exit 4
    fi
fi
OUTPUT_DIR="${2%/}"
shift 2
TARGET_FILES=($*)


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

##############################################################################
# 処理の実行
##############################################################################
for DMPFILE in ${TARGET_FILES[*]}
do
    SOURCE="${TARGET_DIR}/${DMPFILE}"
    
    # 【注意】conf/プラットフォーム に存在するグラフ化用コンフィグは、【コマンド名】.confでなければならない。これが制約。
    #         sarだけは、sar*.confで受け取る。
    #         他のファイルは、コマンド名_・・・.・・・であればよい。
    #         後方最長一致で_*を消しているから。
    #         これらのダンプの作成は、sarはcollect_resstat.sh、その他はresstat.shで行っている。
    
    # グラフ作成用Confファイル取得
    if [[ "${DMPFILE}" == "${SAR_DATA_PREFIX}"* ]];then
        # sar形式
        GRAPH_CONF="${GRAPH_CONF_DIR}/${DMPFILE%.*}.conf"
    else 
        # それ以外
        GRAPH_CONF="${GRAPH_CONF_DIR}/${DMPFILE%%_*}.conf"
    fi
    # グラフ化元ファイルチェック
    if [[ ! -s "${SOURCE}" || ! -r "${SOURCE}" ]];then
        echo -e "Warn : draw_graph.sh : this source file is not readable. skipping. [${SOURCE}]"
        continue
    fi

    # グラフ化コンフィグファイルチェック
    if [[ ! -s "${GRAPH_CONF}" || ! -r "${GRAPH_CONF}" ]];then
        echo -e "Warn : draw_graph.sh : this conf file is not readable. skipping. [${GRAPH_CONF}]"
        continue
    fi

    # 【注意】
    # ヘッダ行(行No.0)からグラフ作成タイプを取得
    # 空行と先頭#の行、及び空白#の連続行を回避。confでいうところの[No.]カラムが[0]の行をヘッダとみなす。
    # 尚、ここはさすがにawkに頼った方がいい。シェルビルトインだけでは、N番目のフィールド取得とそのレコードの判定を同時には出来ずに煩わしいからだ。
    # (やろうと思ったら全行取り込み＆配列セットし、各値を単語分割してそのN番目のカラムを判定するということになるが、awk一回の方がすっきりする。……珍しく)
    GNUPLOT_TYPE=$(sed -e 's/^  *//g' ${GRAPH_CONF} | awk '(/^[^#]/){ if ( $0 != "" && $1 != "" ){
                                                                        if ( $1 == 0 ){
                                                                            print $2;
                                                                            exit;
                                                                        }
                                                                      }
                                                                    }')

    # タイプに応じてグラフ作成シェルを起動
    # 【注意】サポートしているタイプは、[normal]と[separator]
    #  ただし、[separator]の場合、[separator:分割タイプ名]というフォーマットであること。
    #  [分割タイプ名]は現在[cpu]と[network]に対応しており、gnuplot_separator.shに引数として渡して適切な処置が取られる。
    
    if [[ ${GNUPLOT_TYPE} == "normal" ]];then
         ${GNUPLOT_NORMAL_SH} "${SOURCE}" "${GRAPH_CONF}" ${OUTPUT_DIR}
    elif [[ ${GNUPLOT_TYPE} == "separator"* ]];then
         ${GNUPLOT_SEPARATOR_SH} "${SOURCE}" "${GRAPH_CONF}" ${OUTPUT_DIR} "${GNUPLOT_TYPE#*:}"
    else
        echo -e "Error : draw_graph.sh : this type is not supported [${GNUPLOT_TYPE}]"
        exit 4
    fi

done

exit 0

