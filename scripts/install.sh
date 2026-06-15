#!/bin/sh

# If $1 is set, take that as input (s/p/u)
[ -n "$1" ] && action="$1"

# Let user pick a CDN proxy first
echo "请选择 CDN 代理："
echo "1) https://cdn.gh-proxy.org/（推荐）"
echo "2) https://gh-proxy.org/"
echo "3) https://v4.gh-proxy.org/"
echo "4) https://v6.gh-proxy.org/"
read -p "输入编号 (1-4): " cdn_choice
case "$cdn_choice" in
1) SELECTED_PROXY="https://cdn.gh-proxy.org/" ;;
2) SELECTED_PROXY="https://gh-proxy.org/" ;;
3) SELECTED_PROXY="https://v4.gh-proxy.org/" ;;
4) SELECTED_PROXY="https://v6.gh-proxy.org/" ;;
*) echo "无效选择，使用默认 https://cdn.gh-proxy.org/"; SELECTED_PROXY="https://cdn.gh-proxy.org/" ;;
esac

echo "请输入字母执行对应的操作："
echo "s) 安装 decky-loader 稳定版"
echo "p) 安装 decky-loader 预发布版"
echo "u) 卸载 decky-loader"
echo "b) 修复 bazzite 系统安装后不展示扳手图标"
# Keep asking which release to install
while true
do
    # If $action is not set by $1, prompt the user
    [ -z "$action" ] && read -p "安装 稳定版/预发布版/卸载 deck-loader (s/p/u): " action

    case $(echo "${action}" | tr '[:lower:]' '[:upper:]') in
    S*)
        echo "安装 decky-loader 稳定版"
        curl -L "${SELECTED_PROXY}https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install_release.sh" | GITHUB_PROXY="${SELECTED_PROXY}" sh -s --
        exit 0
        ;;
    P*)
        echo "安装 decky-loader 预发布版"
        curl -L "${SELECTED_PROXY}https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install_prerelease.sh" | GITHUB_PROXY="${SELECTED_PROXY}" sh -s --
        exit 0
        ;;
    U*)
        echo "卸载 decky-loader"
        curl -L "${SELECTED_PROXY}https://github.com/elton11220/decky-loader-cn/blob/main/scripts/uninstall.sh" | GITHUB_PROXY="${SELECTED_PROXY}" sh -s --
        exit 0
        ;;
    B*)
        echo "修复 bazzite 系统安装后不展示扳手图标"
        sudo -A chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
        exit 0
        ;;
    *)
        unset action
        continue
        ;;
    esac
done