#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : auto_passwd_ssh.sh
	        
	        auto_passwd_ssh.sh [ [34;1m-p port[m ] ssh {passwd} [{user}@]{host} {COMMAND...}
	        auto_passwd_ssh.sh [ [34;1m-p port[m ] scp {passwd} [[{user}@]{host}:]{FROM_PATH} [[{user}@]{host}:]{TO_PATH}
	        auto_passwd_ssh.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: auto_passwd_ssh.sh [m  -- セキュアシェルコマンドのパスワード自動入力
	
	       auto_passwd_ssh.sh [ [34;1m-p port[m ] ssh {passwd} [{user}@]{host} {COMMAND...}
	       auto_passwd_ssh.sh [ [34;1m-p port[m ] scp {passwd} [[{user}@]{host}:]{FROM_PATH} [[{user}@]{host}:]{TO_PATH}
	       auto_passwd_ssh.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	       
	       [35;1mpasswd[m : 自動入力するパスワード
	       
	       [35;1muser[m : ログインユーザ
	       
	       [35;1mhost[m : リモートホスト
	       
	       [35;1mCOMMAND...[m : SSHで実行するコマンドライン。
	                    クォーティングして一つの引数とすること。
	       
	       [35;1mFROM_PATH[m : コピー元ファイルパス
	       
	       [35;1mTO_PATH[m : コピー先ファイルパス
	
	
	[36;1m[Options] : [m
	
	       [34;1m-p[m : ssh/scpで接続するポートを指定する。デフォルト22。
	
	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       セキュアリモートシェル系のコマンドsshとscpを、
	       引数で指定されたパスワードで自動入力化する。
	       また、初回接続時のリモートホスト鍵の受け入れも自動的に「yes」とする。
	       
	       引数の指定は、パスワード指定があることを除いて
	       sshやscpでのコマンドと変わらないが、
	       以下の点に注意する。
	       
	         ・scp機能では、ローカルからローカルへのコピーを禁止している。
	           （行ってしまった場合は手動でシグナルを送って停止させること）
	         
	         ・ssh/scpのタイムアウト時間は1200秒。
	           これを超える処理を行わないこと。
	           （あるいは、スクリプト内のタイムアウト指定を大きくすること。
	             オプション化はしていない）
	       
	       それ以外は、sshやscpを利用する感覚で使用できる。
	       
	       尚、このスクリプトは、resstatパッケージとは独立しており、
	       修正なしに他の環境でも使用可能である。


	[31;1m[Caution] : [m
	
	       [35;1m１．エラーハンドリングとゾンビプロセス[m
	           sshやscpがエラーとなった時のハンドリングに難がある。
	           それは、パスワード入力をミスした場合にも同様である。
	           そのため、引数の入力は慎重を期してもらいたい。
	           
	           万が一エラーが起きた場合、
	           ゾンビプロセスが残ってしまう可能性があるので注意。
	           ただ、正常終了した場合にもプロセスが残る様なことが稀にあり、
	           やや不安定なスクリプトであるのだが。
	           
	           このスクリプトがexpectコマンドを使用して実装されているためであるが、
	           このコマンドとプロセス生成に詳しい方がいらしゃったら、
	           ぜひご助力願いたい。
	       
	       [35;1m２．パスワードが既に無い場合の動作[m
	           パスワード入力が既にパスされている状態の場合、
	           テストが充分でないかもしれない。
	           何度か試してみた結果、ゾンビプロセスなどは残らなかったが、
	           expectスクリプトに対して警告メッセージが出力されてしまっている。
	           尚、パスワード入力がなく、サーバ鍵の受け入れのみ答える場合も同様である。
	           expectに詳しい方がいらっしゃったら、
	           こちらもぜひ上手な回避法についてご助力を願いたい。
	       
	       [35;1m３．expectパッケージ[m
	           デフォルトでLinux系OSをインストールした場合、入っていないかもしれない。
	           インターネットに接続できるマシンの場合、
	           リポジトリからexpectパッケージをインストールしておく。
	           あるいは、ディストリビューションのインストールCDがあるなら、
	           そこからexpectパッケージを入れておくこと。
	           
	           [インストールCDからの例]
	           RedHat系ディストリビューションで、/media/cdromにマウントした場合
	           
	           yum --disablerepo=\* --enablerepo=c5-media install expect
	           
	           （有効化するローカルリポジトリはディストロによって変わるかもしれないので、
	             確認しておくこと）


	[36;1m[Author & Copyright] : [m
	        
	        resstat version ${RESSTAT_VERSION}.
	        
	        Author : Written by ${RESSTAT_AUTHOR}.
	        
	        Report bugs to <${RESSTAT_REPORT_TO}>.
	        
	        Release : ${RESSTAT_LASTUPDATE}.
	
	
	EOF

}


########################################
#
# auto_passwd_ssh.sh
# (zshスクリプト。HelpMsgのPAGER起動方法を変えればbashでも動作する)
# 
#
# [概要]
#    セキュアリモートシェル系のコマンドsshとscpをスクリプト実行用にパスワード指定で自動化する。
# [起動条件、仕様]
# [引数]
#    UsageMsg()、HelpMsg()参照。
#
# expectコマンドで内部処理を行う。
# expectの内部プロセスタイムアウト時間は20分。(1200sec)
#
# (Caution!)
#  まだバグが抜け切れておらず、稀にゾンビプロセスを生むことがある。（expectの仕様を読みきれてない。）
#  特にscpは謎が多い。
#  また、入出力端末が存在する状態で実行しなければ、scpは失敗する。(interact機能を使用しているため。この制限はまだ回避できていない)
#  cron等で自動起動したい場合には未だ不明のまま。（下段のコメント参照。基本的には上手く行くのだが……何か安定しない）
#
########################################

#スクリプト実行名退避
CURRENT_SCRIPT="$0"

########################################
# オプション/引数設定
########################################
# コマンドラインオプションチェック
while getopts :p:h ARG
do
    case "${ARG}" in
        p)
          TARGET_PORT="${OPTARG}"
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



# コマンドライン引数チェック（1st Argument必須）
if [[ -z "$1" ]];then
    UsageMsg
    exit 4
fi

COMMAND="$1"

case "${COMMAND}" in
    "ssh")
        # 2nd、3rd、4thオプション必須。
        if [[ $# -lt 4 ]];then
            UsageMsg
            exit 4
        fi
        
        TARGET_PSWD="$2"
        TARGET_USERHOST="$3"
        TARGET_CMD="$4"
        
        ;;
    "scp")
        # 2nd、3rd、4thオプション必須。
        if [[ $# -lt 4 ]];then
            UsageMsg
            exit 4
        fi
        
        TARGET_PSWD="$2"
        TARGET_FROM="$3"
        TARGET_TO="$4"

        ;;
    *)
        UsageMsg
        exit 4
        ;;
esac



########################################
# 変数定義
########################################
# expect command parameters
ALIVE_TIME=1200


########################################
# secure shell commands executtion
########################################

# 標準入力予測で下手に日本語化されないようにするため、キャラセットを英字固定する。
export LANG=C
export LC_ALL=C

# remort shell exec 
case "${COMMAND}" in 
"ssh")

    expect -c "
set timeout ${ALIVE_TIME}
if {\"${TARGET_PORT}\" == \"\"} { 
    spawn ssh ${TARGET_USERHOST} \"${TARGET_CMD}\"
} else {
    spawn ssh -p ${TARGET_PORT} ${TARGET_USERHOST} \"${TARGET_CMD}\"
}
expect {
  \"Are you sure you want to continue connecting (yes/no)?\" {
    send \"yes\r\"
    expect \"password:\"
    send \"${TARGET_PSWD}\r\"
  } \"password:\" {
    send \"${TARGET_PSWD}\r\"
  }
}
expect eof exit 0
"
    # 起動はsshに-fを指定してバックグラウンドで行っている。
    # フォアグラウンドで処理終了を待つ場合、終了後の何らかの標準入力へのechoバックを検知してexpectし、exitをsendするか、
    # その場合にはサーバのプロセスも終了出来ているのでexpect自体をexitする。
    # つまり、「終了」と検知するための何らかの出力が、サーバ側に送ったsshプロセスで必要となってしまう。
    # やろうと思えば、意図的に作ればいいのだが。
    # 汎用的な方法としては、プロンプト文字列を検知するとか。でも、sshプロセスが不意にプロンプト文字列と同様の出力をした場合には壊れる。
    # あるいは、interactで端末制御に戻し、exitをsendするとかでも……いや、無理か。とにかく、フォアグラウンド終了を待つのはやや困難。
    
    # ⇒後日解消。EOFを検知してexpectをexitすればよい。あら、単純。
    
    ;;
"scp")
    expect -c "
set timeout ${ALIVE_TIME}
if {\"${TARGET_PORT}\" == \"\"} { 
    spawn scp -p ${TARGET_FROM} ${TARGET_TO}
} else {
    spawn scp -P ${TARGET_PORT} -p ${TARGET_FROM} ${TARGET_TO}
}
expect {
  \"Are you sure you want to continue connecting (yes/no)?\" {
    send \"yes\r\"
    expect \"password:\"
    send \"${TARGET_PSWD}\r\"
  } \"password:\" {
    send \"${TARGET_PSWD}\r\"
  }
}
interact

# コメントアウト。端末制御がない状態で使うには以下の様にすべきだが、なぜかプロセス生成が行われない……ことがある。
# 標準出力とエラー出力の吐き先をきっちりしなければならないと思う。
#expect {
#    \"denied\" { exit 1 } \
#    \"100%\"  { exit 0 } 
#}

"
    # SSH同様にEOFを検知してexitする。（上手く行かなければ、100%終了を待つか、denyを待ってexitする。タイミングが悪いとプロセスがゾンビ化する）
    
    # ⇒やはり、scpのコピー終了前にリターンしてしまうため、ここは100%終了を待つ。
    # ⇒すると、今度はscpでコピープロセスが正常に上がらなくなる。
    
    # ⇒interactを使用する。ただし、この方法は端末が存在する場合にしか使えない。cron等ではやはり100%終了を待つ方法しかないだろうが……難しい。
    #   そもそもなぜ正常にコピーしてくれないのだろうか。恐らく、scpの標準出力及びエラー出力がどうなっているかの問題だとは思うが。
    
    # ⇒基本的には、下の100%検知で問題ない。ただ、一度コピープロセスが出ない罠に掛かると、その後どうやっても使えなくなるのが謎。（現状、マシン再帰動しかなくなる）
    #   かなり怪しいので、端末制御がある状態ならinteract版にした方が良い。どうしても必要な場合のみ、100%検知にすべき。
    
    ;;
esac

exit ${RETCD_OK}
