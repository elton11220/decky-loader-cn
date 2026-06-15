# decky-loader-cn

用于在中国大陆安装 [SteamDeckHomebrew/decky-loader](https://github.com/SteamDeckHomebrew/decky-loader) 的脚本

通过 `gh-proxy` 实现国内访问加速，修改自官方安装脚本，纯绿色无私货

## 加速原理

```mermaid
graph TD
    Users["👥 终端用户<br/>(中国大陆)"]
    
    Users -->|请求资源| GHProxy["🔗 gh-proxy<br/>(加速代理)"]
    GHProxy -->|代理请求| Github["🌐 GitHub 源站"]
    Github -->|返回资源| GHProxy
    GHProxy -->|返回资源| Users
    
    style Users fill:#e1f5ff
    style GHProxy fill:#fff3e0
    style Github fill:#f3e5f5
```

## 使用方式

以下四条命令中选任意一条执行即可：

```bash
curl -L https://cdn.gh-proxy.org/https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install.sh | sh

curl -L https://gh-proxy.org/https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install.sh | sh

curl -L https://v4.gh-proxy.org/https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install.sh | sh

curl -L https://v6.gh-proxy.org/https://github.com/elton11220/decky-loader-cn/blob/main/scripts/install.sh | sh
```
