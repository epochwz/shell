#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# Maven 安装包下载路径前缀
BASE_DOWNLOAD_URL=https://archive.apache.org/dist/maven
# BASE_DOWNLOAD_URL=http://mirrors.hust.edu.cn/apache/maven
# BASE_DOWNLOAD_URL=http://mirror.bit.edu.cn/apache/maven

init(){
    # 版本号
    MAVEN_VERSION=$1
    # 主版本号
    MAJOR_VERSION=$(echo $MAVEN_VERSION | cut -f 1 -d ".")
    # 版本名称
    VERSION_NAME=apache-maven-$MAVEN_VERSION
    # 软件安装包名称
    ZIP_NAME=$VERSION_NAME-bin.tar.gz
    # 软件安装包下载链接
    DOWNLOAD_URL=$BASE_DOWNLOAD_URL/maven-$MAJOR_VERSION/$MAVEN_VERSION/binaries/$ZIP_NAME
    # 软件安装包下载路径
    DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
    # 软件安装路径
    MAVEN_HOME=$SOFTWARE_PATH/$VERSION_NAME
}

uninstall(){
    rm -rf $MAVEN_HOME

    sed -i "s|export MAVEN_HOME=$MAVEN_HOME||g" $ENV_FILE
}

install(){
    uninstall

	wget -c -t 3 $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1

	tar -zxf $DOWNLOAD_PATH -C $SOFTWARE_PATH || exit 1

    setenv
}

switch(){
    if [ ! -d $MAVEN_HOME ];then
        install
    else
        setenv
    fi
}

setenv(){
    # unset old env
    sed -i "/^export MAVEN_HOME/d" $ENV_FILE
    sed -i "/^PATH=\$MAVEN_HOME/d" $ENV_FILE

    # set new env
    sed -i "1iexport MAVEN_HOME=$MAVEN_HOME" $ENV_FILE
    sed -i "2iPATH=\$MAVEN_HOME/bin:\$PATH" $ENV_FILE

    # refresh env
    source $ENV_FILE

    # verify
    mvn -v
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    install)
        [ -z "$2" ] && echo "Usage: $SELF_NAME install <version>" && exit 1
        init $2 && $1
    ;;
    uninstall)
        [ -n "$2" ] && init $2
        [ -n "$MAVEN_HOME" ] && $1
    ;;
    switch)
        [ -z "$2" ] && echo "Usage: $SELF_NAME switch <version>" && exit 1
        init $2 && $1
    ;;
    *)
        echo "Usage: $SELF_NAME <install|switch> <version>"
        echo "Usage: $SELF_NAME <uninstall> <version>"
    ;;
esac