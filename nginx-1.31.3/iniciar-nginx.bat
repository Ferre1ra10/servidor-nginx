@echo off
title Servidor NGINX

echo.
echo ========================================
echo        SERVIDOR NGINX
echo ========================================
echo.

start "" nginx.exe

timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo     SERVIDOR ESTA LIGADO!
echo ========================================
echo.
echo Tech:
echo http://localhost:8080
echo.
echo Suporte:
echo http://localhost:8081
echo.
echo ========================================
echo.
pause
