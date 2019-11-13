#!/bin/bash
# ============================== ⬇⬇⬇  无需改动 ⬇⬇⬇ ==============================
# 重载环境变量
. Init ENV || echo "Not initialized" && [ -z "$ENV_FILE" ] && exit 1
# 获取脚本名称
SELF_NAME=$(basename $BASH_SOURCE)
# ============================== ⬆⬆⬆  无需改动 ⬆⬆⬆ ==============================

# 版本名称
MYSQL_VERSION=mysql-apt-config_0.8.12-1_all.deb
# 下载链接
DOWNLOAD_URL=https://repo.mysql.com/$MYSQL_VERSION
# 下载路径
DOWNLOAD_PATH=$PACKAGE_PATH/$MYSQL_VERSION

uninstall(){
    sudo apt-get autoremove -y --purge mysql*
}

install(){
    # Install mysql-apt-get
    wget -c -t 3 $DOWNLOAD_URL -O $DOWNLOAD_PATH && sudo dpkg -i $DOWNLOAD_PATH
    # Install MySQL
    sudo apt-get -y update && sudo apt-get -y install mysql-server
    # Secure config
    sudo mysql_secure_installation
    # Verify
    mysql -V
}

# ============================== ⬇⬇⬇  Main ⬇⬇⬇ ==============================

case $1 in
    install)    install     ;;
    uninstall)  uninstall   ;;
    *)
        echo "Usage: $SELF_NAME <install|uninstall>"
    ;;
esac