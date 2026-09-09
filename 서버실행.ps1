[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================
# 수안이네 영어공부방 - 로컬 서버 런처
# 더블클릭하면 localhost:8080에서 실행됩니다.
# 마이크 권한이 영구 저장되어 매번 허용할 필요가 없습니다.
# ============================================

$port = 8080
$root = $PSScriptRoot
if (-not $root) {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $root) {
    $root = "c:\Users\DAEWOO\Desktop\English"
}

# 이미 사용 중인 포트 확인 후 다른 포트 사용
$maxRetry = 5
for ($i = 0; $i -lt $maxRetry; $i++) {
    $testPort = $port + $i
    $inUse = Get-NetTCPConnection -LocalPort $testPort -ErrorAction SilentlyContinue
    if (-not $inUse) {
        $port = $testPort
        break
    }
}

$url = "http://localhost:$port"

# MIME 타입 매핑
$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
    ".ttf"  = "font/ttf"
    ".mp3"  = "audio/mpeg"
    ".mp4"  = "video/mp4"
    ".webm" = "video/webm"
    ".pdf"  = "application/pdf"
    ".txt"  = "text/plain; charset=utf-8"
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "   수안이네 영어공부방 - 로컬 서버" -ForegroundColor White
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [시작] 서버 주소: $url" -ForegroundColor Green
Write-Host "  [정보] 마이크 권한이 자동 저장됩니다." -ForegroundColor Yellow
Write-Host "  [종료] 이 창을 닫거나 Ctrl+C를 누르세요." -ForegroundColor DarkGray
Write-Host ""

# HTTP 리스너 생성
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("$url/")

try {
    $listener.Start()
} catch {
    Write-Host "  [오류] 포트 $port 리스너 시작 실패: $_" -ForegroundColor Red
    Read-Host "  Enter를 눌러 종료"
    exit 1
}

# 브라우저 자동 열기
Start-Process "$url/index.html"
Write-Host "  [브라우저] $url/index.html 실행 완료!" -ForegroundColor Green
Write-Host ""

# 요청 처리 루프
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $requestPath = $request.Url.LocalPath
        if ($requestPath -eq "/") { $requestPath = "/index.html" }

        # URL 디코딩 처리
        $decodedPath = [System.Web.HttpUtility]::UrlDecode($requestPath)
        $filePath = Join-Path $root ($decodedPath.TrimStart('/') -replace "/", "\")

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }

            $response.ContentType = $contentType
            $response.StatusCode = 200

            # CORS 및 권한 정책 헤더 (마이크 허용)
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Permissions-Policy", "microphone=(self)")

            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $fileBytes.Length
            $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
        } else {
            $response.StatusCode = 404
            $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $requestPath")
            $response.ContentLength64 = $errorMsg.Length
            $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
        }

        $response.OutputStream.Close()
    }
} catch {
    # 정상 종료
} finally {
    $listener.Stop()
    $listener.Close()
    Write-Host ""
    Write-Host "  [종료] 서버가 정상 종료되었습니다." -ForegroundColor Cyan
}