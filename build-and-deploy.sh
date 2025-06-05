#!/bin/bash

echo "========================================"
echo "   DailyApp 生产环境构建和部署脚本"
echo "========================================"

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java环境，请安装Java 17或更高版本"
    exit 1
fi

if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven环境，请安装Maven"
    exit 1
fi

echo "正在构建后端应用..."
cd serverDemo

# 添加生产环境profile到pom.xml（如果不存在）
if ! grep -q "<id>prod</id>" pom.xml; then
    echo "警告: pom.xml中未找到prod profile，将使用默认配置"
fi

mvn clean package -DskipTests=true
if [ $? -ne 0 ]; then
    echo "后端构建失败！"
    exit 1
fi

echo "后端构建成功！"
echo "生成的JAR文件: target/serverDemo-1.0.0.jar"

cd ..

echo ""
echo "========================================"
echo "正在配置前端生产环境..."

# 复制生产环境配置文件
cp "entry/src/main/resources/rawfile/config-production.json" "entry/src/main/resources/rawfile/config.json"

echo "前端已配置为生产环境模式"

echo ""
echo "========================================"
echo "部署说明:"
echo "1. 将后端JAR文件上传到服务器: target/serverDemo-1.0.0.jar"
echo "2. 在服务器上创建数据库（如果使用MySQL）:"
echo "   mysql -u root -p"
echo "   CREATE DATABASE dailyapp;"
echo "   CREATE USER 'dailyapp'@'localhost' IDENTIFIED BY 'dailyapp123';"
echo "   GRANT ALL PRIVILEGES ON dailyapp.* TO 'dailyapp'@'localhost';"
echo "   FLUSH PRIVILEGES;"
echo ""
echo "3. 设置环境变量（可选）:"
echo "   export DB_USERNAME=dailyapp"
echo "   export DB_PASSWORD=your_secure_password"
echo "   export JWT_SECRET=your_very_secure_jwt_secret_key"
echo ""
echo "4. 在服务器上运行应用:"
echo "   java -jar -Dspring.profiles.active=prod serverDemo-1.0.0.jar"
echo ""
echo "5. 或者使用systemd服务（推荐）:"
echo "   sudo systemctl start dailyapp"
echo "   sudo systemctl enable dailyapp"
echo "========================================"

echo ""
echo "前端构建说明:"
echo "1. 在DevEco Studio中打开项目"
echo "2. 选择 Build -> Build Hap(s)/APP(s)"
echo "3. 或者选择 Build -> Generate Signed Bundle/APK"
echo "4. 构建完成后安装到设备"
echo "========================================" 