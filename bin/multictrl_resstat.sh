#!/usr/bin/env zsh

########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : multictrl_resstat.sh
	        
	        multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d output_dirname_suffix[m ] start
	        multictrl_resstat.sh [ [34;1m-f node_file[m ] { stop | show | clear | configure | sync }
	        multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d target_dirname_suffix[m ] collect dest_dir
	        multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d dest_dir[m ] output src_dir
	        multictrl_resstat.sh [ [34;1m-h[m ]
	
	EOF

}

########################################
# function HelpMsg
########################################
function HelpMsg(){
    #PAGER変数の設定取り込み
    source $(cd ${CURRENT_SCRIPT%/*};pwd)/"common_def.sh"
    LANG=ja_JP.utf8
    ${=PAGER} <<-EOF
	
	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: multictrl_resstat.sh [m  -- パフォーマンス計測管理 複数ノード版
	
	       multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d output_dirname_suffix[m ] start
	       multictrl_resstat.sh [ [34;1m-f node_file[m ] { stop | show | clear | configure | sync }
	       multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d target_dirname_suffix[m ] collect dest_dir
	       multictrl_resstat.sh [ [34;1m-f node_file[m ] [ [34;1m-d dest_dir[m ] output src_dir
	       multictrl_resstat.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mstart[m : パフォーマンス計測の起動。
	       
	       [35;1mstop[m : パフォーマンス計測の終了。
	       
	       [35;1mclear[m : パフォーマンス計測結果格納ディレクトリのクリア。
	       
	       [35;1mconfigure[m : SYSKBN、パフォーマンス計測対象CPU、NWインタフェース、ブロックデバイスの自動調整。
	       
	       [35;1msync[m : conf、conf/${SYSKBN}ディレクトリ内の全ファイル同期。
	       
	       [35;1mshow[m : パフォーマンス計測の起動ステータス表示。
	       
	       [35;1mcollect[m : パフォーマンス計測結果の収集とグラフ化。
	       
	       [35;1moutput[m : パフォーマンス計測結果のWindows閲覧用セット出力。
	       
	       [35;1mdest_dir[m : collect結果の収集先ディレクトリ
	       
	       [35;1msrc_dir[m : outputの対象ディレクトリ
	
	
	[36;1m[Options] : [m
	
	       [34;1m-d[m : start時の計測結果格納ディレクトリ名サフィックス/
	            collect時の収集対象ディレクトリ名サフィックス/
	            output時の出力先ディレクトリを指定する。
	            start/collect時：ここで指定した値をctrlresstat.shの-dオプションに付加する。
	                             start時に指定した場合、同じオプションをcollectでも付加すればよい。
	            output時：ここで指定したディレクトリを、出力ファイルの格納ディレクトリとする。
	                      指定しなければarchiveディレクトリとなる。
	                      このディレクトリは、入力ディレクトリと異なるディレクトリを指定すること。
	                      start、collect時と異なり、こちらはパス指定。
	
	       [34;1m-f[m : 起動対象ノード記述ファイルを指定する。
	            指定しない場合、デフォルトはconf/targethost。

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       [35;1mnode_file[mに記述されているノード対する
	       パフォーマンス計測の一括制御コマンド送信を受け付ける。
	       デフォルト[35;1mnode_file[mは、conf/targethostを使用する。
	       [35;1mnode_file[mのフォーマットは、
	       1行に名前解決可能な1ノード名 or IPアドレスを記述し、
	       空行及び先頭[#]は読み飛ばしている。
	       
	       基本的には、指定されたコマンドに応じて、
	       対象全ノードにctrlresstat.shを起動するのみとなる。
	       以下、各機能の対応である。
	       
	       [35;1m１．start機能[m
	         resstatの計測開始指示。
	         [33;1mbin/ctrlresstat.sh start[mをsshバックグラウンド起動する。

	       [35;1m２．stop機能[m
	         resstatの計測終了指示。
	         [33;1mbin/resstat.sh stop[mを起動する。

	       [35;1m３．show機能[m
	         resstatの計測起動状態表示。
	         [33;1mbin/resstat.sh show[mを起動する。
	         オプションに[34;1m-s[mを指定して、ON/OFFのみの表示とする。

	       [35;1m４．clear機能[m
	         resstatの計測結果格納ディレクトリのクリア。
	         [33;1mbin/ctrlresstat.sh clear[mを起動する。
	         data、archive、outputディレクトリ、
	         及び起動中のプロセスIDを格納するproc_idをクリアする。
	         [31;1mそのため、必ずresstatプロセスを停止させた状態で行うこと。[m
	         
	       [35;1m５．configure機能[m
	         SYSKBN値、resstatの計測対象CPU、ネットワークインタフェース、ブロックデバイスを、
	         起動したノードに合わせて自動的に全てを計測するように設定する。
	         [33;1mbin/configure.sh[mを起動して行う。
	         尚、conf/resstat.confで、AUTO_CONFIGパラメータをONにしていれば、
	         グラフ作成時に自動的にconfigureするため、必要ない。
	       
	       [35;1m６．sync機能[m
	         confディレクトリ、及びconf/${SYSKBN}ディレクトリ内の全ファイルを、
	         scpコマンドで起動対象全ノードに配布する。
	         配布は[33;1mmultisetup/bin/scp_hosts.sh[mをバックグラウンド起動して行う。
	         
	         同期するconf以下のディレクトリは、SYSKBNパラメータに依存する。
	         この機能の使用前にconfigure機能を使用しておくか、
	         手動でconf/resstat.shのSYSKBNを修正しておくこと。
	       
	       [35;1m７．collect機能[m
	         resstatの計測結果の収集とグラフ画像ファイルの作成。
	         カレントノードの[33;1mbin/node1collect.sh[mをバックグラウンド起動し、
	         その中で[33;1mbin/collect_resstat.sh[mを呼び出して、
	         終了を待った後に結果ファイルをカレントノードに転送する。
	         （尚、全てをバックグラウンド起動した後は、waitを行って終了を待つ）
	         
	       [35;1m８．output機能[m
	         resstatの計測結果の、Windows閲覧用整形/軽量化出力。
	         collect機能で収集先に指定したディレクトリをそのまま指定して行う。
	         この機能の出力先は[34;1m-dオプション[mで指定するか、
	         デフォルトではarchiveディレクトリとなる。
	         
	         指定ディレクトリから拡張子pngのファイルを全て取得し、
	         [33;1mbin/make_htmlforgraph.sh[mを起動してHTMLを作成した上で、
	         そのファイル群をzipに固める。
	         
	         この機能はローカルノードで完結しており、リモートコマンドを発行しない。
	         
	         
	       [35;1mEX．ツール起動方法[m
	         使用時は、(configure⇒)start⇒stop(または起動時間終了)⇒collect⇒output
	         という順に起動すれば、archiveディレクトリ内に
	         全ノードのzipファイルが作成されている。
	         
	         configureはこのパッケージを展開時に、
	         clearはディレクトリ内にファイルが溜まってきた場合に、
	         showは起動中かどうかを確認する場合に使用すればよい。
	         他、confディレクトリのファイルを修正した場合、syncによって同期することが出来る。


	[31;1m[Caution] : [m
	
	       [35;1m１．起動条件[m
	           起動前に、以下の条件が満たされているかチェックする。
	           
	           ・conf/targethost
	             このファイルに、起動対象の全てのノードを記述すること。
	           
	           ・resstatツールの展開先
	             起動対象ノードの全てについて、同じディレクトリに展開されていること。
	             また、全てのノードでresstat起動条件が満たされていること。
	           
	           ・起動ユーザ
	             起動対象ノードの全てについて、
	             このスクリプトの起動ユーザと同じユーザが存在すること。
	             また、このユーザにresstatツールの実行権限/読み込み権限があること。
	           
	           ・ssh公開鍵接続
	             このノードから(自ノードを含む)起動対象ノードの全てについて、
	             同じユーザ間でsshでパスフレーズ無の公開鍵を用いて接続可能であること。
	             （尚、sshの接続ポートは22のみ、また、ssh/scp以外のリモートコマンドは未対応。
	               要望があれば次期バージョンで対応予定。無いと思うが）
	       
	       [35;1m２．clear機能[m
	           clearはディレクトリ内のデータ及び、起動中のプロセス状態をリセットする。
	           そのため、必ずresstat停止状態を確認して行うこと。
	           また、確認入力も何もなく削除する為、使用の際には充分注意すること。
	       
	       [35;1m３．start、collect機能[m
	           startはオプションを付けず、また、
	           一回のstartの後、次のstartを行わずにstop⇒collect、outputと行うこと。
	           連続起動すると、collectやoutputは「最新」を取るため、
	           旧結果が取得不可能になる。
	           
	           旧結果に対してcollectを行うには、予めstart時に
	           ディレクトリサフィックスを指定しておき、
	           collect実行時に同じサフィックスを指定する必要がある。
	           

	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/targethost


	[36;1m[Author & Copyright] : [m
	        
	        resstat version ${RESSTAT_VERSION}.
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.
	
	
	EOF

}


########################################
#
# multictrl_resstat.sh
# (zshスクリプト。NODEファイル読み込みにzsh独自の機能を使用。変数定義と展開も同じく)
#
# [概要]
#    指定されたノード記述ファイルを元に、全ノードでresstatを実行する。
#
# [起動条件、仕様]
# [引数]
#   UsageMsg()、HelpMsg()参照。
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

while getopts :d:f:h ARG
do
    case "${ARG}" in
        d)
          # 面倒なので３つに入れてしまう。
          DATA_TO_DIR_SUFFIX="${OPTARG%/}"
          COLLECT_TDIR_SUFFIX="${DATA_TO_DIR_SUFFIX}"
          TO_ARCHIVE="${DATA_TO_DIR_SUFFIX}"
        ;;
        f)
          # ノード記述ファイル
          NODEFILE="${OPTARG}"
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
# コマンドライン引数チェック（1st Arg必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

CMD="$1"

case "${CMD}" in
    "start")
        COMSTR="start"
        ;;
    "stop")
        COMSTR="stop"
        ;;
    "show")
        COMSTR="show"
        ;;
    "collect")
        if [[ -z "$2" ]];then
            UsageMsg
            exit 4
        fi
        CPTODIR="${2%/}"
        COMSTR="collect"
        ;;
    "output")
        if [[ -z "$2" ]];then
            UsageMsg
            exit 4
        fi
        OUTPUT_ROOT="${2%/}"
        ;;
    "clear")
        COMSTR="clear"
        ;;
    "configure")
        COMSTR="configure"
        ;;
    "sync")
        COMSTR="sync"
        ;;
    *)
        UsageMsg
        exit 4
esac


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

LOGIN_USER="$(whoami)"

# ノード記述ファイル設定。
# オプション指定されていない場合、デフォルト値を取り込む。
: ${NODEFILE:=${RESSTAT_TG_HOSTS}}

# ノードファイルチェック
if [[ ! -r "${NODEFILE}" ]];then
    echo -e "No NodeConfig File : ${NODEFILE}\n"
    exit 4
fi

##############################################################################
# Nodeファイルを読み、その各行を対象ノードとみなして起動
##############################################################################
#show機能は特殊な処理を行う。
if [[ "${CMD}" == "show" ]];then

    # 全ホスト名の最大文字数を取得して、ブランクのオフセットとして利用する。
    # length()は2バイト以上の文字を含む場合にLOCALE設定が絡むが、ノード名のファイルくらいなら大丈夫だろう。
    HOSTNAME_MAX=$(awk 'BEGIN{__max__ = 1}
                        ( NF > 0 && $0 !~ /^#.*/ ){ if (length($0) > __max__) {
                                                        __max__ = length($0);
                                                    }
                                                  }
                        END{print __max__}' ${NODEFILE})
    # 最大桁数から2桁余裕を持たせる。
    BLANK_OFFSET=$(( HOSTNAME_MAX + 2))
    # 左寄せ＆桁数指定のSPACE埋め変数を定義。
    typeset -L ${BLANK_OFFSET} NODE_SPACING
    
fi


unset COMPLETE_LIST
# 先頭#以外の行を読む。
for NODE in ${${(@f)"$(<${NODEFILE})"}:#[#]*}
do
    # 重複起動回避 
    if [[ -n "${(M)COMPLETE_LIST:#${NODE}}" ]];then
        continue
    else
        COMPLETE_LIST=(${COMPLETE_LIST[*]} "${NODE}")
    fi
    
    # showコマンドの場合は対象ノードのechoをここでは行わない。（冗長になる上フォーマットが崩れるので、出力先に任せる。management_toolで使用するのみ）
    # また、ローカルでのみ完結するoutput機能、及びスクリプトからscp_hosts.shを呼ぶsync機能もechoしなくてよい。
    if [[ "${CMD}" != show && "${CMD}" != output && "${CMD}" != sync ]];then
        echo -e "        ---------------------------------------------------------------------"
        echo -e "        ---- NODE:${NODE} resstat ${CMD}"
        echo -e "        ---------------------------------------------------------------------\n"
    fi

    case "${CMD}" in
        "start")
            # バックグラウンドで即リターン。
            # ssh -f の場合、「sshで接続してコマンド発行」までがフォアグラウンドのため、コマンド自体をバックグラウンド化する。
            if [[ -n "${DATA_TO_DIR_SUFFIX}" ]];then
                nohup ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH}"' -d '"${DATA_TO_DIR_SUFFIX}"' '"${COMSTR}" &> /dev/null &
            else
                nohup ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH}"' '"${COMSTR}" &> /dev/null &
            fi
            ;;
        "stop")
            # 現在はフォアグラウンド起動。
            # 少しでも高速化するため、resstat.shを直接呼ぶ。
            ssh ${LOGIN_USER}@${NODE} "${RESSTAT_SH}"' '"${COMSTR}"' &> /dev/null'
            ;;
        "show")
            # 桁数SPACE埋め変数に格納して出力に利用する。
            NODE_SPACING="${NODE}"
            # -sオプションを付けて、出力内容をON/OFF表示のみとする。
            # この機能はバックグラウンドが逆に遅いと思われる。（結果の回収のオーバヘッドが大きいので）
            # そのため、ctrlresstat.shを呼ばない。無駄なプロセス生成を避けることで、少しでも高速化したい。
            echo -e "  ----- ${NODE_SPACING}| $(ssh ${LOGIN_USER}@${NODE} "${RESSTAT_SH}"' -s '"${COMSTR}")"
            ;;
        "collect")
            # 並列処理化
            # 各ノードに対し、バックグラウンドでcollect実行スクリプトを流す。
            if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
                nohup ${NODE1COLLECT_SH} -d "${COLLECT_TDIR_SUFFIX}" ${LOGIN_USER} ${NODE} "${CPTODIR}" &> /dev/null &
            else
                nohup ${NODE1COLLECT_SH} ${LOGIN_USER} ${NODE} "${CPTODIR}" &> /dev/null &
            fi

            ;;
            
        "output")
            # 引数チェック
            if [[ -z "${OUTPUT_ROOT}" || ! -d "${OUTPUT_ROOT}" ]];then
                echo "Error : multictrl_resstat.sh : srcdir is empty or not directory"
                exit 4
            fi
            
            # 出力先が設定されていれば変更しない。デフォルトはarchive。
            : ${TO_ARCHIVE:="${ARCHIVE_DIR}"}
            
            # 邪魔なディレクトリは再作成
            if [[ -e ${TO_OUTPUT::=${TO_ARCHIVE}/${OUTPUT_ROOT##*/}} ]];then
                rm -rf "${TO_OUTPUT}"
            fi
            mkdir -p "${TO_OUTPUT}"

            # ディレクトリチェンジを含むため、パスは相対から絶対に修正。
            TO_OUTPUT=($(cd ${TO_OUTPUT};pwd))
            
            cd ${OUTPUT_ROOT}/
            # OUTPUTDIRから拡張子pngファイルを全て出力先ディレクトリへ階層ごとコピー。
            find ./ -name "*.png" | cpio -pdmu "${TO_OUTPUT}/"
            
            # コピーした階層でHTMLファイルを作成させる。
            "${MAKE_HTML_SH}" -m -x "${HTML_NOT_TARGET}" "${TO_OUTPUT}/"
            
            cd "${TO_OUTPUT}/../"
            
            # 最終出力のアーカイブは、閲覧がwindowsであることが多いためzipにする。
#            tar jcf "${TO_OUTPUT##*/}.tbz2" "${TO_OUTPUT##*/}/"
            if [[ -e "${TO_OUTPUT##*/}.zip" ]];then
                rm -rf "${TO_OUTPUT##*/}.zip"
            fi
            zip -q -r "${TO_OUTPUT##*/}.zip" "${TO_OUTPUT##*/}/"
            rm -rf "${TO_OUTPUT}"
            echo -e "\n  ##---- output complete to : [ ${TO_OUTPUT}.zip ]\n"
            break
            ;;
        "clear")
            nohup ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH}"' '"${COMSTR}" &> /dev/null &
            ;;
        "configure")
            ssh ${LOGIN_USER}@${NODE} "${CTRLRESSTAT_SH}"' '"${COMSTR}"' &> /dev/null'
            ;;
        "sync")
            # confディレクトリ、及びconf/{SYSKBN}ディレクトリを全ノードに展開する。
            echo -e "\n        conf directory copy start......\n"
            for FILE_IN_CONF in $(find "${CONF_DIR}"/* -maxdepth 0 -type f)
            do
                nohup "${SCP_HOSTS_SH}" "${FILE_IN_CONF}" &> /dev/null &
            done
            
            echo -e "\n        conf/${SYSKBN} directory copy start......\n"
            for FILE_IN_SYSKBN in $(find "${CONF_DIR}/${SYSKBN}"/* -maxdepth 0 -type f)
            do
                nohup "${SCP_HOSTS_SH}" "${FILE_IN_SYSKBN}" &> /dev/null &
            done
            
            break
            ;;
    esac
    
done

# 実行コマンドがcollect、clear、syncの場合、並列に起動したssh～scpプロセスをwaitする。
# わざわざスクリプト化してcollectをバックグラウンドで流したのは、
# グラフ作成の一連の処理を各マシンで並列化させるためである。
# ssh -f で流した場合、waitが効かないからと、scpはバックグラウンドで流すと終了時が解らないから。
if [[ "${CMD}" == "collect" || "${CMD}" == "clear" || "${CMD}" == "sync" ]];then
    echo -e "\n        ${CMD} waiting .....\n"
    wait
    echo -e "\n        complete.\n"
fi

exit 0


