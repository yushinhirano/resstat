########################################
#
# common.sh
#
# [概要]
#    source読み込み用共通スクリプト。
#    zshでのみ有効。
#
# [登録関数]
#    ◆関数名                         ◆区分  ◆概要
#    ・checkReturnErrorFatal          公開    関数戻り値を引数にして、0でなければ即exitする。
#    ・getParamFromConf               公開    resstat.confからパラメータ取得
#    ・getParamFromGraphConf          公開    graph.confからパラメータ取得
#    ・getParamFromAllHeaderConf      公開    conf/{SYSKBN}/all_header.confからパラメータ取得
#    ・getParamFromAllFooterConf      公開    conf/{SYSKBN}/all_footer.confからパラメータ取得
#    ・getParamFromCommonConf         公開    conf/{SYSKBN}/common.confからパラメータ取得
#    ・getParam                       内部    指定コンフィグファイルからパラメータ取得
#    ・getGraphConfDataBy1stKey       内部    グラフコンフィグから第一フィールドをKeyに発見した最初の行を返す
#    ・getGraphConfMultiHeader        公開    グラフコンフィグからMultiplot用ヘッダ行を取得
#    ・getGraphConfData               公開    グラフコンフィグからヘッダ行以外のデータ行を取得
#    ・getGraphMultiData              公開    グラフコンフィグファイルからMultiplot用データ行を取得
#    ・getLineFieldsNumber            公開    引数として与えられた行のフィールド数を取得
#    ・getLineFields                  公開    引数として与えられた行の指定フィールドを取得
#    ・getFieldsForMultiLines         公開    getLineFieldsの複数行化。指定フィールドを改行区切りで切りだす。
#    ・getLineFieldsRear              公開    引数として与えられた行の指定フィールド以降全てのフィールドを取得
#    ・getLines                       公開    引数として与えられた複数行から、指定の1行を取得
#    ・getLinesFromFile               公開    引数として与えられたファイルから、指定の1行を取得
#    ・getParamFieldsNum              公開    引数として与えられた行から、指定文字列にヒットするフィールド番号を取得
#    ・getSysstatVersion              公開    インストールされているsysstatバージョンを取得
#    ・getProcsVersion                公開    インストールされているprocsバージョンを取得
#
#    ・setParam_ForConf               公開    resstat.confのパラメータを修正
#    ・setParam                       内部    指定コンフィグのパラメータを修正
#
#    ・loadAllParam_FromConf          公開    resstat.confのパラメータを全読み込みしてグローバル変数設定
#    ・loadAllParam                   内部    指定コンフィグのパラメータを全読み込みしてグローバル変数設定
#
#    ・compVersion                    公開    ２つの引数指定文字列に対し、バージョン番号とみなして比較する。
#
########################################

# 関数ロード準備。ここから先はプロセス階層で1回のみで良い。既に1回起動して「準備完了」となっていれば、コンパイルチェックやfpathの調整は不要。
if [[ -z "${COMMON_FUNC_ON}" ]];then
    # 関数名定義（配列変数のexportは仕様的に不可能なので、別手段を取る）
    export RESSTAT_FUNCS='checkReturnErrorFatal \
                    getParamFromConf \
                    getParamFromGraphConf \
                    getParamFromAllHeaderConf \
                    getParamFromAllFooterConf \
                    getParamFromCommonConf \
                    getParam \
                    getGraphConfDataBy1stKey \
                    getGraphConfHeader \
                    getGraphConfMultiHeader \
                    getGraphConfData \
                    getGraphMultiData \
                    getLineFieldsNumber \
                    getLineFields \
                    getFieldsForMultiLines \
                    getLineFieldsRear \
                    getLines \
                    getLinesFromFile \
                    getParamFieldsNum \
                    getSysstatVersion \
                    getProcsVersion \
                    setParam_ForConf \
                    setParam \
                    loadAllParam_FromConf \
                    loadAllParam \
                    compVersion'

    # zcompile済みでなければ、zcompileを掛ける。
    
    # lib/*.zwcファイルがあるかどうかを確認するだけだが、zsh機能のグロッビングパターンを利用する場合にはエラーメッセージが標準エラー出力にリダイレクトしても消せない（zsh-4.3系では少なくとも）
    # lsでリスト＋パイプ＋grepのパターンで２プロセス上げるのと、findのグロッビングに頼って１プロセスにする、の２パターンが考えられるが、はたしてどっちが軽い？
    # ……grepはヒット行が存在しない場合にはリターンエラーだが、findはヒットせずともリターンに関係ないので、別にチェックする必要がある。
    # ただ、外部コマンドの微妙なリターンコード仕様に頼るのは（バージョン等により変わる可能性を考慮して）良くないか。ちなみに時間的には微妙なところ。どちらも4～6msec程度。
    if [[ -z "$(find "${LIB_DIR}" -maxdepth 1 -name "*.zwc")" ]];then
        # 登録関数名がパスを含めないために、ディレクトリ移動。
        cd "${LIB_SRC_DIR}"
        # メモリ読み込み型強制でコンパイル。
        for FUNC_SRCFILE in *
        do
            zcompile -R "../${FUNC_SRCFILE}.zwc" "${FUNC_SRCFILE}"
        done
        # ディレクトリ戻り
        cd -
    fi
    # functionパスを通す。
    export FPATH="${FPATH}${FPATH:+:}${LIB_DIR}"

    # 関数定義読み込み準備完了
    export COMMON_FUNC_ON=1
fi

# 全関数をエイリアス抑制autoload対象として登録する。
# autoloadはプロセス毎に定義しなおさなければ、exportできないために消えてしまう。
# また、-wでコンパイル済みであることを指示する場合、zwcファイルが存在するディレクトリに行かないと失敗する。FPATH指定だけでは無効だった。
# 一応これだけなら1msec。許容範囲に収まるので許してあげる。
cd "${LIB_DIR}"
autoload -Uw ${(z)RESSTAT_FUNCS[*]}
cd -


