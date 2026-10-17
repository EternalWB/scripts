@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ================================
echo   文件夹 → CBZ 批量转换工具
echo ================================
echo.

set "SOURCE_DIR=%~dp0newfolder"

:: 如果 newfolder 不在脚本同目录，可以手动修改上面的路径
:: 例如: set "SOURCE_DIR=D:\漫画\newfolder"

if not exist "%SOURCE_DIR%" (
    echo [错误] 找不到目录: %SOURCE_DIR%
    echo 请确认 newfolder 文件夹与本脚本在同一目录，或手动修改脚本内的路径。
    pause
    exit /b 1
)

set COUNT=0
set SKIP=0

for /d %%F in ("%SOURCE_DIR%\*") do (
    set "FOLDER=%%F"
    set "NAME=%%~nxF"
    set "OUTPUT=%SOURCE_DIR%\!NAME!.cbz"

    :: 如果 CBZ 已存在则跳过
    if exist "!OUTPUT!" (
        echo [跳过] !NAME!.cbz 已存在
        set /a SKIP+=1
    ) else (
        echo [处理] !NAME!
        powershell -NoProfile -Command ^
            "Compress-Archive -Path '!FOLDER!\*' -DestinationPath '!OUTPUT!' -CompressionLevel Optimal"
        if !errorlevel! == 0 (
            echo        √ 生成: !NAME!.cbz
            set /a COUNT+=1
        ) else (
            echo        × 失败: !NAME!
        )
    )
)

echo.
echo ================================
echo   完成！成功 %COUNT% 个，跳过 %SKIP% 个
echo ================================
pause
