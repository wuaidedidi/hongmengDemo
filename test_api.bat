@echo off
echo 测试大白兔用户登录...
echo.

REM 登录获取token
powershell -Command "try { $headers = @{'Content-Type' = 'application/json'}; $body = '{\"username\":\"大白兔\",\"password\":\"7758258\"}'; $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/auth/login' -Method POST -Headers $headers -Body $body -UseBasicParsing; Write-Host '登录成功'; $response.Content } catch { Write-Host '登录失败:' $_.Exception.Message }"

echo.
echo 如果登录成功，请复制上面的token，然后手动测试获取待办事项
echo 使用以下命令（将TOKEN替换为实际token）：
echo powershell -Command "$headers = @{'Authorization' = 'Bearer TOKEN'; 'Content-Type' = 'application/json'}; $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/todos' -Method GET -Headers $headers -UseBasicParsing; $response.Content"

pause 