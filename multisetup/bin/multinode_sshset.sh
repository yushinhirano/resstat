#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : multinode_sshset.sh
	        
	        multinode_sshset.sh [ [34;1m-f hostsfile[m ] [ [34;1m-s[m ] [ [34;1m-k[m ] {passwd}
	        multinode_sshset.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: multinode_sshset.sh [m  -- 複数ノードへの、ssh公開鍵接続自動設定
	
	       multinode_sshset.sh [ [34;1m-f hostsfile[m ] [ [34;1m-s[m ] [ [34;1m-k[m ] {passwd}
	       multinode_sshset.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mpasswd[m : 対象全ノード共通のssh接続パスワード
	
	
	[36;1m[Options] : [m

	       [34;1m-f[m : 対象ノード記述ファイルを指定する。
	
	       [34;1m-s[m : 秘密鍵と公開鍵も配布する。（全ノード同一鍵、相互接続設定）

	       [34;1m-k[m : known_hosts自動登録設定。（SSHサーバの公開鍵未チェック設定）
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       起動対象ノード記述ファイルの全ノードに対し、
	       スクリプト実行カレントユーザでssh接続する為の公開鍵を配布する。
	       つまり、相互接続は考慮せず、このスクリプトの実行ノードからの
	       片道接続が公開鍵で行われればよいとする。
	       （-sオプションを付けると、秘密鍵を配布して同一鍵による相互接続を可能とする）
               （-kオプションを指定すると、サーバ公開鍵に対して未チェック設定をconfigに追加する）
	       起動対象ノード記述ファイルのデフォルトは、conf/targethost。オプション指定可能。
	       
	       カレントノード/カレントユーザでRSA公開鍵が作成されていない場合、
	       その場で作成するが、その際のパスフレーズの入力は自動化していないので、
	       実行者が空のパスフレーズを入力すること。
	       
	       その後は自動的に処理され、
	       カレントユーザで指定全ノードに指定パスワードでssh接続して、
	       カレントノードの公開鍵を所定のディレクトリに配布し、
	       パーミッションを設定する。
	       
	       対象ノード記述ファイルは、先頭[#]と空行を無視して、
	       1行1ノードとして読み込む。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。
	       （ただし、デフォルトの起動対象ノード記述ファイルパスは変える必要あり）


	[31;1m[Caution] : [m
	
	       [35;1m１．対象ノードのユーザとパスワード[m
	           起動対象となる全てのノードに、スクリプト実行カレントユーザが存在し、
	           また、sshログインパスワードが引数で指定するパスワードに
	           統一されていなければならない。
	           multinode_useradd.shで一斉作成したユーザで行うのが適切だろう。
	       
	       [35;1m２．接続に使用する鍵[m
	           公開鍵の配布以外に選択肢を用意していない。
	           また、既に公開鍵登録されているかどうかはチェックしていないので注意。
	
	       [35;1m３．セキュリティ関連[m
	           -sオプション、-kオプションはセキュリティ上危険度が高い。
	           クローズな検証環境の様に、全く考慮しないくてよい環境での利用に留めること。

	       [35;1m４．SELinux[m
	           SELinuxを有効にしてあると、ラベルが不正になってしまい
	           修復しなければ公開鍵接続が出来ない事象が生じる。
	           ラベル修復コマンドやSELinux無効化コマンドまでは組み込んでいないので注意。

	
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
    
#}


########################################
#
# zshスクリプト
# multinode_sshset.sh
#
# [概要]
#    起動対象ノードの（このスクリプトの）カレントユーザに対し、現在のホスト及びカレントユーザからの
#    SSH公開鍵接続を可能とするよう公開鍵を配布する。公開鍵は存在しなければ新規作成する。
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
# 起動対象ノード記述ファイル
BIN_PWD=($(cd ${0%/*};pwd))
MYHOST=$(uname -n)

HOSTSFILE="${BIN_PWD}/../../conf/targethost"
SECRET_KEY=false
KNOWN_HOST_IGNORE=false

# コマンドラインオプションチェック
while getopts :f:skh ARG
do
    case "${ARG}" in
        f)
          HOSTSFILE="${OPTARG}"
        ;;
        s)
          SECRET_KEY=true
        ;;
        k)
          KNOWN_HOST_IGNORE=true
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
# コマンドライン引数チェック（1st Arguments必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

USER_PASSWD="$1"

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
EXEC_SCRIPT_NAME="rsa_keyset.sh"
RSA_KEYSET_SH="${BIN_DIR}/${EXEC_SCRIPT_NAME}"
AUTO_SECURESHELL_SH="${BIN_PWD}/auto_passwd_ssh.sh"

MYUSER=$(whoami)
MYHOST=$(uname -n)

LOCAL_PUBKEY_FILE=~/.ssh/id_rsa.pub
LOCAL_SECKEY_FILE=~/.ssh/id_rsa

if [[ ! -s "${RSA_KEYSET_SH}" ]];then
    echo -e "Error : multinode_sshset.sh : RSA Key Set script [ ${RSA_KEYSET_SH} ] does not exist."
    exit 4
fi

if [[ ! -s "${AUTO_SECURESHELL_SH}" ]];then
    echo -e "Error : multinode_sshset.sh : Remote SSH_SCP Auto Password script [ ${AUTO_SECURESHELL_SH} ] does not exist."
    exit 4
fi


########################################
# 公開鍵存在チェック
########################################
if [[ ! -s "${LOCAL_PUBKEY_FILE}" ]];then
    echo -e "Info : multinode_sshset.sh : public key does not exist on this node. make new key (please input empty passphrase)\n"
    sleep 1
    ssh-keygen -t rsa
fi

########################################
# 自動起動SSHシェルを使用し、全ノードに公開鍵を配布する。自ノードも同様。
########################################

PUBKEY_STRING=$(cat "${LOCAL_PUBKEY_FILE}") 
SECKEY_STRING=$(cat "${LOCAL_SECKEY_FILE}") 

# rsa_keysetスクリプト配布
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [[ "${NODE}" == "${MYHOST}" ]];then
        # 自ノードはカレントディレクトリにあるスクリプトを使う。
        continue
    fi
    ${AUTO_SECURESHELL_SH} scp "${USER_PASSWD}" "${RSA_KEYSET_SH}" "${MYUSER}@${NODE}:"
done

# rsa_keysetスクリプト実行
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [[ "${NODE}" == "${MYHOST}" ]];then
        if ${SECRET_KEY};then
            if ${KNOWN_HOST_IGNORE};then
                ${RSA_KEYSET_SH} -k -s "${SECKEY_STRING}" "${PUBKEY_STRING}"
            else
                ${RSA_KEYSET_SH} -s "${SECKEY_STRING}" "${PUBKEY_STRING}"
            fi
        else 
            if ${KNOWN_HOST_IGNORE};then
                ${RSA_KEYSET_SH} -k "${PUBKEY_STRING}"
            else
                ${RSA_KEYSET_SH} "${PUBKEY_STRING}"
            fi
        fi
        continue
    fi
    
    if ${SECRET_KEY};then
        if ${KNOWN_HOST_IGNORE};then
            ${AUTO_SECURESHELL_SH} ssh "${USER_PASSWD}" "${MYUSER}@${NODE}" '~/'"${EXEC_SCRIPT_NAME} -k -s '${SECKEY_STRING}' '${PUBKEY_STRING}'"
        else
            ${AUTO_SECURESHELL_SH} ssh "${USER_PASSWD}" "${MYUSER}@${NODE}" '~/'"${EXEC_SCRIPT_NAME} -s '${SECKEY_STRING}' '${PUBKEY_STRING}'"
        fi
    else
        if ${KNOWN_HOST_IGNORE};then
            ${AUTO_SECURESHELL_SH} ssh "${USER_PASSWD}" "${MYUSER}@${NODE}" '~/'"${EXEC_SCRIPT_NAME} -k '${PUBKEY_STRING}'"
        else
            ${AUTO_SECURESHELL_SH} ssh "${USER_PASSWD}" "${MYUSER}@${NODE}" '~/'"${EXEC_SCRIPT_NAME} '${PUBKEY_STRING}'"
        fi
    fi

done


# rsa_keysetスクリプト削除
for NODE in ${${(@f)"$(<${HOSTSFILE})"}:#[#]*}
do
    if [[ "${NODE}" == "${MYHOST}" ]];then
        continue
    fi

    ${AUTO_SECURESHELL_SH} ssh "${USER_PASSWD}" "${MYUSER}@${NODE}" "rm -f "'~/'"${EXEC_SCRIPT_NAME}"
done

echo -e "\n  ##---- public key setting complete.\n"

exit 0

