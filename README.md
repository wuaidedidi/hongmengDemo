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
│   ├── requirements.md
│   └── ...
└── data/                   # 数据文件
```

> **重要说明**: HarmonyOS 前端项目位于根目录，使 DevEco Studio 能够正确识别项目结构并支持内置的 Git 功能。

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
./build_and_deploy.sh

# Windows
build_and_deploy.bat
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
3. **测试工具**位于 `scripts/test/` 和 `tests/` 目录
4. **部署配置**位于 `scripts/deploy/` 目录

### 使用 DevEco Studio

- 直接用 DevEco Studio 打开项目根目录
- DevEco 会自动识别 HarmonyOS 项目并支持 Git 功能
- 无需额外配置

## 🔧 环境要求

- Java 8+
- Maven 3.6+
- DevEco Studio (HarmonyOS 开发)

## 🚀 部署

### 本地部署

```bash
# 1. 构建后端
cd server
mvn clean package

# 2. 启动服务
java -jar target/harmony-daily-app-0.0.1-SNAPSHOT.jar

# 3. 验证部署
curl http://localhost:8080/api/health
```

### 服务器部署

```bash
# 使用提供的部署脚本
./deploy_to_server.sh
```

## 📊 健康检查

```bash
# 应用健康状态
curl http://localhost:8080/api/health

# API测试
curl http://localhost:8080/api/todos
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🆘 获取帮助

- 📚 [完整文档](docs/)
- 🐛 问题反馈请提交 Issue
- 📧 联系开发者
