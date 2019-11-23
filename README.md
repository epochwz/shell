# Server Manage

本项目提供一系列适用于 `Ubuntu` 的 *软件管理命令*，用于常用开发软件的安装和管理，从而简化服务器安装、部署等管理工作。

## Install & Usage

使用下面其中一个命令进行安装

```bash
# 已登录服务器
wget https://raw.githubusercontent.com/epochwz/shell/master/src/init.sh && . init.sh && rm init.sh

# 未登录服务器
ssh username@host 'wget -qO- https://raw.githubusercontent.com/epochwz/shell/master/src/init.sh | bash'
```

安装完成之后，系统会提供类似 `Nginx` 这样的*软件管理命令*，这些命令通常提供了相应软件的安装、卸载、版本切换、启动、停止等功能

这里以 `Nginx` 作为示例，其他命令请参考 [Feature List](#feature-list)

```bash
Nginx install 1.12.1    # 安装 Nginx 1.12.1 版本
Nginx uninstall         # 卸载 Nginx 当前（正在使用的）版本
Nginx uninstall 1.12.1  # 卸载 Nginx 指定版本
Nginx switch 1.16.1     # 切换到 Nginx 1.16.1 版本
Nginx start             # 启动
Nginx stop              # 停止
Nginx reload            # 重载配置文件
```

## Feature List

| Command                                     | Feature                                                      |
|:--------------------------------------------|:-------------------------------------------------------------|
| [Init](#init)                               | 更新本项目所提供的所有软件管理命令，包括 `Init` 本身            |
| [Install](#install)                         | 提供一些补充功能 （SSH 相关配置、添加 Linux 用户、便捷安装软件） |
| [MySQL](#mysql)                             | 安装、卸载                                                    |
| [JDK](#jdk)                                 | 安装、卸载、版本切换                                          |
| [Maven](#maven)                             | 安装、卸载、版本切换                                          |
| [Tomcat](#tomcat)                           | 安装、卸载、版本切换、启动、停止、开机启动                      |
| [Nginx](#nginx)                             | 安装、卸载、版本切换、启动、停止、开机启动、配置文件更新         |
| [IDEA License Server](#idea-license-server) | 安装、卸载、启动、停止、开机启动                               |
| [ShadowsocksR Server](#shadowsocksr-server) | 安装、卸载、启动、停止、开机启动                               |
| [Vsftpd](#vsftpd)                           | 安装、卸载、配置更新、添加 FTP 用户                            |
| [RAM](#ram)                                 | 启用、禁用、系统重启                                          |

> **Tips:** 本文档中如果没有特殊说明，则 `<xxx>` 表示必选项，`{xxx}` 表示可选项，`<A|B|C>` 和 `{A|B|C}` 表示选项具体支持的参数值

示例

```txt
# 安装 或者 切换指定版本的 Nginx
#   选项一必须指定 install 或者 switch
#   选项二必须指定 Nginx 版本号
Nginx <install|switch> <version>

# 卸载 Nginx
#   如果指定了版本号，则卸载指定版本的 Nginx
#   如果不指定版本号，则卸载当前（正在使用的）版本
Nginx uninstall {version}
```

### Init

```txt
# 卸载整个项目
Init DEL
# 更新全部命令
Init ALL
# 更新指定命令
Init <Init|Install|MySQL|JDK|Maven|Tomcat|Nginx|IDEA-Server|SSR-Server|Vsftpd>
```

### Install

```txt
Install key     # 配置 SSH 公钥（需要在本项目 src/resources 中上传自己的公钥文件）
Install ssh     # 延长 SSH 超时断开时间至 1 小时
Install nvm     # 安装 nvm
Install all     # 安装当前支持的所有软件
# 授予 指定用户 sudo 权限，且无需密码
Install sudo <username>
# 添加 Linux 用户
Install useradd <username> <password>
# 删除 Linux 用户
Install userdel <username>
```

### MySQL

| Command           | Feature | Comment                          |
|:------------------|:--------|:---------------------------------|
| `MySQL install`   | 安装    | 需要在命令行中交互式地进行相关配置 |
| `MySQL uninstall` | 卸载    | 需要在命令行中交互式地进行相关配置 |

### JDK

| Command                   | Feature | Comment                    |
|:--------------------------|:--------|:---------------------------|
| `JDK install <version>`   | 重装    |                            |
| `JDK uninstall {version}` | 卸载    | 若不指定版本，则卸载当前版本 |
| `JDK switch <version>`    | 切换版本 | 如果未安装，则自动安装      |

### Maven

| Command                     | Feature | Comment                    |
|:----------------------------|:--------|:---------------------------|
| `Maven install <version>`   | 重装    |                            |
| `Maven uninstall {version}` | 卸载    | 若不指定版本，则卸载当前版本 |
| `Maven switch <version>`    | 切换版本 | 如果未安装，则自动安装      |

### Tomcat

| Command                      | Feature       | Comment                    |
|:-----------------------------|:--------------|:---------------------------|
| `Tomcat install <version>`   | 重装并启动     | 设置开机启动                |
| `Tomcat uninstall {version}` | 卸载          | 若不指定版本，则卸载当前版本 |
| `Tomcat switch <version>`    | 切换版本并启动 | 如果未安装，则自动安装       |
| `Tomcat start`               | 重启          |                            |
| `Tomcat stop`                | 停止          |                            |

### Nginx

| Command                                      | Feature                            | Comment                    |
|:---------------------------------------------|:-----------------------------------|:---------------------------|
| `Nginx install <version>`                    | 重装并启动                          | 设置开机启动                |
| `Nginx uninstall {version}`                  | 卸载                               | 若不指定版本，则卸载当前版本 |
| `Nginx switch <version>`                     | 切换版本并启动                      | 如果未安装，则自动安装       |
| `Nginx start`                                | 重启                               |                            |
| `Nginx stop`                                 | 停止                               |                            |
| `Nginx reload`                               | 重载配置文件                        | 如果尚未启动，则直接启动     |
| `Nginx config`                               | 下载 / 更新主配置文件               |                            |
| <code>Nginx vhost <filename&#124;all></code> | 下载 / 更新指定的 / 全部域名配置文件 |                            |

### IDEA License Server

| Command                 | Feature   | Comment               |
|:------------------------|:----------|:----------------------|
| `IDEA-Server install`   | 重装并启动 | 设置开机启动           |
| `IDEA-Server uninstall` | 卸载      |                       |
| `IDEA-Server start`     | 重启      | 如果未安装，则自动安装 |
| `IDEA-Server stop`      | 停止      |                       |

### ShadowsocksR Server

| Command                | Feature   | Comment               |
|:-----------------------|:----------|:----------------------|
| `SSR-Server install`   | 重装并启动 | 设置开机启动           |
| `SSR-Server uninstall` | 卸载      |                       |
| `SSR-Server start`     | 重启      | 如果未安装，则自动安装 |
| `SSR-Server stop`      | 停止      |                       |

### Vsftpd

| Command                                | Feature                | Comment                                        |
|:---------------------------------------|:-----------------------|:-----------------------------------------------|
| `Vsftpd install`                       | 重装并启动              | 设置开机启动                                    |
| `Vsftpd uninstall`                     | 卸载                   | 若不指定版本，则卸载当前版本                     |
| `Vsftpd config`                        | 下载 / 更新配置文件     |                                                |
| `Vsftpd useradd <username> <password>` | 添加 FTP 用户           | 添加无法 SSH 登录的 Linux 用户，并加入 FTP 白名单 |
| `Vsftpd userdel <username>`            | 删除 FTP 用户           | 删除 Linux 用户，并移出 FTP 白名单               |
| `Vsftpd listadd <username>`            | 往 FTP 白名单中添加用户 |                                                |
| `Vsftpd listdel <username>`            | 从 FTP 白名单中删除用户 |                                                |

### RAM

| Command               | Feature                                       |
|:----------------------|:----------------------------------------------|
| `RAM enable <size/M>` | 启用虚拟内存，并指定大小，单位是 `M`, 默认 1024M |
| `RAM disable`         | 禁用虚拟内存                                   |
| `RAM reboot`          | 重启系统                                       |
