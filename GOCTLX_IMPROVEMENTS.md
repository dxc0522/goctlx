# goctlx 改进内容分析报告

> 基于 go-zero/tools/goctl 的深度定制增强版，针对实际开发需求进行了多项架构级改进。

---

## 一、项目背景

`goctlx` (github.com/dxc0522/goctlx) 是基于 `go-zero v1.10.1` 的增强版脚手架工具。它在保留 go-zero 原有功能的基础上，对默认模板、文件生成逻辑、数据访问层和目录结构进行了深度定制，并新增了多项实用功能。

---

## 二、架构级改进

### 2.1 数据访问层：sqlx → GORM

**这是最核心的架构变更。** 原始 go-zero 使用 `github.com/zeromicro/go-zero/core/stores/sqlx` 作为数据访问层，所有 SQL 操作通过拼接原始 SQL 字符串完成。goctlx 全面迁移到 `gorm.io/gorm`。

| 对比维度 | go-zero (sqlx) | goctlx (GORM) |
|---------|---------------|---------------|
| SQL 构建 | 手动拼接原始 SQL | GORM 自动映射 |
| PostgreSQL 占位符 | 需手动处理 `$1` vs `?` | GORM 透明处理 |
| 缓存嵌入 | `sqlc.CachedConn` 嵌入 model struct | 缓存分离为外部关注点 |
| `database/sql` | 直接依赖 | 不再依赖 |
| 错误哨兵 | `sqlx.ErrNotFound` | `gorm.ErrRecordNotFound` |

**收益：** 消除了所有手工 SQL 拼接、字段映射和占位符切换逻辑，代码更简洁，多数据库支持更自然。

### 2.2 Handler/Logic 层：注入 HTTP 原始对象

原始 go-zero 的 logic 层只有 `ctx` 和 `svcCtx` 两个字段，无法直接操作 HTTP 请求/响应。goctlx 将 `*http.Request` 和 `*http.ResponseWriter` 注入到 logic 层：

```go
// go-zero: 2 字段
type XxxLogic struct {
    ctx    context.Context
    svcCtx *svc.ServiceContext
}

// goctlx: 4 字段
type XxxLogic struct {
    ServiceContext *svc.ServiceContext
    ctx            context.Context
    reqCtx         *http.Request
    respWriter     *http.ResponseWriter
}
```

**收益：** logic 层可直接读取请求体、设置自定义状态码、写响应头，无需绕道框架抽象层。

### 2.3 ServiceContext 初始化可返回错误

```go
// go-zero: 不返回 error
func NewServiceContext(c config.Config) *ServiceContext

// goctlx: 返回 error，支持启动失败优雅退出
func NewServiceContext(c config.Config) (*ServiceContext, error)
```

main.go 中增加 `defer server.Stop()` 优雅关闭和 `os.Exit(0)` 错误处理。

### 2.4 配置支持环境变量覆盖

- 引入 `conf.UseEnv()` 支持环境变量覆盖 YAML 配置
- Config 结构体新增 `AppMode string` 字段（`env=APP_MODE, default=LOCAL`）
- 新增 `provide.ServerSetup()` 扩展钩子

---

## 三、Model 生成改进

### 3.1 GORM 方法体系重构（最新）

生成的 Model 所有 CRUD 方法均通过 GORM 实现，集中在 `customized.tpl` 中生成，无 `Gorm` 后缀，共 12 个方法：

**查询方法（6 个）：**

| 方法 | 说明 |
|------|------|
| `FindOne(ctx, pk)` | 按主键查询单条记录 |
| `FindOneByConditions(ctx, conditions, args...)` | 按自定义条件查询单条 |
| `FindCount(ctx, conditions, args...)` | 按条件统计记录数 |
| `FindAll(ctx, conditions, args...)` | 按条件查询所有匹配记录 |
| `FindList(ctx, limit, offset, sorts, conditions, args...)` | 分页查询 |
| `FindPageWithCount(ctx, limit, offset, sorts, conditions, args...)` | 分页查询并返回总数 |

