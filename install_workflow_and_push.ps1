param(
    [switch]$NoPush
)

$WorkflowPath = ".github/workflows/build-and-release.yml"

# Conteúdo do workflow (EXEMPLO — aqui você colará o workflow correto)
$Workflow = @"
name: Build Windows and publish release

on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build_and_release:
    runs-on: windows-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Build (electron-builder)
        run: npm run build:win

      - name: Zip installer
        run: |
          powershell Compress-Archive -Path dist\win-unpacked -DestinationPath build.zip -Force

      - name: Create Release
        uses: ncipollo/release-action@v1
        with:
          tag: v1.0.0-test
          artifacts: build.zip
          token: ${{ secrets.GITHUB_TOKEN }}
"@

Write-Host "📌 Gravando workflow..." -ForegroundColor Cyan
New-Item -Path $WorkflowPath -ItemType File -Force | Out-Null
Set-Content -Path $WorkflowPath -Value $Workflow -Encoding UTF8

Write-Host "✔ Workflow salvo em $WorkflowPath" -ForegroundColor Green

Write-Host "📌 Preparando commit..." -ForegroundColor Cyan
git add $WorkflowPath

git commit -m "Atualiza workflow automático" --allow-empty

if (-not $NoPush) {
    Write-Host "📤 Enviando para o GitHub..." -ForegroundColor Yellow
    git push origin main
} else {
    Write-Host "🚫 Push desabilitado (-NoPush)" -ForegroundColor DarkYellow
}

Write-Host "✅ Tudo concluído!" -ForegroundColor Green
