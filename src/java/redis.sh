#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# Redis 安装包下载路径前缀
BASE_DOWNLOAD_URL=http://download.redis.io/releases

init(){
    # 版本名称
    VERSION_NAME=redis-$1
    # 软件安装包名称
    ZIP_NAME=$VERSION_NAME.tar.gz
    # 软件安装包下载链接
    DOWNLOAD_URL=$BASE_DOWNLOAD_URL/$ZIP_NAME
    # 软件安装包下载路径
    DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
    # 软件安装路径
    REDIS_HOME=$SOFTWARE_PATH/$VERSION_NAME
    CONF_FILE=$REDIS_HOME/redis.conf
}

uninstall(){
    redis-cli shutdown 2>/dev/nul
    rm -rf $REDIS_HOME && sed -i "s|export REDIS_HOME=$REDIS_HOME||g" $ENV_FILE
}

install(){
    uninstall

	wget -c -t 3 $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1

	tar -zxf $DOWNLOAD_PATH -C $SOFTWARE_PATH || exit 1

    sed -i "s/daemonize no/daemonize yes/g" $CONF_FILE # 设置后台运行

	cd $REDIS_HOME && make || exit 1

    setenv
}

switch(){
    if [ ! -d $REDIS_HOME ];then
        install
    else
        setenv
    fi
}

setenv(){
    # unset old env
    sed -i "/^export REDIS_HOME/d" $ENV_FILE
    sed -i "/^PATH=\$REDIS_HOME/d" $ENV_FILE
    sed -i "/^alias redis-server/d" $ENV_FILE

    # set new env
    sed -i "1iexport REDIS_HOME=$REDIS_HOME" $ENV_FILE
    sed -i "2iPATH=\$REDIS_HOME/src:\$PATH" $ENV_FILE
    sed -i "3ialias redis-server='redis-server $CONF_FILE'" $ENV_FILE

    # refresh env
    source $ENV_FILE

    # verify
    redis-cli -v
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    uninstall)
        [ -n "$2" ] && init $2
        [ -n "$REDIS_HOME" ] && $1
    ;;
    install)
        [ -z "$2" ] && echo "Usage: $SELF_NAME install <version>" && exit 1
        init $2 && $1
    ;;
    switch)
        [ -z "$2" ] && echo "Usage: $SELF_NAME switch <version>" && exit 1
        init $2 && $1
    ;;
    *)
        echo "Usage: $SELF_NAME <install|switch> <version>"
        echo "Usage: $SELF_NAME <uninstall> {version}"
    ;;
esac