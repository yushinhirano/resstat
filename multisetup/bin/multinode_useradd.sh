#!/usr/bin/env zsh

########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : multinode_useradd.sh
	        
	        multinode_useradd.sh [ [34;1m-f hostsfile[m ] [ [34;1m-o useradd_option_Strings[m ] {new_user_passwd} {root_passwd}
	        multinode_useradd.sh [ [34;1m-h[m ]
	
	EOF

}

########################################
# function HelpMsg
########################################
function HelpMsg(){
    #PAGER変数は手動でセット。このスクリプトはresstat packageとは独立している。
    PAGER="/usr/bin/less -RFX"
    export LC_ALL=ja_JP.utf8
    case "`uname`" in
        CYGWIN*) 
            export PAGER="/usr/bin/less -FX"
            ;;
    esac

    if [[ -s "${VERSION_TXT::=${CURRENT_SCRIPT%/*}/../../VERSION}" ]];then
        RESSTAT_VERSION=$(awk -F ' *= *' '(NF > 0){if ($1 == "VERSION") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_AUTHOR=$(awk -F ' *= *' '(NF > 0){if ($1 == "AUTHOR") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_REPORT_TO=$(awk -F ' *= *' '(NF > 0){if ($1 == "REPORT_TO") { print $2; exit; } }' "${VERSION_TXT}")
        RESSTAT_LASTUPDATE=$(awk -F ' *= *' '(NF > 0){if ($1 == "LAST_UPDATE") { print $2; exit; } }' "${VERSION_TXT}")
    fi

    ${=PAGER} <<-EOF
	
	
	[32;1;4m#### resstat package manual ####[m
	
	
	[36;1mUsage: multinode_useradd.sh [m  -- 複数ノードへのユーザの作成とパスワードセットの自動入力
	
	       multinode_useradd.sh [ [34;1m-f hostsfile[m ] [ [34;1m-o useradd_option_Strings[m ] {new_user_passwd} {root_passwd}
	       multinode_useradd.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mnew_user_passwd[m : 作成するユーザの初期パスワード
	       
	       [35;1mroot_passwd[m : リモートノード共通rootパスワード
	
	
	[36;1m[Options] : [m

	       [34;1m-f[m : 対象ノード記述ファイルを指定する。
	
	       [34;1m-o[m : useraddコマンドのオプションに指定する文字列
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       起動対象ノード記述ファイルに書かれたノードを対象に、
	       スクリプト起動カレントユーザと同じユーザを作成し、
	       指定された初期パスワードをセットする。
	       起動対象ノード記述ファイルのデフォルトは、conf/targethost。オプション指定可能。
	       
	       起動対象の全てのノードのrootユーザが、
	       引数で指定するパスワードで統一されていなければならず、
	       起動条件は非常に厳しい。正直、活躍の機会はあまり無いのでは、と思われる。
	       
	       内部実装としては、
	       自動ssh/scp実行にauto_passwd_ssh.shを使い、
	       ユーザ作成とパスワードセットはauto_useradd_passwdset.shを配布して行う。
	       起動対象ノード記述ファイルは、先頭[#]の行と空行を読み飛ばし、
	       1行1ノードと認識して行う。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。
	       （ただし、デフォルトの起動対象ノード記述ファイルパスは変える必要あり）


	[31;1m[Caution] : [m
	
	       [35;1m１．特殊ケースに関する注意[m
	           カレントノードから起動対象ノードのrootユーザに、
	           auto_passwd_ssh.shで自動パスワード入力を行って接続する点で注意が必要。
	           このスクリプトは公開鍵接続で自動化されていても、
	           パスワード入力プロンプトを待ってしまうため、
	           下手をするとゾンビプロセスが残ってしまう可能性がある。
	           
	           そもそも、rootユーザに自由に入れるなら、
	           auto_passwd_ssh.shなんて使わずとも
	           単にsshをforか何かのループで回して
	           自力でユーザ作成を実行すればよい。
	           このツール群はあくまでsshに自動接続できない場合のためのものなので。
	
	
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
# multinode_useradd.sh
#
# [概要]
#    起動対象ノードに対し、このシェルの実行ユーザと同じユーザを作成する。
#    また、初期パスワードを設定する。
#    ssh接続のパスワード入力を自動化している。対象全ノード共通のrootパスワードが必要。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。

# [注意]
#    ノード毎にrootパスワードが異なる様なら、そもそもこのシェルで共通化する意味が無い。自力でログインしてやりましょう。
#    ２～３パターンくらいまでなら、hostsfileを変えて実行すれば効率化は測れるかも。
#
########################################

#非エラーハンドリング

#非シグナルハンドリング

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

########################################
# オプション/引数設定
########################################
# 起動対象ノード記述ファイル
BIN_PWD=($(cd ${0%/*};pwd))
MYHOST=$(uname -n)

HOSTSFILE="${BIN_PWD}/../../conf/targethost"

# コマンドラインオプションチェック
while getopts :f:o:h ARG
do
    case "${ARG}" in
        f)
          HOSTSFILE="${OPTARG}"
        ;;
        o)
          USERADD_OPTIONS="${OPTARG}"
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
# コマンドライン引数チェック（1st、2nd Args必須）
if [[ -z "$1" || -z "$2" ]];then
    UsageMsg
    exit 4
fi


NEW_PASSWD="$1"

ROOTPASSWD="$2"

if [[ ! -s "${HOSTSFILE}" ]];then
    echo -e "Error : multinode_useradd.sh : this hostfile [${HOSTSFILE}] does not exist."
    exit 4
fi


########################################
# 変数定義
########################################
#スクリプト格納ディレクトリ(絶対パス)
BIN_PWD=($(cd ${0%/*};pwd))
export BIN_DIR=${BIN_PWD}

AUTO_SECURESHELL_SH="${BIN_PWD}/auto_passwd_ssh.sh"
EXEC_SCRIPT_NAME="auto_useradd_passwdset.sh"
AUTO_USERADD_PASSWDSET_SH="${BIN_PWD}/${EXEC_SCRIPT_NAME}"


MYUSER=$(whoami)
MYHOST=$(uname -n)

########################################
# 自動起動SSHシェルを使用し、全ノードでuseraddを行う。
########################################

# 現在のユーザがrootの場合には何もしない。
if [[ "${MYUSER}" == "root" ]];then
    "Warning: Current User is root. Nothing to execute and exit."
    exit 0
fi

# useraddスクリプト配布
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do 
    if [[ "${NODE}" == "${MYHOST}" ]];then 
        continue
    fi
    ${AUTO_SECURESHELL_SH} scp "${ROOTPASSWD}" "${AUTO_USERADD_PASSWDSET_SH}" "root@${NODE}:"
done

# useraddスクリプト実行
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [[ "${NODE}" == "${MYHOST}" ]];then 
        continue
    fi

    if [[ -n "${USERADD_OPTIONS}" ]];then
        # USERADD_OPTIONSは単語分割しておく。
        # ホームディレクトリ部分はこの時点での展開を抑制。
        ${AUTO_SECURESHELL_SH} ssh "${ROOTPASSWD}" "root@${NODE}" 'chmod 775 ~/'"${EXEC_SCRIPT_NAME}; "'~/'"${EXEC_SCRIPT_NAME} -o '${USERADD_OPTIONS}' ${MYUSER} ${NEW_PASSWD}"
    else 
        ${AUTO_SECURESHELL_SH} ssh "${ROOTPASSWD}" "root@${NODE}" 'chmod 775 ~/'"${EXEC_SCRIPT_NAME}; "'~/'"${EXEC_SCRIPT_NAME} ${MYUSER} ${NEW_PASSWD}"
    fi
done


# useraddスクリプト削除
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [[ "${NODE}" == "${MYHOST}" ]];then 
        continue
    fi
    
    ${AUTO_SECURESHELL_SH} ssh "${ROOTPASSWD}" "root@${NODE}" "rm -f "'~/'"${EXEC_SCRIPT_NAME}"
done

echo -e "\n  ##---- MultiNode useradd and password set sequence complete. \n"

exit 0

