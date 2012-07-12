#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : resstat.sh
	        
	        resstat.sh start outputdir
	        resstat.sh stop
	        resstat.sh [ [34;1m-s[m ] show
	        resstat.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: resstat.sh [m  -- パフォーマンス計測 起動/停止/状態表示
	
	       resstat.sh start outputdir
	       resstat.sh stop
	       resstat.sh [ [34;1m-s[m ] show
	       resstat.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mstart[m : パフォーマンス計測の起動。
	       
	       [35;1moutputdir[m : start時の計測結果格納ディレクトリ。
	       
	       [35;1mstop[m : パフォーマンス計測の終了。
	       
	       [35;1mshow[m : パフォーマンス計測の起動ステータス表示。
	
	
	[36;1m[Options] : [m
	
	       [34;1m-s[m : short message。起動中ならON、停止中ならOFFと表示し、プロセスの表示を行わない。
	            showの場合以外では無効。（--> 無害オプション）

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       パフォーマンス計測の起動/停止/ステータス表示を行う。
	       起動時は、conf/{SYSKBN}/command.confに従って、起動コマンドを決定する。
	       起動インターバルは[32;1mINTERVAL_SECパラメータ[m、
	       起動最大時間は[32;1mTOTAL_MINUTESパラメータ[mからそれぞれ取得する。
	       また、conf/resstat.confの[32;1mAUTO_CONFIGパラメータ[mがONならば、
	       起動前にconfigure.shを呼び出して環境に合わせた設定を行う。
	       
	       [35;1m１．start機能[m
	         以下のコマンド及びスクリプトを実行する。
	         sar、sadc、mpstat、vmstat、iostat、pidstatは全てバックグラウンドで起動し、
	         起動したプロセスID/コマンド/実行ユーザ名を、
	         [33;1mPID_FILE環境変数[m（common_def.sh参照）が
	         示すファイルに追記していく。

	         ・sadc
	           sarレポート収集のためのコマンド。
	           アーキテクチャによって格納場所が異なり、
	           一般的にPATHを通さないディレクトリに置かれるため、
	           絶対パス指定で実行する。
	           
	           始めに、sysstatをソースからビルドインストールした際のデフォルト格納先である、
	           /usr/local/lib64/sa/sadcを検索し、存在しなければ、
	           /usr/local/lib/sa/sadcを確認する。
	           これらのどちらかに存在すれば使用する。
	
	           実行パスは、uname -m（CPUアーキテクチャタイプ表示）の実行結果によって
	           以下の様に別れる。
	           x86_64、s390x、ia64、ppc64  :  /usr/lib64/sa/sadc
	           s390、その他                :  /usr/lib/sa/sadc
	           
	           実行の際には、割り込み情報やディスク情報を取得する為のオプションを付加する。
	           sysstat 8.1.2までは、割り込み情報を-Iで、ディスク情報を-dで取得する。
	           8.1.3以降は以下の通り。
	           
	           割り込み情報          : -S INT
	           ディスク情報          : -S DISK（sysstat9.0.1まで）、-S XDISK(sysstat 9.0.2以降)
	           SNMP MIB(IPv4系)情報  : -S SNMP
	           SNMP MIB(IPv6系)情報  : -S IPV6
	           電源管理ステータス    : -S POWER

	         ・sar
	           プロセスIDにアタッチして情報を取得する場合、
	           sadcとは別にsar -x及びsar -Xを実行する。
	           ただし、sysstatバージョンが7.1.3以下の場合のみ。

	         ・mpstat
	           PATH上にコマンドが存在するものと仮定し、mpstat -P ALLを実行する。

	         ・vmstat
	           PATH上にコマンドが存在するものと仮定し、vmstatを実行する。

	         ・iostat
	           sysstat バージョン8.1.7までは、iostat -xkを実行し、
	           sysstat バージョン8.1.8以降は、iostat -xk -pを実行する。

	         ・pidstat
	           プロセスIDにアタッチして情報を取得する場合で、
	           sysstatバージョンが7.1.4以上の場合、このコマンドを実行する。
	           実行オプションはバージョンによって異なる。
	           
	           7.1.4         : pidstat -u、pidstat -r
	           7.1.5 - 8.0.1 : pidstat -u、pidstat -r、pidstat -d
	           8.0.2 - 8.1.5 : pidstat -u、pidstat -r、pidstat -d、pidstat -w
	           8.1.6 - 9.1.7 : pidstat -hurdw
	           10.0.0 -      : pidstat -hurdws

	         ・date_stamp.sh
	           起動インターバル時間、起動回数、起動最大時間、
	           出力ディレクトリを引数にして実行する。

	       [35;1m２．stop機能[m
	         [33;1mPID_FILE環境変数[m（common_def.sh参照）が示すファイルに
	         書かれたプロセスIDに対し、
	         同じプロセスID/コマンド/ユーザ名を持つ起動中のプロセスに対して
	         SIGKILLシグナルを送り、同ファイル内容をクリアする。

	       [35;1m３．show機能[m
	         [33;1mPID_FILE環境変数[m（common_def.sh参照）が示すファイルに
	         書かれたプロセスID/コマンド/実行ユーザ名に対し、
	         ps -efコマンドから同プロセスID/コマンド/実行ユーザ名を持つ行を取得して表示する。
	         [34;1m-sオプション[mが指定されている場合、
	         起動中の実行プロセスがあれば"ON"、
	         なければ"OFF"と表示する。


	[31;1m[Caution] : [m
	
	       [35;1m１．sadc格納パス[m
	           マシンアーキテクチャによって異なるパスを使用する。
	           出来る限り実行前に事前調査した方がよい。
	       
	       [35;1m２．mpstat、vmstat、iostatファイル名[m
	           {コマンド名}_{ホスト名}_{タイムスタンプ}.dmpとなっている。
	           draw_graph.shで、このファイル名の先頭アンダースコアから先を抜いて
	           末尾に.confを付加したファイル名が
	           conf/{システム区分}/ディレクトリに存在することを判定しており、
	           そのファイルをグラフ化コンフィグファイルとみなしている。
	           ファイル名形式はハードコーディングされているが、
	           この部分との連携を取ること。
	       
	       [35;1m３．proc_idとshow機能の課題[m
	           start時に記録するのは、プロセスIDだけで充分かもしれないが、
	           特殊なケースではそれは誤りになる。
	           その回避のため、プロセスID以外にユーザ名とコマンド名を記録している。
	           ただ、それによりshow機能の実行速度が劣化してしまっており、
	           特に複数ノード起動時における速度に影響することから、性能向上が望まれる。


	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/resstat.conf
	        ・conf/{SYSKBN}/command.conf


	[36;1m[Related Parameters] : [m
	        
	        [35;4;1mresstat.conf[m
	            ・AUTO_CONFIG
	            ・INTERVAL_SEC
	            ・TOTAL_MINUTES
	            ・ATTACH_PID
	            ・INTR_NUMBER
	
	
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
# resstat.sh
#
# [概要]
#    パフォーマンス計測のバックグラウンド起動、停止、及びステータス表示を行う。
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

# showの時に、出力をプロセスではなく、起動中か未起動かでON/OFFと出力するのみにする。
SHOW_ONOFF_FLAG=false

while getopts :sh ARG
do
    case "${ARG}" in
        s)
          SHOW_ONOFF_FLAG=true
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
# コマンドライン引数チェック（1st Argument必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

CMD="$1"

case "${CMD}" in
    "start")
        if [[ -z "$2" ]];then
            UsageMsg
            exit 4
        fi
        DATA_OUTDIR="$2"
        ;;
    "stop")
        
        ;;
    "show")

        ;;
    *)
        UsageMsg
        exit 4
        ;;
esac

########################################
# 変数定義
########################################
#共通の変数が未取り込みなら取り込む
if [[ -z "${COMMON_DEF_ON}" ]];then
    BIN_PWD=($(cd ${0%/*};pwd))
    export BIN_DIR=${BIN_PWD}
    COMMON_DEF="common_def.sh"
    source ${BIN_DIR}/${COMMON_DEF}
fi

#共通関数スクリプトの取り込み（全スクリプト共通）
COMMON_SCRIPT="common.sh"
source ${BIN_DIR}/${COMMON_SCRIPT}

##############################################################################
# sadcコマンドプロセスの起動/停止/参照
##############################################################################
case "${CMD}" in
    "start")
        # 既に起動していれば起動しない。
        # ⇒起動応答を早くする為と、PIDFILEだけでは「自然終了」の場合に誤検知してしまうため、ここでは何もしない。
#        if [[ -s "${PID_FILE}" ]];then
#            echo -e "Warn : resstat.sh : resstat has already started."
#            exit 0
#        fi

        # 出力ディレクトリ作成
        if [[ ! -d "${DATA_OUTDIR}" ]];then
            mkdir -m 0777 ${DATA_OUTDIR}
            checkReturnErrorFatal $? "Error : resstat.sh : make directory output miss"
        fi
        
        ##############################################################################
        # 必要変数設定
        ##############################################################################
        TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")                # 実行日付取得
        MYHOST=$(uname -n)                                  # 起動ノード取得
        MYUSER=$(whoami)                                    # 起動ユーザ取得
        
        # コマンド実行フラグ
        SAR_CMD=false
        MPSTAT_CMD=false
        VMSTAT_CMD=false
        IOSTAT_CMD=false
        PIDSTAT_CMD=false
        
        # sadcパスのセット
        MACHINE_NAME=$(uname -m)
        SADC_31=/usr/lib/sa/sadc
        SADC_32=/usr/lib/sa/sadc
        SADC_64=/usr/lib64/sa/sadc
        LOCAL32_SADC=/usr/local/lib/sa/sadc
        LOCAL64_SADC=/usr/local/lib64/sa/sadc

        # sysstatをソースからビルドした際のデフォルトインストール先に存在すれば、優先セット。
        if [[ -x "${LOCAL64_SADC}" ]];then
            SADC="${LOCAL64_SADC}"
        elif [[ -x "${LOCAL32_SADC}" ]];then
            SADC="${LOCAL32_SADC}"
        else
            # s390x, ia64, ppc64, s390 ：動作未テスト
            case "${MACHINE_NAME}" in
                "x86_64")
                    SADC=$SADC_64
                    ;;
                "s390x")
                    SADC=$SADC_64
                    ;;
                "ia64")
                    SADC=$SADC_64
                    ;;
                "ppc64")
                    SADC=$SADC_64
                    ;;
                "s390")
                    SADC=$SADC_31
                    ;;
                *)
                    SADC=$SADC_32
                    ;;
            esac
        fi

        ##############################################################################
        # resstat.confから全変数を取得。（グローバル変数セット）
        ##############################################################################
        loadAllParam_FromConf 1
        checkReturnErrorFatal $? "Error : resstat.sh : call loadAllParam_FromConf()"
        
        ##############################################################################
        # AUTO_CONFIGがONならばcofigure機能を呼び出す。
        ##############################################################################
        if [[ ${AUTO_CONFIG} == "ON" ]];then
            "${CONFIGURE_SH}"
            checkReturnErrorFatal $? "Error : resstat.sh start : auto configure execute."
            # 再度環境変数を取り込む。
            source "${BIN_DIR}/common_def.sh"
        fi
        
        ##############################################################################
        # 起動時間の取得
        ##############################################################################
        # 起動回数を算出
        FREQ=$(( ( TOTAL_MINUTES * 60 ) / INTERVAL_SEC + 1 ))
        checkReturnErrorFatal $? "Error : resstat.sh : calculate FREQ"
        
        echo -e "\nInfo : resstat.sh : Start : interval [${INTERVAL_SEC}], count [${FREQ}]"
        echo -e "Info : resstat.sh : Start : output to [${DATA_OUTDIR}]\n"

        ##############################################################################
        # アタッチプロセスの確認
        ##############################################################################
        SARX_EXEC=false
        PID_MONITOR=false
        if [[ -n "${ATTACH_PID}" ]];then
            PID_MONITOR=true
        fi

        ##############################################################################
        # 計測割り込み番号の取得
        ##############################################################################
        INTR_MONITOR=false
        if [[ -n "${INTR_NUMBER}" ]];then
            INTR_MONITOR=true
        fi
        
        ##############################################################################
        # sysstatバージョンの取得
        ##############################################################################
        SYSSTAT_VERSION=$(getSysstatVersion)
        checkReturnErrorFatal $? "${SYSSTAT_VERSION}"

        ##############################################################################
        # 起動コマンド要否の確認
        ##############################################################################
        # command.confから、空白行と先頭#を除いて各行を調査。
        SADC_S_OPT_DISK=false
        SADC_S_OPT_INT=false
        SADC_S_OPT_SNMP=false
        SADC_S_OPT_IPV6=false
        SADC_S_OPT_POWER=false
        
        for LINE in ${${(@f)"$(<${COMMAND_CONFFILE})"}:#[#]*}
        do
            case "${LINE}" in
            "sar"*)
                SAR_CMD=true
                case "${LINE}" in 
                "sar_d"*)
                    if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.3;then
                        SADC_OPTSTR="${SADC_OPTSTR} -d"                # 8.1.3未満のバージョン：sar -dの実行には、sadc -dが必要。
                    else
                        if ! ${SADC_S_OPT_POWER};then
                            SADC_S_OPT_DISK=true                       # 8.1.3以降のバージョンでは、-SオプションにDISKかXDISK(9.0.2以降)を使う。
                        fi
                    fi
                    ;;
                "sar__I"*)
                    if ${INTR_MONITOR};then
                        if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.3;then
                            SADC_OPTSTR="${SADC_OPTSTR} -I"            # 8.1.3未満のバージョン：sar -Iの実行には、sadc -Iが必要。
                        else
                            if ! ${SADC_S_OPT_INT};then
                                SADC_S_OPT_INT=true                    # 8.1.3以降のバージョン：sar -Iの実行には、sadc -S INTが必要。
                            fi
                        fi
                    fi
                    ;;
                "sar_n_IP"|\
                "sar_n_EIP"|\
                "sar_n_ICMP"|\
                "sar_n_EICMP"|\
                "sar_n_TCP"|\
                "sar_n_ETCP"|\
                "sar_n_UDP")
                    if ! ${SADC_S_OPT_SNMP};then
                        SADC_S_OPT_SNMP=true                           # sadc -S SNMPが必要。
                    fi
                    ;;
                "sar_n_SOCK6"|\
                "sar_n_IP6"|\
                "sar_n_EIP6"|\
                "sar_n_ICMP6"|\
                "sar_n_EICMP6"|\
                "sar_n_UDP6")
                    if ! ${SADC_S_OPT_IPV6};then
                        SADC_S_OPT_IPV6=true                           # sadc -S IPV6が必要。
                    fi
                    ;;
                "sar_m"*)
                    if ! ${SADC_S_OPT_POWER};then
                        SADC_S_OPT_POWER=true                          # sadc -S POWERが必要。
                    fi
                    ;;
                "sar_x"* | "sar__X"* )
                    if ${PID_MONITOR};then
                        SARX_EXEC=true                                 # pidstatが生まれる前、sar_xやsar__Xを使う場合は、特別なフラグを立てておく。
                    fi
                    ;;
                esac
                ;;
            "mpstat"*)
                MPSTAT_CMD=true
                ;;
            "vmstat"*)
                VMSTAT_CMD=true
                ;;
            "iostat"*)
                IOSTAT_CMD=true
                ;;
            "pidstat"*)
                if ${PID_MONITOR};then
                    PIDSTAT_CMD=true                                    # pidstatとpidstat-*。
                fi
                ;;
            esac
        done
        
        if ${SADC_S_OPT_DISK};then
            if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 9.0.2;then
                # 9.0.1以下のバージョン：sar -dの実行には、sadc -S DISKが必要。ただし、この場合パーティションが読めない。
                SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}DISK"
            else
                # 9.0.2以上のバージョン：sar -dの実行には、sadc -S XDISKを使う。sar -dでもパーティション認識可能。
                SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}XDISK"
            fi
        fi
        
        if ${SADC_S_OPT_INT};then
            SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}INT"
        fi
        
        if ${SADC_S_OPT_SNMP};then
            SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}SNMP"
        fi
        
        if ${SADC_S_OPT_IPV6};then
            SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}IPV6"
        fi
        
        if ${SADC_S_OPT_POWER};then
            SADC_S_OPTSTR="${SADC_S_OPTSTR}${SADC_S_OPTSTR:+,}POWER"
        fi
        
#        echo "Debug SADC OPTSTR = ${SADC_S_OPTSTR}"

        ##############################################################################
        # コマンド実行
        ##############################################################################
        # 【注意】 [コマンド名]_[ホスト名]_[現在時刻].[拡張子]で保存する。
        #          sadcを除き、これがそのままdraw_grapth.shに引き渡され、conf/プラットフォーム名 内のコンフィグ存在判定になる。
        #          具体的には、ダンプファイルの後方最長一致で_*を消した際、[その名称.conf]がconf/プラットフォーム名 の下のコンフィグの名前になる。
        #          この関連を意識すること。
        #          尚、sadcは、collect_resstat.shでsarダンプの出力を行うので、そちらを参照。
        
        if ${SAR_CMD};then
            SAR_OFILE="${DATA_OUTDIR}/${SADC_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${SADC_DATA_SUFFIX}"
            
            if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.3;then
                # 8.1.3未満のバージョン。単にオプション付加。
                ${SADC} ${=SADC_OPTSTR} ${INTERVAL_SEC} ${FREQ} > ${SAR_OFILE} &
                checkReturnErrorFatal $? "Error : resstat.sh : start sadc [${SADC}]"
            fi
            # ここでelseステートメントを使わないのは、テスト中のzshの動作（バグ？）によるもの。
            # else文の中で、リダイレクトによるファイル出力をバックグラウンドで実行すると、全てのリターンコードが1になってしまう。
            # ifステートメントでは発生しない不可思議な現象だが、zsh 4.3.10ではこの様な動作だった。
            if compVersion ${COMPVERSION_LARGE} ${SYSSTAT_VERSION} 8.1.2;then
                # 8.1.3以降のバージョン。-S オプション。
                ${SADC} ${SADC_S_OPTSTR:+-S} ${SADC_S_OPTSTR} ${INTERVAL_SEC} ${FREQ} > ${SAR_OFILE} &
                checkReturnErrorFatal $? "Error : resstat.sh : start sadc [${SADC}]"
            fi

            # sadcコマンドをバックグラウンド起動してプロセスIDを保存。
            SAR_PID=$!
            
            # アタッチするプロセスIDに対し、sar -x＆sar -Xを実行。
            if ${SARX_EXEC};then
                # 7.1.5以下では、sar -x とsar -Xを使用する。
                if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 7.1.6;then
                    sar -x "${ATTACH_PID}" ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${SAR_DATA_PREFIX}_x.${SAR_DATA_SUFFIX} &
                    checkReturnErrorFatal $? "Error : resstat.sh : start sar -x"
                    SAR_SX_PID=$!
                    sar -X "${ATTACH_PID}" ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${SAR_DATA_PREFIX}__X.${SAR_DATA_SUFFIX} &
                    checkReturnErrorFatal $? "Error : resstat.sh : start sar -X"
                    SAR_LX_PID=$!
                fi
            fi
            # それ以外のバージョンは、pidstatに回す。

        fi
        
        if ${MPSTAT_CMD};then
            # mpstat コマンドをバックグラウンド起動してプロセスIDを保存
            MPSTAT_OFILE=${DATA_OUTDIR}/${MPSTAT_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${MPSTAT_DATA_SUFFIX}
            mpstat -P ALL ${INTERVAL_SEC} ${FREQ} > ${MPSTAT_OFILE} &
            checkReturnErrorFatal $? "Error : resstat.sh : start mpstat "
            MPS_PID=$!
        fi

        if ${VMSTAT_CMD};then
            # vmstat コマンドをバックグラウンド起動してプロセスIDを保存
            VMSTAT_OFILE=${DATA_OUTDIR}/${VMSTAT_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${VMSTAT_DATA_SUFFIX}
            # -nを指定してヘッダ出力を1回に抑制する。
            vmstat -n ${INTERVAL_SEC} ${FREQ} > ${VMSTAT_OFILE} &
            checkReturnErrorFatal $? "Error : resstat.sh : start vmstat "
            VMS_PID=$!
        fi

        if ${IOSTAT_CMD};then
            # iostat コマンドをバックグラウンド起動してプロセスIDを保存
            IOSTAT_OFILE=${DATA_OUTDIR}/${IOSTAT_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${IOSTAT_DATA_SUFFIX}
            
            # sysstat 8.1.8未満（正確なバージョンは不明）では、iostat -xkを使う。
            if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.8;then
                iostat -xk ${INTERVAL_SEC} ${FREQ} > ${IOSTAT_OFILE} &
                checkReturnErrorFatal $? "Error : resstat.sh : start iostat -xk"
            fi
            
            # sysstat 8.1.8以降では、iostat -xk -pを使う。（else文にしないのはsarの場合と同じ理由によるもの）
            if compVersion ${COMPVERSION_LARGE} ${SYSSTAT_VERSION} 8.1.7;then
                iostat -xk -p ${INTERVAL_SEC} ${FREQ} > ${IOSTAT_OFILE} &
                checkReturnErrorFatal $? "Error : resstat.sh : start iostat -xk -p"
            fi
            
            IOS_PID=$!
        fi
        
        if ${PIDSTAT_CMD} && ${PID_MONITOR};then
            # pidstatの実行。このツールの命名規則流儀に反する例外として、各オプション名をファイル名に組み込む場合には、[-]で付加している。
            # draw_graph.shでは、sar以外のコマンドについては[_*]の後方最長一致で削除 + .confを探すため、
            # sar以外の場合に[_]は組み込めない。
            # これにより、conf/{SYSKBN}のpidstat用コンフィグも、pidstat-u.conf、という様に[-]で区切った名称を使うこと。
            # 尚、この制約は-hが登場する8.1.6以上なら省ける。（尤も、-hを使うとグラフ化の際に自力でタイムスタンプを付けなければならないということになるが）
            
            # 7.1.4以上の場合のみ実行
            if compVersion ${COMPVERSION_LARGE} ${SYSSTAT_VERSION} 7.1.3;then
                # 7.1.4以下では、pidstat -u と -r を別々に実行
                if compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 7.1.5;then
                    pidstat -p "${ATTACH_PID}" -u ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-u_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[1]=$!
                    pidstat -p "${ATTACH_PID}" -r ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-r_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[2]=$!
                # 8.0.1以下では、pidstat -u 、 -r 、 -d を別々に実行
                elif compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.0.2;then
                    pidstat -p "${ATTACH_PID}" -u ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-u_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[1]=$!
                    pidstat -p "${ATTACH_PID}" -r ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-r_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[2]=$!
                    pidstat -p "${ATTACH_PID}" -d ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-d_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[3]=$!
                # 8.1.5以下では、pidstat -u 、 -r 、 -d 、-w を別々に実行
                elif compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 8.1.6;then
                    pidstat -p "${ATTACH_PID}" -u ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-u_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[1]=$!
                    pidstat -p "${ATTACH_PID}" -r ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-r_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[2]=$!
                    pidstat -p "${ATTACH_PID}" -d ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-d_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[3]=$!
                    pidstat -p "${ATTACH_PID}" -w ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}-w_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[4]=$!
                # 9.1.7以下なら、pidstat -hurdw。-hで統合して出力可能（タイムスタンプのフィールドが壊れるというめんどくさい仕様はあるが、軽量化を優先）
                elif compVersion ${COMPVERSION_SMALL} ${SYSSTAT_VERSION} 10.0.0;then
                    pidstat -p "${ATTACH_PID}" -hurdw ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[1]=$!
                # それ以上（10.0.0以上）なら、pidstat -hurdws。
                else 
                    pidstat -p "${ATTACH_PID}" -hurdws ${INTERVAL_SEC} ${FREQ} > ${DATA_OUTDIR}/${PIDSTAT_DATA_PREFIX}_${MYHOST}_${TODAYS_DATE}.${PIDSTAT_DATA_SUFFIX} &
                    PIDS_PID[1]=$!
                fi
            fi
        fi
        
        # 実行時間帯に可能性のある日付を算出しておく。（ざっくり）
        # また、現在時刻、インターバル時間、起動回数を記録する。
        ${DATE_STAMP_SH} ${INTERVAL_SEC} ${FREQ} ${TOTAL_MINUTES} ${DATA_OUTDIR}
        
        # 起動プロセスIDを書き込む。フォーマットは、「[プロセスID]:[コマンド名]:[起動ユーザ名]」。
        # こうするのは、時間切れ終了の次回起動におけるstop時に、出来得る限り誤検知を防ぐため。
        # コマンド実行の分岐終了時でやらないのは、処理だけ先に終わらせるのを高速化し、
        # startから起動完了までのタイムラグを極力減らすため。ファイルアクセスは後回しにする。
        if ${SAR_CMD};then
            echo "${SAR_PID}:sadc:${MYUSER}" >> ${PID_FILE}
            if [[ -n "${SAR_SX_PID}" ]];then
                echo "${SAR_SX_PID}:sar:${MYUSER}" >> ${PID_FILE}
            fi
            if [[ -n "${SAR_LX_PID}" ]];then
                echo "${SAR_LX_PID}:sar:${MYUSER}" >> ${PID_FILE}
            fi
        fi
        if ${MPSTAT_CMD};then
            echo "${MPS_PID}:mpstat:${MYUSER}" >> ${PID_FILE}
        fi
        if ${VMSTAT_CMD};then
            echo "${VMS_PID}:vmstat:${MYUSER}" >> ${PID_FILE}
        fi
        if ${IOSTAT_CMD};then
            echo "${IOS_PID}:iostat:${MYUSER}" >> ${PID_FILE}
        fi
        if ${PIDSTAT_CMD} && ${PID_MONITOR} && [[ -n "${PIDS_PID}" ]];then
            for PIDSTAT_PROC_ID in ${PIDS_PID[*]}
            do
                echo "${PIDSTAT_PROC_ID}:pidstat:${MYUSER}" >> ${PID_FILE}
            done
        fi
        
        echo "resstat start ..."
        
        ;;
    "stop")
        # 【課題】
        # もっと軽量化は出来ないか？
        # 現在、「時間切れで自然終了」の場合にproc_idファイルに旧プロセスが残ってしまうので、
        # プロセスIDを未チェックでkillするわけにはいかず、
        # かつもしも他のユーザが一周して（30000程度で周期）同じプロセスIDを使ったり
        # 同じユーザで別プロセスを上げていた場合、killしてはいけなくなる。その回避のためにユーザ名とコマンド名の判定を入れている。
        # また、今のロジックでも全く同じプロセスIDで次回のresstatを起動したら、自然終了の場合は重複killになる。（害は無いが）
        # これでも完璧じゃないというのに、それでも処理が遅くて重い。proc_idファイルにプロセスID以外の情報は少し重いからか。
        # 目標として、複数ノード時のことを考えると、10msec以内に収めたい。
        
        # プロセスIDファイルがなければ強制終了。
        if [[ ! -s "${PID_FILE}" ]];then
            echo -e "Warn : resstat.sh : stop target process none"
        else 
            # 現在のプロセスリスト取得（sar、sadc、mpstat、iostat、vmstat、pidstatに絞っておく）
            CURRENT_PSLIST="$(ps -ef | grep -E "(sar|sadc|mpstat|iostat|vmstat|pidstat)")"
            
            for line in $(<"${PID_FILE}")
            do
                PS_COMMAND="${${line%[:]*}#*[:]}"                     # コマンド名（[:]を区切りに中心の値）
                PS_ID="${line%%[:]*}"                                 # プロセスID（[:]を区切りに左側）
                PS_USER="${line##*[:]}"                               # 起動ユーザ（[:]を区切りに右側）
                # ps -ef で見た場合にフィールドが8以上の場合で、
                # フィールド1（ユーザ）が起動ユーザと等しく、
                # フィールド2（プロセスID）がプロセスIDと等しく、
                # かつ行全体（フィールド8以降だが、等しいとは限らないため妥協する）にコマンドを含んでいること
                for PSLINE in ${(@f)CURRENT_PSLIST}
                do
                    : ${(A)ALINE::=${=PSLINE}}                        # 単語分割して配列セット
                    if [[ "${ALINE[1]}" == "${PS_USER}" && \
                          "${ALINE[2]}" == "${PS_ID}" && \
                          "${ALINE[*]}" == *"${PS_COMMAND}"* ]];then
                          kill -KILL ${PS_ID}                         # プロセスIDにkillシグナルを送り、エラーチェックはしない。
                          break
                    fi
                done
            done
            # プロセスIDファイルクリア
            cat /dev/null > "${PID_FILE}"
        fi
        
        echo "resstat stop ..."
        
        ;;
    "show")
        # 起動中のsadcプロセスを表示。
        if [[ ! -s "${PID_FILE}" ]];then
            if ${SHOW_ONOFF_FLAG};then
                echo -e "OFF"
            else
                echo -e "\nExecuting resstat list -- none\n"
            fi
        else
            # 現在のプロセスリスト取得（この時点でiostat、vmstat、mpstat、pidstat、sar、sadcに絞っておく）
            CURRENT_PSLIST="$(ps -ef | grep -E "(sar|sadc|mpstat|iostat|vmstat|pidstat)")"
        
            unset PSLIST
            for line in $(<"${PID_FILE}")
            do
                PS_COMMAND="${${line%[:]*}#*[:]}"                     # コマンド名（[:]を区切りに中心の値）
                PS_ID="${line%%[:]*}"                                 # プロセスID（[:]を区切りに左側）
                PS_USER="${line##*[:]}"                               # 起動ユーザ（[:]を区切りに右側）
                # ps -ef で見た場合にフィールドが8以上の場合で、
                # フィールド1（ユーザ）が起動ユーザと等しく、
                # フィールド2（プロセスID）がプロセスIDと等しく、
                # かつ行全体（フィールド8以降だが、等しいとは限らないため妥協する）にコマンドを含んでいること
                
                for PSLINE in ${(@f)CURRENT_PSLIST}
                do
                    : ${(A)ALINE::=${=PSLINE}}                        # 単語分割して配列セット
                    if [[ "${ALINE[1]}" == "${PS_USER}" && \
                          "${ALINE[2]}" == "${PS_ID}" && \
                          -z "${${ALINE[8]}:#*${PS_COMMAND}*}" ]];then
                        if ${SHOW_ONOFF_FLAG};then                    # 起動状態のみを判定する場合、この時点で[ON]と表示して終了する。
                            echo -e "ON"
                            exit 0
                        fi
                        
                        if [[ -n "${PSLIST}" ]];then
                            PSLIST="${PSLIST}\n${PSLINE}"
                        else
                            PSLIST="${PSLINE}"
                        fi
                        break
                    fi
                done

            done
            if [[ -n "${PSLIST}" ]];then
                echo -e "\nExecuting resstat list --\n"
                echo -e "${PSLIST}"
                echo -e "\n--\n"
            else
                if ${SHOW_ONOFF_FLAG};then
                    echo -e "OFF"
                else
                    echo -e "\nExecuting resstat list -- none\n"
                fi
            fi
        fi
        ;;
    *)
        UsageMsg
        exit 4
        ;;
esac

exit 0

