# 测试API脚本
$headers = @{
    'Content-Type' = 'application/json'
}

Write-Host "=== 测试健康检查 ==="
try {
    $response = Invoke-RestMethod -Uri "http://8.148.20.194:8080/api/health" -Method GET
    Write-Host "健康检查成功: $response"
} catch {
    Write-Host "健康检查失败: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== 测试注册新用户 ==="
$registerBody = @{
    username = "测试用户$(Get-Date -Format 'mmss')"
    password = "123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://8.148.20.194:8080/api/auth/register" -Method POST -Headers $headers -Body $registerBody
    Write-Host "注册成功: $($response | ConvertTo-Json)"
} catch {
    Write-Host "注册失败: $($_.Exception.Message)"
    Write-Host "响应内容: $($_.Exception.Response)"
}

Write-Host ""
Write-Host "=== 测试大白兔用户登录 ==="
$loginBody = @{
    username = "大白兔"
    password = "7758258"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://8.148.20.194:8080/api/auth/login" -Method POST -Headers $headers -Body $loginBody
    Write-Host "登录成功: $($response | ConvertTo-Json)"
} catch {
    Write-Host "登录失败: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "错误响应: $responseBody"
    }
} 