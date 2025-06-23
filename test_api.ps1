# 测试远程API连接和功能
$baseUrl = "http://8.148.20.194:8080/api"

Write-Host "=== 开始API测试 ===" -ForegroundColor Green

# 1. 测试健康检查
Write-Host "1. 测试健康检查..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
    Write-Host "✅ 健康检查成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 健康检查失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. 测试用户登录
Write-Host "2. 测试用户登录..." -ForegroundColor Yellow
$headers = @{
    'Content-Type' = 'application/json'
}

$loginBody = @{
    username = "大白兔"
    password = "7758258"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Headers $headers -Body $loginBody
    $token = $response.token
    Write-Host "✅ 登录成功，用户: $($response.username)" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Cyan
} catch {
    Write-Host "❌ 登录失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 添加Authorization头
$authHeaders = @{
    'Content-Type' = 'application/json'
    'Authorization' = "Bearer $token"
}

# 3. 测试获取待办事项
Write-Host "3. 测试获取待办事项..." -ForegroundColor Yellow
try {
    $todos = Invoke-RestMethod -Uri "$baseUrl/todos" -Method GET -Headers $authHeaders
    Write-Host "✅ 获取待办事项成功，数量: $($todos.Length)" -ForegroundColor Green
} catch {
    Write-Host "❌ 获取待办事项失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "响应内容: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 4. 测试创建待办事项
Write-Host "4. 测试创建待办事项..." -ForegroundColor Yellow
$todoData = @{
    title = "测试待办事项"
    description = "这是一个测试待办事项"
    type = "WORK"
    duration = 30
    isImportant = $true
    isUrgent = $false
} | ConvertTo-Json

try {
    $newTodo = Invoke-RestMethod -Uri "$baseUrl/todos" -Method POST -Headers $authHeaders -Body $todoData
    Write-Host "✅ 创建待办事项成功，ID: $($newTodo.id)" -ForegroundColor Green
    $createdTodoId = $newTodo.id
} catch {
    Write-Host "❌ 创建待办事项失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "响应状态码: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "响应内容: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 5. 测试获取待办合集
Write-Host "5. 测试获取待办合集..." -ForegroundColor Yellow
try {
    $collections = Invoke-RestMethod -Uri "$baseUrl/todo-collections" -Method GET -Headers $authHeaders
    Write-Host "✅ 获取待办合集成功，数量: $($collections.Length)" -ForegroundColor Green
} catch {
    Write-Host "❌ 获取待办合集失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "响应内容: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 6. 测试创建待办合集
Write-Host "6. 测试创建待办合集..." -ForegroundColor Yellow
$collectionData = @{
    title = "测试待办合集"
    description = "这是一个测试待办合集"
} | ConvertTo-Json

try {
    $newCollection = Invoke-RestMethod -Uri "$baseUrl/todo-collections" -Method POST -Headers $authHeaders -Body $collectionData
    Write-Host "✅ 创建待办合集成功，ID: $($newCollection.id)" -ForegroundColor Green
    $createdCollectionId = $newCollection.id
} catch {
    Write-Host "❌ 创建待办合集失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "响应状态码: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "响应内容: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 7. 测试添加子待办到合集
if ($createdCollectionId) {
    Write-Host "7. 测试添加子待办到合集..." -ForegroundColor Yellow
    $itemData = @{
        title = "测试子待办"
        description = "这是一个测试子待办"
        durationMinutes = 25
        orderIndex = 0
    } | ConvertTo-Json

    try {
        $newItem = Invoke-RestMethod -Uri "$baseUrl/todo-collections/$createdCollectionId/items" -Method POST -Headers $authHeaders -Body $itemData
        Write-Host "✅ 添加子待办成功，ID: $($newItem.id)" -ForegroundColor Green
    } catch {
        Write-Host "❌ 添加子待办失败: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "响应状态码: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "响应内容: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host "=== API测试完成 ===" -ForegroundColor Green 