**写入方法（6 个）：**

| 方法 | 说明 | 缓存失效 |
|------|------|---------|
| `Insert(ctx, data)` | 插入一条记录 | ✅ 清除主键+唯一索引缓存 |
| `InsertBatch(ctx, dataList)` | 批量插入记录 | ✅ 逐条清除缓存 |
| `Update(ctx, data)` | 全量更新（Save 模式） | ✅ 清除主键+唯一索引缓存 |
| `UpdateFields(ctx, pk, fields)` | 部分更新指定字段 | ⚠️ 无缓存清除，依赖 TTL |
| `Delete(ctx, pk)` | 按主键删除单条 | ⚠️ 无缓存清除，依赖 TTL |
| `DeleteBatch(ctx, conditions, args...)` | 按条件批量删除 | ⚠️ 无法精确清缓存，依赖 TTL |

**关键设计决策：**
- 所有查询方法统一将 `gorm.ErrRecordNotFound` 映射为 `ErrNotFound`
- 缓存失效通过内部构建的 `cacheClient cache.Cache` 实例实现，与 `CachedConn` 共享同一 Redis 后端
- sqlx CRUD 方法已完全移除（模板文件清空为占位符），所有数据访问通过 GORM 完成

**架构组织：**
- 所有 GORM 方法集中在 `customized.tpl`，sqlx CRUD 模板（`find-one.tpl`、`insert.tpl` 等）为空占位符
- 接口声明统一在 `interface-find-one.tpl`
- `invalidateCache` 辅助方法使用 `DataKeyExpression` 正确引用 `data.Field` 格式

### 3.3 JSON 序列化标签

原始 go-zero 生成的 struct 字段不含 JSON 标签。goctlx 为每个字段自动添加 `json:"field_name,omitempty"`：

```go
// go-zero 生成
type User struct {
    Id   int64
    Name string
}

// goctlx 生成
type User struct {
    Id   int64  `json:"id,omitempty"`
    Name string `json:"name,omitempty"`
}
```

### 3.4 Handler 文件名改为 `_gen.go` 后缀

go-zero 生成的 handler 文件名为 `<name>.go`，goctlx 改为 `<name>_gen.go`，遵循 Go 社区约定（`*_gen.go` 表示自动生成，不应手动编辑）。

---

## 四、全新功能

### 4.1 结构化错误响应

Handler 中新增 `httpx2.ResponseError` 类型检测，支持返回携带自定义状态码和结构化数据的错误响应。

---

## 五、CLI/UX 改进

### 5.1 `goctl api go` 智能默认值

原始 go-zero 必须显式指定 `--dir` 和 `--api` 参数。goctlx 改为：

| 参数 | go-zero 默认 | goctlx 默认 |
|------|------------|-----------|
| `--dir` | 空（必填） | `"."`（当前目录） |
| `--api` | 空（必填） | `./<当前目录名>.api` |

**收益：** 在标准 go-zero 项目目录下直接运行 `goctlx api go` 即可，无需任何参数。

### 5.2 `goctl api new` 默认导出到当前目录

生成的新服务代码默认输出到当前文件夹，减少路径输入。

---

## 六、模板文件变更汇总

