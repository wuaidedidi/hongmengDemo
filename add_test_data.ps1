# 添加测试数据脚本
Write-Host "开始添加测试数据..." -ForegroundColor Green

# 1. 登录获取Token
Write-Host "1. 登录获取Token..." -ForegroundColor Yellow
$loginBody = @{
    "username" = "大白兔"
    "password" = "7758258"
} | ConvertTo-Json -Compress

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ 登录成功，Token: $($token.Substring(0,20))..." -ForegroundColor Green
} catch {
    Write-Host "❌ 登录失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. 添加测试待办事项
Write-Host "2. 添加测试待办事项..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$testTodos = @(
    @{
        "title" = "学习HarmonyOS开发"
        "description" = "完成第一个应用开发"
        "type" = "学习"
        "duration" = 120
        "isImportant" = $true
        "isUrgent" = $false
    },
    @{
        "title" = "写技术博客"
        "description" = "分享开发经验"
        "type" = "工作"
        "duration" = 60
        "isImportant" = $false
        "isUrgent" = $false
    },
    @{
        "title" = "锻炼身体"
        "description" = "每天跑步30分钟"
        "type" = "健康"
        "duration" = 30
        "isImportant" = $true
        "isUrgent" = $true
    }
)

foreach ($todo in $testTodos) {
    try {
        $todoJson = $todo | ConvertTo-Json -Compress
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/todos" -Method POST -Body $todoJson -Headers $headers
        Write-Host "✅ 已添加: $($response.title) (ID: $($response.id))" -ForegroundColor Green
    } catch {
        Write-Host "❌ 添加失败: $($todo.title) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3. 验证数据
Write-Host "3. 验证添加的数据..." -ForegroundColor Yellow
try {
    $todos = Invoke-RestMethod -Uri "http://localhost:8080/api/todos" -Method GET -Headers $headers
    Write-Host "✅ 总共有 $($todos.Count) 个待办事项" -ForegroundColor Green
    foreach ($todo in $todos) {
        Write-Host "  - $($todo.title) (类型: $($todo.type), 时长: $($todo.duration)分钟)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ 获取待办事项失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "脚本执行完成!" -ForegroundColor Green 