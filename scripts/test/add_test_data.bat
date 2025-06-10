@echo off
echo 为大白兔用户添加测试数据...
echo.

echo 1. 登录大白兔用户...
powershell -Command "try { $loginData = @{ username = '大白兔'; password = '7758258' } | ConvertTo-Json -Compress; $loginResponse = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method POST -ContentType 'application/json' -Body $loginData; $token = $loginResponse.token; Write-Host '登录成功，Token:' $token; Write-Host ''; Write-Host '2. 添加测试待办事项...'; $todoData1 = @{ title = '学习HarmonyOS开发'; description = '完成第一个应用开发'; priority = 'HIGH' } | ConvertTo-Json -Compress; $todoData2 = @{ title = '写技术博客'; description = '分享开发经验'; priority = 'MEDIUM' } | ConvertTo-Json -Compress; $todoData3 = @{ title = '锻炼身体'; description = '每天跑步30分钟'; priority = 'LOW' } | ConvertTo-Json -Compress; $headers = @{ 'Authorization' = 'Bearer ' + $token; 'Content-Type' = 'application/json' }; $todo1 = Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todoData1; $todo2 = Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todoData2; $todo3 = Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todoData3; Write-Host '已添加3个测试待办事项'; Write-Host ''; Write-Host '3. 获取所有待办事项验证...'; $todos = Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method GET -Headers $headers; Write-Host '当前待办事项数量:' $todos.Count; foreach($todo in $todos) { Write-Host '- ID:' $todo.id 'Title:' $todo.title 'Completed:' $todo.completed } } catch { Write-Host '错误:' $_.Exception.Message; Write-Host '详细错误:' $_.Exception.Response.StatusCode }"

echo.
echo 测试数据添加完成！
pause 