#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 初始化环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# 初始化公钥
init_authorized_keys(){
    [ -z "$1" ] && USERNAME=$USER
    [ -z "$2" ] && USERHOME=$HOME
    mkdir -p $USERHOME/.ssh
    wget $GIT_HOST/resources/authorized_keys -O $USERHOME/.ssh/authorized_keys
    sudo chown -R $USER:$USER $USERHOME
}

# 避免 SSH 超时断开
avoid_ssh_timeout_disconnected(){
    SSHD_CONFIG_FILE=/etc/ssh/sshd_config
    if [ -z "$(grep ^ClientAliveInterval $SSHD_CONFIG_FILE)" ];then
        echo -e "\n# 定义超时的间隔时间 (s)" >> $SSHD_CONFIG_FILE
        echo -e "ClientAliveInterval 120" >> $SSHD_CONFIG_FILE
        echo -e "# 定义允许的最大超时次数" >> $SSHD_CONFIG_FILE
        echo -e "ClientAliveCountMax 30" >> $SSHD_CONFIG_FILE
        echo -e "# --> 允许的总超时时间：120s * 30 次 = 3600s = 1h" >> $SSHD_CONFIG_FILE

        sudo service sshd restart
    fi
}

# 设置 sudo 免密码
sudo_without_password(){
    [ -n "$1" ] && sudo sed -i "s|^$1||" /etc/sudoers && sudo sed -i '$a'"$1 ALL=(ALL:ALL)NOPASSWD: ALL" /etc/sudoers
}

# 安装当前支持的全部软件
install_all(){
    IDEA-Server start
    SSR-Server start

    Vsftpd install

    Nginx install 1.16.1

    JDK install 8
    Maven install 3.5.0
    Tomcat install 8.5.23

    install_nvm

    MySQL install
}

# 安装 nvm
install_nvm(){
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | PROFILE=$ENV_FILE bash
}

Tips(){
    echo "Usage: $SELF_NAME <key|ssh|nvm|all>"
    echo "Usage: $SELF_NAME sudo <username>"
    echo "Usage: $SELF_NAME useradd <username> <password>"
    echo "Usage: $SELF_NAME userdel <username>"
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    useradd)    add_linux_user $2 $3 /bin/bash  ;;
    userdel)    del_linux_user $2               ;;
    key)        init_authorized_keys            ;;
    ssh)        avoid_ssh_timeout_disconnected  ;;
    sudo)       sudo_without_password $2        ;;
    all)        install_all                     ;;
    nvm)        install_nvm                     ;;
    *)
        [ -z "$1" ] && Tips || echo "The command $1 is not yet supported!"
esac