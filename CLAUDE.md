# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**与用户沟通时请使用中文。**

## 项目概述

`goctlx` 是 go-zero 的 `goctl` CLI 脚手架工具的增强定制版。它为 go-zero 框架生成 API 服务、RPC 服务和数据库 Model 代码，在原版模板和生成逻辑基础上做了深度定制。

模块：`github.com/dxc0522/goctlx`
Go 版本：1.24.0
基线：go-zero v1.10.1

## 构建与测试命令

```bash
# 构建二进制
go build -o goctlx goctlx.go

# 跨平台编译（多平台 zip 打包见 build.sh）
GOOS=darwin go build -ldflags="-s -w" -o goctlx goctlx.go

# 运行所有测试
go test ./...

# 运行指定包的测试
go test ./model/sql/gen/...
go test ./api/gogen/...

# 运行单个测试
go test ./model/sql/gen/... -run TestCacheModel -v

# 与上游 goctl 输出做对比
bash compare/compare.sh
```

入口：`goctlx.go` → `cmd.Execute()`。各顶层包（`api/cmd.go`、`model/cmd.go`、`rpc/cmd.go` 等）通过 `cobra` + 内部 `cobrax` 封装注册子命令。

## 架构

### 命令注册
每个功能域（`api/`、`model/`、`rpc/`、`migrate/`、`docker/`、`kube/` 等）各自导出一个 `Cmd *cobra.Command`，由 `cmd/root.go` 统一挂载到 `rootCmd`。

### 代码生成流程
所有生成器遵循相同模式：
1. `Generator` 结构体（`api/gogen/`、`rpc/generator/`、`model/sql/gen/`）持有配置和输出目录
2. 模板通过 `//go:embed` 嵌入同目录下的 `.tpl` 文件
3. `genFile()` 根据 `config.Config.NamingFormat` 决定输出文件名大小写风格
4. `pathx.LoadTemplate` 始终使用嵌入模板（`~/.goctl/` 磁盘模板不再被加载）

### 核心定制点（修改时需保持这些特性）

**Model 层 — GORM 优先：**
生成的 Model 结构体同时持有 `sqlx.SqlConn`（基础设施连接）和 `*gorm.DB`，但所有 CRUD 方法均通过 GORM 实现，集中在 `customized.tpl` 中生成。方法无 `Gorm` 后缀：`FindOne`、`FindOneByConditions`、`FindCount`、`FindAll`、`FindList`、`FindPageWithCount`、`Insert`、`InsertBatch`、`Update`、`UpdateFields`、`Delete`、`DeleteBatch`。写操作（Insert/InsertBatch/Update）自动通过 `invalidateCache` 清除主键和唯一索引缓存。`ErrNotFound` 通过 `errors.Is(err, gorm.ErrRecordNotFound)` 映射。sqlx 原始 CRUD 模板文件（`find-one.tpl`、`insert.tpl` 等）已清空为占位符。

**模板加载 — 嵌入优先：**
`pathx.LoadTemplate` 始终使用 `//go:embed` 嵌入的模板，**不再检查** `~/.goctl/` 目录。这确保项目嵌入的模板始终生效，不会被磁盘上的旧模板覆盖。

**Logic 层 — 注入 HTTP 原始对象：**
`api/gogen/logic.tpl` 生成的 logic 结构体包含 4 个字段：`ctx`、`ServiceContext`、`reqCtx *http.Request`、`respWriter *http.ResponseWriter`。Handler 模板将 `r` 和 `&w` 传入 logic 构造函数。

**Handler 文件 — `_gen.go` 后缀：**
`api/gogen/genhandlers.go` 将 handler 文件写为 `<name>_gen.go`，标识为自动生成代码。

**ServiceContext 返回 error：**
`api/gogen/svc.tpl` 生成 `NewServiceContext(c config.Config) (*ServiceContext, error)`。main 模板包含 `defer server.Stop()` 和 `conf.UseEnv()`。

**CLI 智能默认值：**
`goctlx api go` 的 `--dir` 默认 `.`，`--api` 默认 `./<父目录名>.api`，在项目目录下裸跑即可。

### 模板文件位置
- API 模板：`api/gogen/*.tpl`（handler、logic、main、svc、config、etc、routes、middleware）
- Model 模板：`model/sql/template/tpl/*.tpl`（model、types、insert、update、delete、find-one、find-one-by-field、import、err、interface-*、tag、var、table-name、field、customized、model-new）
- RPC 模板：`rpc/generator/*.tpl`

### 测试工具
- `test/test.go` — 基于泛型的通用表驱动测试执行器（`test.Data[T,Y]`、`test.Executor`）
- `compare/compare.sh` — 对比新旧 goctl 输出差异，发版前使用
- `model/sql/gen/testdata/user.sql` — Model 生成测试的 SQL fixture

## 注意事项

- **文档同步规则：** 每次项目逻辑变更时，必须同步更新以下两个文件：
  - `GOCTLX_IMPROVEMENTS.md` — 记录相对上游 go-zero 的所有定制改进
  - `README.md` — 面向用户的使用说明和功能介绍
- `vendor/` 目录已提交。修改 `go.mod` 依赖后需执行 `go mod vendor`。
- 模板使用 Go `text/template` 语法。编辑模板前先确认对应 `gen*.go` 传入了哪些变量。
- Model 模板中的 `hasField` 辅助函数已被有意移除，不要重新引入。
- 修改 Model 模板时，`{{if .withCache}}` 分支尤其敏感——cache 和 no-cache 两种情况都要测试。
- `pathx.LoadTemplate` 始终使用嵌入模板，`~/.goctl/` 目录下的模板文件**不会被加载**。如需自定义模板输出，直接修改 `model/sql/template/tpl/*.tpl` 文件。
- Model 的 CRUD 方法全部通过 GORM 实现（在 `customized.tpl` 中），sqlx CRUD 模板文件（`find-one.tpl`、`insert.tpl`、`update.tpl`、`delete.tpl` 等）为空占位符，不要在其中添加代码。
