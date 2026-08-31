@echo off
title WorkBuddy Prompt Patcher - Web UI
cd /d "%~dp0"

echo ==================================================
echo    WorkBuddy Prompt Patcher - Web UI
echo ==================================================
echo.
echo    [1/3] 正在启动 Web 服务器...
echo    关闭本窗口即可停止服务并释放端口
echo ==================================================
echo.

rem 延迟 2 秒后打开浏览器（在后台异步执行，不阻塞 node 启动）
start /b cmd /c "timeout /t 3 /nobreak >nul & start http://localhost:7474"

echo    [2/3] 服务启动中，浏览器将自动打开...
echo    [3/3] 服务运行中。关闭本窗口即可停止服务。
echo ==================================================
echo.

rem 前台运行 node 服务：关闭本窗口或按 Ctrl+C 即可终止服务并释放端口
node server.js