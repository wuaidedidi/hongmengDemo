@echo off
echo Adding test data for user: 大白兔
echo.

echo Step 1: Login user...
powershell -Command ^
  "$loginData = '{\"username\":\"大白兔\",\"password\":\"7758258\"}'; ^
   try { ^
     $response = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method POST -ContentType 'application/json' -Body $loginData; ^
     $token = $response.token; ^
     Write-Host 'Login successful. Token:' $token.Substring(0,20) '...'; ^
     ^
     Write-Host 'Step 2: Adding test todos...'; ^
     $headers = @{'Authorization' = 'Bearer ' + $token; 'Content-Type' = 'application/json'}; ^
     ^
     $todo1 = '{\"title\":\"Learn HarmonyOS\",\"description\":\"Complete first app\",\"priority\":\"HIGH\"}'; ^
     $todo2 = '{\"title\":\"Write Blog\",\"description\":\"Share development experience\",\"priority\":\"MEDIUM\"}'; ^
     $todo3 = '{\"title\":\"Exercise\",\"description\":\"Run 30min daily\",\"priority\":\"LOW\"}'; ^
     ^
     Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todo1; ^
     Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todo2; ^
     Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method POST -Headers $headers -Body $todo3; ^
     ^
     Write-Host 'Added 3 test todos successfully!'; ^
     ^
     Write-Host 'Step 3: Verifying todos...'; ^
     $todos = Invoke-RestMethod -Uri 'http://localhost:8080/api/todos' -Method GET -Headers $headers; ^
     Write-Host 'Total todos:' $todos.Count; ^
     foreach($todo in $todos) { Write-Host '- ID:' $todo.id 'Title:' $todo.title } ^
   } catch { ^
     Write-Host 'Error:' $_.Exception.Message ^
   }"

echo.
echo Test data setup completed!
pause 