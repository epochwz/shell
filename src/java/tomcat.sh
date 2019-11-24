#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# 获取脚本路径
SELF_PATH=$(cd `dirname $0` && pwd)/$SELF_NAME
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# Tomcat 安装包下载路径前缀
BASE_DOWNLOAD_URL=https://archive.apache.org/dist/tomcat
# BASE_DOWNLOAD_URL=http://mirrors.hust.edu.cn/apache/tomcat
# BASE_DOWNLOAD_URL=http://mirror.bit.edu.cn/apache/tomcat

init(){
    # 检查 Tomcat 版本是否已经初始化
    [ -z "$TOMCAT_VERSION" ] && echo "env TOMCAT_VERSION has not been initialized!" && exit 1

    # 主版本号
    MAJOR_VERSION=$(echo $TOMCAT_VERSION | cut -f 1 -d ".")
    # 版本名称
    VERSION_NAME=apache-tomcat-$TOMCAT_VERSION
    # 软件安装包名称
    ZIP_NAME=$VERSION_NAME.tar.gz
    # 软件安装包下载链接
    DOWNLOAD_URL=$BASE_DOWNLOAD_URL/tomcat-$MAJOR_VERSION/v$TOMCAT_VERSION/bin/${ZIP_NAME}
    # 软件安装包下载路径
    DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
    # 软件安装路径
    SETUP_PATH=$SOFTWARE_PATH/$VERSION_NAME
    # 软件启动路径
    STARTUP=$SETUP_PATH/bin/startup.sh
    # 软件停止路径
    SHUTDOWN=$SETUP_PATH/bin/shutdown.sh
    # 软件配置文件路径
    CONF_FILE=$SETUP_PATH/conf/server.xml
    # PID_NAME
    PID_NAME=$VERSION_NAME
    # 软件环境变量
    CATALINA_HOME=$SETUP_PATH
}

stop(){
    # 使用软件自带的停止方法
    PID=$(pgrep -f $STARTUP) && [ -f $SHUTDOWN ] && $SHUTDOWN
    # 根据进程名称停止当前进程
    PID=$(pgrep -f $STARTUP) && kill $PID
    # 强制杀死所有PID_NAME进程
    PID=$(pgrep -f $PID_NAME | grep -v $$) && [ -n "$PID" ] && kill $PID 2>/dev/null

    shutdown.sh 2>/dev/null 1>&2
}

start(){
    [ ! -f $STARTUP ] && echo "$VERSION_NAME has not been installed!" || (stop;$STARTUP)
}

uninstall(){
    # 使用软件自带的停止方法
    PID=$(pgrep -f $STARTUP) && [ -f $SHUTDOWN ] && $SHUTDOWN

    rm -rf $SETUP_PATH

    sed -i "s|TOMCAT_VERSION=$TOMCAT_VERSION||g" $ENV_FILE
    sed -i "s|CATALINA_HOME=$CATALINA_HOME||g" $ENV_FILE
}

install(){
    uninstall

	wget -c $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1

	tar -zxf $DOWNLOAD_PATH -C $SOFTWARE_PATH || exit 1

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
    sed -i "/^TOMCAT_VERSION/d" $ENV_FILE && sed -i '$a'"TOMCAT_VERSION=$TOMCAT_VERSION" $ENV_FILE

    # unset old env
    sed -i "/^export CATALINA_HOME/d" $ENV_FILE
    sed -i "/^PATH=\$CATALINA_HOME/d" $ENV_FILE

    # set new env
    sed -i "1iexport CATALINA_HOME=$CATALINA_HOME" $ENV_FILE
    sed -i "2iPATH=\$CATALINA_HOME/bin:\$PATH" $ENV_FILE

    # refresh env
    source $ENV_FILE

    # verify
    catalina.sh version
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    install)
        [ -z "$2" ] && echo "Usage: $SELF_NAME install <version>" && exit 1
        TOMCAT_VERSION=$2 && init && $1
    ;;
    uninstall)
        # 清除开机启动设置
        [ -z "$2" ] && startup_clear $SELF_NAME
        [ "$2" = "$TOMCAT_VERSION" ] && startup_clear $SELF_NAME
        # 卸载
        [ -n "$2" ] && TOMCAT_VERSION=$2
        [ -n "$TOMCAT_VERSION" ] && init && $1

    ;;
    switch)
        [ -z "$2" ] && echo "Usage: $SELF_NAME switch <version>" && exit 1
        init && stop
        TOMCAT_VERSION=$2 && init && $1
    ;;
    start)  init && $1 ;;
    stop)   init && $1 ;;
    *)
        echo "Usage: $SELF_NAME <install|switch> <version>"
        echo "Usage: $SELF_NAME uninstall {version}"
        echo "Usage: $SELF_NAME <start|stop>"
    ;;
esac