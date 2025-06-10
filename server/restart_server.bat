@echo off
echo 正在重新编译和启动服务器...
echo.

echo 1. 停止现有服务器进程...
taskkill /f /im java.exe 2>nul

echo 2. 清理和编译项目...
call mvn clean package -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo 编译失败！
    pause
    exit /b 1
)

echo 3. 启动服务器...
echo 服务器将在 http://localhost:8080/api 启动
echo 按Ctrl+C可以停止服务器
echo.
java -jar target\harmony-daily-app-0.0.1-SNAPSHOT.jar 