#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# 获取脚本路径
SELF_PATH=$(cd `dirname $0` && pwd)/$SELF_NAME
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# 软件名称
ZIP_NAME=idea-server
# 下载链接
DOWNLOAD_URL=$GIT_HOST/idea/$ZIP_NAME
# 安装路径
SETUP_PATH=$SOFTWARE_PATH/$ZIP_NAME
# 启动路径
STARTUP=$SETUP_PATH
#
# 软件参数
PORT=1117
USER=epoch

stop(){
    PID=$(pgrep -f $STARTUP) && kill $PID 2>/dev/null
}

start(){
    stop

    [ -f $STARTUP ] || install || exit 1

    $STARTUP -p $PORT -u $USER 1>/dev/null 2>&1 &
}

uninstall(){
    stop

    rm -rf $SETUP_PATH

    startup_clear $SELF_NAME
}

install(){
    uninstall

    wget -c -t 3 $DOWNLOAD_URL -O $SETUP_PATH || exit 1

    chmod +x $STARTUP

    startup $SELF_NAME

    start

    echo "install idea-server success!"
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    stop)           stop        ;;
    start)          start       ;;
    uninstall)      uninstall   ;;
    install)        install     ;;
    *)
        echo "Usage: $SELF_NAME <start|stop|install|uninstall>"
    ;;
esac