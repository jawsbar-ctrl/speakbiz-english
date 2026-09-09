@echo off
chcp 65001 > nul
title SpeakBiz Local Web Server
echo ============================================================
echo   SpeakBiz - AI 비즈니스 영어 회화 앱을 로컬 서버로 시작합니다...
echo   (마이크 음성 인식 권한이 100%% 지원됩니다)
echo ============================================================
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0server.ps1"
pause
