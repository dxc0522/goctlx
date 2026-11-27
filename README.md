# goctlx

[![Go Reference](https://pkg.go.dev/badge/github.com/dxc0522/goctlx.svg)](https://pkg.go.dev/github.com/dxc0522/goctlx)
[![deps.dev](https://img.shields.io/badge/deps.dev-查看依赖分析-blue)](https://deps.dev/go/github.com%2Fdxc0522%2Fgoctlx)

`goctlx` 是基于 [go-zero/tools/goctl v1.11.0](https://github.com/zeromicro/go-zero/tree/tools/goctl/v1.11.0/tools/goctl) 的增强版脚手架工具，针对实际开发需求进行了深度定制。本项目优化了默认模板、文件生成逻辑和目录结构，并添加了多项实用功能。

编译需要 Go 1.25.0 或更高版本。同步 goctl v1.11.0 后，可使用 `goctlx rpc protoc --client-only` 仅生成 RPC 客户端。

---

## 🛠️ 核心改进

### 架构级变更

- **数据访问层 sqlx → GORM：** 生成的 Model 所有 CRUD 方法均通过 GORM 实现，消除手工 SQL 拼接，多数据库支持更自然
- **Logic 层注入 HTTP 对象：** Logic 结构体包含 `*http.Request` 和 `*http.ResponseWriter`，可直接操作请求/响应
- **ServiceContext 返回 error：** `NewServiceContext` 支持返回错误，配合 `defer server.Stop()` 实现优雅启动/关闭
- **配置支持环境变量覆盖：** 引入 `conf.UseEnv()`，新增 `AppMode` 字段（`env=APP_MODE`）
- **MySQL 初始化：** 新生成的 API 服务通过 `github.com/gchhotels/pkgx/provide.Mysql` 初始化连接，业务代码可使用 `ServiceContext.DB`。DSN 可在 YAML 的 `Mysql.DSN` 或环境变量 `MYSQL_DSN` 中设置，留空时可独立启动 API。使用 `pkgx v0.1.0` 构建生成的服务需要 Go 1.26.11 和对应仓库的访问权限

### Model 生成增强

- **GORM 优先模式：** 所有 CRUD 方法均通过 GORM 实现，集中在 `customized.tpl` 中生成，无 `Gorm` 后缀
- **查询 API（6 个）：** `FindOne`（主键查询）、`FindOneByConditions`（条件首条）、`FindCount`（计数）、`FindAll`（全量）、`FindList`（分页）、`FindPageWithCount`（分页+总数）
- **写入 API（6 个）：** `Insert`、`InsertBatch`（批量插入）、`Update`（全量更新）、`UpdateFields`（部分更新）、`Delete`（主键删除）、`DeleteBatch`（条件批量删除）
- **写操作自动清缓存：** `Insert`/`InsertBatch`/`Update` 写入后自动清除主键和唯一索引缓存
- **缓存过期：** `UpdateFields`、`Delete` 和 `DeleteBatch` 写入后的缓存依赖 TTL 过期
- **统一错误处理：** 所有查询方法将 `gorm.ErrRecordNotFound` 映射为 `ErrNotFound`
- **模板嵌入优先：** `pathx.LoadTemplate` 始终使用项目嵌入模板，`~/.goctl/` 目录不再被加载
- **JSON 标签自动生成：** 每个字段自动添加 `json:"field_name,omitempty"`
- **`database/sql` 智能 import：** 自动检测表中是否存在 nullable 字段（`sql.NullTime`、`sql.NullString` 等），仅在需要时引入 `"database/sql"`，避免未使用 import 导致编译错误
- **跳过迁移跟踪表：** 从数据源生成 model 时，始终跳过表名以 `goose_db_version` 结尾的表（goose 迁移版本表），避免把无业务主键的迁移表误生成 model

### CLI 智能默认值

- `goctlx api go` 的 `--dir` 默认 `.`，`--api` 默认 `./<父目录名>.api`，在项目目录下裸跑即可
- `goctlx api new` 默认导出到当前目录
- `goctlx api new` 生成的新项目不带 `-api` 后缀：`.api` 源文件 service 名、etc 配置文件名（`<name>.yaml`）、etc.yaml 中 `Name` 字段均使用纯 `<name>`，命名一致
- Handler 文件使用 `_gen.go` 后缀，标识自动生成代码

### 其他

- **结构化错误响应：** Logic 可返回 `github.com/gchhotels/pkgx/httpx.NewErrorResponse` 创建的错误，由 `provide.ServerSetup` 注册的处理器转换为 HTTP 状态码和 JSON 响应
- **服务启动：** 注册业务路由后，由 `pkgx` 的 `provide.ServerSetup(server, c.RestConf)` 安装共享中间件、注册 `/api/<服务名>/ping` 并启动服务

---

## 📦 安装方式

```bash
go install github.com/dxc0522/goctlx@latest
```

---

## 🚀 快速使用

### 生成 API 服务模板

```bash
goctlx api demo  # 自动生成基于 go-zero 框架的 API 服务，默认生成到 demo/demo.api
```

### 从 .api 文件生成代码

```bash
goctlx api go    # 自动读取 [父级文件夹名称].api 文件并生成代码到当前文件夹
```

### 生成 Model（从 DDL）

```bash
goctlx model mysql ddl --src user.sql --dir ./model
```

### 生成 Model（从数据源）

```bash
# MySQL
goctlx model mysql datasource --url "user:pass@tcp(host:3306)/db" --table "users" --dir ./model

# PostgreSQL
goctlx model pg datasource --url "postgres://user:pass@host:5432/db?sslmode=disable" --table "users" --dir ./model
```

---

## 📁 生成项目结构

```
demo/
├── config/        # 配置结构体
├── etc/           # YAML 配置文件
├── handler/       # HTTP Handler（*_gen.go）
├── logic/         # 业务逻辑层
├── svc/           # ServiceContext
├── types/         # 请求/响应类型
├── demo.api       # API 定义文件
└── demo.go        # 入口 main.go
```

---

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源，可自由使用和修改。
