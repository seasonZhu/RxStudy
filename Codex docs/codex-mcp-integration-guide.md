# Codex Desktop MCP 集成说明

本文记录本项目集成 MasterGo Vibe MCP 时验证出来的 Codex Desktop MCP 配置方式和排障经验。后续接入其它 MCP 时优先按本文检查。

## 1. Codex 的配置文件位置

Codex Desktop 使用用户级配置文件：

```text
/Users/dy/.codex/config.toml
```

注意：很多 MCP 文档给的是 Cursor / VSCode 常见 JSON 格式，例如：

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "some-mcp-package"]
    }
  }
}
```

Codex Desktop 不是直接粘贴这段 JSON，而是转换成 TOML：

```toml
[mcp_servers.server-name]
type = "stdio"
command = "npx"
args = ["-y", "some-mcp-package"]
```

## 2. MasterGo Vibe MCP 示例

本次 MasterGo 文档给出的配置是：

```json
{
  "mcpServers": {
    "mastergo": {
      "command": "npx",
      "args": ["-y", "@mastergo/vibe-mcp", "--url=http://localhost:50678"]
    }
  }
}
```

Codex Desktop 中对应写法：

```toml
[mcp_servers.mastergo]
type = "stdio"
command = "npx"
args = ["-y", "@mastergo/vibe-mcp", "--url=http://localhost:50678"]
```

其中 `http://localhost:50678` 是 MasterGo 本地客户端启动的 Vibe MCP 服务地址。如果 MasterGo 自动换了端口，需要同步修改 `--url`。

## 3. 修改配置后必须重新加载 Codex

新增或修改 `~/.codex/config.toml` 后，当前已打开的 Codex 任务通常不会自动加载新 MCP。

推荐操作：

1. 保存 `~/.codex/config.toml`。
2. 重启 Codex Desktop，或新开一个 Codex 任务。
3. 在新任务中检查 MCP 是否出现。

本次排查中，旧任务里调用 `mastergo` 时出现过：

```text
unknown MCP server 'mastergo'
```

这不代表 MasterGo 服务坏了，而是当前任务启动时没有加载到新配置。

## 4. 判断 MCP 是否成功加载

不要只用 `resources/list` 判断 MCP 是否成功。

原因：有些 MCP 只暴露 tools，不实现 resources。MasterGo 就是这种情况。它对 `resources/list` 返回：

```text
Mcp error: -32601: Method not found
```

这不是失败，只表示它没有 resources 接口。

正确判断方式：

1. 搜索工具命名空间是否出现，例如 `mcp__mastergo`。
2. 调用一个轻量工具，例如 MasterGo 的 `get_version`。
3. 能返回版本或工具结果，即说明 MCP 链路成功。

MasterGo 成功返回示例：

```json
{
  "name": "MasterGo-Vibe-MCP",
  "displayName": "MasterGo",
  "packageName": "@mastergo/vibe-mcp",
  "version": "1.0.26",
  "updateAvailable": false
}
```

## 5. MCP 链路分层排查方法

排查时按三层拆开，不要混在一起判断。

### 5.1 本地服务层

先确认 MCP 背后的本地服务是否可访问。

MasterGo 示例：

```bash
nc -vz localhost 50678
```

如果端口可连通，说明 MasterGo 本地服务已启动。

MasterGo 的某些接口不是普通网页接口，直接访问根路径或某些路径可能返回 `Bad Request`，这不一定是异常。应优先使用 MCP 工具，或使用已知 API 做验证，例如本次曾用：

```bash
curl -s -X GET http://localhost:50678/api/getSelectionNode
```

### 5.2 MCP server 进程层

确认 MCP server 包本身能运行。

MasterGo 示例：

```bash
npx -y @mastergo/vibe-mcp@latest --version
```

如果 `npx` 首次启动慢、无输出或受网络影响，可以考虑固定版本或全局安装。

### 5.3 Codex 加载层

确认 Codex 当前任务是否加载到了 MCP server。

现象对照：

- `unknown MCP server 'xxx'`：当前 Codex 任务没加载到这个 server，通常需要重启 Codex 或新开任务。
- `Method not found` from `resources/list`：server 已存在，但不支持 resources 接口，不等于失败。
- 工具命名空间出现且轻量工具可调用：加载成功。

## 6. stdio 协议手动测试注意点

不同 MCP SDK/版本的 stdio 传输格式可能不一样。不要想当然用 `Content-Length` 帧格式。

本次 `@mastergo/vibe-mcp` 使用的是每行一个 JSON-RPC 消息的 stdio 传输。手动测试时应写入换行结尾的 JSON：

```js
const { spawn } = require("child_process");

const cp = spawn("npx", [
  "-y",
  "@mastergo/vibe-mcp",
  "--url=http://localhost:50678"
], { stdio: ["pipe", "pipe", "pipe"] });

cp.stdout.on("data", data => console.log(data.toString()));
cp.stderr.on("data", data => console.error(data.toString()));

function send(message) {
  cp.stdin.write(JSON.stringify(message) + "\n");
}

send({
  jsonrpc: "2.0",
  id: 1,
  method: "initialize",
  params: {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "local-check", version: "1.0.0" }
  }
});
```

如果用错了帧格式，可能表现为进程不返回任何内容，但这并不一定说明 MCP server 坏了。

## 7. npx 与固定 command 的取舍

文档常见写法是：

```toml
command = "npx"
args = ["-y", "@scope/package", "..."]
```

优点：不用手动安装，始终可以拉取 npm 包。

缺点：首次启动慢；依赖网络或 npm 缓存；Codex 启动 MCP 时如果等待过久，可能表现为工具不可用。

更稳定的方式是全局安装：

```bash
npm install -g @mastergo/vibe-mcp
```

然后配置：

```toml
[mcp_servers.mastergo]
type = "stdio"
command = "mastergo-vibe-mcp"
args = ["--url=http://localhost:50678"]
```

也可以临时使用 npm 缓存中的实际 bin 路径，但不推荐长期依赖，因为清理 npm 缓存后路径可能失效。

## 8. 通用接入清单

后续接入其它 MCP 时按以下清单执行：

1. 确认 MCP 类型：`stdio` 还是 `http`。
2. 将官方 JSON 配置转换为 Codex TOML。
3. 写入 `/Users/dy/.codex/config.toml` 的 `[mcp_servers.xxx]` 段。
4. 若使用本地服务，先确认端口可连通。
5. 若使用 `npx`，先在终端跑 `--version` 或 `--help` 确认包能启动。
6. 重启 Codex Desktop 或新开任务。
7. 不要只看 resources，优先确认 tools 命名空间和轻量工具调用。
8. 如果失败，区分是本地服务不可用、MCP server 进程不可用，还是 Codex 当前任务未加载配置。

## 9. 本次 MasterGo 结论

本次 MasterGo MCP 的最终状态：

- `~/.codex/config.toml` 配置正确。
- MasterGo 本地端口 `50678` 可连通。
- `@mastergo/vibe-mcp` 版本 `1.0.26` 可正常作为 MCP server 返回工具。
- Codex 新任务中 `mcp__mastergo` 命名空间可见。
- `get_version` 调用成功。
- `resources/list` 返回 `Method not found` 是预期现象，不影响工具使用。

