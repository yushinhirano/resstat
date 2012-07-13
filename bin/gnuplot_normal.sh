#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : gnuplot_normal.sh
	        
	        gnuplot_normal.sh sourcefile configfile outputroot_dir
	        gnuplot_normal.sh [ [34;1m-h[m ]
	        
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
	
	
	[36;1mUsage: gnuplot_normal.sh [m  -- 通常型グラフ作成スクリプト
	
	       gnuplot_normal.sh sourcefile configfile outputroot_dir
	       gnuplot_normal.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1msourcefile[m : グラフ化対象ファイル
	       
	       [35;1mconfigfile[m : [35;1msourcefile[mをグラフ化するためのコンフィグファイル
	       
	       [35;1moutputroot_dir[m : グラフ出力先ルートディレクトリ
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       指定されたグラフ化対象ファイルとグラフ化コンフィグファイルを元に、
	       gnuplotコマンドでグラフ画像を作成する。
	       画像の出力形式はpng形式。
	       ヘッダ/フッタを除く、グラフ化対象ファイルのデータ行全てをグラフにする。

	       このスクリプトは基本的にそれ以上のことを行わないが、
	       それでもこのツール内ではやや大きめである。
	       以下に概略と注意を示す。
	       
	       [35;1m１．通常グラフ化コンフィグヘッダ行取得[m
	           指定されているグラフ化コンフィグファイルから、
	           [34;1m「No.」カラムが「0」[mの行を取得する。
	           これがヘッダ行となり、このフィールド数を
	           全体のフィールドフォーマットの基準とする。
	           また、「No.」が0以外の行を、通常実行データ行として取得しておく。
	           
	           基本的には、conf/{SYSKBN}/内のconfファイルを指定すればよい。
	       
	       [35;1m２．通常実行ヘッダ解析[m
	           HEADER_COLMIN_NUM環境変数（common_def.sh参照）の値を
	           「共通パラメータフィールド数」として取得する。
	           全グラフに共通として必要なパラメータの個数である。
	           この数は最低限グラフ化コンフィグに存在していなければならない。
	           共通フィールドは「No.」「type」がフィールド固定（第一、第二）、
	           以降、「column」「directory」「fname」「title」「size」「ti」が必要である。
	           （フィールドはコンフィグによって順不同）
	           
	           共通フィールドより先のフィールドは、コンフィグ毎に自由に決められる。
	           それぞれ、ヘッダの行のフィールド名がgnuplotにおける[set]のパラメータ名であり、
	           通常の行はその設定値となる。
	           [34;1mここが「NONE」という値の場合、その行におけるsetコマンドは行われない。[m
	           各行のフォーマットを合わせる必要があるので、ある行にのみsetを行う場合には、
	           他の行はNONEとしておくこと。
	           
	           conf/{SYSKBN}/common.confからlinewidthパラメータを取得し、
	           線の太さを決定する。
	           この時、gnuplotバージョンが4.1系以下なら、
	           取得した太さに+1を行っている。
	           これは、4.1で実験した際に推奨の値である「2」が、
	           「1」の場合と同じであったため。
	           4.4.3で実験した際には「2」で上手く行っていた。
	       
	       [35;1m３．multiplotヘッダ解析[m
	           グラフ化コンフィグファイルに、「No.」カラムが「multi0」の行がある場合、
	           マルチプロット実行対象となる。
	           その行をマルチプロットヘッダ行として取得する。
	           この行をマルチプロットフィールドフォーマットの基準とする。
	           
	           また、MULTIHEADER_FIELDS_NUM環境変数（common_def.sh）の値を
	           「マルチプロット共通パラメータフィールド数」として取得する。
	           通常グラフ化同様、マルチプロット共通のカラム数である。
	           この共通フィールドは、「No.」がフィールド固定（第一）、
	           以降、「layout」「size」「directory」「target」「fname」「title」が必要である。
	           （フィールドはコンフィグによって順不同）
	           共通フィールド以降の扱いは通常グラフ化と同様である。
	       
	       [35;1m４．ヘッダの調整[m
	           グラフ化対象ソースファイルの名称から、
	           実行コマンドが「sar」「mpstat」「vmstat」「iostat」「pidstat」のいずれかであるかを判定し、
	           conf/{SYSKBN}/all_header.confから、[ヘッダ行数],[グラフ化用項目ヘッダ行]を取得する。
	           同じくconf/{SYSKBN}/all_footer.confから、[フッタ行数],[フッタ判定先頭行名]を取得する。
	           ここで、グラフ化対象ソースファイルから、ヘッダ行とフッタ行を削除し、
	           また、グラフ化用項目ヘッダ行を取得しておく。
	           フッタ行の削除は、フッタ先頭行の第一カラムが[フッタ判定先頭行名]と一致した場合にしか行わない。
	           これは、フッタ行はステータスレポートがシグナルなどにより強制終了された場合は
	           出力されないことがあるからである。
	       
	       [35;1m５．時間フィールドの作成[m
	           グラフ化に当たって、全てのデータファイルで第一フィールドを時間フィールドとしてX軸に設定して扱う。
	           しかし、元のデータファイルは、時間フィールドに日付が含まれていない、
	           そもそも時間フィールドが無い、という状態なので、
	           このスクリプトで時間フィールドを連結する。
	           時間フィールドの生成には、開始時間、インターバル時間、生成回数が必要だが、
	           これはresstat.sh起動時に[34;1mdate_stamp.shで生成されているテキストファイル[mが
	           存在すると見越して、そこから取得している。
	           
	           生成方法としては、sar、mpstat、pidstat形式（sysstatバージョン8.1.5まで）は
	           時間フィールドだけ存在して日付がないので、
	           日付のみを第一フィールドに追加し、
	           vmstat、iostat、pidstat形式（sysstatバージョン8.1.6以降）は
	           日付と時間をアンダースコアで連結して第一フィールドに追加している。
	       
	       [35;1m６．時間フィールド関連値の取得[m
	           conf/graph.confから、時間フィールド番号（1固定）をTIME_FIELDから、
	           入力日付フォーマットをINPUT_DATE_FORMATから、入力時間フォーマットをINPUT_TIME_FORMATから、
	           また、出力時間フォーマットをOUTPUT_TIME_FORMATから取得する。
	       
	       [35;1m７．マルチプロットターゲットの実行[m
	           マルチプロットデータ行の「target」カラムは、半角カンマ区切りで番号が指定されている。
	           その番号が通常データ行の「No.」値となり、指定された全ての通常行を
	           一斉にgnuplotコマンドでmultiplotをセットして投入する。
	           この時、通常行の「size」「fname」「directory」はマルチプロットデータ行で上書きされる。
	       
	       [35;1m８．通常グラフ化ターゲットの実行[m
	           マルチプロットが行われなかった通常データ行について、通常gnuplotターゲットとして実行する。
	           [34;1mこの時、「type」カラム値が「1」のものは1行1gnuplotとして1つのグラフ画像になり、[m
	           [34;1m「2」以上の値の場合、同じ値を持つ行は一つのグラフに纏めて複数の線で描かれる。[m
	           [34;1mさらに、「fl」で始まる値の場合、同じ値を持つ行を積み上げ面グラフで描画する。[m
	           （この場合、「ti（凡例）」以外のset項目は、最上段の行で設定される）
	           
	           出力ファイルは、引数指定のルートディレクトリに、「directory」カラム値のディレクトリを作り、
	           「fname」カラムのファイル名で作成される。
	           また、[34;1m「column」値[mが、グラフ化対象ファイルの[34;1m[グラフ化用項目ヘッダ行]に存在するヘッダの値[mと
	           一致していなければならない。
	       
	       [35;1mEX1．gnuplotコマンド[m
	             conf/graph.confのGNUPLOT_CMDパラメータからgnuplotの実行パスを取得する。
	             このパラメータから実行可能なコマンドが見つからなければ、
	             環境変数PATH上で発見されるgnuplotを使用する。
	             
	             また、最終的に使用されるgnuplotのバージョンが4.2以上でなければ、
	             このパッケージにおけるマルチプロットは不能であるため、
	             マルチプロットは使用せず全て通常の1グラフ1画像で出力する。
	             及び、100%積み上げ面グラフ出力を行わず、通常の折れ線グラフで処理する。
	       
	       [35;1mEX2．出力ファイル名、ディレクトリ名、タイトル名プレフィックス[m
	            環境変数GRAPH_FILE_NAME_PREFIXでファイル名のプレフィックスを、
	            環境変数GRAPH_DIR_NAME_PREFIXでグラフ名のプレフィックスを、
	            環境変数GRAPH_TITLE_NAME_PREFIXでタイトル名のプレフィックスを指定可能。
	            必要な場合はスクリプト実行前に指定しておくこと。
	       
	       
	       より詳細ロジックはソース内のコメントを参照して欲しい。
	       （スクリプトの割に混沌としたソースなので、読めるものなら）
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．gnuplot制約[m
	           gnuplotはpng形式をサポートしている必要がある。
	           また、グラフ化コンフィグファイルに"multiplot"形式が存在する場合、
	           gnuplotは4.2以上のバージョンを使用しなければならない。
	           multiplot自体はこれより下のバージョンにも存在するが、
	           レイアウト指定に「layout」という設定機能を使用しており、
	           この機能は4.2以上でなければならないからである。（この機能なしにレイアウト指定はやや困難）
	           加えて、gnuplot 4.2以上でなければ、100%積み上げ面グラフの指定は無効になり、折れ線グラフで描かれる。
	           
	       [35;1m２．入力データダンプファイル[m
	           このスクリプトで指定される引数[35;1msourcefile[mの内容は、
	           「ヘッダ行」＋「データ行」×Ｎ（＋「フッタ行」）
	           という形式に限られる。
	           「ヘッダ行」は、conf/{SYSKBN}/all_header.confに該当するヘッダ行フォーマット、
	           「フッタ行」は、conf/{SYSKBN}/all_footer.confに該当するフッタ行フォーマットでなければならない。
	           （尚、フッタ行は存在しなくとも良い）
	           また、「データ行」×Ｎ部分に空行を含んではならない。
	           このスクリプトを呼ぶ前にこの形式にして回避しておくこと。
	           
	           具体的には、以下の様に１回の出力で１行ずつ出力されるフォーマットの場合に使用できる。
	           ---------------------------------------------------------------
	           Linux 2.6.18-128.el5xen (node11)        07/11/11

	           07:59:18          tps      rtps      wtps   bread/s   bwrtn/s
	           07:59:19         0.00      0.00      0.00      0.00      0.00
	           07:59:20         0.00      0.00      0.00      0.00      0.00
	           07:59:21         0.00      0.00      0.00      0.00      0.00
	           07:59:22         0.00      0.00      0.00      0.00      0.00
	           07:59:23        11.00      0.00     11.00      0.00    168.00
	           ---------------------------------------------------------------
	           一回の出力で複数行となるフォーマットの場合、gnuplot_separator.shを利用すること。
	       
	       [35;1m３．日付と時間の生成情報[m
	           date_stamp.shで生成されるファイルを使用し、そのフォーマットを信用している。
	           修正する場合にはこのスクリプトと同期すること。
	       
	       
	[36;1m[Related ConfigFiles] : [m
	        ・conf/graph.conf
	        ・conf/{SYSKBN}/all_header.conf
	        ・conf/{SYSKBN}/all_footer.conf
	        ・conf/{SYSKBN}/sar_*.conf
	        ・conf/{SYSKBN}/mpstat.conf
	        ・conf/{SYSKBN}/vmstat.conf
	        ・conf/{SYSKBN}/iostat.conf
	        ・conf/{SYSKBN}/pidstat.conf
	        ・conf/{SYSKBN}/common.conf
	
	[36;1m[Related Parameters] : [m
	        
	        [35;4;1mgraph.conf[m
	            ・TIME_FIELD
	            ・INPUT_DATE_FORMAT
	            ・INPUT_TIME_FORMAT
	            ・OUTPUT_TIME_FORMAT

	
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
# function createTimeField
#
#   [概要]
#      開始時間（%H:%M:%S）、インターバル時間（秒を示す正数）、生成回数を引数として、
#      開始時間からインターバル時間毎に増加する時間列を生成して改行区切りで出力する。
#      日付は結合しない。
#
#   [戻り値]
#       0:正常
#      99:引数不正
#
########################################
function createTimeField(){
    local ST_TIME
    local IT_SEC
    local CT_MAX
    local CT_CNT
    
    if [[ -z "$1" ]];then
        echo -e "Error:createTimeField(): 1st Param is required"
        return 99
    fi
    ST_TIME="$1"
    
    if [[ -z "$2" ]];then
        echo -e "Error:createTimeField(): 2nd Param is required"
        return 99
    fi
    IT_SEC="$2"
    
    if [[ -z "$3" ]];then
        echo -e "Error:createTimeField(): 3rd Param is required"
        return 99
    fi
    CT_MAX="$3"
    
    CT_CNT=0
    while [[ ${CT_CNT} -lt ${CT_MAX} ]]
    do
        echo "${ST_TIME}"
        ST_TIME=$(calcAddSec2Time "${ST_TIME}" "${IT_SEC}")
        CT_CNT=$(( CT_CNT + 1 ))
    done
    
    return 0
    
}

########################################
#
# function calcAddSec2Time
#
#   [概要]
#      加算対象時間（%H:%M:%S）、加算秒数を引数として、
#      加算後の時間（%H:%M:%S）をグローバル変数（AFT_ADD_TIME）にセットする。
#      日付は考慮せず、23:59:59を超える場合は00:00:00から起算する。
#
#      【注意】うるう秒未対応(笑)
#
#   [戻り値]
#       0:正常
#      99:引数不正
#
########################################
function calcAddSec2Time(){
    local OPE_TIME
    local OPE_SEC
    
    # ２桁0埋め数値にすると、３桁以上の繰り上がりを行えない（内部的にも切り捨てられてしまう模様）。
    # ここでは変数展開時に埋める。
    local SRC_HOUR
    local SRC_MIN
    local SRC_SEC
    
    if [[ -z "$1" ]];then
        echo -e "Error:calcAddSec2Time(): 1st Param is required"
        return 99
    fi
    OPE_TIME="$1"
    
    if [[ -z "$2" ]];then
        echo -e "Error:calcAddSec2Time(): 2nd Param is required"
        return 99
    fi
    OPE_SEC="$2"
    
    # 後方最長一致で:から右を全削除⇒時間
    SRC_HOUR=${OPE_TIME%%:*}
    # 後方最短一致で:から右を、前方最短一致で:から左を削除⇒分
    SRC_MIN=${${OPE_TIME%:*}#*:}
    # 前方最長一致で:から左を全削除⇒秒
    SRC_SEC=${OPE_TIME##*:}
    
    # 秒に加算する。
    SRC_SEC=$(( SRC_SEC + OPE_SEC ))
    # 秒が繰り上がる限り繰り返す。（非効率かな？まぁどうせこの関数に60秒以上足そうなんて使い方はすまい）
    while [[ ${SRC_SEC} -ge 60 ]]
    do
        SRC_SEC=$(( SRC_SEC - 60 ))
        SRC_MIN=$(( SRC_MIN + 1 ))
        if [[ ${SRC_MIN} -ge 60 ]];then
            SRC_MIN=$(( SRC_MIN - 60 ))
            SRC_HOUR=$(( SRC_HOUR + 1 ))
            if [[ ${SRC_HOUR} -ge 24 ]];then
                SRC_HOUR=$(( SRC_HOUR - 24 ))
            fi
        fi
    done
    
    echo "${(l,2,,0,)SRC_HOUR}:${(l,2,,0,)SRC_MIN}:${(l,2,,0,)SRC_SEC}"
    return 0
}



########################################
#
# function pasteDateField
#
#   [概要]
#      第一引数として指定されたファイルの[:]区切りでの1～3フィールドを
#      時間フォーマット（%H:%M:%S）とみなし、日付が変わるたびに
#      第三引数以降の文字列をシフトして第二引数をデリミタとして連結する。
#
#   [戻り値]
#       0:正常
#      99:引数不正
#
########################################
function pasteDateField(){
    local TIMEFIELD_FILE
    local DATESTAMP_ARRAY
    local NEW_TMP
    local DELIMITER
    
    if [[ ! -s "$1" ]];then
        echo -e "Error:pasteDateField(): 1st Param is readable file required"
        return 99
    fi
    TIMEFIELD_FILE="$1"
    NEW_TMP="${TIMEFIELD_FILE}.tmp"
    
    
    if [[ -z "$2" ]];then
        echo -e "Error:pasteDateField(): 2nd Param is required"
        return 99
    fi
    DELIMITER="$2"
    
    if [[ -z "$3" ]];then
        echo -e "Error:pasteDateField(): 3rd Param [ and later ] is required"
        return 99
    fi
    
    shift 2
    DATESTAMP_ARRAY=($*)
    
    # pasteコマンド使えよ……(笑)。
    # 時間を元に日付だけのラインを作り、元ファイルと垂直結合すればawkいらないんじゃね？
    # ってか、日付だけのラインを作るのにやっぱりawkが要るということか。意味ねぇ。このままでいいすね。
    # pasteコマンドってほとんど実戦投入したことねぇなー。
    awk -F ':' 'BEGIN{ # 23時検索中フラグ
                       __flg23__ = 0;
                       # 配列を空白で区切って文字列として取り込み
                       __datestamps__ = "'"${DATESTAMP_ARRAY[*]}"'";
                       # 空白で区切って__dates配列に格納
                       split(__datestamps__,__dates__," ");
                       # __dates配列カウント
                       __datescnt__ = 1;
                       # 現在の出力中の時間。初回は１番目。
                       __current__ = __dates__[__datescnt__];
                       }
                # 空行以外を処理
         ( $0 != "" ){ # 23時検索中ならフラグON
                       if ( $1 == "23" && __flg23__ == 0 ){
                         __flg23__ = 1;
                       } else if ( $1 == "00" && __flg23__ == 1 ){
                         # 23時から24時(0時)に変化したタイミングで__dates__をカウントアップして現在日時を変更。
                         __datescnt__++;
                         __current__ = __dates__[__datescnt__];
                         # 23時検索中フラグを降ろす。
                         __flg23__ = 0;
                       }
                       # 行全体に現在日時を結合して出力。デリミタ[_]
                       printf("%s'"${DELIMITER}"'%s\n",__current__,$0);
                     }' "${TIMEFIELD_FILE}" > "${NEW_TMP}"
    mv -f "${NEW_TMP}" "${TIMEFIELD_FILE}"
    
    return 0
}


########################################
#
# (グローバル変数を用いたプライベート関数。このスクリプト以外では全くの無効)
# 
# 必要グローバル変数 : PLOT_TARGETS配列（グラフコンフィグの今回ターゲットNo.行配列）
#                    : MAIN_NO配列（グラフコンフィグの全No.行配列）
#                    : MAIN_DATA配列（グラフコンフィグのデータ行）
#
#                      MAIN_NO配列とMAIN_DATA配列は、配列INDEX毎に同じ行のデータであること。
#
# function getGnuplotScripts
# 
#   1st Option：1：single
#               2：multi
#   
#
########################################
function getGnuplotScripts(){
    TYPE="$1"
    if [[ ${TYPE} != "1" && ${TYPE} != "2" ]];then
         echo -e "Error : gnuplot_normal.sh : function getGnuplotScripts() : this type is not supported [${TYPE}]"
         exit 4
    fi
    unset GPLOT_SCRIPTS
    unset MAIN_GPSTS_DATAS
    unset MAIN_GPSTS_TYPES
    unset GRAPH_TYPES
    unset GRAPH_TYPES_STRING
    
    # タイプの種類数
    GRPTYPE_CNT=1
    # 一斉出力配列のターゲットを実データ行に変換し、かつタイプの種類を取得。
    for PTARGET in ${PLOT_TARGETS[*]}
    do
        # MAIN_NO配列とMAIN_DATA配列のINDEX並びが等しいことを利用する為、ここはカウンタを用意する。
        NO_CNT=1
        while [[ ${NO_CNT} -le ${#MAIN_NO[*]} ]]
        do
            # 一斉出力ターゲットNo.とデータNo.の一致するArrayインデックス
            if [[ ${PTARGET} -eq ${MAIN_NO[${NO_CNT}]} ]];then
                # 実データ行を取得
                MAIN_GPSTS_DATAS=(${MAIN_GPSTS_DATAS[*]} "${MAIN_DATA[${NO_CNT}]}")
                # type値を取得
                GRAPH_TYPE=$(getLineFields "${MAIN_DATA[${NO_CNT}]}" ${TYPE_FNUM})
                # 実データType配列に追加
                MAIN_GPSTS_TYPES=(${MAIN_GPSTS_TYPES[*]} "${GRAPH_TYPE}")
                
                # GRAPH_TYPES配列に既に入っているかどうかを検出
                if [[ -z "${(M)GRAPH_TYPES:#${GRAPH_TYPE}}" ]];then
                    # 入っていなければtypeの種類配列に追加。
                    GRAPH_TYPES=(${GRAPH_TYPES[*]} "${GRAPH_TYPE}")
                fi
                
                # このループのみbreakする。
                break 1
            fi
            
            # Arrayインデックスカウントアップ
            NO_CNT=$(( NO_CNT + 1 ))
        done
    done
    
    # Type値の種類によって処理を分ける。
    for GTYPE in ${GRAPH_TYPES[*]}
    do
        # 【注意】
        #  Typeカラムフィールドは、[1]の場合1行1グラフ。
        #  2以降は同じ番号の組を同一グラフに出力する。
        
        # グラフタイプ１：個別出力
        if [[ ${GTYPE} == "1" ]];then
            # MAIN_GPSTS_DATAS配列とMAIN_GPSTS_TYPES配列のINDEX並びが等しいことを利用する為、カウンタを使用する。
            GTYPE_CNT=1
            while [[ ${GTYPE_CNT} -le ${#MAIN_GPSTS_DATAS[*]} ]]
            do
                if [[ ${MAIN_GPSTS_TYPES[${GTYPE_CNT}]} == "1" ]];then
                    MAIN_LINE="${MAIN_GPSTS_DATAS[${GTYPE_CNT}]}"
                    GPLOT_SCRIPTS=(${GPLOT_SCRIPTS[*]} "$(getGnuplotScriptDataType1 "${TYPE}" "${MAIN_LINE}")")
                fi
                GTYPE_CNT=$(( GTYPE_CNT + 1 ))
            done
            
        else
        # グラフタイプ１以外：複数Line出力
            GTYPE_CNT=1
            unset MLINE_TYPE_DATAS
            while [[ ${GTYPE_CNT} -le ${#MAIN_GPSTS_DATAS[*]} ]]
            do
                if [[ ${MAIN_GPSTS_TYPES[${GTYPE_CNT}]} == "${GTYPE}" ]];then
                    MLINE_TYPE_DATAS=(${MLINE_TYPE_DATAS[*]} "${MAIN_GPSTS_DATAS[${GTYPE_CNT}]}")
                fi
                GTYPE_CNT=$(( GTYPE_CNT + 1 ))
            done
            if [[ "${GTYPE}" == "fl"*  ]];then
                if ${FILLEDCURVE_FLG};then
                    # TYPE値がflから始まり、filledcurveが有効の場合。
                    GPLOT_SCRIPTS=(${GPLOT_SCRIPTS[*]} "$(getGnuplotScriptDataFilledMLineType "${TYPE}" ${MLINE_TYPE_DATAS[*]})")
                    continue
                fi
            fi
            GPLOT_SCRIPTS=(${GPLOT_SCRIPTS[*]} "$(getGnuplotScriptDataMLineType "${TYPE}" ${MLINE_TYPE_DATAS[*]})")
        fi
    done

}

########################################
#
# (グローバル変数を用いたプライベート関数。このスクリプト以外では全くの無効)
#
# function getGnuplotParamsByLine
# 
#   1st Option：1：single
#               2：multi
#   2nd Option：target line
#
########################################
function getGnuplotParamsByLine(){
    TYPE="$1"
    if [[ ${TYPE} != "1" && ${TYPE} != "2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotParamsByLine() : this type is not supported [${TYPE}]"
        exit 4
    fi
    if [[ -z "$2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotParamsByLine() : 2nd Param required"
        exit 4
    fi
    MAINPARAM_LINE="$2"
    
    # フィールド数取得
    FIELDS_CNT=$(getLineFieldsNumber "${MAINPARAM_LINE}")
    
    # データ行フィールド数チェック（ヘッダ行と異なっている場合はフォーマットエラーとしてスキップ）
    if [[ ${FIELDS_CNT} -ne ${HEADER_FIELDS_NUM} ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotParamsByLine() :Header Column Number [${HEADER_FIELDS_NUM}] not equal DataColumn Number [${FIELDS_CNT}]"
        return 1
    fi
    
    # gnuplot用共通パラメータ取得
    DIR_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${DIR_FNUM}")
    FNAME_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${FNAME_FNUM}")
    TITLE_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${TITLE_FNUM}")
    SIZE_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${SIZE_FNUM}")
    COLUMN_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${COLUMN_FNUM}")
    TI_FIELD=$(getLineFields "${MAINPARAM_LINE}" "${TI_FNUM}")
    
    # 名称プレフィックス環境変数が指定されていればその値を前置する。（ファイル名、タイトル）
    if [[ -n "${GRAPH_FILE_NAME_PREFIX}" ]];then
        FNAME_FIELD="${GRAPH_FILE_NAME_PREFIX}_${FNAME_FIELD}"
    fi
    if [[ -n "${GRAPH_TITLE_NAME_PREFIX}" ]];then
        # スペース結合
        TITLE_FIELD="${GRAPH_TITLE_NAME_PREFIX} ${TITLE_FIELD}"
    fi
    
    # 単独出力の場合、必要に応じてディレクトリ作成（multiplotの場合は全体で一括）
    if [[ ${TYPE} == "1" ]];then
        GNUPLOT_OUTDIR="${OUTPUT_DIR}/${DIR_FIELD}"
        if [[ -n "${GRAPH_DIR_NAME_PREFIX}" ]];then
            GNUPLOT_OUTDIR="${GNUPLOT_OUTDIR}/${GRAPH_DIR_NAME_PREFIX}"
        fi
        if [[ -e "${GNUPLOT_OUTDIR}" ]];then
            if [[ ! -d "${GNUPLOT_OUTDIR}" ]];then
                "Error : gnuplot_normal.sh : gnuplot output directory [${GNUPLOT_OUTDIR}] , already used for other file name"
                exit 4
            fi
        else
            mkdir -p -m 0777 "${GNUPLOT_OUTDIR}"
            CMDRET=$?
            if [[ ${CMDRET} -ne 0 ]];then
                echo -e "Error : gnuplot_normal.sh : make directory gnuplot_output miss [${GNUPLOT_OUTDIR}]"
                exit 4
            fi
        fi
        # 旧ファイルがあれば削除
        GNUPLOT_OUTFILE="${GNUPLOT_OUTDIR}/${FNAME_FIELD}.png"
        if [[ -e "${GNUPLOT_OUTFILE}" ]];then
            rm -f "${GNUPLOT_OUTFILE}"
        fi
    fi
    
    # gnuplot個別パラメータ用コマンドストリング作成
    # 共通でないフィールドパラメータを取得
    FIELDCNT=$(( HEADER_COLMIN_NUM + 1 ))
    unset COMMON_PARAMS
    while [[ ${FIELDCNT} -le ${HEADER_FIELDS_NUM} ]]
    do
        COMMON_PARAMS=(${COMMON_PARAMS[*]} "$(getLineFields "${MAINPARAM_LINE}" ${FIELDCNT})")
        FIELDCNT=$(( ${FIELDCNT} + 1 ))
    done
    
    # ソースファイルヘッダ行からグラフ化項目のフィールド数を取得
    SOURCE_TARGET_NUM=$(getParamFieldsNum "${SOURCE_HEADERLINE}" "${COLUMN_FIELD}")
    

}

########################################
#
# (グローバル変数を用いたプライベート関数。このスクリプト以外では全くの無効)
#
# function getGnuplotScriptDataType1
#
#   タイプ1（１グラフに１ライン）
# 
#   1st Option：1：single
#               2：multi
#   2nd Option：target line
#
########################################
function getGnuplotScriptDataType1(){
    TYPE="$1"
    if [[ ${TYPE} != "1" && ${TYPE} != "2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataType1() : this type is not supported [${TYPE}]"
        exit 4
    fi
    if [[ -z "$2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataType1() : 2nd Param required"
        exit 4
    fi
    MAINPARAM_LINE_T1="$2"
    
    unset SIZE_FIELD
    unset GNUPLOT_OUTFILE
    unset TITLE_FIELD
    unset COMMON_PARAMS
    unset SOURCE_TARGET_NUM
    unset TI_FIELD

    getGnuplotParamsByLine "${TYPE}" "${MAINPARAM_LINE_T1}"
    
    # 出力ファイル形式、サイズセット（共通）
    if [[ ${TYPE} == "1" ]];then
        echo -e "set term png size ${SIZE_FIELD}\nset output \"${GNUPLOT_OUTFILE}\""
    fi
    # グラフタイトルセット(共通)
    echo -e "set title \"${TITLE_FIELD}\""
    # 時間フォーマットセット（共通）
    echo -e "set xdata time"
    echo -e "set timefmt \"${INPUT_TIMEFMT_PARAM}\""
    echo -e "set format x \"${OUTPUT_TIME_FORMAT}\""
    # 凡例位置セット（固定）
    echo -e "set key below right"
    echo -e "set key box lt 3 lw 2"
    echo -e "set key spacing 2 width 3"
    # グリッド線（固定）
    echo -e "set grid front"

    # 個別パラメータセット
    BCNT=1
    while [[ ${BCNT} -le ${#COMMON_PARAMS[*]} ]]
    do
        # 文字列：NONEは無視すること。
        if [[ -n "${COMMON_PARAMS[${BCNT}]}" && "${COMMON_PARAMS[${BCNT}]}" != "NONE" ]];then
            echo -e "set ${COMMON_HEADER_PARAMS[${BCNT}]} ${COMMON_PARAMS[${BCNT}]}"
        fi
        BCNT=$(( BCNT + 1 ))
    done
    
    echo -e "plot \"${SOURCE_TMP}\" using ${TIME_FIELD}:${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with lines lw ${LINEWIDTH}"
    
}

########################################
#
# (グローバル変数を用いたプライベート関数。このスクリプト以外では全くの無効)
#
# function getGnuplotScriptDataMLineType
#
#   タイプN（1グラフに複数ラインを引くケース）
# 
#   1st Option：1：single
#               2：multi
#   2nd Option：target line
#
########################################
function getGnuplotScriptDataMLineType(){
    TYPE="$1"
    if [[ ${TYPE} != "1" && ${TYPE} != "2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataMLineType() : this type is not supported [${TYPE}]"
        exit 4
    fi
    if [[ -z "$2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataMLineType() : 2nd Param required"
        exit 4
    fi
    # 第二引数以降を配列取り込み
    shift 1
    MAINPARAM_LINE_T2=($*)
    
    unset SIZE_FIELD
    unset GNUPLOT_OUTFILE
    unset TITLE_FIELD
    unset COMMON_PARAMS
    unset SOURCE_TARGET_NUM
    unset TI_FIELD

    # 1行目から共通設定を取得
    getGnuplotParamsByLine "${TYPE}" "${MAINPARAM_LINE_T2[1]}"
    
    # 出力ファイル形式、サイズセット（共通）
    if [[ ${TYPE} == "1" ]];then
        echo -e "set term png size ${SIZE_FIELD}\nset output \"${GNUPLOT_OUTFILE}\""
    fi
    # グラフタイトルセット(共通)
    echo -e "set title \"${TITLE_FIELD}\""
    # 時間フォーマットセット（共通）
    echo -e "set xdata time"
    echo -e "set timefmt \"${INPUT_TIMEFMT_PARAM}\""
    echo -e "set format x \"${OUTPUT_TIME_FORMAT}\""
    # 凡例位置セット（固定）
    echo -e "set key below right"
    echo -e "set key box lt 3 lw 2"
    echo -e "set key spacing 2 width 3"
    # グリッド線（固定）
    echo -e "set grid front"
    # 個別パラメータセット
    BCNT=1
    while [[ ${BCNT} -le ${#COMMON_PARAMS[*]} ]]
    do
        # 文字列：NONEは無視すること。
        if [[ -n "${COMMON_PARAMS[${BCNT}]}" && "${COMMON_PARAMS[${BCNT}]}" != "NONE" ]];then
            echo -e "set ${COMMON_HEADER_PARAMS[${BCNT}]} ${COMMON_PARAMS[${BCNT}]}"
        fi
        BCNT=$(( BCNT + 1 ))
    done
    
    
    if [[ ${#MAINPARAM_LINE_T2[*]} -eq 1 ]];then
        # 1行目で終わる場合
        echo -e "plot \"${SOURCE_TMP}\" using ${TIME_FIELD}:${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with lines lw ${LINEWIDTH}"
    else 
        # 2行目以降がある場合
        # 1行目出力
        BUFF_PLOTER="plot \"${SOURCE_TMP}\" using ${TIME_FIELD}:${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with lines lw ${LINEWIDTH}, "
        # 2行目以降
        MLINE_CNT=2
        while [[ ${MLINE_CNT} -le ${#MAINPARAM_LINE_T2[*]} ]]
        do
            unset SOURCE_TARGET_NUM
            unset TI_FIELD
            # 設定取得
            getGnuplotParamsByLine "${TYPE}" "${MAINPARAM_LINE_T2[${MLINE_CNT}]}"
            if [[ ${MLINE_CNT} -eq ${#MAINPARAM_LINE_T2[*]} ]];then
                # 最終行
                BUFF_PLOTER="${BUFF_PLOTER}""\"${SOURCE_TMP}\" using ${TIME_FIELD}:${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with lines lw ${LINEWIDTH}"
            else 
                # 続きがある場合
                BUFF_PLOTER="${BUFF_PLOTER}""\"${SOURCE_TMP}\" using ${TIME_FIELD}:${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with lines lw ${LINEWIDTH}, "
            fi
            MLINE_CNT=$(( MLINE_CNT + 1 ))
        done
        echo -E "${BUFF_PLOTER}"
    fi
    
}


########################################
#
# (グローバル変数を用いたプライベート関数。このスクリプト以外では全くの無効)
#
# function getGnuplotScriptDataFilledMLineType
#
#   タイプflN（100%積み上げ面グラフを書くケース）
# 
#   1st Option：1：single
#               2：multi
#   2nd Option：target line
#
########################################
function getGnuplotScriptDataFilledMLineType(){
    TYPE="$1"
    if [[ ${TYPE} != "1" && ${TYPE} != "2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataFilledMLineType() : this type is not supported [${TYPE}]"
        exit 4
    fi
    if [[ -z "$2" ]];then
        echo -e "Error : gnuplot_normal.sh : function getGnuplotScriptDataFilledMLineType() : 2nd Param required"
        exit 4
    fi
    # 第二引数以降を配列取り込み
    shift 1
    MAINPARAM_LINE_T2=($*)
    
    unset SIZE_FIELD
    unset GNUPLOT_OUTFILE
    unset TITLE_FIELD
    unset COMMON_PARAMS
    unset SOURCE_TARGET_NUM
    unset TI_FIELD

    # 1行目から共通設定を取得
    getGnuplotParamsByLine "${TYPE}" "${MAINPARAM_LINE_T2[1]}"
    
    # 出力ファイル形式、サイズセット（共通）
    if [[ ${TYPE} == "1" ]];then
        echo -e "set term png size ${SIZE_FIELD}\nset output \"${GNUPLOT_OUTFILE}\""
    fi
    # グラフタイトルセット(共通)
    echo -e "set title \"${TITLE_FIELD}\""
    # 時間フォーマットセット（共通）
    echo -e "set xdata time"
    echo -e "set timefmt \"${INPUT_TIMEFMT_PARAM}\""
    echo -e "set format x \"${OUTPUT_TIME_FORMAT}\""
    # 凡例位置セット（固定）
    echo -e "set key below right"
    echo -e "set key box lt 3 lw 2"
    echo -e "set key spacing 2 width 3"
    # グリッド線（固定）
    echo -e "set grid front"
    # 塗りつぶしスタイルセット（固定）
    echo -e "set style data lines"
    echo -e "set style fill solid 0.4 border -1"
    
    # 個別パラメータセット
    BCNT=1
    while [[ ${BCNT} -le ${#COMMON_PARAMS[*]} ]]
    do
        # 文字列：NONEは無視すること。
        if [[ -n "${COMMON_PARAMS[${BCNT}]}" && "${COMMON_PARAMS[${BCNT}]}" != "NONE" ]];then
            echo -e "set ${COMMON_HEADER_PARAMS[${BCNT}]} ${COMMON_PARAMS[${BCNT}]}"
        fi
        BCNT=$(( BCNT + 1 ))
    done
    
    
    if [[ ${#MAINPARAM_LINE_T2[*]} -eq 1 ]];then
        # 1行目で終わる場合
        echo -e "plot \"${SOURCE_TMP}\" using ${TIME_FIELD}:(0):${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with filledcu "
    else 
        # 2行目以降がある場合
        # 1行目出力
        BUFF_PLOTER="plot \"${SOURCE_TMP}\" using ${TIME_FIELD}:(0):${SOURCE_TARGET_NUM} ti \"${TI_FIELD}\" with filledcu, "
        
        # 今回行出力をバッファリング
        PREVIOUS_FORM="${SOURCE_TARGET_NUM}"
        PREVIOUS_LINE="${SOURCE_TARGET_NUM}"
        unset NEXT_FORM
        unset NEXT_LINE
        
        # 2行目以降
        MLINE_CNT=2
        while [[ ${MLINE_CNT} -le ${#MAINPARAM_LINE_T2[*]} ]]
        do
            unset SOURCE_TARGET_NUM
            unset TI_FIELD
            # 設定取得
            getGnuplotParamsByLine "${TYPE}" "${MAINPARAM_LINE_T2[${MLINE_CNT}]}"
            
            # 2行目の場合
            if [[ ${MLINE_CNT} -eq 2 ]];then
                NEXT_FORM='$'"${PREVIOUS_FORM}"'+$'"${SOURCE_TARGET_NUM}"
                NEXT_LINE="(${NEXT_FORM})"
            else 
                # 3行目以降
                NEXT_FORM="${PREVIOUS_FORM}"'+$'"${SOURCE_TARGET_NUM}"
                NEXT_LINE="(${NEXT_FORM})"
            fi
            
            if [[ ${MLINE_CNT} -eq ${#MAINPARAM_LINE_T2[*]} ]];then
                # 最終行
                BUFF_PLOTER="${BUFF_PLOTER}""\"${SOURCE_TMP}\" using ${TIME_FIELD}:${PREVIOUS_LINE}:${NEXT_LINE} ti \"${TI_FIELD}\" with filledcu "
            else 
                # 続きがある場合
                BUFF_PLOTER="${BUFF_PLOTER}""\"${SOURCE_TMP}\" using ${TIME_FIELD}:${PREVIOUS_LINE}:${NEXT_LINE} ti \"${TI_FIELD}\" with filledcu, "
            fi
            
            # 今回実行分の退避
            PREVIOUS_FORM="${NEXT_FORM}"
            PREVIOUS_LINE="${NEXT_LINE}"
            
            MLINE_CNT=$(( MLINE_CNT + 1 ))
        done
        echo -E "${BUFF_PLOTER}"
    fi
    
}


########################################
#
# zshスクリプト
# gnuplot_normal.sh
#
# [概要]
#    指定された元ファイル、設定ファイル、出力ディレクトリに対し、パフォーマンス計測データを集計してグラフ化する。
#    グラフ化の実行にはファイル名に応じたconfigファイルが必要です。
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
# コマンドライン引数チェック（1st、2nd、3rd Args必須）
if [[ -z "$1" || -z "$2" || -z "$3" ]];then
    UsageMsg
    exit 4
fi

if [[ ! -r "$1" ]];then
    echo -e "Error : gnuplot_normal.sh : source file is not readable [$1]"
    exit 4
fi
SOURCE="$1"

if [[ ! -r "$2" ]];then
    echo -e "Error : gnuplot_normal.sh : config file is not readable [$1]"
    exit 4
fi
GRAPH_CONF="$2"

if [[ -e "$3" ]];then
    if [[ ! -d "$3" ]];then
       "Error : gnuplot_normal.sh : this output directory [$3] , already used for other file name"
       exit 4
   fi
else
    mkdir -m 0777 "$3"
    CMDRET=$?
    if [[ ${CMDRET} -ne 0 ]];then
        echo -e "Error : gnuplot_normal.sh : make directory output miss [$3]"
        exit 4
    fi
fi
OUTPUT_DIR="${3%/}"

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

# 一時ファイル
SOURCE_TMP="${SOURCE}.tmp"
# GNUPLOTスクリプトファイル
GNUPLOT_SCRIPT="${SOURCE%/*}/gnuplot_script.plt"

# プロット日時（YYYY/MM/DD_HH:MI:SS）出力ファイル
TIMELINE_FILE="${SOURCE%/*}/timeplot.txt"

# 入力タイムスタンプにおける、日付と時間の結合子。
DATE_TIME_DELIMITER="_"

# multiplotフラグ
MULTIPLOT_FLG=false

# 配列定義：（可読性のため、使用する変数名のみ挙げておく。後でunsetすることからtypesetはしない）
# configメインデータ部配列
MAIN_DATA[1]=""
# configメインデータNo.部配列
MAIN_NO[1]=""

# multiplotデータ部配列
MULTIPLOT_DATA[1]=""
# multiplotターゲット部配列
MULTIPLOT_TARGETS[1]=""

# 一斉出力配列
PLOT_TARGETS[1]=""

# gnuplotスクリプト共通部分配列
GPLOT_SCRIPTS[1]=""

# 単独出力配列
SINGLE_TARGETS[1]=""

# gnuplotスタイルのfilledcurve有効/無効（gnuplot_4.2以降）
FILLEDCURVE_FLG=true

echo -e "Info : gnuplot_normal.sh : File [${SOURCE}] Graph making start"


##---------------------------------------------------------------------------------------------------------------
# コンフィグパラメータ取得
##---------------------------------------------------------------------------------------------------------------
##############################################################################
# 共通ヘッダ解析
##############################################################################
# gnuplotコマンドパスを取得
# 【注意】graph.confのパラメータでgnuplotコマンドパスを決定。現在、バージョンによる機能差が大きいため。
# このパスに存在しない場合には、通常のPATHから検索する。
GNUPLOT_CMD=$(getParamFromGraphConf "GNUPLOT_CMD")
if [[ ! -x "${GNUPLOT_CMD}" ]];then
    GNUPLOT_CMD=gnuplot
fi

# CPU使用率グラフ化時に、100%積み上げ棒グラフを使用するかどうか。
CPU_USAGE_PATTERN=$(getParamFromConf "CPU_USAGE_PATTERN")
if [[ ${CPU_USAGE_PATTERN} != "${GRAPH_PATTERN_FILLEDCURVE}" ]];then
    FILLEDCURVE_FLG=false
fi

##---------------------------------------------------------------------------------------------------------------
# 共通解析
##---------------------------------------------------------------------------------------------------------------
##############################################################################
# 共通ヘッダ解析
##############################################################################
# グラフコンフィグからヘッダ行を取得する。
# ヘッダ行は、グラフコンフィグ中の[No.]カラムが0の行である。
# ヘッダ行取得
HEADER_LINES=$(getGraphConfHeader "${GRAPH_CONF}")
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_normal.sh : call function getGraphConfHeader miss ret [${FUNC_RET}] \n[${HEADER_LINES}]"
    exit 4
fi

# ヘッダ行フィールド数取得
HEADER_FIELDS_NUM=$(getLineFieldsNumber "${HEADER_LINES}")
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_normal.sh : call function getLineFieldsNumber miss ret [${FUNC_RET}] \n[${HEADER_LINES}]"
    exit 4
fi

# ヘッダフィールド数チェック。固定で設定するフィールド数以上でならない。
# HEADER_COLMIN_NUMはcommon_def.shに定義。グラフコンフィグの固定設定フィールド数。
if [[ ${HEADER_FIELDS_NUM} -lt ${HEADER_COLMIN_NUM} ]];then
    echo -e "Error : gnuplot_normal.sh : Header Column is not supported [${HEADER_FIELDS_NUM}]"
    exit 4
fi

# 【注意】
# 共通フィールドカラムNo.取得(No.3～8)
# TYPE_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "type")
# 固定（どの道draw_grapth.shでも固定してるし）
TYPE_FNUM=2
COLUMN_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "column")
DIR_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "directory")
FNAME_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "fname")
TITLE_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "title")
SIZE_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "size")
TI_FNUM=$(getParamFieldsNum "${HEADER_LINES}" "ti")


# それ以外のフィールドパラメータを取得して配列に格納
#（固定ヘッダ＋１以降のフィールドを全て取得。エラー無視。固定以外は無くてもいいが、取得できない場合にエラーが返ってきてしまうため）
: ${(A)COMMON_HEADER_PARAMS::=$(getLineFieldsRear "${HEADER_LINES}" $(( HEADER_COLMIN_NUM + 1 )) )}

##############################################################################
# コンフィグメインデータ部取得
##############################################################################
# ヘッダ行（No.カラム0）以外で、multiで始まらない行を取得。
TARGET_LINES=$(getGraphConfData "${GRAPH_CONF}")

# 各行の配列取り込み
# ここでは、予め空行は無視されているのでシェルの配列化を使う。（(@f)フラグは空行を無視するので、厳密に行数をカウントするような処理には向かない）

# データ行を配列化
: ${(A)MAIN_DATA::=${(@f)TARGET_LINES}}

# 各行の第一フィールドを配列化。（No.カラム）
: ${(A)MAIN_NO::=${(@f)"$(getFieldsForMultiLines "${TARGET_LINES}" 1)"}}


##---------------------------------------------------------------------------------------------------------------
# MultiPlotターゲット解析
##---------------------------------------------------------------------------------------------------------------
##############################################################################
# multiplotヘッダ解析
##############################################################################
# multiplotヘッダ行取得
# 第一フィールドがmulti0となっている行である。
MULTIHEADER_LINES=$(getGraphConfMultiHeader "${GRAPH_CONF}")
RETCD=$?
if [[ ${RETCD} -eq 0 ]];then
    # multiplot行が存在する場合。MULTIPLOT_FLGを立てておく。
    MULTIPLOT_FLG=true

    # multiplotヘッダ行フィールド数取得
    MULTIHEADER_FIELDS_NUM=$(getLineFieldsNumber "${MULTIHEADER_LINES}")

    # ヘッダフィールド数チェック
    # multiplotを行う際に固定で必要となるパラメータ数以上のカラムがあることをチェック。
    # multiplot固定パラメータ数のMULTIHEADER_COLMIN_NUMは、common_def.shに定義している。
    if [[ ${MULTIHEADER_FIELDS_NUM} -lt ${MULTIHEADER_COLMIN_NUM} ]];then
        echo -e "Error : gnuplot_normal.sh : MultiHeader Column is not supported [${MULTIHEADER_FIELDS_NUM}]"
        exit 4
    fi

    # MultiPlot共通フィールドカラムNo.取得
    MULTI_LAYOUT_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "layout")
    MULTI_SIZE_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "size")
    MULTI_TARGET_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "target")
    MULTI_DIR_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "directory")
    MULTI_FNAME_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "fname")
    MULTI_TITLE_FNUM=$(getParamFieldsNum "${MULTIHEADER_LINES}" "title")

    # それ以外のパラメータを取得
    #（固定ヘッダ＋１以降のフィールドを全て取得。エラー無視。固定以外は無くてもいいが、取得できない場合にエラーが返ってきてしまうため）
    : ${(A)MULTICOMMON_HEADER_PARAMS::=$(getLineFieldsRear "${MULTIHEADER_LINES}" $(( MULTIHEADER_COLMIN_NUM + 1 )) )}

    ##############################################################################
    # multiplotデータ部取得
    ##############################################################################
    # 第一フィールドがmulti1～9で始まる行を取得する。
    MULTIPLOT_LINES=$(getGraphMultiData "${GRAPH_CONF}")
    # 各行の配列取り込み
    
    # 各行の配列取り込み
    # ここでは、予め空行は無視されているのでシェルの配列化を使う。（(@f)フラグは空行を無視するので、厳密に行数をカウントするような処理には向かない）

    # データ行を配列化
    : ${(A)MULTIPLOT_DATA::=${(@f)MULTIPLOT_LINES}}

    # 各行の第[target]番目フィールドを配列化。（targetカラム。このカラムはさらに[,]で分割されている）
    : ${(A)MULTIPLOT_TARGETS::=$(getFieldsForMultiLines "${MULTIPLOT_LINES}" ${MULTI_TARGET_FNUM})}
fi

##---------------------------------------------------------------------------------------------------------------
# gnuplotバージョンチェック
##---------------------------------------------------------------------------------------------------------------
LINEWIDTH_ADDFLG=false
GNUPLOT_VERSION=$(${GNUPLOT_CMD} --version | cut -d " " -f2)
if [[ $(( GNUPLOT_VERSION - 4.2 )) -lt 0 ]];then
    # バージョン4.2より小さい場合
    echo -e "Warning : gnuplot_normal.sh : Multiplot function requires gnuplot version 4.2 or later in this package. sorry."
    # マルチプロット起動不能。全て通常版に戻す。
    MULTIPLOT_FLG=false
    # 線の太さに1を加える。
    LINEWIDTH_ADDFLG=true
    # filledcurve無効化
    FILLEDCURVE_FLG=false
fi


##---------------------------------------------------------------------------------------------------------------
# グラフ作成ソースファイルの変換
##--------------------------------------------------------------------------------------------------------------
# コンフィグからヘッダ/フッタ情報パラメータの取得。

# 【注意】
#  linuxフォーマットでのハナシ。他のフォーマットは知らん。
#  各コマンドのダンプによって、ヘッダ行が何行あり、どの行に項目ヘッダが入っているのかが異なる。
#  sar、pidstatやmpstatは、先頭１行目に環境情報、２行目が空白、三行目に項目ヘッダが表れることを前提にしたロジック。
#  重要なのは、「3行目にヘッダ」「最初の２行は無視」である。これを、iostatやvmstatも同様に事前調査し、all_header.confに記述しておく。
#  フッタも同様。all_footer.confを作成しておくこと。

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

# all_header.confからパラメータを取得。[ヘッダ行数],[グラフ化用項目ヘッダ行]。
ALLHEADER_CONTENTS=$(getParamFromAllHeaderConf ${AHCONF_PARAM})
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : gnuplot_normal.sh : call function getParamFromAllHeaderConf miss ret [${FUNC_RET}] \n[${ALLHEADER_CONTENTS}]"
    exit 4
fi

# ヘッダ行数を取得
HEADER_NUM=${ALLHEADER_CONTENTS%,*}
# グラフ化用項目ヘッダ行を取得
PARAMLINE_NUM=${ALLHEADER_CONTENTS#*,}

# all_footer.confからパラメータを取得。
# 値は[フッタ行数],[フッタ判定先頭行名]。
ALLFOOTER_CONTENTS=$(getParamFromAllFooterConf ${AHCONF_PARAM})
FOOTER_NUM=${ALLFOOTER_CONTENTS%,*}
FOOTER_STRING=${ALLFOOTER_CONTENTS#*[,]}

##------------------------------------------------------------------------------------
# 特殊処理：ソースを変換する前に、特別なケースへの対応を行う。
##------------------------------------------------------------------------------------
# pidstatの場合
# ソースファイルから、「先頭#」を除く。行を削除するのではなく、#という文字のみ半角空白に変換する。これは、-h指定時に、ヘッダ行の先頭に余計な#が付くのを消すため。
# どうせ単語分割するんだから変換じゃなく消してもいいが、デバッグ時とかに中間ファイルを見る時見栄えが悪くて気持ち悪いので変換。
# この処理はgnuplot_separatorでも行っている。pidstatのコンフィグはセパレータ系なのでこちらでは実質不要だが、セパレータからノーマルにした場合に顕在化してハマるのが怖いので、
# ここでも行っておく。大体、この仕様自体がpidstatのほぼバグだろうに、本当にめんどくさいことをさせる。
if [[ "${SOURCE##*/}" == "${PIDSTAT_DATA_PREFIX}"*."${PIDSTAT_DATA_SUFFIX}"* ]];then
    sed -e 's/^#/ /g' "${SOURCE}" > "${SOURCE_TMP}"
    mv -f "${SOURCE_TMP}" "${SOURCE}"
fi

##------------------------------------------------------------------------------------
# 共通処理：ヘッダの削除、項目値ヘッダから項目値並びの定義を取り込み、フッタの削除、
#           日付定義ファイルの取得、時間定義ファイルの取得、共通グラフ設定パラメータの取得
##------------------------------------------------------------------------------------
# tmpの編集一時領域セット
SOURCE_TMP_TMP="${SOURCE_TMP}.tmp"

# ヘッダ削除はsedで行う。
# ヘッダの削除
sed -e "1,${HEADER_NUM}d" "${SOURCE}" > "${SOURCE_TMP}"

# フッタの削除（0の場合には何もしない）
if [[ ${ALLFOOTER_CONTENTS} != "0" ]];then
    # フッタ行の先頭
    FOOTER_HEAD1=$(tail -n ${FOOTER_NUM} "${SOURCE_TMP}" | awk '(NR == 1){print $1}')
    # マッチするかどうかをチェック
    if [[ "${FOOTER_HEAD1}" == "${FOOTER_STRING}" ]];then
        TMP_LINE_NUM=$(cat "${SOURCE_TMP}" | wc -l)
        MAINLINE_CNT=$(( TMP_LINE_NUM - FOOTER_NUM ))
        head -n ${MAINLINE_CNT} "${SOURCE_TMP}" > "${SOURCE_TMP_TMP}"
        mv -f "${SOURCE_TMP_TMP}" "${SOURCE_TMP}"
    fi
fi

# 件数取得
SOURCE_LINENUM=$(cat "${SOURCE_TMP}" | wc -l)

# sedってなぜか'$-2,$d'の様な指定が出来ない……edとは違うのね。フッタ行なんてあんまり多くないと見越して、headで取って送っている。

# 日付定義ファイルを取得し、配列に取り込む。難しい操作の無い単純取り込み。
DATE_TXT_FILE="${SOURCE%/*}/${DATE_STAMP_FNAME}"
if [[ ! -s "${DATE_TXT_FILE}" ]];then
    echo -e "Error : gnuplot_normal.sh : date stamp file is not exists [${DATE_TXT_FILE}]"
    exit 4
fi
: ${(A)DATE_STAMPS::=${(@f)"$(<${DATE_TXT_FILE})"}}

# 時間定義ファイルを取得し、各項目を取得する。
TIME_TXT_FILE="${SOURCE%/*}/${TIME_STAMP_FNAME}"

# 【注意】
# date_stamp.shに出力フォーマットが直接関わっている。修正時にはそちらも同期を取ること。
: ${(A)TIME_TXT_CONTS::=${="$(<${TIME_TXT_FILE})"}}
# 第二カラム：開始時間（%H:%M:%S）
START_TIME=${TIME_TXT_CONTS[2]}
# 第三カラム：インターバル秒（正数）
INTERVAL_SEC=${TIME_TXT_CONTS[3]}
# 第四カラム：生成回数
FREQ_NUM=${TIME_TXT_CONTS[4]}

# 今のところそれ以外は使わない。あえて直すまでもないが。

# グラフ設定共通パラメータ取得
# linewidth : 線の太さ
LINEWIDTH=$(getParamFromCommonConf "linewidth")
# gnuplotバージョンが4.2未満の場合には、調整のため+1している。
# （どうもこちらの推奨の「2」の太さが、4.1では1と変わらないため。4.4で実験したところ、反映されていた。かなり苦肉の策だが……）
if ${LINEWIDTH_ADDFLG};then
    LINEWIDTH=$(( LINEWIDTH + 1 ))
fi

##------------------------------------------------------------------------------------
# 個別処理：タイムラインとの結合、SOURCE_HEADERLINEの調整。
##------------------------------------------------------------------------------------
# SOURCE_HEADERLINEに注意する。
# この変数はgnuplotを行う時のフィールド数定義そのもの。このヘッダ行を元にどの項目が何フィールド目かを判定している。
# タイムラインの項目自体が増える場合にはこの変数もダミーでいいのでカラム追加しないと、元データとずれてしまう。
# タイムラインが元から存在するmpstatやsarでは必要ないが、iostatやvmstatでは追加必須。

# sysstatバージョンの取得
SYSSTAT_VERSION=$(getSysstatVersion)
checkReturnErrorFatal $? "${SYSSTAT_VERSION}"
compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.6
SYSVERSION_816=$?

# sar形式のファイル
# mpstat形式のファイル
# pidstat形式かつsysstatバージョンが8.1.5以下
if [[ "${SOURCE##*/}" == "${SAR_DATA_PREFIX}"*."${SAR_DATA_SUFFIX}"* || \
      "${SOURCE##*/}" == "${MPSTAT_DATA_PREFIX}"*."${MPSTAT_DATA_SUFFIX}"* || \
      ( "${SOURCE##*/}" == "${PIDSTAT_DATA_PREFIX}"*."${PIDSTAT_DATA_SUFFIX}"* && ${SYSVERSION_816} == 0 ) \
   ]];then
    # 項目ヘッダ行を取得（タイムカラムは最初からあるので調整不要。この行そのものが項目ヘッダでよい）
    SOURCE_HEADERLINE=$(getLinesFromFile "${SOURCE}" ${PARAMLINE_NUM})

    # 【注意】
    # 時間情報に日付を追加する。（存在しない場合はエラーにしてしまう）
    # タイムスタンプとの結合
    
    pasteDateField "${SOURCE_TMP}" "${DATE_TIME_DELIMITER}" ${DATE_STAMPS[*]}
    
elif [[ "${SOURCE##*/}" == "${VMSTAT_DATA_PREFIX}"*."${VMSTAT_DATA_SUFFIX}"* || \
        "${SOURCE##*/}" == "${IOSTAT_DATA_PREFIX}"*."${IOSTAT_DATA_SUFFIX}"* || \
        ( "${SOURCE##*/}" == "${PIDSTAT_DATA_PREFIX}"*."${PIDSTAT_DATA_SUFFIX}"* && ${SYSVERSION_816} != 0 ) \
     ]];then
    # vmstat 形式のファイル
    # iostat 形式のファイル
    # pidstat形式のファイルかつsysstatバージョンが8.1.6以上。pidstat -hを使うと、TimeカラムがUnix秒時間になるため、これを無視して自らTIMEカラムを埋め込む。
    
    # 項目ヘッダ行を取得し、タイムカラムを疑似的に埋め込む。（元のヘッダに対し時間項目を結合する為）
    SOURCE_HEADERLINE="TIME $(getLinesFromFile "${SOURCE}" ${PARAMLINE_NUM})"
    
    # 【注意】
    # プロット時間定義ファイルが既に存在する場合にはそちらを使用し、
    # ここでは改めて作成しない。
    # また、存在してもソースより短い場合、ソース行数分だけ作り直す。
    
    # 条件を纏めるために少し非効率なことをしている。ご了承。
    TIME_LENGTH=0
    if [[ -s "${TIMELINE_FILE}" ]];then
        TIME_LENGTH=$(cat "${TIMELINE_FILE}" | wc -l)
    fi
    
    if [[ ${TIME_LENGTH} -lt ${SOURCE_LINENUM} ]];then
        
        # 各ステータスレポートコマンドを実行した時、全て起動時間からインターバル時間経過後にレポートを開始する為、開始時間をずらす。
        # 【注意】インターバル時間だけずらして開始する。
        START_TIME=$(calcAddSec2Time "${START_TIME}" "${INTERVAL_SEC}")
        
        # 時間ファイルの出力
        createTimeField "${START_TIME}" "${INTERVAL_SEC}" "${SOURCE_LINENUM}" > "${TIMELINE_FILE}"
        
        # 日付フィールドとの連結。第二引数以降は日付定義ファイル内容の全てを送る。
        pasteDateField "${TIMELINE_FILE}" "${DATE_TIME_DELIMITER}" ${DATE_STAMPS[*]}
        
    fi
    
    # プロット時間定義ファイルとデータファイルを半角スペース区切りで垂直連結する。
    # データファイル行数に合わせ、プロット時間定義ファイルを切り出して行う。（プロセス置換展開に注意）
    paste -d " " <(head -n "${SOURCE_LINENUM}" "${TIMELINE_FILE}") "${SOURCE_TMP}" > "${SOURCE_TMP_TMP}"

    mv -f "${SOURCE_TMP_TMP}" "${SOURCE_TMP}"
else
    echo -e "Error : gnuplot_normal.sh : this source file type is not supported [${SOURCE}]"
    exit 4

fi



##---------------------------------------------------------------------------------------------------------------
# normalグラフ化スクリプト用パラメータ解析
##---------------------------------------------------------------------------------------------------------------
# 【注意】使用パラメータ
# 時間フィールド番号（固定で1のはず。というよりも、今は１以外対応できない）
TIME_FIELD=$(getParamFromGraphConf "TIME_FIELD")

# 入力日付フォーマット：%Y/%m/%d
INPUT_DATE_FORMAT=$(getParamFromGraphConf "INPUT_DATE_FORMAT")
# 入力時間フォーマット：%H:%M:%S
INPUT_TIME_FORMAT=$(getParamFromGraphConf "INPUT_TIME_FORMAT")
# 時間結合：デリミタ[_]で結合する。
INPUT_TIMEFMT_PARAM="${INPUT_DATE_FORMAT}${DATE_TIME_DELIMITER}${INPUT_TIME_FORMAT}"

# グラフ上での時間出力フォーマット（コンフィグに回した方がいい？）
OUTPUT_TIME_FORMAT=$(getParamFromGraphConf "OUTPUT_TIME_FORMAT")

##---------------------------------------------------------------------------------------------------------------
# 処理の実行
##---------------------------------------------------------------------------------------------------------------
##############################################################################
# multiplotターゲットの実行
##############################################################################
if ${MULTIPLOT_FLG};then
    # multiplotデータ部の繰り返し
    for LINE in ${MULTIPLOT_DATA[*]}
    do
        # フィールド数取得
        FIELDS_CNT=$(getLineFieldsNumber "${LINE}")

        # データ行フィールド数チェック（ヘッダ行と異なっている場合はフォーマットエラーとしてスキップ）
        if [[ ${FIELDS_CNT} -ne ${MULTIHEADER_FIELDS_NUM} ]];then
            echo -e "Error : gnuplot_normal.sh : MultiHeader Column Number [${MULTIHEADER_FIELDS_NUM}] not equal DataColumn Number [${FIELDS_CNT}]"
            continue
        fi
        
        # multiplot用共通パラメータ取得
        MULTI_LAYOUT_FIELD=$(getLineFields "${LINE}" "${MULTI_LAYOUT_FNUM}")
        MULTI_SIZE_FIELD=$(getLineFields "${LINE}" "${MULTI_SIZE_FNUM}")
        MULTI_TARGET_FIELD=$(getLineFields "${LINE}" "${MULTI_TARGET_FNUM}")
        MULTI_DIR_FIELD=$(getLineFields "${LINE}" "${MULTI_DIR_FNUM}")
        MULTI_FNAME_FIELD=$(getLineFields "${LINE}" "${MULTI_FNAME_FNUM}")
        MULTI_TITLE_FIELD=$(getLineFields "${LINE}" "${MULTI_TITLE_FNUM}")
        
        # ターゲットNo.を一斉出力配列へ格納。そのついでに、Multi出力したターゲットを保存。
        unset PLOT_TARGETS
        # ターゲットフィールドは[,]区切りでメインの行のNo.が記述されている。そのフィールド毎にループ。
        for PLOT_TARGET in ${=${MULTI_TARGET_FIELD//,/ }}
        do
            # フィールドの各カラムを取得し、今回のmultiplotターゲットをPLOT_TARGETSに格納する。
            # また、multiplotターゲットで作成済みのグラフを後の通常グラフターゲットから外すため、
            # ALL_MULTI_TARGETにも記録していく。
            PLOT_TARGETS=(${PLOT_TARGETS[*]} ${PLOT_TARGET})
            ALL_MULTI_TARGET=(${ALL_MULTI_TARGET[*]} ${PLOT_TARGET})
        done
        
        # 一斉出力配列のgnuplotスクリプト化（type multiplot）
        unset GPLOT_SCRIPTS
        getGnuplotScripts 2
        
        # Multiplot実行
        # グラフファイル名称プレフィックス環境変数が指定されていればその値を前置して[_]で結合する。
        if [[ -n "${GRAPH_FILE_NAME_PREFIX}" ]];then
            MULTI_FNAME_FIELD="${GRAPH_FILE_NAME_PREFIX}_${MULTI_FNAME_FIELD}"
        fi
        # グラフタイトル名環境変数が指定されていればその値を前置して[ ]で結合する。
        if [[ -n "${GRAPH_TITLE_NAME_PREFIX}" ]];then
            # スペース結合
            MULTI_TITLE_FIELD="${GRAPH_TITLE_NAME_PREFIX} ${MULTI_TITLE_FIELD}"
        fi
        
        # 必要に応じてディレクトリ作成
        MULTIGNUPLOT_OUTDIR="${OUTPUT_DIR}/${MULTI_DIR_FIELD}"
        # ディレクトリプレフィックス環境変数が指定されていればそのディレクトリを作成して置き換える。
        if [[ -n "${GRAPH_DIR_NAME_PREFIX}" ]];then
            MULTIGNUPLOT_OUTDIR="${MULTIGNUPLOT_OUTDIR}/${GRAPH_DIR_NAME_PREFIX}"
        fi
        if [[ -e "${MULTIGNUPLOT_OUTDIR}" ]];then
            if [[ ! -d "${MULTIGNUPLOT_OUTDIR}" ]];then
                "Error : gnuplot_normal.sh : gnuplot output directory [${MULTIGNUPLOT_OUTDIR}] , already used for other file name"
                exit 4
            fi
        else
            mkdir -p -m 0777 "${MULTIGNUPLOT_OUTDIR}"
            CMDRET=$?
            if [[ ${CMDRET} -ne 0 ]];then
                echo -e "Error : gnuplot_normal.sh : make directory gnuplot_output miss [${MULTIGNUPLOT_OUTDIR}]"
                exit 4
            fi
        fi
        
        # 【注意】png形式固定
        # 旧ファイルがあれば削除
        MULTIGNUPLOT_OUTFILE="${MULTIGNUPLOT_OUTDIR}/${MULTI_FNAME_FIELD}.png"
        if [[ -e "${MULTIGNUPLOT_OUTFILE}" ]];then
            rm -f "${MULTIGNUPLOT_OUTFILE}"
        fi
        
#$$$$$$$$$$$$$$$$$$--------------DEBUG-ON
#GNUPLOTSCRIPT_CNT=$((${GNUPLOTSCRIPT_CNT} + 1))
#GNUPLOT_SCRIPT=${GNUPLOT_SCRIPT}_${GNUPLOTSCRIPT_CNT}
#$$$$$$$$$$$$$$$$$$--------------

        # gnuplot スクリプト作成
        echo -e "set term png size ${MULTI_SIZE_FIELD}\nset output \"${MULTIGNUPLOT_OUTFILE}\"" > ${GNUPLOT_SCRIPT}
        echo -e "set multiplot layout ${MULTI_LAYOUT_FIELD} title \"${MULTI_TITLE_FIELD}\"" >> ${GNUPLOT_SCRIPT}
        for SCRIPT in ${GPLOT_SCRIPTS[*]}
        do
            # 中に\が入ってるので解析禁止
            echo -E "${SCRIPT}" >> ${GNUPLOT_SCRIPT}
        done
        
        # gnuplotコマンド実行
        # Work Arround : for gnuplot can't find error message
        ${=GNUPLOT_CMD} ${GNUPLOT_SCRIPT} 2>&1 | grep -E -v "(Could not find/open font when opening font|Warning: empty y range)"

    done
fi

##############################################################################
# 単独実行ターゲット抽出
##############################################################################
# multiplot以外のターゲットをSINGLE_TARGETSに格納する。
if ${MULTIPLOT_FLG};then
    # multiplotを実行した場合、グラフ化済みのターゲットは除く。
    for MNO in ${MAIN_NO[*]}
    do
        NOT_EXECUTED_FLG=true
        
        # multiplotとして実行されているかどうかをチェック。
        for AMTNO in ${ALL_MULTI_TARGET[*]}
        do
            if [[ "${MNO}" == "${AMTNO}" ]];then
                NOT_EXECUTED_FLG=false
                break 1
            fi
        done
        
        # 実行されていない場合、単独実行ターゲットに追加。
        if ${NOT_EXECUTED_FLG};then
            SINGLE_TARGETS=(${SINGLE_TARGETS[*]} ${MNO})
        fi
    done
else
    # 配列値をそのまま取得
    SINGLE_TARGETS=(${MAIN_NO[*]})
fi

##############################################################################
# 単独実行ターゲットの起動
##############################################################################
if [[ ${#SINGLE_TARGETS[*]} -ge 1 ]];then
    
    # ターゲットNo.を一斉出力配列へ格納。
    # 配列コピーすればいいだけだが、bash/zshの互換性を考慮してインデックスを指定する。
    unset PLOT_TARGETS
    PLOT_TARGETS=(${SINGLE_TARGETS[*]})
    
    # 一斉出力配列のgnuplotスクリプト化 (type normal)
    unset GPLOT_SCRIPTS
    getGnuplotScripts 1
    
    # 単独出力をそれぞれ実行
    for SCRIPT in ${GPLOT_SCRIPTS[*]}
    do

#$$$$$$$$$$$$$$$$$$--------------DEBUG-ON
#GNUPLOTSCRIPT_CNT=$((${GNUPLOTSCRIPT_CNT} + 1))
#GNUPLOT_SCRIPT=${GNUPLOT_SCRIPT}_${GNUPLOTSCRIPT_CNT}
#$$$$$$$$$$$$$$$$$$--------------

        # 中に\が入ってるので解析禁止
        echo -E "${SCRIPT}" > ${GNUPLOT_SCRIPT}
        # gnuplotコマンド実行
        # Work Arround : for gnuplot can't find error message
        ${=GNUPLOT_CMD} ${GNUPLOT_SCRIPT} 2>&1 | grep -E -v "(Could not find/open font when opening font|Warning: empty y range)"
    done
fi

rm -f "${SOURCE_TMP}"
rm -f "${GNUPLOT_SCRIPT}"

exit 0

