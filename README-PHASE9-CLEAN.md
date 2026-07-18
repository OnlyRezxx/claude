# Name Guesser Phase 9 — CLEAN Distribution

Distribusi ini menggantikan bootstrap lama yang menghasilkan `Truncated tar archive`.

## Unduh branch yang benar

https://github.com/OnlyRezxx/claude/archive/refs/heads/phase9-clean-final.zip

Jangan gunakan ZIP branch `main` atau installer lama `INSTALL-PHASE9.cmd`.

## Instalasi Windows

1. Ekstrak `claude-phase9-clean-final.zip`.
2. Buka folder hasil ekstrak.
3. Jalankan `00-INSTALL-PHASE9-CLEAN.cmd`.
4. Tunggu proses dependency, pembuatan dataset, dan build selesai.

Installer akan memeriksa:

- Ukuran arsip: `13624` byte.
- SHA-256: `503c09b38c16aba14d4cb92b126edb2f6bbda10a0dbde5cf581c7e1936b66c51`.
- Integritas XZ/TAR sebelum ekstraksi.
- Node.js minimal 22.12.0.
- Pembuatan dataset sekitar 194.785 kandidat.
- Production build tujuh halaman MPA.

## Menjalankan aplikasi

Setelah installer selesai, jalankan perintah yang ditampilkan. Secara umum:

```powershell
cd .\Name-Guesser-Phase9-Clean\name-guesser-phase9-clean-package
npm run dev
```

Buka:

```text
http://localhost:4173
```

## Catatan

Paket CLEAN merupakan rebuild ringkas dari Phase 9 yang mempertahankan fungsi utama: tujuh halaman fisik, permainan adaptif, dataset standard/mega, tiga percobaan tebakan, feedback nama sebenarnya, klasifikasi kandidat hilang atau kesalahan ranking, memori lokal, statistik, admin feedback, dark mode, dan desain responsif.

Paket ini tidak memerlukan Python. Dataset dibuat menggunakan Node.js melalui `npm run setup`.
