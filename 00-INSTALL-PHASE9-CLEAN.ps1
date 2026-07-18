param(
    [switch]$SkipSetup
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$EncodedPath = Join-Path $Root 'phase9-clean\package.b64'
$ArchivePath = Join-Path $Root 'Name-Guesser-Phase9-Clean.tar.xz'
$OutputDirectory = Join-Path $Root 'Name-Guesser-Phase9-Clean'
$ProjectDirectory = Join-Path $OutputDirectory 'name-guesser-phase9-clean-package'
$ExpectedArchiveSize = 13624
$ExpectedArchiveHash = '503c09b38c16aba14d4cb92b126edb2f6bbda10a0dbde5cf581c7e1936b66c51'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

try {
    Write-Step 'Memeriksa paket Phase 9 CLEAN'

    if (-not (Test-Path $EncodedPath -PathType Leaf)) {
        throw "Paket tidak ditemukan: $EncodedPath`nPastikan Anda mengunduh branch phase9-clean-final, bukan branch main."
    }

    $EncodedText = [System.IO.File]::ReadAllText($EncodedPath)
    $EncodedText = [System.Text.RegularExpressions.Regex]::Replace($EncodedText, '\s+', '')

    if ([string]::IsNullOrWhiteSpace($EncodedText)) {
        throw 'package.b64 kosong.'
    }

    Write-Step 'Mendekode arsip source'
    try {
        $ArchiveBytes = [Convert]::FromBase64String($EncodedText)
    }
    catch {
        throw "Base64 tidak valid. Detail: $($_.Exception.Message)"
    }

    [System.IO.File]::WriteAllBytes($ArchivePath, $ArchiveBytes)

    $ActualSize = (Get-Item $ArchivePath).Length
    if ($ActualSize -ne $ExpectedArchiveSize) {
        throw "Ukuran arsip tidak sesuai.`nDiharapkan: $ExpectedArchiveSize byte`nDidapatkan: $ActualSize byte"
    }

    Write-Step 'Memvalidasi SHA-256'
    $ActualHash = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ActualHash -ne $ExpectedArchiveHash) {
        throw "Checksum tidak cocok.`nDiharapkan: $ExpectedArchiveHash`nDidapatkan: $ActualHash"
    }
    Write-Host "Checksum valid: $ActualHash" -ForegroundColor Green

    if (-not (Get-Command tar.exe -ErrorAction SilentlyContinue)) {
        throw 'tar.exe tidak tersedia. Gunakan Windows 10/11 terbaru atau instal bsdtar/7-Zip.'
    }

    Write-Step 'Menguji integritas arsip XZ'
    & tar.exe -tJf $ArchivePath *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Uji arsip gagal dengan exit code $LASTEXITCODE."
    }
    Write-Host 'Arsip lengkap dan dapat dibaca.' -ForegroundColor Green

    Write-Step 'Mengekstrak source project'
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

    Remove-Item $ArchivePath -Force -ErrorAction SilentlyContinue
    Write-Host "Source berhasil diekstrak ke:`n$ProjectDirectory" -ForegroundColor Green

    if (-not $SkipSetup) {
        Write-Step 'Memeriksa Node.js dan npm'
        if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
            throw 'Node.js tidak ditemukan. Instal Node.js 22.12 atau lebih baru.'
        }
        if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
            throw 'npm tidak ditemukan. Instal Node.js 22.12 atau lebih baru.'
        }

        $NodeVersionText = (& node.exe --version).TrimStart('v')
        try {
            $NodeVersion = [version]$NodeVersionText
        }
        catch {
            throw "Versi Node.js tidak dapat dibaca: $NodeVersionText"
        }
        if ($NodeVersion -lt [version]'22.12.0') {
            throw "Node.js terlalu lama: $NodeVersionText. Diperlukan minimal 22.12.0."
        }
        Write-Host "Node.js valid: v$NodeVersionText" -ForegroundColor Green

        Push-Location $ProjectDirectory
        try {
            Write-Step 'Menginstal dependency'
            & npm.cmd install
            if ($LASTEXITCODE -ne 0) {
                throw "npm install gagal dengan exit code $LASTEXITCODE."
            }

            Write-Step 'Membuat dataset 194.785 kandidat'
            & npm.cmd run setup
            if ($LASTEXITCODE -ne 0) {
                throw "npm run setup gagal dengan exit code $LASTEXITCODE."
            }

            Write-Step 'Memvalidasi production build tujuh halaman'
            & npm.cmd run build
            if ($LASTEXITCODE -ne 0) {
                throw "npm run build gagal dengan exit code $LASTEXITCODE."
            }
        }
        finally {
            Pop-Location
        }
    }

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host 'PHASE 9 CLEAN BERHASIL DIPASANG' -ForegroundColor Green
    Write-Host '============================================' -ForegroundColor Green
    Write-Host "`nJalankan:" -ForegroundColor White
    Write-Host "cd `"$ProjectDirectory`"" -ForegroundColor Yellow
    Write-Host 'npm run dev' -ForegroundColor Yellow
    Write-Host "`nLalu buka: http://localhost:4173" -ForegroundColor Cyan
}
catch {
    Remove-Item $ArchivePath -Force -ErrorAction SilentlyContinue
    Write-Host "`nINSTALASI GAGAL" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
