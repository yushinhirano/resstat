#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
	
	Usage : make_html.sh
	        
	        make_html.sh [ [34;1m-c[m ] [ [34;1m-m[m ] [ [34;1m-x exclude.conf[m ] [ [34;1m-l status_contents_path[m ] target_dir
	        make_html.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: make_html.sh [m  -- パフォーマンス計測結果グラフファイルの参照用HTML作成
	
	       make_html.sh [ [34;1m-c[m ] [ [34;1m-m[m ] [ [34;1m-x exclude.conf[m ] [ [34;1m-l status_contents_path[m ] target_dir
	       make_html.sh [ [34;1m-h[m ]
	
	
	[36;1m[Args] : [m
	
	       [35;1mtarget_dir[m : pngファイルを格納したディレクトリルート
	
	
	[36;1m[Options] : [m

	       [34;1m-c[m : 子階層用の作成を行う。
	            具体的には、トップページにフレーム参照を作成しない。

	       [34;1m-m[m : マルチノードの結果収集用に作成を行う。
	            デフォルトは単独ノード起動用に行っている。

	       [34;1m-x[m : HTML参照除外ファイルを指定する。
	            現在はconf/html_exclude.confとなっている。
	            このファイルに記述されているグラフファイルは、HTMLに含めない。

	       [34;1m-l[m : 計測項目一覧ファイルであるstatus_contents.htmlについて、
	            新たに出力ディレクトリにコピーするのではなく
	            このオプションで与えられた値でリンクする。
	            子階層用の作成にはこの機能も付けた方が良い。

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       resstat実行結果を元に、pngファイル参照用のHTMLを作成する。
	       -mオプションを付けると複数ノード一斉起動結果を、
	       付けない場合は単独ノード起動結果を対象としたHTMLになる。
	       
	       [32;1m１．各ディレクトリ階層に対するHTMLの作成[m
	           指定されたディレクトリ階層以下全てのディレクトリに対して、
	           そのディレクトリ直下に存在する拡張子png形式ファイルの画像を
	           参照できるHTMLを出力する。
	           また、下の階層のディレクトリがある場合、
	           その階層のディレクトリに作成されるHTMLへのリンクも作成する。
	           
	           画像及びディレクトリリンク名は、
	           複数ノード起動結果（-mオプション有）なら2階層下の階層以降、
	           単独ノード起動結果（-mオプション無）なら1階層下の階層以降、
	           現在の階層名のディレクトリをプレフィックスする。
	           また、一度プレフィックスをした場合、その階層から下の階層は
	           その名前でプレフィックする。
	           
	           さらに、複数ノード起動結果の場合には
	           最初の階層のみリンク名を変換してノード名となる様にする。
	           
	       [32;1m２．メニューフレームページ作成[m
	           １．で作成したページを右ページとし、
	           その全てのHTMLを一覧リンクできるメニューページを作成して
	           左ページとしたフレームHTMLを作成する。
	           このページがindex.htmlである。
	           
	           ディレクトリリンク名に施す複数ノード起動結果に対する
	           変換処理は１と同様である。
	           
	           
	       [32;1m３．測定項目一覧へのリンク[m
	           documents/status_contents.htmlファイルを
	           指定ディレクトリにコピーし、
	           生成するHTMLファイルの第一階層と、
	           メニューフレームページに参照リンクを作成する。
	           (-lでリンク先を指定した場合にはコピーせず、リンクのみ作成)
	       
	       尚、conf/html_exclude.confファイルに記述されているpngファイルは、
	       HTMLの参照に含めない。（作成者も何に使うか解らない仕様だが）
	       
	       
	[31;1m[Caution] : [m
	
	       [35;1m１．グラフ化除外ファイル[m
	           conf/html_exclude.confは、他のコンフィグ同様に先頭#はコメントであり、
	           空行を回避し、1行に1ファイル記述すること。

	
	[36;1m[Related ConfigFiles] : [m
	        
	        ・conf/html_exclude.conf
	
	
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
    # 割り込み時のシグナルハンドリング用（未実装）
    
#}

########################################
#
# function make_html_rec
#
# グラフ表示ページ作成
#
# 再帰関数
#   make_html_rec {対象ディレクトリパス} {リンク名プレフィックス付与のための再帰周回数} {リンク名プレフィックス名}
#
#     {対象ディレクトリパス}から下のディレクトリがある限り、そのディレクトリに向かってこの関数を再帰的に呼び続ける。
#
########################################
function make_html_rec(){
    if [[ -z "$1" ]];then
        echo -e "Error:make_html_rec(): 1st Param is required"
        return 99
    fi
    
    local CURRENTDIR
    local DIRNAME
    local HTMLNAME
    local PNGS_SRC
    local PNG_FILE
    local SUBDIR
    local SUB_DIRLINKS
    local CNT
    local PNG_LINKS
    # この回数を超えて再帰的に呼び出した時、カレントディレクトリ名をプレフィックスに付ける。デフォルトは0（付けない）。
    # 1は全てに付ける。２以降は、その回数目の再帰呼び出しから付ける。（具体的には、ディレクトリ階層と等しい。3を指定すれば、3階層目から付けることになる）
    local LINKNAME_PREFIX_RSVCNT
    local LINKNAME_PREFIX

    CURRENTDIR="$1"
    
    DIRNAME=${CURRENTDIR##*/}
    HTMLNAME="${DIRNAME}.html"
    if [[ -n "$2" ]];then
        LINKNAME_PREFIX_RSVCNT="$2"
    else
        LINKNAME_PREFIX_RSVCNT=0
    fi
    
    if [[ ${LINKNAME_PREFIX_RSVCNT} -eq 1 ]];then
        if [[ -n "${LINKNAME_PREFIX}" ]];then
            # プレフィックス値は、一度指定されれば下の階層で固定とする。
            LINKNAME_PREFIX="$3"
        else
            LINKNAME_PREFIX="${DIRNAME}_"
        fi
    elif [[ ${LINKNAME_PREFIX_RSVCNT} -gt 1 ]];then
        LINKNAME_PREFIX_RSVCNT=$(( LINKNAME_PREFIX_RSVCNT - 1 ))
    fi

    CNT=0

    # 指定階層のpngファイルについて、imgタグを生成。
    for PNG_FILE in $(find ${CURRENTDIR}/* -maxdepth 0 -name "*.png")
    do
        # 除外対象リストにマッチした場合、pngファイルを作成しない。
        if [[ -n "${(M)EXCLUDE_LIST:#${PNG_FILE##*/}}" ]];then
            continue
        fi
        # pngファイルのimgタグを生成し、画像の前に場所指定リンクを貼った画像名を記述。
        PNGS_SRC="${PNGS_SRC}\n<a name=\"${CNT}\">${PNG_FILE##*/}</a><br>\n<img src=\"./${PNG_FILE##*/}\"><br><br>\n"
        # 場所指定リンク生成。
        PNG_LINKS="${PNG_LINKS}\n<a href=\"#${CNT}\">${PNG_FILE##*/}</a><br>"
        CNT=$(( CNT + 1 ))
    done
    
    # 一つの下の階層について、HTMLファイルを生成。同時に、そのファイルへのリンクを取得。
    for SUBDIR in $(find ${CURRENTDIR}/* -maxdepth 0 -type d)
    do
        make_html_rec "${SUBDIR}" ${LINKNAME_PREFIX_RSVCNT} "${LINKNAME_PREFIX}"
        SUB_DIRLINKS="${SUB_DIRLINKS}\n<a href=\"./${SUBDIR##*/}/${SUBDIR##*/}.html\">${LINKNAME_PREFIX}${SUBDIR##*/}</a><br>"
    done
    
    # 下階層のディレクトリがある場合、改行調整
    if [[ -n "${SUB_DIRLINKS}" ]];then
        SUB_DIRLINKS="${SUB_DIRLINKS}<br><br>"
    fi
    
    echo -e '<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>resstat_log</title>
</head>
<body>
    <H2>■'"${HTMLNAME}"'</H2>
    <br>
    '"${SUB_DIRLINKS}"'
    '"${PNG_LINKS}"'
    <br>
    '"${PNGS_SRC}"'
</body>
</html>
' > "${CURRENTDIR}/${HTMLNAME}"

    return 0

}

########################################
#
# function make_frame_menu
#
# フレームページ用メニュー作成
#
#   make_frame_menu {対象ディレクトリパス} [リンク名プレフィックス付与のための再帰周回数]
#
#   出力するメニューHTML名は、グローバル変数の${FRAME_MENU_NAME}になっている。
#   また、ターゲットフレーム名はJS内にgraphで固定記述。
#   あと、マルチノードの場合に少し細工。
#   そこを直せばこのスクリプト外でも使用可能。
#
#   この関数内で、make_menu_contents関数を再帰的に呼び出して、ディレクトリ階層を辿っている。
#
########################################
function make_frame_menu(){
    if [[ -z "$1" ]];then
        echo -e "Error:make_frame_menu(): 1st Param is required"
        return 99
    fi
    
    local CURRENTDIR
    local DIRNAME
    local OUT_HTMLNAME
    local SUBDIR
    # この回数を超えて再帰的に呼び出した時、カレントディレクトリ名をプレフィックスに付ける。デフォルトは0（付けない）。
    # 1は全てに付ける。２以降は、その回数目の再帰呼び出しから付ける。（具体的には、ディレクトリ階層と等しい。3を指定すれば、3階層目から付けることになる）
    local LINKNAME_PREFIX_RSVCNT

    # グローバル変数。ここから呼び出す再帰関数で利用する。再帰関数全体で一意に保つため。
    # ツリー状にリンクを展開する時のDIVに付けるID。
    typeset TREE_CNT
    # マルチノードの場合にのみ使う。第一階層のリンク名をノード名に変換。
    typeset MULTINODE_1ST_FLG
    
    CURRENTDIR="$1"
    if [[ -n "$2" ]];then
        LINKNAME_PREFIX_RSVCNT="$2"
    else
        LINKNAME_PREFIX_RSVCNT=0
    fi
    
    DIRNAME=${CURRENTDIR##*/}
    
    OUT_HTMLNAME="${CURRENTDIR}/${FRAME_MENU_NAME}"

    
    # ヘッダ/共通部分の作成。
echo -e '
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <SCRIPT language="JavaScript"> 
    <!-- 
    function open_close(id){ if(document.all(id).style.display == "none") { 
                                 document.all(id).style.display="block";
                             } else {
                                 document.all(id).style.display="none";
                             }
                           }
    function graph_link(link){ parent.graph.location.href = link; }
    function ocl_link(id,link){ graph_link(link);
                                open_close(id);
                           }
    //--> 
    </SCRIPT>
    <title>resstat_log</title>
</head>
<body>
    <H3>■測定項目メニュー</H3>
    <br>
    <a href="JavaScript:graph_link('"'${STATUS_CONTS_LINK}'"');">## @contents list</a>
    <br>
    <br>
    <a href="JavaScript:graph_link('"'./${CURRENTDIR##*/}.html'"');">## @index</a>
    <br>
    <br>
' > "${OUT_HTMLNAME}"
    
    # 中核部分の作成
    # 指定ディレクトリ直下のディレクトリに対しループ
    # 再帰関数で使うtree部分の一意性保持のためのカウンタ
    TREE_CNT=0
    for SUBDIR in $(find ${CURRENTDIR}/* -maxdepth 0 -type d)
    do
        # マルチノード版対応第一階層に特殊処理。
        if ${MULTINODE_FLG};then
            MULTINODE_1ST_FLG=true
        else 
            MULTINODE_1ST_FLG=false
        fi
        make_menu_contents "${SUBDIR}" "${LINKNAME_PREFIX_RSVCNT}" "" "" "." >> "${OUT_HTMLNAME}"
    done
    
    # フッタ/共通部分の作成
    echo -e '
</body>
</html>
' >> "${OUT_HTMLNAME}"

    return 0

}



########################################
#
# function make_menu_contents
#
# グラフメニュー中核部分の作成
#
# 再帰関数
#   make_menu_contents {対象ディレクトリパス} {リンク名プレフィックス付与のための再帰周回数} {リンク名プレフィックス名} {コンテンツプレフィックス} {ディレクトリ階層}
#
#     {対象ディレクトリパス}から下のディレクトリがある限り、そのディレクトリに向かってこの関数を再帰的に呼び続ける。
#
########################################
function make_menu_contents(){
    if [[ -z "$1" ]];then
        echo -e "Error:make_menu_contents(): 1st Param is required"
        return 99
    fi
    
    local CURRENTDIR
    local DIRNAME
    local SUBDIRS
    local SUBPINGS
    local SUBHTML
    local JSLINKER
    local CONTENTS_PREFIX
    local NEW_CPREFIX
    local SUBDIR
    # この回数を超えて再帰的に呼び出した時、カレントディレクトリ名をプレフィックスに付ける。デフォルトは0（付けない）。
    # 1は全てに付ける。２以降は、その回数目の呼び出しから付ける。
    local LINKNAME_PREFIX_RSVCNT
    local LINKNAME_PREFIX
    local PARENT_DIRS

    CURRENTDIR="$1"
    DIRNAME=${CURRENTDIR##*/}
    LINKNAME_PREFIX_RSVCNT="$2"
    CONTENTS_PREFIX="$4"
    PARENT_DIRS="$5"
    
    if [[ ${LINKNAME_PREFIX_RSVCNT} -eq 1 ]];then
        LINKNAME_PREFIX="$3"
    elif [[ ${LINKNAME_PREFIX_RSVCNT} -gt 1 ]];then
        LINKNAME_PREFIX_RSVCNT=$(( LINKNAME_PREFIX_RSVCNT - 1 ))
    fi
    
    
    # 配列化はするものの、配列長で有無を測らない様に。この方法だと、findの中身が空っぽでも配列長は１になる。
    : ${(A)SUBDIRS::=${(@f)"$(find ${CURRENTDIR}/* -maxdepth 0 -type d)"}}
    : ${(A)SUBPINGS::=${(@f)"$(find ${CURRENTDIR}/* -maxdepth 0 -name "*.png" -type f)"}}
    : ${(A)SUBHTML::=${(@f)"$(find ${CURRENTDIR}/* -maxdepth 0 -name "*.html" -type f)"}}
    
    # マルチノード第一階層のみ、リンク名をノード名のみに変換する細工を行う。
    if ${MULTINODE_1ST_FLG};then
        # マルチノードの結果の場合、少し細工する。前方のoutput_と、後方の_を消して、ノード名だけにする。
        UNDERDIR_LINKNAME=${LINKNAME_PREFIX}${${DIRNAME#${OUTPUT_DIR_PREFIX}_}%%[_]*}
        MULTINODE_1ST_FLG=false
    else
        UNDERDIR_LINKNAME=${LINKNAME_PREFIX}${DIRNAME}
    fi
    
    # さらに下位のディレクトリが存在する場合
    if [[ -n "${SUBDIRS}" ]];then
        # ツリーカウンタアップ。ここだけは、再帰関数全体で一意である必要がある。
        TREE_CNT=$(( TREE_CNT + 1 ))
        if [[ -n "${SUBPINGS}" ]];then
            # この階層の直下にpngファイルと下位ディレクトリが存在する場合
            # メニュー切り替えとグラフページ移動リンク。新DIVを作成。下位ディレクトリに処理を投げて、終わったらDIVを閉じる。プレフィックス指定。
            JSLINKER="    ${CONTENTS_PREFIX}"'<a href="JavaScript:ocl_link('"'tree${TREE_CNT}'"','"'${PARENT_DIRS}/${DIRNAME}/${${SUBHTML[1]}##*/}'"');">'"${UNDERDIR_LINKNAME}"'</a><br>'
        else 
            # 下位ディレクトリのみ存在
            # メニュー切り替えのみリンク。新DIVを作成。下位ディレクトリに処理を投げて、終わったらDIVを閉じる。プレフィックス指定。
            JSLINKER="    ${CONTENTS_PREFIX}"'<a href="JavaScript:open_close('"'tree${TREE_CNT}'"');">'"${UNDERDIR_LINKNAME}"'</a><br>'
        fi
        echo -e "${JSLINKER}"
        
        # 下位ディレクトリが存在すれば、新たにDIVを切って下位ディレクトリに処理を投げる。
        if [[ -n "${CONTENTS_PREFIX}" ]];then
            NEW_CPREFIX="　${CONTENTS_PREFIX}"
        else 
            NEW_CPREFIX="　|-"
        fi
        echo -e '<DIV id="'"tree${TREE_CNT}"'" style="display:none;">'
        for SUBDIR in ${SUBDIRS[*]}
        do
            # 同関数を再帰呼び出し。
            make_menu_contents "${SUBDIR}" ${LINKNAME_PREFIX_RSVCNT} "${DIRNAME}_" "${NEW_CPREFIX}" "${PARENT_DIRS}/${DIRNAME}"
        done
        echo -e '</DIV>'
    else 
        # 下位ディレクトリなしの場合
        # グラフページ移動リンクのみ作成。
        JSLINKER="    ${CONTENTS_PREFIX}"'<a href="JavaScript:graph_link('"'${PARENT_DIRS}/${DIRNAME}/${${SUBHTML[1]}##*/}'"');">'"${UNDERDIR_LINKNAME}"'</a><br>'
        echo -e "${JSLINKER}"
    fi
    
    return 0

}




########################################
#
# zshスクリプト
# make_html_1result.sh
#
# [概要]
#    グラフ参照用HTMLの作成。
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

CHILD_FLG=false
MULTINODE_FLG=false

while getopts :x:l:cmh ARG
do
    case "${ARG}" in
        x)
          # 除外対象コンフィグ
          EXCLUDE_CONF="${OPTARG}"
        ;;
        l)
          # コンテンツ一覧リンク
          STATUS_CONTS_LINK="${OPTARG}"
        ;;
        c)
          CHILD_FLG=true
        ;;
        m)
          MULTINODE_FLG=true
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

# 2nd Argument：ターゲットディレクトリ
if [[ ! -d "$1" ]];then
    UsageMsg
    exit 4
fi
TARGET_DIR="${1%/}"

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

FRAME_INDEX_NAME="index.html"
FRAME_MENU_NAME="menu.html"

########################################
# グラフ画像HTML 出力実行
########################################
# status_contents.htmlを出力先ルートにコピー。-lでリンク先を指定されている場合には行わない。
if [[ -z "${STATUS_CONTS_LINK}" ]];then
    cp -p "${STATS_CONTENTS_HTML}" "${TARGET_DIR}/"
    STATUS_CONTS_LINK="./${STATS_CONTENTS_HTML##*/}"
fi

# HTML excludeファイルから、除外対象を取得
if [[ -s "${EXCLUDE_CONF}" ]];then
    : ${(A)EXCLUDE_LIST::=${${(@f)"$(<${EXCLUDE_CONF})"}:#[#]*}}
fi

# 直下の階層ループ：：CONTENTS
for CONTENTS in $(find ${TARGET_DIR}/* -maxdepth 0 -type d)
do
    if ${MULTINODE_FLG};then
        # マルチノード出力の場合、2階層目からリンク名にプレフィックスを要求。
        make_html_rec "${CONTENTS}" 2
    else 
        # シングルノード出力の場合、1階層目からリンク名にプレフィックスを要求。
        make_html_rec "${CONTENTS}" 1
    fi
    
    CONTENTS_NAME=${CONTENTS##*/}
    
    if ${MULTINODE_FLG};then
        # マルチノードの結果の場合、少し細工する。前方のoutput_と、後方の_を消して、ノード名だけにする。
        UNDERDIR_LINKNAME=${${CONTENTS_NAME#${OUTPUT_DIR_PREFIX}_}%%[_]*}
    else
        UNDERDIR_LINKNAME=${CONTENTS_NAME}
    fi
    
    LINKS_SRC="${LINKS_SRC}\n<a href=\"./${CONTENTS_NAME}/${CONTENTS_NAME}.html\">${UNDERDIR_LINKNAME}</a><br>"
done

# 全体リンクの作成
TARGET_DIR_NAME=${TARGET_DIR##*/}

# マルチノード結果出力の場合は、タイトルとかの見栄えに少し細工をする。
if ${MULTINODE_FLG};then
    PAGE_TITLE="■ALLNODE_RESULTS"
    LINKS_SRC="    <br>\n<b>NODE Name</b><br><br>\n${LINKS_SRC}"
else
    PAGE_TITLE="■${TARGET_DIR_NAME}"
fi

# グラフ閲覧HTMLのトップページ作成
echo -e '<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>resstat_log</title>
</head>
<body>
    <H2>■'"${TARGET_DIR_NAME}"'</H2>
    <p style="text-align: right;"><a href="'"${STATUS_CONTS_LINK}"'">計測項目一覧</a></p>
    '"${LINKS_SRC}"'
    <br>
</body>
</html>
' > "${TARGET_DIR}/${TARGET_DIR_NAME}.html"

########################################
# フレームページ・左メニューの出力実行
########################################
# 子階層用作成の場合はフレーム不要。
if ! ${CHILD_FLG};then
    # フレーム定義ページ：index.html
    echo -e '<html lang="ja">
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"> 
  <meta http-equiv="Content-Language" content="ja"> 
  <title>resstat測定結果</title>
<head>
</head>
<frameset cols="20%,*">
  <frame src="'"${FRAME_MENU_NAME}"'" name="menu">
  <frame src="'"${TARGET_DIR_NAME}.html"'" name="graph">
</frameset>
</html>
' > "${TARGET_DIR}/${FRAME_INDEX_NAME}"

    # メニューページ
    if ${MULTINODE_FLG};then
        # マルチノード出力の場合、3階層目からリンク名にプレフィックスを要求。
        make_frame_menu "${TARGET_DIR}" 3
    else
        # シングルノード出力の場合、2階層目からリンク名にプレフィックスを要求。
        make_frame_menu "${TARGET_DIR}" 2
    fi
fi

exit 0

