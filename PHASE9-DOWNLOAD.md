# Name Guesser Phase 9

Project Phase 9 disimpan sebagai lima bagian Base64 agar dapat dipindahkan melalui konektor GitHub tanpa tautan `sandbox:`.

## Unduh

Unduh seluruh repository sebagai ZIP:

https://github.com/OnlyRezxx/claude/archive/refs/heads/main.zip

Ekstrak `claude-main.zip`, lalu masuk ke folder `claude-main`.

## Instalasi otomatis di Windows

Klik dua kali:

```text
INSTALL-PHASE9.cmd
```

Installer akan:

1. Menggabungkan lima bagian di `phase9-bootstrap/`.
2. Mendekode arsip source.
3. Memvalidasi SHA-256.
4. Mengekstrak project.
5. Menjalankan `npm install` dan `npm run setup:env`.
6. Memasang dependency Python.
7. Membuat ulang dataset nama.
8. Menjalankan audit kualitas dataset.

Setelah selesai, buka PowerShell di project dan jalankan:

```powershell
cd .\Name-Guesser-Phase9\name-guesser-phase9
npm run dev
```

Kemudian buka:

```text
http://localhost:4173
```

## Instalasi bertahap

Hanya rekonstruksi dan ekstrak source:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\INSTALL-PHASE9.ps1
```

Rekonstruksi sekaligus memasang dependency dan membuat dataset:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\INSTALL-PHASE9.ps1 -Setup
```

## Persyaratan

- Windows 10 atau Windows 11 dengan `tar.exe`.
- Node.js 22.12 atau lebih baru.
- Python 3.10 atau lebih baru.
- Koneksi internet untuk dependency npm dan Python.

## Integritas arsip

SHA-256 arsip hasil penggabungan:

```text
bd8572ae5f7b6987b804e9cb68ba377cc1ce17f9d580d699b44a1390938d11d4
```

Installer menolak ekstraksi apabila checksum tidak cocok.

## Catatan dataset

Paket bootstrap berisi source code dan generator, bukan seluruh chunk dataset yang telah dibuat sebelumnya. Dataset sekitar 194 ribu kandidat dibuat ulang secara deterministik oleh `scripts/generate_dataset.py` saat setup.
