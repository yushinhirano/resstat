#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : management_setup.sh
	        
	        management_setup.sh [ [34;1m-f hostsfile[m ]
	        management_setup.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: management_tool.sh [m  -- resstat複数起動セットアップ対話的実行ツール
	
	       management_setup.sh [ [34;1m-f hostsfile[m ]
	       management_setup.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m

	       [34;1m-f[m : 起動対象ノード記述ファイルを指定する。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       resstatパッケージの複数ノード起動条件について、
	       条件を満たすための作業負担を軽減するツール実行入力を対話的に促す。
	       
	       このツールでは、各機能に応じて以下のスクリプトを呼び出す。
	       （セットアップ機能呼び出し順も、この順番で行うことを想定しているので、
	         以下の順に従って進めること）
	       
	       ・複数ノードユーザ作成
	         [33;1mmultisetup/bin/multinode_useradd.sh[m
	       
	       ・公開鍵接続設定
	         [33;1mmultisetup/bin/multinode_sshset.sh[m
	       
	       ・resstatパッケージ配布
	         [33;1mmultisetup/bin/multinode_dist.sh[m
	       
	       また、オプションで指定しない限り、
	       対象ノード記述ファイルはconf/targethostを使用する。
	       このファイルの1行を1ノード名として認識する。
	       （空行、先頭[#]はコメント行として読み飛ばす）
	       
	       尚、resstatパッケージ配布を除き、
	       対象ノード記述ファイルをオプション指定で変えれば
	       このパッケージ外でも動作する。


	[31;1m[Caution] : [m
	
	       [35;1m１．起動順番[m
	           メニュー番号において、「１⇒２⇒３」の順で起動することが望ましい。
	           つまり、「ユーザ作成」「公開鍵接続設定」「パッケージ配布」の順である。
	           （公開鍵設定とパッケージ配布前にユーザ作成が必要なのは自明だろう。
	             パッケージ配布は公開鍵接続設定が必要となっている）
	           また、各ノードで「あるノードは条件を満たしている」という様な場合には
	           動作中に警告やエラーが上がるので注意。
	           （ユーザ作成時に、あるノードには既にそのユーザが存在していたり、
	             公開鍵設定時にあるノードは既に設定済みである場合など）
	       
	       [35;1m２．小言[m
	           これはセキュリティを完全に無視したツール群です。
	           手動で環境設定しても問題ないなら、手動で行うべきです。
	           [31;1mつまるところ、できれば使わないでください。[m
	
	
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
# function ContinueInput
########################################
function ContinueInput(){
    echo -e "\n\n[ Please input ENTER to continue ..... ]\c"
    read
}

########################################
# function PrintTargetHost
########################################
function PrintTargetHost(){
    local NODES
    local TOP=0
    
    # 先頭#を除いてtargethostファイルを読み込み
    for NODES in ${${(@f)"$(<${TG_HOSTS_FILE})"}:#[#]*}
    do
        if [[ ${TOP} -eq 0 ]];then
            echo -e "  ----  TARGET  : ${NODES}"
            TOP=1
        else 
            echo -e "  ----          : ${NODES}"
        fi
    done
    
    # TODO 対象ノードが多い場合、この記述ではいささか不便。ある程度の文字数まで横に並べることを検討する。
    #      ・・・といっても端末の長さをいちいち測ったり端末長さ変化のシグナルハンドルも面倒なので、優先度は低い。
    #      そこまでやるならやってもいいが、それ言いだすと全体のレイアウトも変更になるので、ちょっときりが無い。
    
}


########################################
# function OpenMainMenu
########################################
function OpenMainMenu(){
    local SELECT_BUFF
    
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '############################################################'
        echo -e '## '
        echo -e '## resstat SPECIAL DANGEROUS tool MainMenu'
        echo -e '## '
        echo -e '##    please select command No.'
        echo -e '## '
        echo -e '############################################################'
        echo -e ''
        echo -e ''
        echo -e '    -- 複数ノード起動条件調整ツールメインメニュー --    '
        echo -e ''
        echo -e '      1. ユーザ作成     : '"${MYUSER}"
        echo -e '      2. SSH公開鍵配布'
        echo -e '      3. resstatツール配布'
        echo -e ''
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ input command code. [1-3q] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "1")
                    OpenUserAddMenu
                    RETVAL=$?
                    break 1
                    ;;
                "2")
                    OpenSSHSetMenu
                    RETVAL=$?
                    break 1
                    ;;
                "3")
                    OpenDistMenu
                    RETVAL=$?
                    break 1
                    ;;
                "q")
                    return ${RET_QUIT}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ input command code. [1-3q] >\c"
        done
        if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
            return ${RET_QUIT}
        elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
            continue
        fi
        
        # 正常終了してリターンした場合にはContinue前に一呼吸置く。
        ContinueInput
    done
}



########################################
#
# function OpenUserAddMenu
#
#    ユーザ作成メイン処理
#
########################################
function OpenUserAddMenu(){
    local SELECT_BUFF
    local ROOT_PASSWD="rootroot"
    local NEW_PASSWD="monitor"
    local USERADD_OPTIONS
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  ユーザ自動作成 config  '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      ■カレントユーザと同じユーザを作成します。[${MYUSER}]"
        echo -e ''
        echo -e "      ルートユーザパスワード          : [${ROOT_PASSWD}]"
        echo -e "      作成するユーザのパスワード      : [${NEW_PASSWD}]"
        echo -e "      useraddコマンドオプション文字列 : [${USERADD_OPTIONS}]"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      r. modify input root password'
        echo -e '      u. modify input new user password'
        echo -e '      o. modify input useradd command option string'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [yruobq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "r")
                    INPUT_BUFF=""
                    StringInput "please input root password"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    ROOT_PASSWD="${INPUT_BUFF}"
                    break 1
                    ;;
                "u")
                    INPUT_BUFF=""
                    StringInput "please input new user password"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    NEW_PASSWD="${INPUT_BUFF}"
                    break 1
                    ;;
                "o")
                    INPUT_BUFF=""
                    StringInput "please input useradd command option string"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    USERADD_OPTIONS="${INPUT_BUFF}"
                    break 1
                    ;;
                "b")
                    return ${RET_BACK}
                    ;;
                "q")
                    return ${RET_QUIT}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ please input command code [yruobq] >\c"
        done
    done
    
    #### multi-useradd shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ AUTO user adding  input confirm $$ ---------'
        PrintTargetHost
        echo -e '  ----'
        echo -e "  ----  COMMAND                         : multinode_useradd"
        echo -e "  ----  ROOT PASSWORD                   : ${ROOT_PASSWD}"
        echo -e "  ----  NEW USER NAME                   : ${MYUSER}"
        echo -e "  ----  NEW USER PASSWORD               : ${NEW_PASSWD}"
        echo -e "  ----  [useradd] COMMAND OPTION STRING : ${USERADD_OPTIONS}"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    if [[ -n "${USERADD_OPTIONS}" ]];then
                        "${MULTI_USERADD_SH}" -f "${TG_HOSTS_FILE}" -o "${USERADD_OPTIONS}" "${NEW_PASSWD}" "${ROOT_PASSWD}"
                    else 
                        "${MULTI_USERADD_SH}" "${NEW_PASSWD}" "${ROOT_PASSWD}" "${TG_HOSTS_FILE}"
                    fi
                    echo -e "\n  executed auto-useradd ..... \n"
                    
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel auto-useradd ..... \n"
                    return ${RET_OK}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ above command take OK ? [yn] >\c"
        done
    done

}



########################################
#
# function OpenSSHSetMenu
#
#    SSH公開鍵設定メイン処理
#
########################################
function OpenSSHSetMenu(){
    local SELECT_BUFF
    local USER_PASSWD="monitor"
    local USERADD_OPTIONS
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  SSH公開鍵自動設定 config  '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      [${MYUSER}]ユーザパスワード       : [${USER_PASSWD}]"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      u. modify input set-user password'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [yubq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "u")
                    INPUT_BUFF=""
                    StringInput "please input set-user password"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    USER_PASSWD="${INPUT_BUFF}"
                    break 1
                    ;;
                "b")
                    return ${RET_BACK}
                    ;;
                "q")
                    return ${RET_QUIT}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ please input command code [yubq] >\c"
        done
    done
    
    #### multi-SSHset shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ AUTO SSH setting input confirm $$ ---------'
        PrintTargetHost
        echo -e '  ----'
        echo -e "  ----  COMMAND           : multinode_sshset"
        echo -e "  ----  SET-USER NAME     : ${MYUSER}"
        echo -e "  ----  SET-USER PASSWORD : ${USER_PASSWD}"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTI_SSHSET_SH}" -f "${TG_HOSTS_FILE}" -k "${USER_PASSWD}"
                    echo -e "\n  executed auto-sshset ..... \n"
                    
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel auto-sshset ..... \n"
                    return ${RET_OK}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ above command take OK ? [yn] >\c"
        done
    done

}

########################################
#
# function OpenDistMenu
#
#    perstatツール配布メニュー
#
########################################
function OpenDistMenu(){
    local SELECT_BUFF
    
    #### multi-dist shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ AUTO resstat distribution confirm $$ ---------'
        PrintTargetHost
        echo -e '  ----'
        echo -e "  ----  COMMAND : multinode_dist"
        echo -e "  ----  DIST    : [$MYHOST]'s this package directory"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTI_DIST_SH}" -f "${TG_HOSTS_FILE}"
                    echo -e "\n  executed multi_dist ..... \n"
                    
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel multi_dist ..... \n"
                    return ${RET_OK}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
                
            fi
            echo -e " \$\$\$ above command take OK ? [yn] >\c"
        done
    done

}


########################################
# 
# function StringInput
# 
#    文字列入力をユーザに促し、その結果を
#    このスクリプト内のスタティックな変数「INPUT_BUFF」に格納して返す。
#
#    第一引数は文字列入力を促す前にechoする誘導文字列。
#
########################################
function StringInput(){
    local ECHO_MESSAGE="$1"
    local SELECT_BUFF
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e ''
        echo -e '    ==============================================='
        echo -e '    ========  $$ input String and Enter $$ ========'
        echo -e '    ==============================================='
        echo -e ''
        echo -e " \$\$\$ ${ECHO_MESSAGE} >\c"
        
        
        while :
        do
            read SELECT_BUFF
            if [[ -n "${SELECT_BUFF}" ]];then
                INPUT_BUFF="${SELECT_BUFF}"
                break
            fi
            echo -e " \$\$\$ ${ECHO_MESSAGE} >\c"
        done
        
        echo -e "\n"
        echo -e ''
        echo -e '    ================================='
        echo -e '    ========  input confirm  ========'
        echo -e '    ================================='
        echo -e ''
        echo -e "      input  value [${INPUT_BUFF}]"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      n. No and RE:input'
        echo -e ''
        echo -e '      b. back and input cancel'
        echo -e '      q. QUIT'
        echo -e ''

        echo -e " \$\$\$ above input OK ? [ynbq] >\c"
    
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    return ${RET_OK}
                    ;;
                "n")
                    INPUT_BUFF=""
                    break 1
                    ;;
                "b")
                    INPUT_BUFF=""
                    return ${RET_BACK}
                    ;;
                "q")
                    INPUT_BUFF=""
                    return ${RET_QUIT}
                    ;;
                *)
                    echo -e "\nplease input correct code\n"
                    ;;
                esac
            fi
            echo -e " \$\$\$ above input OK ? [ynbq] >\c"
        done

    done


}


########################################
#
# multinode_config_cui.sh
# (zshスクリプト)
# 途中でキレてzsh特有機能を使ってます。
# なぜなら、bashとzshでreadのオプション名が変わってしまい、もはや互換性を保てなくなったため。
# (ddコマンドとterm制御を使えば出来なくもないが、bshじゃあるまいし格好悪いので却下)
#
# [概要]
#    resstat複数ノード一斉起動条件調整ツール・対話的ユーザインタフェース
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
#    resstat/binに存在するスクリプトとは基本的に独立しています。
#
# [Caution]
#    ・セキュリティ完全無視。
#    ・使わないでください。
#
########################################

#非エラーハンドリング

#非シグナルハンドリング

#スクリプト実行名退避
CURRENT_SCRIPT="$0"


########################################
# オプション/引数設定
########################################
BIN_PWD=($(cd ${0%/*};pwd))

# 起動対象ノード記述ファイルデフォルト
TG_HOSTS_FILE="${BIN_PWD}/../../conf/targethost"

# コマンドラインオプションチェック
while getopts :f:h ARG
do
    case "${ARG}" in
        f)
          TG_HOSTS_FILE="${OPTARG}"
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

if [[ ! -s "${TG_HOSTS_FILE}" ]];then
    echo -e "Error target host file is not readble or don't exists or has no contents.\n"
    exit 4
fi

########################################
# 変数定義
########################################

MULTI_USERADD_SH="${BIN_PWD}/multinode_useradd.sh"
MULTI_SSHSET_SH="${BIN_PWD}/multinode_sshset.sh"
MULTI_DIST_SH="${BIN_PWD}/multinode_dist.sh"

# 実行日付取得
TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")

# 起動ノード取得
MYHOST=$(uname -n)
MYUSER=$(whoami)

# QUIT
RET_QUIT=99
# BACK
RET_BACK=98

RET_OK=0

# 文字列入力関数用static変数
typeset -g INPUT_BUFF

#起動メニュー呼び出し

unset TARGET_KBN
OpenMainMenu
RETVAL=$?
if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
    echo -e "\n"
    echo -e ""
    echo -e "bye.\n"
fi

exit 0

