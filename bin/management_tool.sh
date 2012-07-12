#!/usr/bin/env zsh
########################################
# function UsageMsg
########################################
function UsageMsg(){
    cat <<-EOF
    
	Usage : management_tool.sh
	        
	        management_tool.sh [ [34;1m-f node_file[m ]
	        management_tool.sh [ [34;1m-h[m ]
	
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
	
	
	[36;1mUsage: management_tool.sh [m  -- resstat対話的管理メニューツール
	
	       management_tool.sh [ [34;1m-f node_file[m ]
	       management_tool.sh [ [34;1m-h[m ]
	
	
	[36;1m[Options] : [m
	
	       [34;1m-f[m : 複数ノード一斉起動時の起動対象ノード記述ファイルを指定する。
	            指定しない場合、デフォルトはconf/targethost。

	       [34;1m-h[m : ヘルプ
	
	
	[36;1m[Overview] : [m
	
	       resstat各機能の管理/実行を対話的に行うツール。
	       ユーザに機能の選択を促し、単独ノード起動の場合は[33;1mbin/ctrlresstat.sh[m、
	       複数ノード起動の場合は[33;1mbin/multictrl_resstat.sh[mを実行する。
	       
	       起動方法に関する注意は[33;1mbin/ctrlresstat.sh -h[mと
	       [33;1mbin/multictrl_resstat.sh -h[mを参照。
	       基本的には、(configure⇒)start⇒stop(または起動時間終了)⇒collect＆outputで良い。
	       
	       ただし、このツールを介しての複数ノード起動には制限を掛けている。
	       conf/.multi_conf_onの値を1にすれば複数ノード起動が有効になるが、
	       conf/targethostファイルを記述したり、
	       対象全ノードに同じユーザを作り公開鍵を介した接続を可能にする、
	       といった準備が必要なので、その準備を行わずに複数ノードを起動しない様にする配慮である。
	       
	       尚、これらの複数ノード起動準備作業は、
	       multisetup/bin/にある複数のツールを利用することができる。


	[31;1m[Caution] : [m
	
	       [35;1m１．複数ノード起動[m
	           上述のように、複数ノード起動準備を整えるまでは有効化しないこと。
	
	
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
# function ShowLocalResstatProcess
########################################
function ShowLocalResstatProcess(){
    local NOWEXEC_LIST
    NOWEXEC_LIST=$("${CTRLRESSTAT_SH}" show)
    
    echo -e ''
    echo -e '    ========================================='
    echo -e "    == [ ${MYHOST} ] Status"
    echo -e "${NOWEXEC_LIST}" | while read line 
    do
        echo -e "    == ${line}"
    done
    echo -e '    == '
    echo -e '    ========================================='
    echo -e ''
    
}


########################################
# function ShowMultiResstatProcess
########################################
function ShowMultiResstatProcess(){
    # multi起動モードのロックが掛かっていれば何もしない。
    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        return ${RET_OK}
    fi

    local NOWEXEC_LIST

    NOWEXEC_LIST=$("${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" show)
    
    echo -e ''
    echo -e '    ========================================='
    echo -e '    == [All Target] Status'
    echo -e '    == '
    echo -e "${NOWEXEC_LIST}" | while read line 
    do
        echo -e "    == ${line}"
    done
    echo -e '    == '
    echo -e '    ========================================='
    echo -e ''
    
}



########################################
# function PrintTargetHost
########################################
function PrintTargetHost(){
    local NODES
    local TOP=0
    
    # 先頭#を除いてtargethostファイルを読み込み
    for NODES in ${${(@f)"$(<${RESSTAT_TG_HOSTS})"}:#[#]*}
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
        echo -e '## resstat tool MainMenu'
        echo -e '## '
        echo -e '##    please select command No.'
        echo -e '## '
        echo -e '############################################################'
        echo -e ''
        echo -e ''
        echo -e '    --  resstat command menu --    '
        echo -e ''
        echo -e '      1. ローカルノード単独起動'
        echo -e '      2. 複数ノード一斉起動'
        echo -e ''
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ input command code. [1-2q] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "1")
                    OpenSingleMenu
                    RETVAL=$?
                    break 1
                    ;;
                "2")
                    OpenMultiMenu
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
            echo -e " \$\$\$ input command code. [1-2q] >\c"
        done
        if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
            return ${RET_QUIT}
        elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
            continue
        fi
    done
}


##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
############   
############   
############   単独ノード起動CUI関数
############   
############   
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################


########################################
# function OpenSingleMenu
########################################
function OpenSingleMenu(){
    local SELECT_BUFF
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '############################################################'
        echo -e '## '
        echo -e '## resstat tool SingleNode Menu'
        echo -e '## '
        echo -e '##    please select command No. '
        echo -e '## '
        echo -e '############################################################'
        echo -e ''
        echo -e ''
        echo -e '    --  resstat ローカルノード単独起動 command menu --    '
        echo -e ''
        echo -e '      1. start'
        echo -e '      2. stop'
        echo -e '      3. collect and output'
        echo -e ''
        echo -e '      4. data directory clear'
        echo -e '      5. auto configure for my host'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        
        ShowLocalResstatProcess
        
        echo -e ""
        echo -e " \$\$\$ input command code [1-5bq] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                # 標準出力が壊れている？\cのせいだろうか。ここでは一旦無意味にechoする。
                echo -e ''
                
                case "${SELECT_BUFF}" in
                "1")
                    SingleStart
                    RETVAL=$?
                    break 1
                    ;;
                "2")
                    SingleStop
                    RETVAL=$?
                    break 1
                    ;;
                "3")
                    SingleCollectAndOutput
                    RETVAL=$?
                    break 1
                    ;;
                "4")
                    SingleClear
                    RETVAL=$?
                    break 1
                    ;;
                "5")
                    SingleConfigure
                    RETVAL=$?
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
            echo -e " \$\$\$ input command code [1-5bq] >\c"
        done
        
        if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
            return ${RETVAL}
        elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
            continue
        fi
        
        # 正常終了してリターンした場合にはContinue前に一呼吸置く。
        ContinueInput
    done
}

########################################
#
# function SingleStartMenu
#
#    単独ノード  startメイン処理
#
########################################
function SingleStart(){
    local SELECT_BUFF
    local DMP_DIR_SUFFIX=""
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  resstat モニタリング start config  '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      ダンプディレクトリ名サフィックス [${DMP_DIR_SUFFIX:-default}]"
        echo -e "         デフォルト値   : ${MYHOST}_YYYYMMDD_HH24MISS      :現在日時を使います"
        echo -e "         ディレクトリ名 : ${MYHOST}_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}"
        echo -e ''
        echo -e "      出力ディレクトリは、\n"
        echo -e "         [${DATA_DIR}/${MYHOST}_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}]"
        echo -e "\n      となります。"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      m. modify input directory_suffix'
        echo -e '      c. clear  input directory_suffix'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [ymcbq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "m")
                    INPUT_BUFF=""
                    StringInput "please input-directory suffix name"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    DMP_DIR_SUFFIX="${INPUT_BUFF}"
                    break 1
                    ;;
                "c")
                    DMP_DIR_SUFFIX=""
                    echo -e "\n suffix input clear .....\n"
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
            echo -e " \$\$\$ please input command code [ymcbq] >\c"
        done
    done
    
    #### start shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ SINGLE NODE resstat input confirm $$ ---------'
        echo -e "  ----  TARGET  : ${MYHOST}"
        echo -e "  ----  COMMAND : start"
        echo -e "  ----  DMPDIR  : ${DATA_DIR}/${MYHOST}_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}"
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
                    AUTO_CONFIG=$(getParamFromConf AUTO_CONFIG)
                    if [[ -n "${DMP_DIR_SUFFIX}" ]];then
                        "${CTRLRESSTAT_SH}" -d "${DMP_DIR_SUFFIX}" start 
                    else 
                        "${CTRLRESSTAT_SH}" start
                    fi
                    echo -e "\n  executed resstat start ..... \n"
                    
                    # AUTO CONFIGUREでのSYSKBN変更ケースを考慮し、common_def.shを再定義。
                    if [[ ${AUTO_CONFIG} == "ON" ]];then
                        source "${BIN_DIR}/common_def.sh"
                    fi
                    
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat start ..... \n"
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
# function SingleStopMenu
#
#    単独ノード  stopメイン処理
#
########################################
function SingleStop(){
    local SELECT_BUFF
    
    #### stop shell execute ####
    
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ SINGLE NODE resstat input confirm $$ ---------'
        echo -e "  ----  TARGET  : ${MYHOST}"
        echo -e "  ----  COMMAND : stop"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        ShowLocalResstatProcess

        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${CTRLRESSTAT_SH}" stop
                    echo -e "\n  executed resstat stop ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat stop ..... \n"
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
# function SingleCollectAndOutput
#
#    単独ノード  グラフ出力関連メイン処理
#
########################################
function SingleCollectAndOutput(){

    local SELECT_BUFF
    local DMP_DIR_GRAPH=""
    local OUTPUT_DIR_GRAPH=""
    local COLLECT_TDIR_SUFFIX=""
    
    ## TODO 最新ディレクトリ、ではなく、きっちりlsで調べて出力。
    
    ## TODO 変更時、dataディレクトリ内のディレクトリをリストして、番号でどのディレクトリか選ばせる機能を持たせる。（そこまでするか？昔やったが実装面倒で誰も使わなかったが…）
    
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  resstat リソースグラフ化  config '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      グラフ化対象ディレクトリ : ${DATA_DIR}/$( if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then echo "${MYHOST}_${COLLECT_TDIR_SUFFIX}" ;else echo '<最新ディレクトリ>' ;fi )"
        echo -e "        グラフ化対象ディレクトリ名サフィックス  : [${COLLECT_TDIR_SUFFIX:-default}]"
        echo -e "        デフォルト値                            : ${DATA_DIR}/<最新ディレクトリ>"
        echo -e '        （※サフィックスを指定する場合はstart時に指定したものと同じものを使ってください）'
        echo -e ""
        echo -e "      出力ディレクトリパス [${OUTPUT_DIR_GRAPH:-default}]"
        echo -e "         デフォルト値      : ${ARCHIVE_DIR}/"
        echo -e "         出力ディレクトリ  : ${OUTPUT_DIR_GRAPH:-${ARCHIVE_DIR}/}"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      s. modify collect directory suffix'
        echo -e '      r. clear collect directory suffix'
        echo -e '      m. modify output directory path'
        echo -e '      c. clear  output directory path'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [ysrmcbq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "s")
                    INPUT_BUFF=""
                    StringInput "please input collect_directory suffix"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    COLLECT_TDIR_SUFFIX="${INPUT_BUFF}"
                    break 1
                    ;;
                "r")
                    COLLECT_TDIR_SUFFIX=""
                    echo -e "\n collect_directory suffix clear .....\n"
                    break 1
                    ;;
                "m")
                    INPUT_BUFF=""
                    StringInput "please input dest_directory path (absolute)"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    OUTPUT_DIR_GRAPH="${INPUT_BUFF}"
                    break 1
                    ;;
                "c")
                    OUTPUT_DIR_GRAPH=""
                    echo -e "\n input directory name clear .....\n"
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
            echo -e " \$\$\$ please input command code [ysrmcbq] >\c"
        done
    done
    
    #### collect and output shell execute ####
    
    ## TODO 最新ディレクトリ、ではなく、きっちりlsで調べて出力。
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ SINGLE NODE resstat input confirm $$ ---------'
        echo -e "  ----  TARGET      : ${MYHOST}"
        echo -e "  ----  COMMAND     : collect and output"
        echo -e "  ----  COLLECT_DIR : ${DATA_DIR}/$( if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then echo "${MYHOST}_${COLLECT_TDIR_SUFFIX}" ;else echo '<最新ディレクトリ>' ;fi )"
        echo -e "  ----  OUTPUTDIR   : ${OUTPUT_DIR_GRAPH:-${ARCHIVE_DIR}/}"
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
                    if [[ -n "${OUTPUT_DIR_GRAPH}" ]];then
                        if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
                            "${CTRLRESSTAT_SH}" -d "${COLLECT_TDIR_SUFFIX}" collect
                        else
                            "${CTRLRESSTAT_SH}" collect
                        fi
                        "${CTRLRESSTAT_SH}" -d "${OUTPUT_DIR_GRAPH}" output
                        # -f指定しなくともoutput対象は最新でOK？
                        # "${CTRLRESSTAT_SH}" -d "${OUTPUT_DIR_GRAPH}" -f "${ARCHIVE_DIR}/${OUTPUT_DIR_PREFIX}_$(uname -n)_${COLLECT_TDIR_SUFFIX}.tbz2" output
                    else 
                        if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
                            "${CTRLRESSTAT_SH}" -d "${COLLECT_TDIR_SUFFIX}" collect
                        else
                            "${CTRLRESSTAT_SH}" collect
                        fi
                        "${CTRLRESSTAT_SH}" output
                    fi

                    echo -e ''
                    echo -e "\n  executed resstat collect and output ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat collect and output ..... \n"
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
# function SingleClear
#
#    単独ノード  clearメイン処理
#
########################################
function SingleClear(){

    local SELECT_BUFF
    
    #### clear script execute ####
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ SINGLE NODE resstat input confirm $$ ---------'
        echo -e "  ----  TARGET  : ${MYHOST}"
        echo -e "  ----  COMMAND : clear"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        echo -e '    data, archive, output, proc_id領域をクリアします。'
        echo -e ''
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${CTRLRESSTAT_SH}" clear
                    echo -e "\n  executed clear ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e "\n  cancel clear ..... \n"
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
# function SingleConfigure
#
#    単独ノード  configureメイン処理
#
########################################
function SingleConfigure(){

    local SELECT_BUFF
    
    #### configure script execute ####
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e "  --------- \$\$ SINGLE NODE resstat input confirm \$\$ ---------"
        echo -e "  ----  TARGET  : ${MYHOST}"
        echo -e "  ----  COMMAND : configure"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        echo -e '    このマシンのsysstat、procsパッケージバージョンに応じたSYSKBNの調整、'
        echo -e '    計測対象CPUコア、ネットワークインタフェース、ブロックデバイスの自動設定を行います。'
        echo -e ''
        echo -e '    尚、conf/resstat.confファイルのAUTO_CONFIGパラメータをONにしておけば、'
        echo -e '    このパッケージの初回start起動時に、自動的にこの処理を行います。'
        echo -e ''
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${CTRLRESSTAT_SH}" configure
                    echo -e "\n  executed configure ..... \n"
                    # SYSKBN変更の可能性があるので、共通変数を再定義する。
                    source "${BIN_DIR}/common_def.sh"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel configure ..... \n"
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


##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
############   
############   
############   複数ノード起動CUI関数
############   
############   
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################


########################################
# function OpenMultiMenu
########################################
function OpenMultiMenu(){
    local SELECT_BUFF
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '############################################################'
        echo -e '## '
        echo -e '## resstat tool MultiNode Menu'
        echo -e '## '
        echo -e '##    please select command No. '
        echo -e '## '
        echo -e '############################################################'
        echo -e ''
        echo -e ''
        echo -e '    --  resstat 複数ノード一斉起動 command menu --    '
        echo -e ''
        echo -e '      1. start'
        echo -e '      2. stop'
        echo -e '      3. collect and output'
        echo -e ''
        echo -e '      4. data directory clear'
        echo -e '      5. auto configure for my host'
        echo -e '      6. All and config files sync'
        echo -e ''
        echo -e '      7. Monitoring User and SSH auto configure (Special Warning!)'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e '      $$  複数ノード一斉起動ロック（起動条件を満たしてから解除してください）  $$'
        echo -e '      $$  Status ：'$(if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]] ;then ;echo -e 'Lock' ; else ; echo -e 'UnLock' ; fi )
        echo -e ''
        echo -e '      o. MultiNode Lock | Mode: Lock'
        echo -e '      u. MultiNode Lock | Mode: UnLock'
        echo -e ''
        ShowMultiResstatProcess
        echo -e ''
        echo -e " \$\$\$ input command code [1-7oubq] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                # 標準出力が壊れている？\cのせいだろうか。ここでは一旦無意味にechoする。
                echo -e ''
                
                case "${SELECT_BUFF}" in
                "1")
                    MultiStart
                    RETVAL=$?
                    break 1
                    ;;
                "2")
                    MultiStop
                    RETVAL=$?
                    break 1
                    ;;
                "3")
                    MultiCollectAndOutput
                    RETVAL=$?
                    break 1
                    ;;
                "4")
                    MultiClear
                    RETVAL=$?
                    break 1
                    ;;
                "5")
                    MultiConfigure
                    RETVAL=$?
                    break 1
                    ;;
                "6")
                    MultiSync
                    RETVAL=$?
                    break 1
                    ;;
                "7")
                    echo -e "\nmultinode setup 管理ツールへ移行します ...... [ENTER]\c"
                    read
                    "${MULTINODE_SETUP_SH}" -f "${NODEFILE}"
                    RETVAL=$?
                    break 1
                    ;;
                "o")
                    echo -e "${MULTI_OFF}" > ${MULTI_FLG_FILE}
                    RET_CODE=$?
                    if [[ ${RET_CODE} -ne ${RET_OK} ]];then
                        echo -e "\nMulti Execute Mode Change Miss \n"
                    else 
                        MULTI_CONFIGURE="${MULTI_OFF}"
                        echo -e "\nChange Complete : Multi Execute Mode  | Lock\n"
                    fi
                    break 1
                    ;;
                "u")
                    echo -e "${MULTI_ON}" > ${MULTI_FLG_FILE}
                    RET_CODE=$?
                    if [[ ${RET_CODE} -ne ${RET_OK} ]];then
                        echo -e "\nMulti Execute Mode Change Miss \n"
                    else 
                        MULTI_CONFIGURE="${MULTI_ON}"
                        echo -e "\nChange Complete : Multi Execute Mode  | UnLock\n"
                    fi
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
            echo -e " \$\$\$ input command code [1-7oubq] >\c"
        done
        
        if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
            return ${RETVAL}
        elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
            continue
        fi
        
        # 正常終了してリターンした場合にはContinue前に一呼吸置く。
        ContinueInput

    done
}



########################################
#
# function MultiStart
#
#    複数ノード  startメイン処理
#
########################################
function MultiStart(){
    local SELECT_BUFF
    local DMP_DIR_SUFFIX=""
    
    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  resstat モニタリング start config  '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      ダンプディレクトリ名サフィックス [${DMP_DIR_SUFFIX:-default}]"
        echo -e "         デフォルト値   : [対象ホスト名]_YYYYMMDD_HH24MISS      :現在日時を使います"
        echo -e "         ディレクトリ名 : [対象ホスト名]_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}"
        echo -e ''
        echo -e "      出力ディレクトリは、\n"
        echo -e "         [${DATA_DIR}/[対象ホスト名]_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}]"
        echo -e "\n      となります。"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      m. modify input directory_suffix'
        echo -e '      c. clear  input directory_suffix'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [ymcbq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "m")
                    INPUT_BUFF=""
                    StringInput "please input-directory suffix name"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    DMP_DIR_SUFFIX="${INPUT_BUFF}"
                    break 1
                    ;;
                "c")
                    DMP_DIR_SUFFIX=""
                    echo -e "\n suffix input clear .....\n"
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
            echo -e " \$\$\$ please input command code [ymcbq] >\c"
        done
    done
    
    #### start shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND : start"
        echo -e "  ----  DMPDIR  : ${DATA_DIR}/[対象ホスト名]_${DMP_DIR_SUFFIX:-YYYYMMDD_HH24MISS}"
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
                    AUTO_CONFIG=$(getParamFromConf AUTO_CONFIG)
                    if [[ -n "${DMP_DIR_SUFFIX}" ]];then
                        "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" -d "${DMP_DIR_SUFFIX}" start
                    else 
                        "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" start
                    fi
                    echo -e "\n  executed resstat start ..... \n"
                    
                    # AUTO CONFIGUREでのSYSKBN変更ケースを考慮し、common_def.shを再定義。
                    if [[ ${AUTO_CONFIG} == "ON" ]];then
                        source "${BIN_DIR}/common_def.sh"
                    fi
                    
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat start ..... \n"
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
# function MultiStop
#
#    複数ノード  stopメイン処理
#
########################################
function MultiStop(){
    local SELECT_BUFF
    
    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    
    #### stop shell execute ####
    
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND : stop"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        ShowMultiResstatProcess
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" stop
                    echo -e "\n  executed resstat stop ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat stop ..... \n"
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
# function MultiCollectAndOutput
#
#    複数ノード  グラフ出力関連メイン処理
#
########################################
function MultiCollectAndOutput(){

    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    local SELECT_BUFF
    local OUTPUT_DIR_GRAPH=""
    local ALLNODE_COLLECTDIR=""
    local COLLECT_TDIR_SUFFIX=""
    
    ## TODO Single版とは違い、こちらはノードが複数に及ぶためdata内のリスティングはほぼ不可能。
    
    while :
    do
        clear
        echo -e ''
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  ----  resstat リソース収集及びグラフ化  config '
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e "      収集対象ディレクトリ : ${DATA_DIR}/$( if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then echo '<ホスト名>_'${COLLECT_TDIR_SUFFIX} ;else echo '<最新ディレクトリ>' ;fi )"
        echo -e "        収集対象ディレクトリ名サフィックス  : [${COLLECT_TDIR_SUFFIX:-default}]"
        echo -e "        デフォルト値                        : ${DATA_DIR}/<最新ディレクトリ>"
        echo -e '        （※サフィックスを指定する場合はstart時に指定したものと同じものを使ってください）'
        echo -e ''
        echo -e "      出力ディレクトリパス [${OUTPUT_DIR_GRAPH:-default}]"
        echo -e "         デフォルト値      : ${ARCHIVE_DIR}/"
        echo -e "         出力ディレクトリ  : ${OUTPUT_DIR_GRAPH:-${ARCHIVE_DIR}/}"
        echo -e ''
        echo -e '      y. OK'
        echo -e '      s. modify collect directory suffix'
        echo -e '      r. clear collect directory suffix'
        echo -e '      m. modify output directory path'
        echo -e '      c. clear  output directory path'
        echo -e ''
        echo -e '      b. back'
        echo -e '      q. QUIT'
        echo -e ''
        echo -e " \$\$\$ please input command code [ysrmcbq] >\c"
        
        while :
        do
            # zshでは-k
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    break 2
                    ;;
                "s")
                    INPUT_BUFF=""
                    StringInput "please input collect_directory suffix"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    COLLECT_TDIR_SUFFIX="${INPUT_BUFF}"
                    break 1
                    ;;
                "r")
                    COLLECT_TDIR_SUFFIX=""
                    echo -e "\n collect_directory suffix clear .....\n"
                    break 1
                    ;;
                "m")
                    INPUT_BUFF=""
                    StringInput "please input dest_directory path (absolute)"
                    RETVAL=$?
                    if [[ ${RETVAL} -eq ${RET_QUIT} ]];then
                        return ${RETVAL}
                    elif [[ ${RETVAL} -eq ${RET_BACK} ]];then
                        break 1
                    fi
                    OUTPUT_DIR_GRAPH="${INPUT_BUFF}"
                    break 1
                    ;;
                "c")
                    OUTPUT_DIR_GRAPH=""
                    echo -e "\n input directory name clear .....\n"
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
            echo -e " \$\$\$ please input command code [ysrmcbq] >\c"
        done
    done
    
    #### collect and output shell execute ####
    
    while :
    do
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND     : collect and output"
        echo -e "  ----  COLLECT_DIR : ${DATA_DIR}/$( if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then echo '<ホスト名>_'${COLLECT_TDIR_SUFFIX} ;else echo '<最新ディレクトリ>' ;fi )"
        echo -e "  ----  OUTPUTDIR   : ${OUTPUT_DIR_GRAPH:-${ARCHIVE_DIR}/}"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    # 本日日付
                    TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")
                    # 収集先の指定
                    while :
                    do
                        if [[ -e "${ALLNODE_OUTPUT_DIR}/${TODAYS_DATE}" ]];then
                            TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")
                        else 
                            mkdir -p ${ALLNODE_COLLECTDIR::="${ALLNODE_OUTPUT_DIR}/${TODAYS_DATE}"}
                            break 1
                        fi
                    done
                    echo -e ''
                    echo -e "\n  ##---- data collect to : [${ALLNODE_COLLECTDIR}]\n"
                    
                    if [[ -n "${OUTPUT_DIR_GRAPH}" ]];then
                        if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
                            "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" -d "${COLLECT_TDIR_SUFFIX}" collect "${ALLNODE_COLLECTDIR}"
                        else
                            "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" collect "${ALLNODE_COLLECTDIR}"
                        fi
                        "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" -d "${OUTPUT_DIR_GRAPH}" output "${ALLNODE_COLLECTDIR}"
                    else 
                        if [[ -n "${COLLECT_TDIR_SUFFIX}" ]];then
                            "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" -d "${COLLECT_TDIR_SUFFIX}" collect "${ALLNODE_COLLECTDIR}"
                        else
                            "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" collect "${ALLNODE_COLLECTDIR}"
                        fi
                        "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" output "${ALLNODE_COLLECTDIR}"
                    fi
                    echo -e "\n  executed resstat collect and output ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel resstat collect and output ..... \n"
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
# function MultiClear
#
#    複数ノード  clearメイン処理
#
########################################
function MultiClear(){

    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    local SELECT_BUFF
    
    #### clear script execute ####
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND : clear"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        echo -e '    data, archive, output, proc_id領域をクリアします。'
        echo -e ''
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" clear
                    echo -e "\n  executed clear ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel clear ..... \n"
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
# function MultiConfigure
#
#    複数ノード  configureメイン処理
#
########################################
function MultiConfigure(){

    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    local SELECT_BUFF
    
    #### configure script execute ####
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND : configure"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        echo -e '    全てのマシンのsysstat、procsパッケージバージョンに応じたSYSKBNの調整、'
        echo -e '    計測対象CPUコア、ネットワークインタフェース、ブロックデバイスの自動設定を行います。'
        echo -e ''
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" configure
                    echo -e "\n  executed configure ..... \n"
                    # SYSKBN変更の可能性があるので、共通変数を再定義する。
                    source "${BIN_DIR}/common_def.sh"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel configure ..... \n"
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
# function MultiSync
#
#    複数ノード  コンフィグファイル同期メイン処理
#
########################################
function MultiSync(){

    if [[ "${MULTI_CONFIGURE}" == "${MULTI_OFF}" ]];then
        echo -e '\n  ##---- 複数ノード同時起動はLock中です。起動条件を満たした後、解除して実行してください。\n'
        return ${RET_OK}
    fi

    local SELECT_BUFF
    
    #### configure script execute ####
    
    while :
    do
        clear
        echo -e "\n"
        echo -e ''
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e '  --------- $$ MULTI NODE resstat input confirm $$ ---------'
        PrintTargetHost
        echo -e "  ----  COMMAND : sync"
        echo -e '  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
        echo -e ''
        echo -e ''
        echo -e '    conf及びconf/'"${SYSKBN}"'ディレクトリ内の全ファイルを、'
        echo -e '    起動対象各ノードに同期します。'
        echo -e ''
        echo -e ''
        echo -e " \$\$\$ above command take OK ? [yn] >\c"
        
        while :
        do
            read -k 1 SELECT_BUFF
            if [[ -n "${${(@f)SELECT_BUFF}:# }"  ]];then
                case "${SELECT_BUFF}" in
                "y")
                    echo -e ''
                    "${MULTICTRL_RESSTAT_SH}" -f "${NODEFILE}" sync
                    echo -e "\n  executed sync ..... \n"
                    return ${RET_OK}
                    ;;
                "n")
                    echo -e ''
                    echo -e "\n  cancel sync ..... \n"
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
# toolcui.sh
# (zshスクリプト)
# 途中でキレてzsh特有機能を使ってます。
# なぜなら、bashとzshでreadのオプション名が変わってしまい、もはや互換性を保てなくなったため。
# (ddコマンドとterm制御を使えば出来なくもないが、bshじゃあるまいし格好悪いので却下)
#
# [概要]
#    resstatツール対話的ユーザインタフェース
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
while getopts :f:h ARG
do
    case "${ARG}" in
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

# 変数定義

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

# 実行日付取得
TODAYS_DATE=$(date "+%Y%m%d_%H%M%S")

# 起動ノード取得
MYHOST=$(uname -n)


# ノード記述ファイル設定。
if [[ -z "${NODEFILE}" ]];then
    # オプション指定されていない場合、デフォルト値を取り込む。
    NODEFILE="${RESSTAT_TG_HOSTS}"
fi


# QUIT
RET_QUIT=99
# BACK
RET_BACK=98

RET_OK=0

# 文字列入力関数用static変数
typeset -g INPUT_BUFF

# 起動区分
# 単独ノード起動
TARGET_SINGLE=1
# 複数ノード一斉起動
TARGET_MULTI=2



# 複数起動コンフィグ完了フラグ設定
MULTI_OFF=0
MULTI_ON=1
MULTI_FLG_FILE="${CONF_DIR}/.multi_conf_on"

MULTI_CONFIGURE=$(cat ${MULTI_FLG_FILE})

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

