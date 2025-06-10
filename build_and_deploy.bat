@echo off
echo ========================================
echo 构建修复版本并准备部署到云服务器
echo ========================================

echo 1. 切换到server目录并构建...
cd server
call mvn clean package -DskipTests=true
if %ERRORLEVEL% neq 0 (
    echo 构建失败！
    pause
    exit /b 1
)

echo.
echo 2. 构建成功！生成的JAR文件位置：
echo    %cd%\target\harmony-daily-app-0.0.1-SNAPSHOT.jar
echo.

echo 3. 部署说明：
echo    请将以下文件上传到云服务器：
echo    - harmony-daily-app-0.0.1-SNAPSHOT.jar
echo.
echo    然后在云服务器上执行：
echo    1) 停止现有服务：sudo systemctl stop dailyapp
echo    2) 备份旧版本：mv harmony-daily-app-0.0.1-SNAPSHOT.jar harmony-daily-app-backup.jar
echo    3) 上传新版本
echo    4) 启动服务：sudo systemctl start dailyapp
echo.

echo 4. 修复内容：
echo    ✅ 修复了CORS配置问题
echo    ✅ 修复了数据库路径配置
echo    ✅ 支持开发和生产环境
echo.

cd ..
echo 现在可以上传 server\target\harmony-daily-app-0.0.1-SNAPSHOT.jar 到云服务器
pause 