# 测试远程服务器登录
Write-Host "测试远程服务器登录..." -ForegroundColor Green

$baseUrl = "http://8.148.20.194:8080/api"

# 1. 测试健康检查
Write-Host "1. 测试健康检查..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
    Write-Host "✅ 健康检查成功: $healthResponse" -ForegroundColor Green
} catch {
    Write-Host "❌ 健康检查失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. 尝试登录
Write-Host "2. 尝试用户登录..." -ForegroundColor Yellow
$loginBody = @{
    "username" = "大白兔"
    "password" = "7758258"
} | ConvertTo-Json -Compress

Write-Host "请求URL: $baseUrl/auth/login" -ForegroundColor Cyan
Write-Host "请求Body: $loginBody" -ForegroundColor Cyan

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ 登录成功!" -ForegroundColor Green
    Write-Host "Token: $($loginResponse.token.Substring(0,20))..." -ForegroundColor Green
    Write-Host "用户名: $($loginResponse.username)" -ForegroundColor Green
} catch {
    Write-Host "❌ 登录失败: $($_.Exception.Message)" -ForegroundColor Red
    
    # 尝试获取详细错误信息
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "状态码: $statusCode" -ForegroundColor Red
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "错误响应: $errorBody" -ForegroundColor Red
        } catch {
            Write-Host "无法读取错误响应" -ForegroundColor Red
        }
    }
}

# 3. 尝试注册新用户（测试服务器是否正常）
Write-Host "3. 尝试注册新用户..." -ForegroundColor Yellow
$testUsername = "测试用户$(Get-Date -Format 'HHmmss')"
$registerBody = @{
    "username" = $testUsername
    "password" = "123456"
} | ConvertTo-Json -Compress

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✅ 注册成功!" -ForegroundColor Green
    Write-Host "新用户: $($registerResponse.username)" -ForegroundColor Green
    
    # 尝试用新用户登录
    Write-Host "4. 测试新用户登录..." -ForegroundColor Yellow
    $newLoginBody = @{
        "username" = $testUsername
        "password" = "123456"
    } | ConvertTo-Json -Compress
    
    $newLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $newLoginBody -ContentType "application/json"
    Write-Host "✅ 新用户登录成功!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ 注册失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "测试完成!" -ForegroundColor Green 