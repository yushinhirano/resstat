#!/usr/bin/env zsh

########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : configure.sh
	        
	        configure.sh
	        configure.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: configure.sh [m  -- パフォーマンス計測対象自動設定
	
	       configure.sh
	       configure.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       sysstatパッケージ、procsパッケージに応じた「システム区分」パラメータ、
	       及びこのスクリプトを起動したマシンのCPUコア数、ネットワークインタフェース、
	       ブロックデバイス名に応じて、resstat.confの修正を行う。
	       修正パラメータは以下の４つである。
	         ・[32;1mSYSKBN[m
	         ・[32;1mCPU_CORES[m
	         ・[32;1mBLOCK_DEVICES[m
	         ・[32;1mNETWORK_INTERFACES[m
	       
	       それぞれ、情報の取得元は以下の通り。
	       
	         ・システム区分               : sar -V、vmstat -Vの出力とconf/syskbn.confに応じて、
	                                        conf/linuxとdocuments/linuxのシンボリックリンクを貼り替える。
	                                        また、SYSKBN値をlinuxに修正する。
	         ・CPUコア数                  : mpstat -P ALLの出力。
	                                        CPUのカラム番号は
	                                        conf/graph.confから取得。
	         ・ネットワークインタフェース : netstat -iの出力。
	                                        第一カラムの第三行以降全て。
	         ・ブロックデバイス           : iostat -pの出力。
	                                        デバイス名のカラム番号は
	                                        conf/graph.confから取得。
	       
	       尚、この機能はパッケージ展開後に一度起動すればよいため、
	       起動後はAUTO_CONFIGパラメータを自動的にOFFに修正する。
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．取得元と使用対象のラグ[m
	           ネットワークインタフェースは、
	           netstatの出力するインタフェース名を元にするが、
	           この値を使用するのはnetstatではなくsar -n DEVやEDEVである。
	           （一応、この差による影響はないと思われるが）
	           
	
	       [35;1m２．パラメータファイルフォーマット[m
	           resstat.confは、パラメータ名の前に空白を入れても一応動作するが、
	           このスクリプトがそのようなファイルを修正する場合には動作しない。
	           また、全角スペースやタブも入れてはならない。
	           awkでパラメータ名を探す時に、
	           「半角SPの0回以上の繰り返し」「=」「半角SPの0回以上の繰り返し」という
	           単純な条件でフィールドを区切っているため。
	       
	       [35;1m３．情報の取得元コマンドフォーマット[m
	           mpstat、netstat、iostatの出力フォーマットが、
	           バージョン違いなどで想定と異なる場合には
	           上手くパラメータを取得できない。
	

	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/resstat.conf
	        ・conf/syskbn.conf
	        ・conf/graph.conf
	        ・conf/{SYSKBN}/all_header.conf


	[36;1m[Related Parameters] : [m

	        [35;4;1mresstat.conf[m
	            ・SYSKBN
	            ・CPU_CORES
	            ・BLOCK_DEVICES
	            ・NETWORK_INTERFACES
	            ・AUTO_CONFIG
	
	        [35;4;1mgraph.conf[m
	            ・CPU_FIELD_NAME
	            ・IOSTAT_DEVICE_FIELD_NAME
	        
	        [35;4;1m{SYSKBN}/all_header.conf[m
	            ・MPSTAT
	            ・IOSTAT
	
	
	[36;1m[Author & Copyright] : [m
	        
	        resstat version ${RESSTAT_VERSION}.
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.
	
	
	EOF

}


########################################
#
# zshスクリプト
# configure.sh
#
# [概要]
#    起動したマシンのCPUコア数、ネットワークインタフェース、デバイス名に応じて、
#    resstat.confの修正を行う。
#
# [起動条件、仕様]
# [引数]
#   UsageMsg()、HelpMsg()参照。
#
########################################

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
# SYSKBN調整
########################################
# SYSKBNを使用している変数を介さずに行う。
PROCS_VERSION=$(getProcsVersion)
SYSSTAT_VERSION=$(getSysstatVersion)

# 現在のところ、3.2.7以上ならprocsバージョンは不問。それ以上のバージョンでもvmstatは変わっていないため。
# sysstatバージョンのみ判定する。
if compVersion ${COMPVERSION_LARGE} ${PROCS_VERSION} 3.2.6;then
    # 空行及び先頭[#]を除いて、conf/syskbn.confから行単位で処理する。
    for LINE in ${${(@f)"$(<${SYSKBN_CONFFILE})"}:#[#]*}
    do
        # 各行を単語分割して配列化
        : ${(A)COLS::=${=LINE}}
        
        # 1行目（デフォルト値）の場合、セットして次の行へ。
        if [[ -z "${SET_SYSKBN}" ]];then
            SET_SYSKBN=${COLS[3]}
            continue
        fi
        
        # 現在行のバージョンをsysstatが下回った場合、前の行のSYSKBN値のままでbreak。
        if compVersion ${COMPVERSION_LARGE} ${COLS[1]} ${SYSSTAT_VERSION};then
            break
        fi
        # この行のSYSKBN条件をを満たしているので、新たにセット。
        SET_SYSKBN=${COLS[3]}
    done
fi

# SYSKBNパラメータの調整。記述値を「linux」にする。
# 【注意】区切り文字は、[半角スペースの繰り返し]=[半角スペースの繰り返し]である。
#         また、パラメータ名に先頭空白が入っていては壊れる。その点に注意。
awk -F ' *= *' '{ if ( $1 == "SYSKBN" ) { 
                  printf("%s = %s\n",$1,"'"${SYSKBN_SYMLINK_NAME}"'");
              } else {
                  print $0;
              }
            }' ${CONF_FILE} > ${CONF_FILE}.tmp

mv -f ${CONF_FILE}.tmp ${CONF_FILE}

# linuxシンボリックリンクの調整
# 旧リンクの削除
rm -f "${SYMLINK_GRAPHCONF_DIR}"
rm -f "${SYMLINK_DOCUMENTS_DIR}"
# 新リンク作成。問題ないとは思うが、一応カレントディレクトリを保ちつつ行う。
cd "${CONF_DIR}"
ln -s "${SET_SYSKBN}" "${SYSKBN_SYMLINK_NAME}"
cd -
cd "${DOCUMENTS_DIR}"
ln -s "${SET_SYSKBN}" "${SYSKBN_SYMLINK_NAME}"
cd -

echo -e "resstat.conf :: SYSKBN set complete. new syskbn [${SET_SYSKBN}]"

# 再度共通変数を定義し直す。
source "${BIN_DIR}/common_def.sh"

########################################
# パラメータ取得
########################################

# mpstatヘッダ情報
MPSTAT_ALLHEADER=$(getParamFromAllHeaderConf "MPSTAT")
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : configure.sh : call function getParamFromAllHeaderConf miss ret [${FUNC_RET}] \n[${MPSTAT_ALLHEADER}]"
    exit 4
fi

# mpstat項目ヘッダを取得
MPSTAT_PARAMLINE=${MPSTAT_ALLHEADER#*,}

# mpstat CPUフィールド名を取得
CPU_FIELD=$(getParamFromGraphConf "CPU_FIELD_NAME")

# iostatヘッダ情報
IOSTAT_ALLHEADER=$(getParamFromAllHeaderConf "IOSTAT")
FUNC_RET=$?
if [[ ${FUNC_RET} -ne 0 ]];then
    echo -e "Error : configure.sh : call function getParamFromAllHeaderConf miss ret [${FUNC_RET}] \n[${IOSTAT_ALLHEADER}]"
    exit 4
fi

# iostat項目ヘッダを取得
IOSTAT_PARAMLINE=${IOSTAT_ALLHEADER#*,}

# iostat デバイスフィールド名を取得
IOSTAT_DEVICE_FIELD=$(getParamFromGraphConf "IOSTAT_DEVICE_FIELD_NAME")

########################################
# CPUコア数調整
########################################

# 起動したマシンのCPUコア数に応じてグラフ化コンフィグファイルのCPUコア数を調整する。
# 単に全てのコアをグラフ化するようにセットするので、対象を絞る場合には手動で変更すること。

# ヘッダ行から${CPU_FIELD}のフィールド数を取得。
CPUNUM=$(getParamFieldsNum "$(mpstat -P ALL | head -n "${MPSTAT_PARAMLINE}" | tail -n 1)" "${CPU_FIELD}")

# CPUコア番号（all含む）を半角カンマ区切りで取得。メインセクションの空行抜きは単なるオマジナイ。
CPU_CORES=$(mpstat -P ALL | sed -e "1,${MPSTAT_PARAMLINE}d" | awk 'BEGIN{ __cnt__ = 0; }
     (NF > 0){ __cpu__[__cnt__] = $'${CPUNUM}';
       __cnt__++;
     }
     END{ __last__ = 0;
          while ( __last__ < __cnt__ ){
              if ( __last__ + 1 != __cnt__ ){
              
                  printf("%s,",__cpu__[__last__]);
              } else {
                  printf("%s\n",__cpu__[__last__]);
              }
              __last__++;
          }
        }')

# CPU_CORESパラメータの調整。
# 【注意】区切り文字は、[半角スペースの繰り返し]=[半角スペースの繰り返し]である。
#         また、パラメータ名に先頭空白が入っていては壊れる。その点に注意。
awk -F ' *= *' '{ if ( $1 == "CPU_CORES" ) { 
                  printf("%s = %s\n",$1,"'"${CPU_CORES}"'");
              } else {
                  print $0;
              }
            }' ${CONF_FILE} > ${CONF_FILE}.tmp
            
mv -f ${CONF_FILE}.tmp ${CONF_FILE}

echo -e "resstat.conf :: CPU core number set complete"

########################################
# ネットワークインタフェース数調整
########################################

# 測定対象ネットワークインタフェースの調整
# netstatコマンドを元にする。
# 【注意】netstat -iの出力フォーマットはawk中で取り込んでいる。
#         2行目までがヘッダであり、3行目以降第一カラムにインタフェース名が並ぶこと。
#         また、sar -n の出力を元にはしていない。
#         そのため、netstatとsarでネットワークインタフェース名の認識が異なる場合、この方法は無意味。
#         （しかし、sarはsysstatサービスを動かしていない限り、インターバルと回数指定になり、必ず1秒以上掛かる。
#           このラグが個人的に非常に嫌なのだ。なるべく使いたくは無い。）
IFACES=$(netstat -i | awk 'BEGIN{ __cnt__ = 0; }
                           (NR > 2){ __nic__[__cnt__] = $1;
                                     __cnt__++;
                                    }
                           END{ __last__ = 0;
                                while ( __last__ < __cnt__ ){
                                    if ( __last__ + 1 != __cnt__ ){
                                        printf("%s,",__nic__[__last__]);
                                    } else {
                                        printf("%s\n",__nic__[__last__]);
                                    }
                                    __last__++;
                                }
                              }')

# NETWORK_INTERFACESカラムの修正。
awk -F ' *= *' '{ if ( $1 == "NETWORK_INTERFACES" ){
                  printf("%s = %s\n",$1,"'"${IFACES}"'");
              } else {
                  print $0;
              }
            }' ${CONF_FILE} > ${CONF_FILE}.tmp

mv -f ${CONF_FILE}.tmp ${CONF_FILE}

echo -e "resstat.conf :: NETWORK INTERFACES set complete"

########################################
# デバイス名調整
########################################

# ヘッダ行から${IOSTAT_DEVICE_FIELD}のフィールド数を取得。
DEVNUM=$(getParamFieldsNum "$(iostat -p | head -n "${IOSTAT_PARAMLINE}" | tail -n 1)" "${IOSTAT_DEVICE_FIELD}")

# デバイス名を半角カンマ区切りで取得。最終行は空白が入るため、空行抜き必須。
DEVICES=$(iostat -p | sed -e "1,${IOSTAT_PARAMLINE}d" | awk 'BEGIN{ __cnt__ = 0; }
     (NF > 0){ __device__[__cnt__] = $'${DEVNUM}';
       __cnt__++;
     }
     END{ __last__ = 0;
          while ( __last__ < __cnt__ ){
              if ( __last__ + 1 != __cnt__ ){
              
                  printf("%s,",__device__[__last__]);
              } else {
                  printf("%s\n",__device__[__last__]);
              }
              __last__++;
          }
        }')

# BLOCK_DEVICESパラメータの調整。
awk -F ' *= *' '{ if ( $1 == "BLOCK_DEVICES" ) { 
                  printf("%s = %s\n",$1,"'"${DEVICES}"'");
              } else {
                  print $0;
              }
            }' ${CONF_FILE} > ${CONF_FILE}.tmp
            
mv -f ${CONF_FILE}.tmp ${CONF_FILE}

echo -e "resstat.conf :: BLOCK DEVICES set complete"

########################################
# AUTO_CONFIGURE機能の無効化
########################################
# 手動でconfigureを起動すれば、AUTO_CONFIGは無効で良い。
# この機能は初回のみ動けば充分の初心者設計。
AUTO_CONFIG_ONOFF=$(getParamFromConf "AUTO_CONFIG")
if [[ ${AUTO_CONFIG_ONOFF} == "ON" ]];then
    setParam_ForConf "AUTO_CONFIG" "OFF"
    echo -e "resstat.conf :: AUTO_CONFIG OFF set complete"
fi


exit 0
