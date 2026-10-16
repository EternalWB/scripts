[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ---------- 基本配置 ----------
$7z  = "C:\Program Files\7-Zip\7z.exe"
$rar = "C:\Program Files\WinRAR\Rar.exe"   # 如果没装 WinRAR，选 rar 格式时会报错

# ---------- 1. 询问压缩目录 ----------
$inputRoot = Read-Host "请输入要压缩的目录路径（直接回车 = 当前目录 $PSScriptRoot）"
if ([string]::IsNullOrWhiteSpace($inputRoot)) {
    $root = $PSScriptRoot
} else {
    $root = $inputRoot
}

if (-not (Test-Path -LiteralPath $root)) {
    Write-Host "目录不存在: $root" -ForegroundColor Red
    Write-Host "按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey()
    exit
}

# ---------- 2. 询问是否删除原文件夹 ----------
$delInput = Read-Host "压缩后是否删除原文件夹？(y/N，直接回车 = 不删除)"
$deleteAfter = ($delInput -eq "y" -or $delInput -eq "Y")

# ---------- 3. 询问压缩格式 ----------
$formatInput = Read-Host "请选择压缩格式 zip / 7z / rar（直接回车 = 7z）"
if ([string]::IsNullOrWhiteSpace($formatInput)) {
    $format = "7z"
} else {
    $format = $formatInput.ToLower()
}

if ($format -notin @("zip", "7z", "rar")) {
    Write-Host "不支持的格式: $format" -ForegroundColor Red
    exit
}

if ($format -eq "rar" -and -not (Test-Path -LiteralPath $rar)) {
    Write-Host "未找到 WinRAR (Rar.exe)，无法创建 rar 格式，请安装 WinRAR 或改用 zip/7z" -ForegroundColor Red
    exit
}

# ---------- 4. 开始批量压缩 ----------
Write-Host ""
Write-Host "压缩目录: $root"
Write-Host "压缩格式: $format"
Write-Host "压缩后删除原文件夹: $deleteAfter"
Write-Host ""

Get-ChildItem -Path $root -Directory | ForEach-Object {
    $folder  = $_.FullName
    $archive = "$folder.$format"

    switch ($format) {
        "7z" {
            & $7z a -t7z $archive "$folder\*" -mx=5
            $success = ($LASTEXITCODE -eq 0)
        }
        "zip" {
            & $7z a -tzip $archive "$folder\*" -mx=5
            $success = ($LASTEXITCODE -eq 0)
        }
        "rar" {
            & $rar a -r $archive "$folder\*"
            $success = ($LASTEXITCODE -eq 0)
        }
    }

    if ($success -and (Test-Path -LiteralPath $archive)) {
        if ($deleteAfter) {
            Remove-Item -LiteralPath $folder -Recurse -Force
            Write-Host "已压缩并删除: $folder" -ForegroundColor Green
        } else {
            Write-Host "已压缩（保留原文件夹）: $folder" -ForegroundColor Green
        }
    } else {
        Write-Host "压缩失败，未删除: $folder" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "全部完成，按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey()