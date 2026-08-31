@echo off
title WorkBuddy Prompt Patcher - Web UI
cd /d "%~dp0"

echo ==================================================
echo    WorkBuddy Prompt Patcher - Web UI
echo ==================================================
echo.
echo    [1/3] 正在启动 Web 服务器...
echo    关闭本窗口即可停止服务
echo ==================================================
echo.

start "WorkBuddy-Prompt-Patcher-Server" /min node server.js

rem 轮询等待服务端口就绪（最多 20 秒）
set /a tries=0
:WAIT_LOOP
set /a tries+=1
timeout /t 1 /nobreak >nul
powershell -NoProfile -Command "=New-Object Net.Sockets.TcpClient; try{.Connect('127.0.0.1',7474);'OK';.Close()}catch{'NO'}" > "%TEMP%\wbp_port_check.txt"
set /p PORT_STATE=<"%TEMP%\wbp_port_check.txt"
if "%PORT_STATE%"=="OK" goto READY
if %tries% GEQ 20 goto TIMEOUT
goto WAIT_LOOP

:READY
echo    [2/3] 服务已就绪，正在打开浏览器...
start http://localhost:7474
echo    [3/3] 启动完成。
goto DONE

:TIMEOUT
echo    [3/3] 服务在 20 秒内未就绪，请检查 node 是否安装、7474 端口是否被占用。
echo    可尝试手动运行: node server.js

:DONE
pause