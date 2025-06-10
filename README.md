# DailyApp - 日常管理应用

一个基于 HarmonyOS 前端和 Java Spring Boot 后端的全栈日常管理应用。

## 📁 项目结构

```
MyTestProject/
├── AppScope/               # HarmonyOS应用级配置
├── entry/                  # HarmonyOS主入口模块
├── src/                    # HarmonyOS源代码
├── oh_modules/             # HarmonyOS依赖模块
├── hvigor/                 # HarmonyOS构建工具
├── *.json5                 # HarmonyOS配置文件
├── server/                 # Java Spring Boot后端
│   ├── src/               # Java源码
│   ├── pom.xml           # Maven配置
│   ├── target/           # 编译输出
│   └── data/             # 数据库文件
├── scripts/                # 脚本管理
│   ├── build/             # 构建脚本
│   │   ├── build-and-deploy.sh
│   │   └── build-and-deploy.bat
│   ├── test/              # 测试脚本
│   │   ├── add_test_data.ps1
│   │   ├── test_api.bat
│   │   └── ...
│   └── deploy/            # 部署配置
│       └── dailyapp.service
├── tests/                  # 测试文件
│   ├── test_api.html      # API测试页面
│   ├── api_test_examples.txt
│   └── ...
├── docs/                   # 文档
│   ├── 部署指南.md
│   └── requirements.md
└── data/                   # 数据文件
```

> **重要变更**: HarmonyOS 前端项目现已移至根目录，使 DevEco Studio 能够正确识别项目结构并支持内置的 Git 功能。

## 🚀 快速开始

### 前端开发

```bash
# 在DevEco Studio中直接打开项目根目录即可
# DevEco Studio 会自动识别 HarmonyOS 项目结构
```

### 后端开发

```bash
cd server
mvn spring-boot:run
```

### 构建部署

```bash
# Linux/Mac
./scripts/build/build-and-deploy.sh

# Windows
scripts\build\build-and-deploy.bat
```

### 测试

```bash
# 添加测试数据
scripts\test\add_test_data.ps1

# API测试
打开 tests\test_api.html
```

## 📖 文档

- [部署指南](docs/部署指南.md)
- [需求文档](docs/requirements.md)

## 🛠️ 技术栈

- **前端**: HarmonyOS (ArkTS/ArkUI)
- **后端**: Java Spring Boot
- **数据库**: H2/MySQL
- **构建工具**: Maven, Hvigor

## 📝 开发说明

1. **前端代码**位于项目根目录 (HarmonyOS 项目结构)
2. **后端代码**位于 `server/` 目录
3. **构建脚本**位于 `scripts/build/` 目录
4. **测试工具**位于 `scripts/test/` 和 `tests/` 目录
5. **部署配置**位于 `scripts/deploy/` 目录

### 使用 DevEco Studio

- 直接用 DevEco Studio 打开项目根目录
- DevEco 会自动识别 HarmonyOS 项目并支持 Git 功能
- 无需额外配置

## 🔧 环境要求

- Java 17+
- Maven 3.6+
- DevEco Studio (HarmonyOS 开发)
- Node.js (可选，用于某些构建工具)
