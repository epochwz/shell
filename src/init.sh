#!/bin/bash
# ============================== ⬇⬇⬇  项目全局变量 ⬇⬇⬇ ==============================
# 脚本自身名称
SELF_NAME=Init
# 脚本安装路径
SHELL_PATH=/usr/local/bin/sm && mkdir -p $SHELL_PATH
# 开机启动文件
STARTUP_FILE=/etc/rc.local && [ ! -f $STARTUP_FILE ] && echo -e "#!/bin/sh -e\n\nexit 0" >> $STARTUP_FILE && chmod +x $STARTUP_FILE
# 环境变量文件
ENV_FILE=/etc/profile.d/initial.sh && touch $ENV_FILE && sudo chmod +x $ENV_FILE

# 软件的基础路径
BASE_PATH=/root
# 软件的安装路径
SOFTWARE_PATH=$BASE_PATH/softwares && mkdir -p $SOFTWARE_PATH
# 软件安装包路径
PACKAGE_PATH=$BASE_PATH/packages && mkdir -p $PACKAGE_PATH
# 软件源代码路径
SRCCODE_PATH=$BASE_PATH/srccode && mkdir -p $SRCCODE_PATH

# GitHub Repository Information
GIT_USER=epochwz
GIT_REPOSITORY=shell
GIT_BRANCH=master
GIT_HOST=https://raw.githubusercontent.com/$GIT_USER/$GIT_REPOSITORY/$GIT_BRANCH/src
# ============================== ⬆⬆⬆  项目全局变量 ⬆⬆⬆ ==============================

# ============================== ⬇⬇⬇  环境变量初始化 ⬇⬇⬇ ==============================
# 初始化环境变量文件内容
sed -i "/^export PATH/d" $ENV_FILE && echo "export PATH=$SHELL_PATH:\$PATH" >> $ENV_FILE
# 开机启动时加载环境变量
sed -i "/^\.\ \//d" $STARTUP_FILE && sed -i "2i. $ENV_FILE" $STARTUP_FILE
# 用户登录时加载环境变量：将环境变量文件更改成 /etc/profile, /etc/profile.d/xxx, ~/.profile 其中之一
# 新建终端时加载环境变量：将环境变量文件更改成 /etc/bash.bashrc, ~/.bashrc, ~/.bash_aliases 其中之一
# 执行命令时加载环境变量
source $ENV_FILE
# ============================== ⬆⬆⬆  环境变量初始化 ⬆⬆⬆ ==============================

# ============================== ⬇⬇⬇  项目公共函数 ⬇⬇⬇ ==============================
# 卸载开机启动服务
startup_clear(){
    sudo sed -i "/$1/d" $STARTUP_FILE
}
# 设置开机启动服务
startup(){
    startup_clear $1 && sudo sed -i '$i'"$1 start" $STARTUP_FILE
}

# 添加 Linux 用户 (<username>,<password>,<login-shell>)
add_linux_user(){
    [ 3 -ne "$#" ] && echo "Usage: <username> <password> {login-shell}" && exit 1
    # if username is not exist, add user & set password
    USERNAME=$(grep "^$1\b" /etc/passwd | cut -f 1 -d ":")
    if [ "$1" != "$USERNAME" ];then
        sudo useradd -m -d /home/$1 $1 -s $3
        echo $1:$2|chpasswd
        if [ 0 -ne $? ];then
            echo "set user password error"
            echo $1:${2}_pwd|chpasswd && echo "it is set as ${2}_pwd,you can change it manually later"
        fi
    fi
}
# 删除 Linux 用户
del_linux_user(){
    sudo userdel -r $1
}

# 添加用户登录 SHELL
add_login_shell(){
    [ -z "$(grep ^$1$ /etc/shells)" ] && echo $1 | sudo tee -a /etc/shells
}
# ============================== ⬆⬆⬆  项目公共函数 ⬆⬆⬆ ==============================

# ============================== ⬇⬇⬇  核心下载函数 ⬇⬇⬇ ==============================
# 当前支持的命令列表
Tips(){
    echo "Usage: $SELF_NAME All"
    echo "Usage: $SELF_NAME <CommandName>"
    echo "For Examples:"
    echo "Usage: $SELF_NAME <$SELF_NAME|Install>"
    echo "Usage: $SELF_NAME <MySQL|OpenJDK|Maven|Tomcat|Nginx>"
    echo "Usage: $SELF_NAME <IDEA-Server|SSR-Server|Vsftpd>"
    echo "Usage: $SELF_NAME <RAM>"
}

# 下载全部软件管理命令
download_all(){
    download $SELF_NAME
    download Install

    download MySQL
    download JDK
    download OpenJDK
    download Maven
    download Tomcat

    download Nginx

    download IDEA-Server
    download SSR-Server

    download Vsftpd

    download RAM
}

# 下载指定软件管理命令
download(){
    case $1 in
        $SELF_NAME)     FILE=init.sh                ;;
        Install)        FILE=manager/install.sh     ;;

        MySQL)          FILE=java/mysql.sh          ;;
        JDK)            FILE=java/jdk.sh            ;;
        OpenJDK)        FILE=java/openjdk.sh        ;;
        Maven)          FILE=java/maven.sh          ;;
        Tomcat)         FILE=java/tomcat.sh         ;;

        Nginx)          FILE=nginx/nginx.sh         ;;

        IDEA-Server)    FILE=idea/idea-server.sh    ;;
        SSR-Server)     FILE=ssr/ssr-server.sh      ;;

        Vsftpd)         FILE=vsftpd/vsftpd.sh       ;;

        RAM)            FILE=system/ram.sh          ;;
        *)
            [ -z "$1" ] && Tips || echo "command $1 is not yet supported!" && exit 1
        ;;
    esac

    # 脚本下载链接
    DOWNLOAD_URL=$GIT_HOST/$FILE
    # 脚本安装路径
    DOWNLOAD_PATH=$SHELL_PATH/$1

    # 删除旧文件 -> 下载新文件 -> 赋予执行权限
    sudo rm -f $DOWNLOAD_PATH && wget $DOWNLOAD_URL -O $DOWNLOAD_PATH && sudo chmod +x $DOWNLOAD_PATH
}

# 卸载本项目
uninstall(){
    # 删除环境变量文件
    rm $ENV_FILE
    # 删除软件管理脚本
    rm -rf $SHELL_PATH

    # 删除开机启动相关设置
    sed -i "/^\.\ \//d" $STARTUP_FILE

    sed -i "/^Tomcat/d" $STARTUP_FILE
    sed -i "/^Nginx/d" $STARTUP_FILE
    sed -i "/^IDEA-Server/d" $STARTUP_FILE
    sed -i "/^SSR-Server/d" $STARTUP_FILE
}
# ============================== ⬆⬆⬆  核心下载函数 ⬆⬆⬆ ==============================

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

if [ "ENV" != "$1" ];then
    if [ "$(basename $BASH_SOURCE)" != "$SELF_NAME" ];then
        # 项目初始化
        download_all
    else
        # 卸载整个项目
        [ "DEL" = "$1" ] && uninstall && exit 1
        # 更新全部软件管理命令
        [ "ALL" = "$1" ] && download_all
        # 更新指定软件管理命令
        [ "ALL" != "$1" ] && download $1
    fi
fi # 不要简化此处代码，防止其他脚本加载环境变量时意外退出