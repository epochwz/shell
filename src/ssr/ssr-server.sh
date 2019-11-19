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
ZIP_NAME=manyuser.tar.gz
# 下载链接
DOWNLOAD_URL=$GIT_HOST/ssr/$ZIP_NAME
# 下载路径
DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
# 安装路径
SETUP_PATH=$SOFTWARE_PATH/shadowsocksr-manyuser
# 启动路径
STARTUP=$SETUP_PATH/shadowsocks/server.py
#
# 软件参数
SERVER_PORT=1121
PASSWORD="io&ij"
METHOD=rc4-md5
PROTOCOL=auth_aes128_md5
PROTOCOLPARAM=32
OBFS=plain

stop(){
    PID=$(pgrep -f $STARTUP) && kill $PID 2>/dev/null
}

start(){
    stop

    [ -f $STARTUP ] || install || exit 1

    python3 $STARTUP -p $SERVER_PORT -k $PASSWORD -m $METHOD -O $PROTOCOL -o $OBFS -G $PROTOCOLPARAM 1>/dev/null 2>&1 &
}

uninstall(){
    stop

    rm -rf $SETUP_PATH

    startup_clear $SELF_NAME
}

install(){
    uninstall

    wget -c -t 3 $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1

    tar -zxf $DOWNLOAD_PATH -C $SOFTWARE_PATH || exit 1

    startup $SELF_NAME

    echo "install ssr-server success!"
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    stop)           stop        ;;
    start)          start       ;;
    uninstall)      uninstall   ;;
    install)        install     ;;
    *)
        echo "Usage $SELF_NAME <start|stop|install|uninstall>"
    ;;
esac