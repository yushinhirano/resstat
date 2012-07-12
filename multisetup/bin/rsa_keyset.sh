#!/usr/bin/env zsh

########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : rsa_keyset.sh
	        
	        rsa_keyset.sh [ [34;1m-s RSA_secretkey_string[m ] {RSA_publickey_string}
	        rsa_keyset.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: rsa_keyset.sh [m  -- SSH公開鍵接続の自動設定。引数に設定する鍵の「内容」を指定して行う。
	
	       rsa_keyset.sh [ [34;1m-s RSA_secretkey_string[m ] {RSA_publickey_string}
	       rsa_keyset.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mRSA_publickey_string[m : 設定するRSA公開鍵の「内容」
	       

	[36;1m[Options] : [m
	
	       [34;1m-s[m : 秘密鍵の設定も同時に行う。オプション文字列に秘密鍵の内容を文字列として指定すること。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       カレントノードに対し、指定された公開鍵の内容で、~/.ssh/authorized_keysにSSH接続認証を加える。
	       -sを指定した場合、同時に~/.ssh/id_rsa、~/.ssh/id_rsa.pubも作成する。
	       これにより、指定した公開鍵を持つホストからパスワード無でSSH接続可能になる。
	       （-sを指定していると相互接続可能になる）
	       既に認証キーに登録されているかどうかをチェックせず、
	       -sを指定の場合には既存の鍵を上書きするので注意。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。


	[31;1m[Caution] : [m
	
	       [35;1m１．セキュリティ[m
	           -sを指定しようとしまいと、セキュリティというものを全く無視した設定と言える。
	           通常はパスワードを要求する接続の方が安心であるので、その点を理解して使用すること。
	
	
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
# rsa_keyset.sh
#
# [概要]
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
# コマンドラインオプションチェック
########################################

SECRET_KEY_SET=false
KNOWN_HOST_IGNORE_SET=false

while getopts :s:kh ARG
do
    case "${ARG}" in
        s)
          SECRET_KEY_SET=true
          SECKEY_STRING="${OPTARG}"
        ;;
        k)
          KNOWN_HOST_IGNORE_SET=true
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
########################################
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

PUBKEY_STRING="$1"

########################################
# 変数定義
########################################
LOCAL_SSHCONF_DIR=~/.ssh
LOCAL_PUBKEY_FILE="${LOCAL_SSHCONF_DIR}/id_rsa.pub"
LOCAL_SECKEY_FILE="${LOCAL_SSHCONF_DIR}/id_rsa"
LOCAL_AUTHKEY_FILE="${LOCAL_SSHCONF_DIR}/authorized_keys"
LOCAL_SSHCONFIG_FILE="${LOCAL_SSHCONF_DIR}/config"

########################################
# 公開鍵設定
########################################
# 対象ユーザのsshコンフィグディレクトリが存在しなければ作っておく。
if [[ ! -e "${LOCAL_SSHCONF_DIR}" ]];then
    mkdir "${LOCAL_SSHCONF_DIR}"
fi
chmod 700 "${LOCAL_SSHCONF_DIR}"

# 認証キー設定
echo -E "${PUBKEY_STRING}" >> "${LOCAL_AUTHKEY_FILE}"
chmod 600 "${LOCAL_AUTHKEY_FILE}"

# 秘密鍵設定オプションケース
if ${SECRET_KEY_SET};then
    # 念のために公開鍵も作成しておく
    echo -E "${PUBKEY_STRING}" > "${LOCAL_PUBKEY_FILE}"
    chmod 644 "${LOCAL_PUBKEY_FILE}"
    echo -E "${SECKEY_STRING}" > "${LOCAL_SECKEY_FILE}"
    chmod 600 "${LOCAL_SECKEY_FILE}"
fi

# known_hostsチェック無視ケース
if ${KNOWN_HOST_IGNORE_SET};then
    if [[ -s "${LOCAL_SSHCONFIG_FILE}" ]];then
        cat <(echo -e "Host "'*'"\n        StrictHostKeyChecking no") "${LOCAL_SSHCONFIG_FILE}" > ${LOCAL_SSHCONFIG_FILE}.rsa_keyset_tmp
        mv -f ${LOCAL_SSHCONFIG_FILE}.rsa_keyset_tmp "${LOCAL_SSHCONFIG_FILE}"
    else
        echo -e "Host "'*'"\n        StrictHostKeyChecking no" > "${LOCAL_SSHCONFIG_FILE}"
        chmod 644 "${LOCAL_SSHCONFIG_FILE}"
    fi
fi

exit 0

