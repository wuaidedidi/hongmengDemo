# Add test data script (English version)
Write-Host "Starting to add test data..." -ForegroundColor Green

# 1. Login to get token
Write-Host "1. Login to get token..." -ForegroundColor Yellow
$loginBody = @{
    "username" = "大白兔"
    "password" = "7758258"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "Login successful, Token: $($token.Substring(0,20))..." -ForegroundColor Green
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}

# 2. Add test todos
Write-Host "2. Adding test todos..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$testTodos = @(
    @{
        "title" = "Learn HarmonyOS Development"
        "description" = "Complete first app development"
        "type" = "Learning"
        "duration" = 120
        "isImportant" = $true
        "isUrgent" = $false
    },
    @{
        "title" = "Write Tech Blog"
        "description" = "Share development experience"
        "type" = "Work"
        "duration" = 60
        "isImportant" = $false
        "isUrgent" = $false
    },
    @{
        "title" = "Exercise"
        "description" = "Run 30 minutes daily"
        "type" = "Health"
        "duration" = 30
        "isImportant" = $true
        "isUrgent" = $true
    }
)

foreach ($todo in $testTodos) {
    try {
        $todoJson = $todo | ConvertTo-Json
        Write-Host "Adding: $($todo.title)" -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/todos" -Method POST -Body $todoJson -Headers $headers
        Write-Host "Successfully added: $($response.title) (ID: $($response.id))" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add: $($todo.title) - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Error response: $responseBody" -ForegroundColor Red
        }
    }
}

# 3. Verify data
Write-Host "3. Verifying added data..." -ForegroundColor Yellow
try {
    $todos = Invoke-RestMethod -Uri "http://localhost:8080/api/todos" -Method GET -Headers $headers
    Write-Host "Total todos: $($todos.Count)" -ForegroundColor Green
    foreach ($todo in $todos) {
        Write-Host "  - $($todo.title) (Type: $($todo.type), Duration: $($todo.duration) min)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Failed to get todos: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script completed!" -ForegroundColor Green 