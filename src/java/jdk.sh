#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

init(){
    case $1 in
        8)
            # 版本名称
            VERSION_NAME=jdk8u40
            # 压缩包名称
            ZIP_NAME=jdk_ri-8u40-b25-linux-x64-10_feb_2015.tar.gz
            # 下载链接
            DOWNLOAD_URL=https://download.java.net/openjdk/$VERSION_NAME/ri/$ZIP_NAME
            # JDK 解压目录的名称
            UNZIP_NAME=java-se-8u40-ri
            # JDK 解压目录(临时)
            UNZIP_PATH=$SOFTWARE_PATH/$UNZIP_NAME

            # JDK 安装包存储路径
            DOWNLOAD_PATH=$PACKAGE_PATH/$ZIP_NAME
            # JDK 安装路径
            JAVA_HOME=$SOFTWARE_PATH/$VERSION_NAME
        ;;
        *)
            echo "This version is not yet supported!"
            exit 1
        ;;
    esac
}

uninstall(){
    rm -rf $JAVA_HOME

    sed -i "s|export JAVA_HOME=$JAVA_HOME||g" $ENV_FILE
}


install(){
    uninstall

    wget -c $DOWNLOAD_URL -O $DOWNLOAD_PATH || exit 1

    tar -zxf $DOWNLOAD_PATH -C $SOFTWARE_PATH && mv $UNZIP_PATH $JAVA_HOME || exit 1

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