#!/bin/bash

# 云服务器部署脚本
echo "=========================================="
echo "   部署修复版本到云服务器"
echo "=========================================="

SERVER_IP="8.148.20.194"
APP_NAME="harmony-daily-app-0.0.1-SNAPSHOT.jar"
LOCAL_JAR="server/target/$APP_NAME"

echo "🔍 检查本地JAR文件..."
if [ ! -f "$LOCAL_JAR" ]; then
    echo "❌ 本地JAR文件不存在: $LOCAL_JAR"
    echo "请先运行构建命令: cd server && mvn clean package -DskipTests=true"
    exit 1
fi

echo "✅ 找到本地JAR文件: $LOCAL_JAR"
echo ""

echo "📤 部署步骤说明："
echo "1. 上传新版本JAR到服务器"
echo "2. 停止现有服务"  
echo "3. 备份旧版本"
echo "4. 替换新版本"
echo "5. 启动服务"
echo ""

echo "📋 手动部署命令（在您的云服务器控制台执行）："
echo "-------------------------------------------"
echo "# 1. 停止服务"
echo "sudo systemctl stop dailyapp"
echo ""
echo "# 2. 备份当前版本"
echo "mv $APP_NAME $APP_NAME.backup.$(date +%Y%m%d_%H%M%S)"
echo ""
echo "# 3. 上传新版本后，启动服务"
echo "sudo systemctl start dailyapp"
echo "sudo systemctl status dailyapp"
echo ""
echo "# 4. 检查日志"
echo "sudo journalctl -u dailyapp -f"
echo "-------------------------------------------"

echo ""
echo "✨ 本次修复内容："
echo "   ✅ 修复CORS配置错误（allowCredentials与*的冲突）"
echo "   ✅ 修复数据库路径配置"
echo "   ✅ 优化错误处理"
echo ""

echo "📱 前端配置已切换为production模式，将连接到："
echo "   http://8.148.20.194:8080/api"
echo ""

echo "🎯 部署完成后请测试："
echo "   1. 打开浏览器访问: http://8.148.20.194:8080/api/health"
echo "   2. 使用HarmonyOS应用登录测试"
echo "   3. 检查功能是否正常" 