| 模板文件 | 变更类型 | 说明 |
|---------|---------|------|
| `model.tpl` | 修改 | 移除 `withSession`（sqlx Session 不再暴露） |
| `types.tpl` | 修改 | 新增 `cacheClient cache.Cache` 字段（withCache 时） |
| `model-new.tpl` | 修改 | 内部构建 `cache.Cache` 实例，初始化 `cacheClient` |
| `customized.tpl` | **重写** | 集中 12 个 GORM 方法 + `invalidateCache` 辅助方法 |
| `find-one.tpl` | **清空** | sqlx CRUD 方法移除，GORM 方法迁移到 customized.tpl |
| `insert.tpl` | **清空** | sqlx CRUD 方法移除，GORM 方法迁移到 customized.tpl |
| `update.tpl` | **清空** | sqlx CRUD 方法移除，GORM 方法迁移到 customized.tpl |
| `delete.tpl` | **清空** | sqlx CRUD 方法移除，GORM 方法迁移到 customized.tpl |
| `find-one-by-field.tpl` | **清空** | sqlx FindOneByField 移除 |
| `find-one-by-field-extra-method.tpl` | **清空** | sqlx formatPrimary/queryPrimary 移除 |
| `var.tpl` | 修改 | 仅保留缓存键前缀（移除 sqlx 行变量） |
| `import.tpl` | 修改 | 精简依赖（移除不需要的标准库） |
| `import-no-cache.tpl` | 修改 | 精简依赖（移除 `database/sql`） |
| `interface-find-one.tpl` | **重写** | 统一声明所有 12 个方法签名（无 Gorm 后缀） |
| `interface-insert.tpl` | **清空** | 签名迁移到 interface-find-one.tpl |
| `interface-update.tpl` | **清空** | 签名迁移到 interface-find-one.tpl |
| `interface-delete.tpl` | **清空** | 签名迁移到 interface-find-one.tpl |
| `interface-find-one-by-field.tpl` | **清空** | sqlx FindOneByField 签名移除 |
| `handler.tpl` | 重写 | 4 参数构造函数，ResponseError 支持 |
| `logic.tpl` | 重写 | 注入 http.Request/ResponseWriter |
| `main.tpl` | 重写 | UseEnv、defer Stop、provide 钩子 |
| `svc.tpl` | 修改 | 返回 (*ServiceContext, error) |
| `config.tpl` | 修改 | 新增 AppMode 字段 |
| `etc.tpl` | 修改 | 新增 log 配置块 |
| `tag.tpl` 等 7 个 | 不变 | 完全一致 |

---

## 七、目录结构对比

### goctlx 新增文件/目录

```
goctlx/
├── internal/models/            # [新增] 预留扩展点（当前为空）
├── demo/                       # [新增] 示例目录
└── README.md                   # [新增] 英文说明文档
```

### goctlx 移除的文件（相对于 go-zero）

```
go-zero/tools/goctl/
├── docker/docker_test.go          # [移除]
├── rpc/generator/gencall_test.go  # [移除]
├── rpc/generator/typeref.go       # [移除]
├── rpc/parser/import_test.go      # [移除]
├── util/zipx/zipx_test.go         # [移除]
└── api/swagger/issue5496/         # [移除]
```

---

## 八、改进要点总结

| 类别 | 改进项 | 影响程度 |
|------|--------|---------|
| 架构 | sqlx → GORM 数据访问层迁移 | **重大** |
| 架构 | Logic 层注入 HTTP 原始对象 | **重大** |
| 架构 | ServiceContext 初始化可返回 error | 中等 |
| 功能 | 查询 API 从 2 个扩展到 5 个 | **重大** |
| 功能 | 批量操作（InsertBatch/DeleteBatch/Save） | **重大** |
| 功能 | JSON 标签自动生成 | 中等 |
| 功能 | 结构化错误响应（ResponseError） | 中等 |
| CLI | `goctl api go` 智能默认值 | 中等 |
| 模板 | Handler 文件改为 `_gen.go` 后缀 | 较小 |
| 配置 | 环境变量覆盖 + AppMode | 中等 |
| 配置 | 优雅关闭 + 扩展钩子 | 中等 |

---

## 九、依赖变更

| 依赖 | go-zero | goctlx | 说明 |
|------|---------|--------|------|
| go-zero | v1.10.1 | v1.10.1 | 与上游同步 |
| gorm.io/gorm | 无 | 有 | ORM 核心 |
| go-sql-driver/mysql | 间接 | **直接** | 数据库驱动 |
| lib/pq | **无** | **直接** | PostgreSQL 驱动 |
| Go 版本 | 1.24.0 | 1.24.0 | — |
| cobra | v1.10.2 | v1.8.1 | 略旧 |
