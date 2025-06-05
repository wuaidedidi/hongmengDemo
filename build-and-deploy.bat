@echo off
echo ========================================
echo    DailyApp 生产环境构建和部署脚本
echo ========================================

set JAVA_HOME=%JAVA_HOME%
set PATH=%JAVA_HOME%\bin;%PATH%

echo 正在构建后端应用...
cd serverDemo
call mvn clean package -DskipTests=true -Pprod
if %ERRORLEVEL% neq 0 (
    echo 后端构建失败！
    pause
    exit /b 1
)

echo 后端构建成功！
echo 生成的JAR文件: target\serverDemo-1.0.0.jar

echo.
echo ========================================
echo 部署说明:
echo 1. 将 target\serverDemo-1.0.0.jar 上传到服务器
echo 2. 在服务器上运行以下命令:
echo    java -jar -Dspring.profiles.active=prod serverDemo-1.0.0.jar
echo.
echo 3. 或者使用 nohup 在后台运行:
echo    nohup java -jar -Dspring.profiles.active=prod serverDemo-1.0.0.jar ^> dailyapp.log 2^>^&1 ^&
echo ========================================

cd ..

echo.
echo 正在配置前端生产环境...

REM 复制生产环境配置文件
copy "entry\src\main\resources\rawfile\config-production.json" "entry\src\main\resources\rawfile\config.json"

echo 前端已配置为生产环境模式
echo.
echo ========================================
echo 前端构建说明:
echo 1. 在DevEco Studio中打开项目
echo 2. 选择 Build -> Build Hap(s)/APP(s)
echo 3. 或者选择 Build -> Generate Signed Bundle/APK
echo 4. 构建完成后安装到设备
echo ========================================

pause 