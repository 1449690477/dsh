# dsh 破限者 - 安装脚本（Windows / PowerShell）
# 用法:
#   .\install.ps1            安装技能包 + 常驻层
#   .\install.ps1 -SkillOnly 只安装技能包
#   .\install.ps1 -Uninstall 卸载

param(
    [switch]$SkillOnly,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $HOME '.dsh' }
$SkillsDir = Join-Path $DshHome 'skills'
$SkillSrc = Join-Path $RepoRoot 'unrestricted-executor'
$SkillDst = Join-Path $SkillsDir 'unrestricted-executor'
$AgentsSrc = Join-Path $RepoRoot 'AGENTS.md'
$AgentsDst = Join-Path $DshHome 'AGENTS.md'

if ($Uninstall) {
    if (Test-Path -LiteralPath $SkillDst) {
        Remove-Item -LiteralPath $SkillDst -Recurse -Force
        Write-Host "[OK] 已删除技能包: $SkillDst"
    }
    if (-not $SkillOnly -and (Test-Path -LiteralPath $AgentsDst)) {
        Remove-Item -LiteralPath $AgentsDst -Force
        Write-Host "[OK] 已删除常驻层: $AgentsDst"
    }
    Write-Host "卸载完成。"
    exit 0
}

if (-not (Test-Path -LiteralPath $SkillSrc)) { throw "找不到技能包目录: $SkillSrc" }
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
Copy-Item -LiteralPath $SkillSrc -Destination $SkillDst -Recurse -Force
Write-Host "[OK] 技能包已安装: $SkillDst"

if (-not $SkillOnly) {
    if (-not (Test-Path -LiteralPath $AgentsSrc)) { throw "找不到常驻层文件: $AgentsSrc" }
    Copy-Item -LiteralPath $AgentsSrc -Destination $AgentsDst -Force
    Write-Host "[OK] 常驻层已安装: $AgentsDst"
}
else {
    Write-Host "[跳过] 常驻层未安装（-SkillOnly）"
}

Write-Host ""
Write-Host "安装完成！新会话将自动生效；技能目录中可找到 unrestricted-executor。"