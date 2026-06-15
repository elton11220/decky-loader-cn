#!/bin/sh

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# Use environment-provided proxy if set, otherwise fallback to built-in
if [ -z "${GITHUB_PROXY}" ]; then
    GITHUB_PROXY="https://cdn.gh-proxy.org/"
fi

# check if JQ is installed
if ! command -v jq &> /dev/null
then
    echo "JQ 未找到，请安装它"
    echo "安装信息可在 https://stedolan.github.io/jq/download/ 找到"
    exit 1
fi

# check if cdn.gh-proxy.org is reachable
if ! curl -Is ${GITHUB_PROXY%/} | head -1 | grep 200 > /dev/null
then
    echo "gh-proxy 代理无法访问，您可能未连接到互联网"
    exit 1
fi

# check if api.github.com is working(not rate-limited)
if ! curl -Is https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases | head -1 | grep 200 > /dev/null
then
    echo "网络无法访问 Github API（可能被限流），请稍候再试"
    exit 1
fi

echo "正在安装 Steam Deck Plugin Loader 预发布版本..."

USER_DIR="$(getent passwd $SUDO_USER | cut -d: -f6)"
HOMEBREW_FOLDER="${USER_DIR}/homebrew"

# Create folder structure
rm -rf "${HOMEBREW_FOLDER}/services"
sudo -u $SUDO_USER mkdir -p "${HOMEBREW_FOLDER}/services"
sudo -u $SUDO_USER mkdir -p "${HOMEBREW_FOLDER}/plugins"
sudo -u $SUDO_USER touch "${USER_DIR}/.steam/steam/.cef-enable-remote-debugging"
# if installed as flatpak, put .cef-enable-remote-debugging there
[ -d "${USER_DIR}/.var/app/com.valvesoftware.Steam/data/Steam/" ] && sudo -u $SUDO_USER touch "${USER_DIR}/.var/app/com.valvesoftware.Steam/data/Steam/.cef-enable-remote-debugging"

# Download latest release and install it
RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "true"))")
VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
DOWNLOADURL=$(jq -r '.assets[].browser_download_url | select(endswith("PluginLoader"))' <<< ${RELEASE})

printf "Installing version %s...\n" "${VERSION}"
curl -L "${GITHUB_PROXY}${DOWNLOADURL}" --output ${HOMEBREW_FOLDER}/services/PluginLoader
chmod +x ${HOMEBREW_FOLDER}/services/PluginLoader

echo "检查 SELinux 存在并设置正确的二进制文件权限..."
hash getenforce 2>/dev/null && getenforce | grep "Enforcing" >/dev/null && chcon -t bin_t ${HOMEBREW_FOLDER}/services/PluginLoader

echo $VERSION > ${HOMEBREW_FOLDER}/services/.loader.version

systemctl --user stop plugin_loader 2> /dev/null
systemctl --user disable plugin_loader 2> /dev/null

systemctl stop plugin_loader 2> /dev/null
systemctl disable plugin_loader 2> /dev/null

curl -L ${GITHUB_PROXY}https://raw.githubusercontent.com/SteamDeckHomebrew/decky-loader/main/dist/plugin_loader-release.service  --output ${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service

cat > "${HOMEBREW_FOLDER}/services/plugin_loader-backup.service" <<- EOM
[Unit]
Description=SteamDeck Plugin Loader
After=network.target
[Service]
Type=simple
User=root
Restart=always
KillMode=process
TimeoutStopSec=15
ExecStart=${HOMEBREW_FOLDER}/services/PluginLoader
WorkingDirectory=${HOMEBREW_FOLDER}/services
Environment=UNPRIVILEGED_PATH=${HOMEBREW_FOLDER}
Environment=PRIVILEGED_PATH=${HOMEBREW_FOLDER}
Environment=LOG_LEVEL=DEBUG
[Install]
WantedBy=multi-user.target
EOM

if [[ -f "${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service" ]]; then
    printf "已获取最新预发布版本服务。\n"
    sed -i -e "s|\${HOMEBREW_FOLDER}|${HOMEBREW_FOLDER}|" "${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service"
    cp -f "${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service" "/etc/systemd/system/plugin_loader.service"
else
    printf "无法获取最新预发布版本 systemd 服务，使用内置服务作为备份！\n"
    rm -f "/etc/systemd/system/plugin_loader.service"
    cp "${HOMEBREW_FOLDER}/services/plugin_loader-backup.service" "/etc/systemd/system/plugin_loader.service"
fi

mkdir -p ${HOMEBREW_FOLDER}/services/.systemd
cp ${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service ${HOMEBREW_FOLDER}/services/.systemd/plugin_loader-prerelease.service
cp ${HOMEBREW_FOLDER}/services/plugin_loader-backup.service ${HOMEBREW_FOLDER}/services/.systemd/plugin_loader-backup.service
rm ${HOMEBREW_FOLDER}/services/plugin_loader-backup.service ${HOMEBREW_FOLDER}/services/plugin_loader-prerelease.service

systemctl daemon-reload
systemctl start plugin_loader
systemctl enable plugin_loader