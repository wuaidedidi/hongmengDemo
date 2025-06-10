#!/bin/bash

# HarmonyOS 日常应用启动脚本
# 适用于Linux服务器和宝塔面板

# 配置变量
APP_NAME="harmony-daily-app"
JAR_FILE="harmony-daily-app-0.0.1-SNAPSHOT.jar"
PROFILE="prod"
PORT="8080"
JAVA_OPTS="-Xms512m -Xmx1024m"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== HarmonyOS 日常应用启动脚本 ===${NC}"
echo -e "应用名称: ${YELLOW}$APP_NAME${NC}"
echo -e "JAR文件: ${YELLOW}$JAR_FILE${NC}"
echo -e "运行环境: ${YELLOW}$PROFILE${NC}"
echo -e "端口: ${YELLOW}$PORT${NC}"
echo ""

# 检查Java环境
echo -e "${YELLOW}[1/5] 检查Java环境...${NC}"
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    echo -e "${GREEN}✓ Java已安装: $JAVA_VERSION${NC}"
else
    echo -e "${RED}✗ Java未安装，请先安装Java 8或更高版本${NC}"
    exit 1
fi

# 检查JAR文件
echo -e "${YELLOW}[2/5] 检查JAR文件...${NC}"
if [ -f "$JAR_FILE" ]; then
    echo -e "${GREEN}✓ JAR文件存在: $JAR_FILE${NC}"
else
    echo -e "${RED}✗ JAR文件不存在: $JAR_FILE${NC}"
    echo -e "请确保JAR文件在当前目录下"
    exit 1
fi

# 检查端口占用
echo -e "${YELLOW}[3/5] 检查端口占用...${NC}"
if netstat -tlnp 2>/dev/null | grep ":$PORT " > /dev/null; then
    echo -e "${RED}⚠ 端口 $PORT 已被占用${NC}"
    echo -e "正在尝试查找占用进程..."
    netstat -tlnp 2>/dev/null | grep ":$PORT "
    echo -e "${YELLOW}是否继续启动？可能会失败 (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ 端口 $PORT 可用${NC}"
fi

# 创建日志目录
echo -e "${YELLOW}[4/5] 准备日志目录...${NC}"
mkdir -p logs
echo -e "${GREEN}✓ 日志目录已准备${NC}"

# 启动应用
echo -e "${YELLOW}[5/5] 启动应用...${NC}"
echo -e "${GREEN}正在启动 $APP_NAME...${NC}"
echo -e "日志文件: ${YELLOW}logs/app.log${NC}"
echo -e "使用 ${YELLOW}Ctrl+C${NC} 停止应用"
echo ""

# 启动命令
java $JAVA_OPTS -jar "$JAR_FILE" \
    --spring.profiles.active="$PROFILE" \
    --server.port="$PORT" \
    --logging.file.name=logs/app.log \
    2>&1 | tee logs/app.log

echo -e "${YELLOW}应用已停止${NC}"