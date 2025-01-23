# goctlx

[![Go Reference](https://pkg.go.dev/badge/github.com/dxc0522/goctlx.svg)](https://pkg.go.dev/github.com/dxc0522/goctlx)
[![deps.dev](https://img.shields.io/badge/deps.dev-查看依赖分析-blue)](https://deps.dev/go/github.com%2Fdxc0522%2Fgoctlx)

`goctlx` 是基于 [go-zero](https://github.com/zeromicro/go-zero)
的增强版脚手架工具，针对实际开发需求进行了深度定制。本项目优化了默认模板、文件生成逻辑和目录结构，并添加了便捷功能。

---

## 🛠️ 主要修改与功能

### **目录结构优化**

- 重构 `handler` 和 `logic` 生成逻辑，更符合分层架构。
- 调整 `template` 模板细节，生成代码更简洁规范。

### **功能增强**

- **智能读取 `.api` 文件**  
  自动以当前父级文件夹名称作为 `.api` 文件的默认来源，减少路径参数输入。
- **默认导出到当前目录**  
  生成的代码默认输出到当前文件夹，简化命令操作。
- **集成 `logic new` 逻辑**  
  支持快速生成业务逻辑层代码，提升开发效率。

---

## 📦 安装方式

通过以下命令一键安装：

```bash
go install github.com/dxc0522/goctlx@latest
```

---

## 🚀 快速使用

### **生成 Go API 服务**

在命令中运行：

```bash
goctlx api new demo  # 自动生成基于go-zero框架的api服务
```

### **生成 API 服务**

1. 在包含 `.api` 文件的目录中运行：

```bash
goctlx api go # 自动读取[父级文件夹名称].api文件并生成代码到当前文件夹
```

---

## 📁 目录结构

```plaintext
demo/
    ├── config/
    ├── etc/
    ├── handler/
    ├── logic/
    ├── svc/
    ├── types/
    ├── demo.api
    └── demo.go
```

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源，可自由使用和修改。