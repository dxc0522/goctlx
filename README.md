# goctlx

[![Go Reference](https://pkg.go.dev/badge/github.com/dxc0522/goctlx.svg)](https://pkg.go.dev/github.com/dxc0522/goctlx)
[![deps.dev](https://img.shields.io/badge/deps.dev-查看依赖分析-blue)](https://deps.dev/go/github.com%2Fdxc0522%2Fgoctlx)

`goctlx` 是基于 [go-zero](https://github.com/zeromicro/go-zero) v1.10.1 的增强版脚手架工具，针对实际开发需求进行了深度定制。本项目优化了默认模板、文件生成逻辑和目录结构，并添加了多项实用功能。

---

## 🛠️ 核心改进

### 架构级变更

- **数据访问层 sqlx → GORM：** 生成的 Model 所有 CRUD 方法均通过 GORM 实现，消除手工 SQL 拼接，多数据库支持更自然
- **Logic 层注入 HTTP 对象：** Logic 结构体包含 `*http.Request` 和 `*http.ResponseWriter`，可直接操作请求/响应
- **ServiceContext 返回 error：** `NewServiceContext` 支持返回错误，配合 `defer server.Stop()` 实现优雅启动/关闭
- **配置支持环境变量覆盖：** 引入 `conf.UseEnv()`，新增 `AppMode` 字段（`env=APP_MODE`）

### Model 生成增强

- **GORM 优先模式：** 所有 CRUD 方法均通过 GORM 实现，集中在 `customized.tpl` 中生成，无 `Gorm` 后缀
- **查询 API（6 个）：** `FindOne`（主键查询）、`FindOneByConditions`（条件首条）、`FindCount`（计数）、`FindAll`（全量）、`FindList`（分页）、`FindPageWithCount`（分页+总数）
- **写入 API（6 个）：** `Insert`、`InsertBatch`（批量插入）、`Update`（全量更新）、`UpdateFields`（部分更新）、`Delete`（主键删除）、`DeleteBatch`（条件批量删除）
- **写操作自动清缓存：** `Insert`/`InsertBatch`/`Update` 写入后自动清除主键和唯一索引缓存
- **统一错误处理：** 所有查询方法将 `gorm.ErrRecordNotFound` 映射为 `ErrNotFound`
- **模板嵌入优先：** `pathx.LoadTemplate` 始终使用项目嵌入模板，`~/.goctl/` 目录不再被加载
- **JSON 标签自动生成：** 每个字段自动添加 `json:"field_name,omitempty"`

### CLI 智能默认值

- `goctlx api go` 的 `--dir` 默认 `.`，`--api` 默认 `./<父目录名>.api`，在项目目录下裸跑即可
- `goctlx api new` 默认导出到当前目录
- Handler 文件使用 `_gen.go` 后缀，标识自动生成代码

### 其他

- **结构化错误响应：** Handler 支持 `httpx2.ResponseError` 类型检测，可返回自定义状态码和结构化数据
- **扩展钩子：** 新增 `provide.ServerSetup()` 扩展点

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

## 📖 详细改进说明

完整的相对上游 go-zero 的改进清单见 [GOCTLX_IMPROVEMENTS.md](GOCTLX_IMPROVEMENTS.md)。

---

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源，可自由使用和修改。
