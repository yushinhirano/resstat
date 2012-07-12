#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : ctrlresstat.sh
	        
	        ctrlresstat.sh [ [34;1m-d output_dirname_suffix[m ] start
	        ctrlresstat.sh stop | clear | configure
	        ctrlresstat.sh [ [34;1m-s[m ] show
	        ctrlresstat.sh [ [34;1m-q[m ] [ [34;1m-d target_dirname_suffix[m ] [ [34;1m-t target_dir[m ] collect
	        ctrlresstat.sh [ [34;1m-d output_dir[m ] [ [34;1m-f target_file[m ] output
	        ctrlresstat.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: ctrlresstat.sh [m  -- パフォーマンス計測管理 単独ノード版
	
	       ctrlresstat.sh [ [34;1m-d output_dirname_suffix[m ] start
	       ctrlresstat.sh stop | clear | configure
	       ctrlresstat.sh [ [34;1m-s[m ] show
	       ctrlresstat.sh [ [34;1m-q[m ] [ [34;1m-d target_dirname_suffix[m ] [ [34;1m-t target_dir[m ] collect
	       ctrlresstat.sh [ [34;1m-d output_dir[m ] [ [34;1m-f target_file[m ] output
	       ctrlresstat.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mstart[m : パフォーマンス計測の起動。
	       
	       [35;1mstop[m : パフォーマンス計測の終了。
	       
	       [35;1mclear[m : パフォーマンス計測結果格納ディレクトリのクリア。
	       
	       [35;1mconfigure[m : SYSKBN、パフォーマンス計測対象CPU、NWインタフェース、ブロックデバイスの自動調整。
	       
	       [35;1mshow[m : パフォーマンス計測の起動ステータス表示。
	       
	       [35;1mcollect[m : パフォーマンス計測結果の収集とグラフ化。
	       
	       [35;1moutput[m : パフォーマンス計測結果のWindows閲覧用セット出力。
	
	
	[36;1m[Options] : [m
	
	       [34;1m-d[m : start時の計測結果格納ディレクトリ名/
	            collect時の収集対象ディレクトリ名/
	            output時の出力先ディレクトリパスを指定する。
	            start時：ここで指定した値に[{ホスト名}_]を前置して、dataディレクトリ内に作成する。
	            このオプションを指定しなければ、data/{ホスト名}_{YYYYMMDD_HH24MISS}となる。
	            collect時：収集対象ディレクトリとして、data/{ホスト名}_{指定の値}を指定する。
	            start時に指定した名称と同じものを指定すればよい。
	            output時：出力先のディレクトリ指定。start/collect時と異なり、パスで指定すること。
	       
	       [34;1m-t[m : collect時の収集対象ディレクトリパスを指定する。
	            -dオプションと異なり、こちらはディレクトリそのものをパスで渡す。
	            -dオプションと両方が指定された場合、こちらが優先され、
	            また、どちらも指定しない場合は
	            dataディレクトリから最新のディレクトリを検索して対象とする。
	       
	       [34;1m-s[m : short messageモード。showの場合のみ有効なオプション。
	            起動中ならON、停止中ならOFFと表示し、プロセスの表示を行わない。

	       [34;1m-f[m : output時のターゲットファイルを指定する。
	            collect機能で作成されたファイルとなる。
	            このオプションを指定しない場合、archiveディレクトリの
	            [output_{ホスト名}_]で始まる最新ファイルを対象とする。
	
	       [34;1m-q[m : quietモード。collectの時のみ有効なオプション。
	            終了メッセージ、アーカイブファイル、及びこのスクリプトが起動する。
	            グラフ作成スクリプトの標準出力/標準エラー出力を捨てる。

	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       自ノードに対するパフォーマンス計測の制御コマンドを受け付ける。
	       基本的には、指定されたコマンドに応じて適切なスクリプトを呼ぶのみとなる。
	       以下、各機能の対応である。
	       
	       [35;1m１．start機能[m
	         resstatの計測開始指示。
	         [33;1mbin/resstat.sh start[mを起動する。
	         出力ディレクトリ指定は、data/{ホスト名}_{YYYYMMDD_HH24MISS}となる。
	         （仕様の通り、1秒に二回起動すると失敗するので注意。
	           尚、[34;1m-dオプション[m指定で、タイムスタンプ部分を変更可能）

	       [35;1m２．stop機能[m
	         resstatの計測終了指示。
	         [33;1mbin/resstat.sh stop[mを起動する。

	       [35;1m３．show機能[m
	         resstatの計測起動状態表示。
	         [33;1mbin/resstat.sh show[mを起動する。
	         オプションに[34;1m-s[mを指定した場合、
	         そのオプションをそのままこのコマンドに渡す。

	       [35;1m４．clear機能[m
	         resstatの計測結果格納ディレクトリのクリア。
	         data、archive、outputディレクトリ、
	         及び起動中のプロセスIDを格納するproc_idをクリアする。
	         [31;1mそのため、必ずresstatプロセスを停止させた状態で行うこと。[m
	         
	       [35;1m５．configure機能[m
	         SYSKBN値、resstatの計測対象CPU、ネットワークインタフェース、ブロックデバイスを、
	         起動したノードに合わせて自動的に全てを計測するように設定する。
	         [33;1mbin/configure.sh[mを起動して行う。
	       
	       [35;1m６．collect機能[m
	         resstatの計測結果の収集とグラフ画像ファイルの作成。
	         １ノード１回分の起動結果ディレクトリについて行う。
	         対象ディレクトリは、[34;1m-tオプション[mでパス自体を指定するか、
	         [34;1m-dオプション[mでdataディレクトリ内の{ホスト名}_{指定値}を
	         検索する様指定できる。
	         どちらも指定しない場合のデフォルトでは、dataディレクトリ内の
	         [{ホスト名}_]で始まる最新ディレクトリを自動探索する。
	         実際の処理は、[33;1mbin/collect_resstat.sh[mを起動して行う。
	         また、[34;1m-q[mを指定されていた場合には、
	         スクリプト起動時に同オプションを付加する。
	         
	       [35;1m７．output機能[m
	         resstatの計測結果の、Windows閲覧用整形/軽量化出力。
	         collect機能で作成されたアーカイブファイルを指定して行う。
	         対象アーカイブファイルは、[34;1m-fオプション[mで指定するか、
	         デフォルトではarchiveディレクトリ内の
	         [output_{ホスト名}_]で始まる最新ファイルを自動探索する。
	         [33;1mbin/getarchive_clean.sh[mを起動して行う。
	         
	         
	       [35;1mEX．ツール起動方法[m
	         使用時は、(configure⇒)start⇒stop(または起動時間終了)⇒collect⇒output
	         という順に起動すれば、archiveディレクトリ内にzipファイルが作成されている。
	         特にstart、collect、outputでオプションを指定してパスを指定せずとも、
	         collectやoutputは「最新」を探す仕様であるため、直前の起動分について処理を行うことになる。
	         
	         configureはこのパッケージを展開時に、
	         clearはディレクトリ内にファイルが溜まってきた場合に、
	         showは起動中かどうかを確認する場合に使用すればよい。


	[31;1m[Caution] : [m
	
	       [35;1m１．clear機能[m
	           clearはディレクトリ内のデータ及び、起動中のプロセス状態をリセットする。
	           そのため、必ずresstat停止状態を確認して行うこと。
	           また、確認入力も何もなく削除する為、使用の際には充分注意すること。
	       
	       [35;1m２．collect、output機能[m
	           オプションなしでは、「最新」を探索する。
	           そのため、perstat start⇒stopを連続で起動してしまうと、
	           旧の起動結果はオプションを指定しなければ取得できなくなる。
	           基本的には、１回のstart⇒stop後にcollect⇒outputと行うこと。

	
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
# ctrlresstat.sh
#
# [概要]
#    パフォーマンス計測シェル全体コントロールシェル。ユーザは基本このシェルを起動するのみで良いとするUIシェル。
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

# showの時に、出力をプロセスではなく、起動中か未起動かでON/OFFと出力するのみにする。
SHOW_ONOFF_FLAG=false
# プログレスechoやコマンド表示を抑制するモード。
MODE_QUIET=false

while getopts :sqd:t:f:h ARG
do
    case "${ARG}" in
        s)
          SHOW_ONOFF_FLAG=true
        ;;
        q)
          MODE_QUIET=true
        ;;
        d)
          # 面倒なので３つに入れてしまう。
          DATA_TO_DIR_SUFFIX="${OPTARG%/}"
          COLLECT_TDIR_SUFFIX="${DATA_TO_DIR_SUFFIX}"
          OUPTUT_TARGET_DIR="${DATA_TO_DIR_SUFFIX}"
        ;;
        t)
          COLLECT_TARGET_DIR="${OPTARG%/}"
        ;;
        f)
          OUTPUT_TARGET_FILE="${OPTARG%/}"
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

CMD="$1"

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

# 実行日付取得
TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")

# 起動ノード取得
MYHOST=$(uname -n)

##############################################################################
# 処理の実行
##############################################################################
case "${CMD}" in
    "start")
        # 計測データ用ディレクトリの作成
        if [[ -n "${DATA_TO_DIR_SUFFIX}" ]];then
            THIS_DATA_DIR="${DATA_DIR}/${MYHOST}_${DATA_TO_DIR_SUFFIX}"
        else 
            THIS_DATA_DIR="${DATA_DIR}/${MYHOST}_${TODAYS_DATE}"
        fi
        # ディレクトリ作成はresstat.shに任せる。
#        mkdir -m 0777 ${THIS_DATA_DIR}
#        CMDRET=$?
#        if [[ ${CMDRET} -ne 0 ]];then
#            echo -e "Error : ctrlresstat.sh : data directory can't make [${THIS_DATA_DIR}]"
#            exit 4
#        fi
        
        # 計測開始
        ${RESSTAT_SH} start ${THIS_DATA_DIR}
        CMDRET=$?
        if [[ ${CMDRET} -ne 0 ]];then
            echo -e "Error : ctrlresstat.sh : resstat.sh start error"
            exit 4
        fi
        # start内でauto configureされている可能性があるので、この先common_def.shの内容を使うなら再定義が必要。
        
        ;;
    "stop")
        # 計測終了
        ${RESSTAT_SH} stop
        CMDRET=$?
        if [[ ${CMDRET} -ne 0 ]];then
            echo -e "Error : ctrlresstat.sh : resstat.sh stop error"
            exit 4
        fi
        ;;
    "show")
        # 計測プロセス表示
        if ${SHOW_ONOFF_FLAG};then
            ${RESSTAT_SH} -s show
        else 
            ${RESSTAT_SH} show
        fi
        CMDRET=$?
        if [[ ${CMDRET} -ne 0 ]];then
            echo -e "Error : ctrlresstat.sh : resstat.sh show error"
            exit 4
        fi
        ;;
    "clear")
        # 計測データ全クリア
        echo -e "  ##---- : ctrlresstat.sh : DataDir All Clear Start"
        for CLEARDIR in $(command ls -1d ${DATA_DIR}/*)
        do
            # エラーチェックしない
            rm -rf ${CLEARDIR}
        done
        
        # アーカイブディレクトリ全クリア
        rm -rf ${ARCHIVE_DIR}/*
        
        # 複数NODE対象起動時の出力推奨領域をクリア
        for CLEARDIR in $(command ls -1d ${ALLNODE_OUTPUT_DIR}/*)
        do
            # エラーチェックしない
            rm -rf ${CLEARDIR}
        done
        
        # プロセスID全クリア
        cat /dev/null > "${PID_FILE}"
        
        echo -e "  ##---- : ctrlresstat.sh : DataDir All Clear End"
        
        ;;
    "collect")
        # データ集計とグラフ化
        # 既にターゲットそのものを指定されていればそちらを使用。
        if [[ -z "${COLLECT_TARGET_DIR}" ]];then
           # サフィックスが指定されている場合にはそちらを使用。
           if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
               COLLECT_TARGET_DIR="${DATA_DIR}/${MYHOST}_${COLLECT_TDIR_SUFFIX}"
           else
               # デフォルト動作
               # データディレクトリ配下のタイムスタンプソート順で検索
               for DIR_BUFF in $(ls -1td  ${DATA_DIR}/*)
               do
                   # ホスト名_から始まる最新ディレクトリを取得
                   BUFF=$(find ${DIR_BUFF} -maxdepth 0 -type d -name "${MYHOST}_*")
                   if [[ -n "${BUFF}" ]];then
                       COLLECT_TARGET_DIR="${BUFF}"
                       break
                   fi
               done
           fi
        fi
        
        # 集計ターゲットディレクトリが見つからなければ終了
        if [[ -z "${COLLECT_TARGET_DIR}" || ! -d "${COLLECT_TARGET_DIR}" ]];then
            echo -e "Warn : ctrlresstat.sh : collect target is none"
            exit 1
        fi
        
        # 集計/グラフ化シェルの起動
        if ${MODE_QUIET};then
            "${COLLECT_RESSTAT_SH}" -q "${COLLECT_TARGET_DIR}"
        else
            "${COLLECT_RESSTAT_SH}" "${COLLECT_TARGET_DIR}"
        fi
        CMDRET=$?
        if [[ ${CMDRET} -ne 0 ]];then
            echo -e "Error : ctrlresstat.sh : ${COLLECT_RESSTAT_SH} [${COLLECT_TARGET_DIR}] error"
            exit 4
        fi
        
        ;;
    "output")
        # グラフ化のWindows閲覧用クリーン
        if [[ -z "${OUTPUT_TARGET_FILE}" ]];then
           # アーカイブディレクトリ配下のタイムスタンプソート順で検索
           for DIR_BUFF in $(ls -1td  ${ARCHIVE_DIR}/*)
           do
               # output_ホスト名_から始まる最新ファイルを取得
               BUFF=$(find ${DIR_BUFF} -maxdepth 0 -type f -name "${OUTPUT_DIR_PREFIX}_${MYHOST}_*")
               if [[ -n "${BUFF}" ]];then
                   OUTPUT_TARGET_FILE="${BUFF}"
                   break
               fi
           done
        fi
        
        # ターゲットファイルが見つからなければ終了
        if [[ -z "${OUTPUT_TARGET_FILE}" || ! -s "${OUTPUT_TARGET_FILE}" ]];then
            echo -e "Warn : ctrlresstat.sh : output target is none"
            exit 1
        fi
        
        # アーカイブクリーンシェルの起動
        if [[ -n "${OUPTUT_TARGET_DIR}" ]];then
            "${GET_ARCHIVE_CLEAN_SH}" -d "${OUPTUT_TARGET_DIR}" "${OUTPUT_TARGET_FILE}"
        else
            "${GET_ARCHIVE_CLEAN_SH}" "${OUTPUT_TARGET_FILE}"
        fi
        CMDRET=$?
        if [[ ${CMDRET} -ne 0 ]];then
            echo -e "Error : ctrlresstat.sh : ${GET_ARCHIVE_CLEAN_SH} [${OUTPUT_TARGET_FILE}] error"
            exit 4
        fi
        
        ;;
    "configure")
        # config実行シェルの呼び出し
        "${CONFIGURE_SH}"
        exit $?
        ;;
    *)
        UsageMsg
        exit 4
        ;;
esac


exit 0

