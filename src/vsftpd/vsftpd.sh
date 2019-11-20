#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# 配置文件
CONF_FILE=/etc/vsftpd.conf
# 白名单文件
USER_LIST=/etc/user_list
# 无法登录Linux系统的Shell
NO_LOGIN_SHELL=/sbin/nologin

uninstall(){
    sudo service vsftpd stop 2>/dev/null

    sudo apt-get -y autoremove --purge vsftpd

    sudo rm -f $USER_LIST
    sudo rm -f $CONF_FILE
}

install(){
    uninstall

    sudo apt-get update -y && sudo apt-get install -y vsftpd
}

config(){
    ! vsftpd -v 2>/dev/null && echo "vsftpd has not been installed!" && exit 1

    sudo wget $GIT_HOST/vsftpd/vsftpd.conf -O $CONF_FILE || exit 1

    add_user_in_userlist ftp
    add_user_in_userlist anonymous

    # change pasv_address to public ip
    # sed -i "s/^\(# \)*pasv_address=.*$/pasv_address=`curl -s ifconfig.me`/g" $CONF_FILE

    sudo service vsftpd restart
}

# 添加 FTP 用户：添加无法 SSH 登录的 Linux 用户，并加入到 FTP 白名单
add_ftp_user(){
    ! vsftpd -v 2>/dev/null && echo "vsftpd has not been installed!" && exit 1

    [ -z "$1" ] && echo "username cannot be empty" && exit 1
    [ -z "$2" ] && echo "password cannot be empty" && exit 1

    # add_nologin_shell
    [ -z "$(grep ^$NO_LOGIN_SHELL$ /etc/shells)" ] && echo $NO_LOGIN_SHELL | sudo tee -a /etc/shells 1>/dev/null

    add_linux_user $1 $2 $NO_LOGIN_SHELL

    add_user_in_userlist $1
}

# 删除 FTP 用户：删除无法 SSH 登录的 Linux 用户，并从 FTP 白名单中移除
del_ftp_user(){
    sed -i "s|^$1$||" $USER_LIST && del_linux_user $1
}

# 添加用户到 FTP 白名单
add_user_in_userlist(){
    touch $USER_LIST && [ -z "$(grep ^$1$ $USER_LIST)" ] && echo $1 | sudo tee -a $USER_LIST
}

# 从 FTP 白名单中移除用户
del_user_in_userlist(){
    touch $USER_LIST && sed -i "s|^$1$||" $USER_LIST
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    install)    install                 ;;
    uninstall)  uninstall               ;;
    config)     config                  ;;
    useradd)    add_ftp_user $2 $3      ;;
    userdel)    del_ftp_user $2         ;;
    listadd)    add_user_in_userlist $2 ;;
    listdel)    del_user_in_userlist $2 ;;
    *)
        echo "Usage: $SELF_NAME <install|uninstall>"
        echo "Usage: $SELF_NAME config"
        echo "Usage: $SELF_NAME useradd <username> <password>"
        echo "Usage: $SELF_NAME userdel <username>"
        echo "Usage: $SELF_NAME <listadd|listdel> <username>"
    ;;
esac