param(
    [switch]$Setup
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ChunkDirectory = Join-Path $Root 'phase9-bootstrap'
$ArchivePath = Join-Path $Root 'Name-Guesser-Phase9-Source.tar.xz'
$OutputDirectory = Join-Path $Root 'Name-Guesser-Phase9'
$ProjectDirectory = Join-Path $OutputDirectory 'name-guesser-phase9'
$ExpectedHash = 'bd8572ae5f7b6987b804e9cb68ba377cc1ce17f9d580d699b44a1390938d11d4'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Find-Python {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        return @('py')
    }

    if (Get-Command python -ErrorAction SilentlyContinue) {
        return @('python')
    }

    throw 'Python tidak ditemukan. Instal Python 3.10 atau lebih baru, lalu jalankan kembali dengan parameter -Setup.'
}

Write-Step 'Memeriksa lima bagian arsip'
if (-not (Test-Path $ChunkDirectory -PathType Container)) {
    throw "Folder tidak ditemukan: $ChunkDirectory"
}

$Parts = @(Get-ChildItem -Path $ChunkDirectory -Filter 'part*.b64' -File | Sort-Object Name)
if ($Parts.Count -ne 5) {
    throw "Jumlah bagian tidak sesuai. Ditemukan $($Parts.Count), seharusnya 5. Unduh ulang ZIP repository GitHub."
}

$ExpectedNames = 0..4 | ForEach-Object { 'part{0:D2}.b64' -f $_ }
for ($Index = 0; $Index -lt $ExpectedNames.Count; $Index++) {
    if ($Parts[$Index].Name -ne $ExpectedNames[$Index]) {
        throw "Bagian arsip tidak lengkap atau urutannya salah. Diharapkan $($ExpectedNames[$Index]), ditemukan $($Parts[$Index].Name)."
    }
}

Write-Step 'Menggabungkan dan mendekode arsip'
$Builder = [System.Text.StringBuilder]::new()
foreach ($Part in $Parts) {
    $Text = [System.IO.File]::ReadAllText($Part.FullName).Trim()
    [void]$Builder.Append($Text)
}

try {
    $ArchiveBytes = [Convert]::FromBase64String($Builder.ToString())
} catch {
    throw "Data Base64 tidak valid. Unduh ulang repository. Detail: $($_.Exception.Message)"
}

[System.IO.File]::WriteAllBytes($ArchivePath, $ArchiveBytes)

Write-Step 'Memvalidasi checksum SHA-256'
$ActualHash = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($ActualHash -ne $ExpectedHash) {
    Remove-Item $ArchivePath -Force -ErrorAction SilentlyContinue
    throw "Checksum tidak cocok.`nDiharapkan: $ExpectedHash`nDidapatkan: $ActualHash`nUnduh ulang repository GitHub."
}
Write-Host "Checksum valid: $ActualHash" -ForegroundColor Green

Write-Step 'Mengekstrak source project'
if (-not (Get-Command tar.exe -ErrorAction SilentlyContinue)) {
    throw 'Perintah tar.exe tidak tersedia. Gunakan Windows 10/11 terbaru atau instal bsdtar/7-Zip.'
}

if (Test-Path $OutputDirectory) {
    Remove-Item $OutputDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
& tar.exe -xJf $ArchivePath -C $OutputDirectory
if ($LASTEXITCODE -ne 0) {
    throw "Ekstraksi gagal dengan exit code $LASTEXITCODE."
}

if (-not (Test-Path (Join-Path $ProjectDirectory 'package.json') -PathType Leaf)) {
    throw "Project hasil ekstraksi tidak lengkap: $ProjectDirectory"
}

Write-Host "`nSource berhasil diekstrak ke:" -ForegroundColor Green
Write-Host $ProjectDirectory -ForegroundColor White

if ($Setup) {
    Write-Step 'Menyiapkan dependency Node.js'
    if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
        throw 'npm tidak ditemukan. Instal Node.js 22.12 atau lebih baru.'
    }

    Push-Location $ProjectDirectory
    try {
        & npm.cmd install
        if ($LASTEXITCODE -ne 0) { throw "npm install gagal dengan exit code $LASTEXITCODE." }

        & npm.cmd run setup:env
        if ($LASTEXITCODE -ne 0) { throw "setup:env gagal dengan exit code $LASTEXITCODE." }

        Write-Step 'Menyiapkan Python dan membuat dataset'
        $Python = Find-Python
        & $Python[0] -m pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) { throw "Instalasi dependency Python gagal dengan exit code $LASTEXITCODE." }

        & $Python[0] scripts/generate_dataset.py
        if ($LASTEXITCODE -ne 0) { throw "Pembuatan dataset gagal dengan exit code $LASTEXITCODE." }

        & $Python[0] scripts/audit_dataset_quality.py
        if ($LASTEXITCODE -ne 0) { throw "Audit dataset gagal dengan exit code $LASTEXITCODE." }
    } finally {
        Pop-Location
    }

    Write-Host "`nSetup selesai. Jalankan:" -ForegroundColor Green
    Write-Host "cd `"$ProjectDirectory`""
    Write-Host 'npm run dev'
    Write-Host 'Lalu buka http://localhost:4173'
} else {
    Write-Host "`nUntuk memasang dependency dan membuat dataset secara otomatis:" -ForegroundColor Yellow
    Write-Host '.\INSTALL-PHASE9.ps1 -Setup'
    Write-Host "`nAtau jalankan manual:" -ForegroundColor Yellow
    Write-Host "cd `"$ProjectDirectory`""
    Write-Host 'npm install'
    Write-Host 'npm run setup:env'
    Write-Host 'py -m pip install -r requirements.txt'
    Write-Host 'py scripts\generate_dataset.py'
    Write-Host 'py scripts\audit_dataset_quality.py'
    Write-Host 'npm run dev'
}
