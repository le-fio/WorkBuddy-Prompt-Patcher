@echo off
chcp 65001 >nul 2>&1
title WorkBuddy Prompt Patcher - Web UI
cd /d "%~dp0"

echo ==================================================
echo    WorkBuddy Prompt Patcher - Web UI
echo ==================================================
echo.
echo    正在启动 Web 服务器...
echo    浏览器将自动打开 http://127.0.0.1:7474
echo    关闭本窗口即可停止服务
echo ==================================================
echo.

:: 延迟2秒后打开浏览器
start "" cmd /c "ping -n 3 127.0.0.1 >nul && start http://127.0.0.1:7474"

:: 启动服务器（前台运行，关闭窗口即停止）
node server.js

pause