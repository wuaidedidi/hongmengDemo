@echo off
echo 测试后端API连接...
echo.

echo 1. 测试服务器是否运行...
curl -s http://localhost:8080/api/auth/login -w "HTTP_STATUS: %%{http_code}\n" -o nul

echo.
echo 2. 尝试登录大白兔用户...
echo 请手动复制以下命令到另一个命令行窗口执行：
echo.
echo curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"大白兔\",\"password\":\"7758258\"}"
echo.
echo 如果登录成功，会返回token，然后用token测试获取待办事项：
echo curl -X GET http://localhost:8080/api/todos -H "Authorization: Bearer YOUR_TOKEN"

echo.
echo 或者直接访问H2数据库控制台查看数据：
echo http://localhost:8080/api/h2-console
echo JDBC URL: jdbc:h2:file:./data/dailydb
echo 用户名: sa
echo 密码: (空)

pause 