#!/usr/bin/env zsh

########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : auto_useradd_passwdset.sh
	        
	        auto_useradd_passwdset.sh [ [34;1m-o useradd_option_Strings[m ] {user} {passwd}
	        auto_useradd_passwdset.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: auto_useradd_passwdset.sh [m  -- ユーザの作成とパスワードセットの自動入力
	
	       auto_useradd_passwdset.sh [ [34;1m-o useradd_option_Strings[m ] {user} {passwd}
	       auto_useradd_passwdset.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1muser[m : 作成ユーザ
	       
	       [35;1mpasswd[m : 設定パスワード
	
	
	[36;1m[Options] : [m
	
	       [34;1m-o[m : useraddコマンドのオプションに指定する文字列
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       カレントノードに対し、指定されたユーザ名で新規ユーザを作成して、
	       さらに初期パスワードを対話入力をパスして設定する。
	       
	       実行はrootユーザでなければ行えず、パスワード変更はpasswdコマンドを使用する。
	       その際、expectコマンドを使って対話入力を予測し、
	       【New UNIX password:】⇒【Retype new UNIX password:】
	       上記の様なプロンプトに対してパスワード文字列を送り込む。
	       既に同名ユーザが存在していれば、パスワード設定は行わずにそのままexitする。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。


	[31;1m[Caution] : [m
	
	       [35;1m１．予測プロンプト文字列[m
	           実装としては、「password:」というプロンプトを二回待つことで実現している。
	           このフォーマットに合致しないpasswdコマンドの仕様の場合は、
	           このスクリプトがフリーズしてしまうので注意。
	
	
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
# auto_useradd_passwdset.sh
#
# [概要]
#    ユーザを作成し、対話入力をパスしてパスワードを設定する。
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
while getopts :o:h ARG
do
    case "${ARG}" in
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

NEWUSERNAME="$1"

SETPASSWD="$2"

# 言語設定。expectで待ち受ける文字列を統一させるため。
export LANG=C
export LC_ALL=C

########################################
# ユーザ作成
########################################

if [[ $(whoami) != "root" ]];then
    echo -e "Error : auto_useradd_passwdset.sh : Sorry, this script is for only root user."
    exit 4
fi


# 既に存在すれば何もしない。
if [[ -n "$(cut -d ":" -f 1 /etc/passwd | grep "^${NEWUSERNAME}$")" ]];then
    echo -e "Error : auto_useradd_passwdset.sh : this user [${NEWUSERNAME}] already exists. Nothing to Execute and exit."
    exit 4
fi

# ユーザ作成
if [[ -n "${USERADD_OPTIONS}" ]];then
    # USERADD_OPTIONSは単語分割しておく。
    useradd ${=USERADD_OPTIONS} "${NEWUSERNAME}"
else 
    useradd "${NEWUSERNAME}"
fi


# 自動パスワードセット
expect -c "
spawn passwd ${NEWUSERNAME}
expect password:\ ;  send -- ${SETPASSWD}; send \r;
expect password:\ ; send -- ${SETPASSWD}; send \r;
expect eof exit 0
"

exit 0

