#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# 获取脚本路径
SELF_PATH=$(cd `dirname $0` && pwd)/$SELF_NAME
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

init(){
    # 检查 Nginx 版本是否已经初始化
    [ -z "$NGINX_VERSION" ] && echo "env NGINX_VERSION has not been initialized!" && exit 1

    # 版本名称
    VERSION_NAME=nginx-$NGINX_VERSION
    # 安装包名称
    ZIP_NAME=$VERSION_NAME.tar.gz
    # 安装包下载链接
    DOWNLOAD_URL=http://nginx.org/download/${ZIP_NAME}
    # 安装包下载路径
    DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
    # 安装路径
    SETUP_PATH=$SOFTWARE_PATH/$VERSION_NAME
    # 启动路径
    STARTUP=$SETUP_PATH/sbin/nginx
    # 配置文件路径
    CONF_FILE=$SETUP_PATH/conf/nginx.conf
    # 域名配置文件路径
    VHOST_PATH=$SETUP_PATH/conf/vhost
    # PID_NAME
    PID_NAME=$SOFTWARE_PATH/nginx

    # 安装选项
    OPTIONS="--with-http_v2_module --with-http_ssl_module --prefix=$SETUP_PATH"
}

stop(){
    # 使用软件自带的停止方法
    PID=$(pgrep -f $STARTUP) && [ -f $STARTUP ] && $STARTUP -s stop
    # 根据进程名称停止当前进程
    PID=$(pgrep -f $STARTUP) && [ -n "$PID" ] && kill $PID 2>/dev/null
    # 强制杀死所有PID_NAME进程
    PID=$(pgrep -f $PID_NAME | grep -v $$) && [ -n "$PID" ] && kill $PID 2>/dev/null

    nginx -s stop 2>/dev/null 1>&2
}

start(){
    [ ! -f $STARTUP ] && echo "$VERSION_NAME has not been installed!" || (stop;$STARTUP)
}

reload(){
    [ ! -f $STARTUP ] && echo "$VERSION_NAME has not been installed!" && exit 1

    pgrep -f $VERSION_NAME && $STARTUP -s reload || $STARTUP
}

uninstall(){
    # 使用软件自带的停止方法
    PID=$(pgrep -f $STARTUP) && [ -f $STARTUP ] && $STARTUP -s stop

    rm -rf $SETUP_PATH

    rm -rf $SRCCODE_PATH/$VERSION_NAME

    sed -i "s|NGINX_VERSION=$NGINX_VERSION||g" $ENV_FILE
    sed -i "s|alias nginx='sudo $STARTUP'||g" $ENV_FILE
}

install(){
    uninstall

    # install dependencies
    echo "start to download dependencies"
	sudo apt-get update && sudo apt-get install -y gcc make openssl libssl-dev zlib1g-dev libpcre3 libpcre3-dev 1>/dev/null

    # download installation package
	wget -c $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1


    # decompress
    echo "start to install $VERSION_NAME ......"
	tar -zxf $DOWNLOAD_PATH -C $SRCCODE_PATH || exit 1
    # change working directory
	cd  $SRCCODE_PATH/$VERSION_NAME || exit 1
    # precompiled
    ./configure $OPTIONS || exit 1
    # compile & install
    make && make install || exit 1

    # avoid_403_Forbidden
    sed -i "/^user\ /d" $CONF_FILE && sed -i "1iuser $USER;" $CONF_FILE

    switch
}

switch(){
    if [ ! -d $SETUP_PATH ];then
        install
    else
        setenv && startup $SELF_NAME && start
    fi
}

setenv(){
    sed -i "/^NGINX_VERSION/d" $ENV_FILE && echo "NGINX_VERSION=$NGINX_VERSION" >> $ENV_FILE
    sed -i "/^alias nginx/d" $ENV_FILE && echo "alias nginx='sudo $STARTUP'" >> $ENV_FILE
    source $ENV_FILE
}

config(){
    [ ! -f "$CONF_FILE" ] && echo "$VERSION_NAME has not been installed!" && exit 1

    wget $GIT_HOST/nginx/nginx.conf -O $CONF_FILE || exit 1

    reload
}

download_vhost_file(){
    [ ! -f "$CONF_FILE" ] && echo "$VERSION_NAME has not been installed!" && exit 1

    mkdir -p $VHOST_PATH && wget $GIT_HOST/nginx/vhost/$1 -O $VHOST_PATH/$1 && $2
}

download_vhost_file_all(){
    download_vhost_file idea.epoch.fun.conf
    download_vhost_file file.epoch.fun.conf
    download_vhost_file mall.epoch.fun.conf

    reload
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    uninstall)
        # 清除开机启动设置
        [ -z "$2" ] && startup_clear $SELF_NAME
        [ "$2" = "$NGINX_VERSION" ] && startup_clear $SELF_NAME
        # 卸载
        if [ -n "$2" ];then
            # 卸载指定版本
            NGINX_VERSION=$2 && init && $1
        else
            # 卸载当前版本
            [ -n "$NGINX_VERSION" ] && init && $1
        fi
    ;;
    install)
        [ -z "$2" ] && echo "Usage: $SELF_NAME install <version>" && exit 1
        NGINX_VERSION=$2 && init && $1
    ;;
    switch)
        [ -z "$2" ] && echo "Usage: $SELF_NAME switch <version>" && exit 1
        init && stop
        NGINX_VERSION=$2 && init && $1
    ;;
    start)  init && $1 ;;
    stop)   init && $1 ;;
    reload) init && $1 ;;
    config) init && $1 ;;
    vhost)
        [ -z "$2" ] && echo "Usage: $SELF_NAME vhost <fileName|all>" && exit 1
        if [ "all" = "$2" ];then
            init && download_vhost_file_all
        else
            init && download_vhost_file $2 reload
        fi
    ;;
    *)
        echo "Usage: $SELF_NAME <install|switch> <version>"
        echo "Usage: $SELF_NAME uninstall {version}"
        echo "Usage: $SELF_NAME <start|stop|reload>"
        echo "Usage: $SELF_NAME config"
        echo "Usage: $SELF_NAME vhost <fileName|all>"
    ;;
esac