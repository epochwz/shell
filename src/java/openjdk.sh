#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

init(){
    case $1 in
        8)  ;;
        11) ;;
        12) ;;
        13) ;;
        *)
            echo "This version is not yet supported!"
            exit 1
        ;;
    esac
    # 版本名称
    VERSION=openjdk-$1-jdk
    # 安装路径
    JAVA_HOME=/usr/lib/jvm/java-$1-openjdk-amd64
}

uninstall(){
    rm -rf $JAVA_HOME

    sed -i "s|export JAVA_HOME=$JAVA_HOME||g" $ENV_FILE
}

install(){
    uninstall

    sudo apt-get update -y && sudo apt-get install $VERSION -y

    setenv
}

setenv(){
    # unset old env
    sed -i "/^export JAVA_HOME/d" $ENV_FILE
    sed -i "/^PATH=\$JAVA_HOME/d" $ENV_FILE

    # set new env
    sed -i "1iexport JAVA_HOME=$JAVA_HOME" $ENV_FILE
    sed -i "2iPATH=\$JAVA_HOME/bin:\$PATH" $ENV_FILE

    # refresh env
    source $ENV_FILE

    # verify
    javac -version
}

switch(){
    if [ ! -d $JAVA_HOME ];then
        install
    else
        setenv
    fi
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    install)
        [ -z "$2" ] && echo "Usage: $SELF_NAME install <version>" && exit 1
        init $2 && $1
    ;;
    uninstall)
        [ -n "$2" ] && init $2
        [ -n "$JAVA_HOME" ] && $1
    ;;
    switch)
        [ -z "$2" ] && echo "Usage: $SELF_NAME switch <version>" && exit 1
        init $2 && $1
    ;;
    *)
        echo "Usage: $SELF_NAME <install|switch> <version>"
        echo "Usage: $SELF_NAME uninstall {version}"
    ;;
esac