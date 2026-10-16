[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ---------- 1. 询问目标目录 ----------
$inputRoot = Read-Host "请输入要处理的目录路径（默认：当前目录 $PSScriptRoot）"
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

# ---------- 2. 询问原后缀名 ----------
$oldExt = Read-Host "请输入要修改的原后缀名（不带点，如 txt）"
if ([string]::IsNullOrWhiteSpace($oldExt)) {
    Write-Host "原后缀名不能为空" -ForegroundColor Red
    exit
}
$oldExt = $oldExt.TrimStart(".")

# ---------- 3. 询问新后缀名 ----------
$newExt = Read-Host "请输入要修改为的新后缀名（不带点，如 md）"
if ([string]::IsNullOrWhiteSpace($newExt)) {
    Write-Host "新后缀名不能为空" -ForegroundColor Red
    exit
}
$newExt = $newExt.TrimStart(".")

# ---------- 4. 是否递归子目录 ----------
$recurseInput = Read-Host "是否包含子目录？(y/N，直接回车 = 不包含)"
$recurse = ($recurseInput -eq "y" -or $recurseInput -eq "Y")

# ---------- 5. 查找匹配文件 ----------
if ($recurse) {
    $files = Get-ChildItem -LiteralPath $root -File -Recurse -Filter "*.$oldExt"
} else {
    $files = Get-ChildItem -LiteralPath $root -File -Filter "*.$oldExt"
}

if ($files.Count -eq 0) {
    Write-Host "未找到任何 .$oldExt 文件" -ForegroundColor Yellow
    Write-Host "按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey()
    exit
}

# ---------- 6. 预览 + 二次确认 ----------
Write-Host ""
Write-Host "共找到 $($files.Count) 个 .$oldExt 文件，预览前 10 个改名结果："
$files | Select-Object -First 10 | ForEach-Object {
    $newName = [System.IO.Path]::ChangeExtension($_.Name, $newExt)
    Write-Host "  $($_.Name)  ->  $newName" -ForegroundColor Cyan
}
Write-Host ""

$confirm = Read-Host "确认要将以上 $($files.Count) 个文件后缀改为 .$newExt 吗？(y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "已取消操作" -ForegroundColor Yellow
    exit
}

# ---------- 7. 执行改名 ----------
$successCount = 0
$failCount = 0

foreach ($file in $files) {
    $newName = [System.IO.Path]::ChangeExtension($file.Name, $newExt)
    $newPath = Join-Path $file.DirectoryName $newName

    if (Test-Path -LiteralPath $newPath) {
        Write-Host "跳过（目标已存在）: $($file.FullName)" -ForegroundColor Red
        $failCount++
        continue
    }

    try {
        Rename-Item -LiteralPath $file.FullName -NewName $newName -ErrorAction Stop
        Write-Host "已修改: $($file.Name) -> $newName" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "修改失败: $($file.FullName) - $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "完成：成功 $successCount 个，失败/跳过 $failCount 个" -ForegroundColor Yellow
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey()