########################################
#
# common_def.sh
#
# [概要]
#    source読み込み用共通スクリプト。変数設定を行う。
#    resstat.confからSYSKBNを取得する部分のみ、zsh。
#
########################################

#########################################################
# 環境設定
#########################################################

# ロケール設定。LANGだとzshの4.3系ですらバグを起こす（子プロセスで設定したLANGがそのさらに子プロセスに引き継がれず、元の親を参照してしまう）
# LC_ALLならそのバグを回避出来るので、こちらを使う。（正直言ってやめたいが）
export LC_ALL=C

# /sbin、/usr/sbinにパスを通す。（念のため）
export PATH=${PATH}${PATH:+:}/sbin:/usr/sbin

#########################################################
# パス設定、ファイル名設定
#########################################################

# スクリプト格納ディレクトリ(絶対パス)
BIN_PWD=($(cd ${0%/*};pwd))
export BIN_DIR=${BIN_PWD}

# RESSTAT_HOMEディレクトリ
export BASE_DIR=${BIN_DIR%/*}

# プロセスIDファイル格納ディレクトリ
export PID_DIR="${BASE_DIR}/proc_id"

# アーカイブディレクトリ
export ARCHIVE_DIR="${BASE_DIR}/archive"

# コンフィグファイルディレクトリ
export CONF_DIR="${BASE_DIR}/conf"

# output圧縮ファイル格納ディレクトリ
export ARCHIVE_DIR="${BASE_DIR}/archive"

# 複数NODE起動用出力データ格納推奨領域
export ALLNODE_OUTPUT_DIR="${BASE_DIR}/output"

# 計測データ格納ディレクトリ
export DATA_DIR="${BASE_DIR}/data"

# 複数ノード一斉起動セットアップディレクトリ
export MULTISETUP_DIR="${BASE_DIR}/multisetup"

# 複数ノード一斉起動セットアップシェルスクリプトディレクトリ
export MULTISETUP_BIN="${MULTISETUP_DIR}/bin"

# ドキュメント格納ディレクトリ
export DOCUMENTS_DIR="${BASE_DIR}/documents"

# 独自関数ライブラリディレクトリ
export LIB_DIR="${BASE_DIR}/lib"

# 独自関数ライブラリ ソースディレクトリ
export LIB_SRC_DIR="${LIB_DIR}/src"



# プロセスIDファイル
export PID_FILE="${PID_DIR}/.proc_id"

# resstat共通コンフィグファイル
export CONF_FILE="${CONF_DIR}/resstat.conf"

# グラフ化用共通コンフィグファイル
export GRAPH_CONFFILE="${CONF_DIR}/graph.conf"

# SYSKBN対応表
export SYSKBN_CONFFILE="${CONF_DIR}/syskbn.conf"

# システム区分（resstat.confから取得する。【注意】シェバングは無いものの、zshでなければ不能）
# なぜか全体をダブルクォーティングすると取れなくなる。摩訶不思議。
export SYSKBN=${${${(M)${(@f)"$(<${CONF_FILE})"}:#SYSKBN*}#*[=]}##* }

# システム個別コンフィグディレクトリ
export GRAPH_CONF_DIR="${CONF_DIR}/${SYSKBN}"

# 実行ダンプ出力コマンド・グラフ化対象ファイル定義
export COMMAND_CONFFILE="${GRAPH_CONF_DIR}/command.conf"

# ステータスレポートコマンド用ヘッダ行数情報定義ファイル
export ALL_HEADER_CONFFILE="${GRAPH_CONF_DIR}/all_header.conf"

# ステータスレポートコマンド用フッタ行数情報定義ファイル
export ALL_FOOTER_CONFFILE="${GRAPH_CONF_DIR}/all_footer.conf"

# 出力ファイル格納ディレクトリ名プレフィックス
export OUTPUT_DIR_PREFIX="output"


# sadc計測ファイルプレフィックス
export SADC_DATA_PREFIX="sadc"
# sadc計測ファイルサフィックス
export SADC_DATA_SUFFIX="dmp"

# sar出力ファイルプレフィックス
export SAR_DATA_PREFIX="sar"
# sar出力ファイルサフィックス
export SAR_DATA_SUFFIX="out"

# mpstat 出力ファイルプレフィックス
export MPSTAT_DATA_PREFIX="mpstat"
# mpstat 出力ファイルサフィックス
export MPSTAT_DATA_SUFFIX="dmp"

# vmstat 出力プレフィックス
export VMSTAT_DATA_PREFIX="vmstat"
# vmstat 出力ファイルサフィックス
export VMSTAT_DATA_SUFFIX="dmp"

# iostat 出力プレフィックス
export IOSTAT_DATA_PREFIX="iostat"
# iostat 出力ファイルサフィックス
export IOSTAT_DATA_SUFFIX="dmp"

# pidstat 出力ファイルプレフィックス
export PIDSTAT_DATA_PREFIX="pidstat"
# pidstat 出力ファイルサフィックス
export PIDSTAT_DATA_SUFFIX="dmp"



# 日付定義ファイル名
export DATE_STAMP_FNAME="date_stamp.txt"
# 起動時間、起動回数、インターバル時間定義ファイル名
export TIME_STAMP_FNAME="time_stamp.txt"


# グラフ出力フォーマット共通設定ファイル
export GRAPH_COMMON_FILE="${GRAPH_CONF_DIR}/common.conf"

# グラフ参照HTML除外対象定義ファイル
export HTML_NOT_TARGET="${GRAPH_CONF_DIR}/html_exclude.conf"

# 複数ノード同時制御・ノード記述ファイル
export RESSTAT_TG_HOSTS="${CONF_DIR}/targethost"

# 計測項目説明HTML
export STATS_CONTENTS_HTML="${DOCUMENTS_DIR}/${SYSKBN}/status_contents.html"

# バージョン情報定義
export VERSION_TXT="${BASE_DIR}/VERSION"

# デフォルトSYSKBNシンボリックリンク名
export SYSKBN_SYMLINK_NAME="linux"

# グラフコンフィグディレクトリのシンボリックリンク
export SYMLINK_GRAPHCONF_DIR="${CONF_DIR}/${SYSKBN_SYMLINK_NAME}"

# ドキュメントディレクトリのシンボリックリンク
export SYMLINK_DOCUMENTS_DIR="${DOCUMENTS_DIR}/${SYSKBN_SYMLINK_NAME}"

# 独自関数ライブラリ コンパイル済みファイル
export COMPILE_COMPLETE_FILE="${LIB_DIR}/resstat_func_compiled"




#########################################################
# シェルスクリプト
#########################################################

# 計測起動管理シェル
export RESSTAT_SH="${BIN_DIR}/resstat.sh"

# データ集計シェル
export COLLECT_RESSTAT_SH="${BIN_DIR}/collect_resstat.sh"

# Normalタイプグラフ化シェル
export GNUPLOT_NORMAL_SH="${BIN_DIR}/gnuplot_normal.sh"

# Networkタイプグラフ化シェル
export GNUPLOT_SEPARATOR_SH="${BIN_DIR}/gnuplot_separator.sh"

# グラフ一括作成シェル
export DRAW_GRAPH_SH="${BIN_DIR}/draw_graph.sh"

# 日付スタンプシェル
export DATE_STAMP_SH="${BIN_DIR}/date_stamp.sh"

# resstatの実行結果に対するHTML作成シェル
export MAKE_HTML_SH="${BIN_DIR}/make_html.sh"



# resstat単独ダンプディレクトリ用、Windows閲覧用zip作成シェル
export GET_ARCHIVE_CLEAN_SH="${BIN_DIR}/getarchive_clean.sh"

# resstatリモートノードcollect実行シェルスクリプト
export NODE1COLLECT_SH="${BIN_DIR}/node1collect.sh"



# CPU/NICのグラフ化対象調整スクリプト。
export CONFIGURE_SH="${BIN_DIR}/configure.sh"


# resstatツール・コマンドラインインタフェースシェルスクリプト
export CTRLRESSTAT_SH="${BIN_DIR}/ctrlresstat.sh"

# resstatツール・複数ノード一斉起動コマンドラインインタフェースシェルスクリプト
export MULTICTRL_RESSTAT_SH="${BIN_DIR}/multictrl_resstat.sh"

# resstatツール・複数ノード一斉起動セットアップインタフェースシェルスクリプト
export MULTINODE_SETUP_SH="${MULTISETUP_BIN}/management_setup.sh"

# resstatツール・複数ノード一斉scpコマンド
export SCP_HOSTS_SH="${MULTISETUP_BIN}/scp_hosts.sh"


#########################################################
# PAGERプログラム
#########################################################
export PAGER="/usr/bin/less -RFX"
case "`uname`" in
    CYGWIN*) 
        export PAGER="/usr/bin/less -FX"
        ;;
esac


#########################################################
# その他共通定義
#########################################################

# ヘッダフィールド最小値（共通カラム数）
# gnuplot_normal.shに使用。
# 各グラフコンフィグにおける、固定設定項目のフィールド数。
# このフィールド数以降は各グラフコンフィグで自由に設定できる。
export HEADER_COLMIN_NUM=8

# multiplotヘッダ最小値（multiplot共通カラム数）
# gnuplot_normal.shに使用。
# 各グラフコンフィグにおける、mutiplot定義行の固定設定フィールド数。
# このフィールド数以降は各グラフコンフィグで自由に設定できる。
export MULTIHEADER_COLMIN_NUM=7

# 共通関数 compVersionの引数に指定する比較演算フラグ
# 等号比較
export COMPVERSION_EQUAL=0
# 大なり
export COMPVERSION_LARGE=1
# 小なり
export COMPVERSION_SMALL=2

# 100%積み上げ面グラフ有効/無効フラグ
export GRAPH_PATTERN_FILLEDCURVE=1

# バージョン/リリース情報
export RESSTAT_VERSION=$(awk -F ' *= *' '(NF > 0){if ($1 == "VERSION") { print $2; exit; } }' "${VERSION_TXT}")
export RESSTAT_AUTHOR=$(awk -F ' *= *' '(NF > 0){if ($1 == "AUTHOR") { print $2; exit; } }' "${VERSION_TXT}")
export RESSTAT_REPORT_TO=$(awk -F ' *= *' '(NF > 0){if ($1 == "REPORT_TO") { print $2; exit; } }' "${VERSION_TXT}")
export RESSTAT_LASTUPDATE=$(awk -F ' *= *' '(NF > 0){if ($1 == "LAST_UPDATE") { print $2; exit; } }' "${VERSION_TXT}")

#変数設定読み込み完了
export COMMON_DEF_ON=1




