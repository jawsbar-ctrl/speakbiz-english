[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$port = 8080
$root = $PSScriptRoot
if (-not $root) {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $root) {
    $root = "c:\Users\DAEWOO\Desktop\English"
}

# 이미 사용 중인 포트 확인
$maxRetry = 10
for ($i = 0; $i -lt $maxRetry; $i++) {
    $testPort = $port + $i
    $inUse = Get-NetTCPConnection -LocalPort $testPort -ErrorAction SilentlyContinue
    if (-not $inUse) {
        $port = $testPort
        break
    }
}

$url = "http://localhost:$port"

# MIME 타입
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
Write-Host "  =================================================" -ForegroundColor Cyan
Write-Host "     수안이네 영어공부방 - 로컬 전용 서버 가동 중" -ForegroundColor White
Write-Host "  =================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [주소] $url" -ForegroundColor Green
Write-Host "  [상태] 마이크 권한이 브라우저에 영구 저장됩니다." -ForegroundColor Yellow
Write-Host "  [종료] 학습을 마치면 이 창을 닫으세요." -ForegroundColor DarkGray
Write-Host ""

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
} catch {
    Write-Host "  [오류] 리스너 시작 실패: $_" -ForegroundColor Red
    Read-Host "  Enter를 누르면 종료됩니다."
    exit 1
}

# 브라우저 실행
Start-Process "$url/index.html"
Write-Host "  [브라우저] 자동으로 창을 열었습니다." -ForegroundColor Green
Write-Host ""

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawPath = $request.Url.LocalPath
        if ($rawPath -eq "/" -or [string]::IsNullOrWhiteSpace($rawPath)) {
            $rawPath = "/index.html"
        }

        # 안전한 URL 디코딩
        $decodedPath = [System.Uri]::UnescapeDataString($rawPath)
        $cleanRelPath = $decodedPath.TrimStart('/').Replace('/', '\')
        $filePath = Join-Path $root $cleanRelPath

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }

            $response.ContentType = $contentType
            $response.StatusCode = 200
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Permissions-Policy", "microphone=(self)")

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            
            $time = Get-Date -Format "HH:mm:ss"
            Write-Host "  [$time] 200 OK: $rawPath" -ForegroundColor DarkGray
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $errBytes.Length
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
            Write-Host "  [404] $rawPath" -ForegroundColor Yellow
        }
        $response.OutputStream.Close()
    } catch {
        # 개별 요청 오류 시에도 서버가 멈추지 않도록 보호
        if ($listener.IsListening) {
            try { $response.OutputStream.Close() } catch {}
        }
    }
}