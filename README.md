
# Nutri-GO: Aplikasi Pelacak Kalori dan Makronutrisi Berbasis Makanan Lokal Indonesia

Nutri-GO adalah aplikasi seluler pelacak asupan kalori dan makronutrisi harian. Aplikasi ini dirancang secara khusus dengan berfokus pada *database* makanan lokal khas Indonesia. Dengan desain UI modern bernuansa *Sage Green*, Nutri-GO cerdas membantu pengguna dalam mencapai target kebugaran fisik, seperti *Bulking*, *Cutting*, atau *Maintenance*.

## Fitur Unggulan Nutri-GO

* **Kalkulator Target:** Penentuan target kalori harian dan pemecahan target makronutrisi otomatis berdasarkan usia, berat badan, tinggi badan, dan aktivitas fisik pengguna.
* **Interactive Tracking:** Pencarian makanan instan dengan filter lokal, fitur *checkbox multi-select*, dan konversi gramasi langsung ke kalori secara *real-time* tanpa jeda.
* **Laporan Harian:** Melihat riwayat asupan secara mendetail setiap hari, termasuk rincian makanan per sesi (Sarapan, Siang, Malam) beserta grafik perbandingannya.

## Alur Pengguna Aplikasi

1. **Autentikasi:** Pendaftaran akun dan proses masuk dengan validasi *form* secara *real-time*.
2. **Assessment:** Input 6 metrik fisik interaktif untuk menghitung target kalori dan makro otomatis.
3. **Dashboard:** Visualisasi *Progress Bar* dinamis untuk melacak asupan harian sesuai target makro.
4. **Tracking Harian:** Pencatatan gramasi makanan terintegrasi dan ringkasan riwayat pencapaian diet.

## Arsitektur Database (Relasi ERD)

Struktur data dirancang untuk memastikan agregasi data harian konsisten (via `SUM`).

* **Relasi Users & Profiles (1-to-1):** Satu pengguna hanya memiliki satu profil. Normalisasi data diterapkan agar tabel `users` tetap ringan untuk verifikasi *Login* (*JWT Token*).
* **Relasi Transaksi Jurnal (1-to-Many):** Satu *user* atau satu jenis *foods* dapat memiliki banyak entri harian di dalam tabel `daily_logs`.

## Dependensi & Library Utama (Lean Tech Stack)

Untuk menjaga performa aplikasi tetap *lightweight* dan responsif (*smooth rendering*), Nutri-GO menerapkan prinsip *clean development* dengan meminimalkan dependensi pihak ketiga (*third-party packages*):

* **Flutter Material UI (`package:flutter/material.dart`):** *Core library* utama untuk me-render seluruh elemen antarmuka visual modern berbasis *Material 3 Design* (seperti komponen *Scaffold*, widget *Dismissible* untuk *Optimistic UI*, *Slider*, dan *ExpansionTile*).
* **HTTP Client (`package:http/http.dart`):** *Package* eksternal yang diisolasi di dalam *layer services* untuk menangani seluruh komunikasi data (*network calling*) secara asinkronus ke RESTful API *server*.
* **Shared Preferences (`package:shared_preferences/shared_preferences.dart`):** Penyimpanan lokal persisten skala kecil (*key-value pair*) pada perangkat untuk mengamankan sesi *JWT Token* otentikasi, hak akses akun (`USER`/`ADMIN`), serta penanda kelengkapan profil fisik.
* **Dart Convert UI (`dart:convert`):** *Core library* bawaan bahasa Dart untuk melakukan encoding/decoding format data string JSON dari respons API secara efisien.

## Rencana Pengembangan

Kami memiliki dua fokus utama untuk pengembangan selanjutnya:

* **Panel Administrator (CMS):** Membangun antarmuka berbasis web (*Web Dashboard*) khusus Admin untuk mempermudah pengelolaan *Master Data* makanan lokal secara dinamis (Operasi CRUD).
* **Sistem Pencatatan Nutrisi:** Membantu pengguna baru merencanakan menu makan yang sesuai dengan target makronutrisi mereka.

## Tim Pengembang (KrinsssTym)

* **Javier:** UI/UX. Mengonsep desain antarmuka *Sage Green* yang modern, menyusun tata letak visual, dan merancang pengalaman pengguna yang mulus.
* **Rian:** *Frontend* & *Logic* UI (*Flutter*). Menangani algoritma sinkronisasi *state progress bar*, konversi gramasi instan, dan integrasi API.
* **Damar:** Integrasi *Backend* & *Database*. Menyediakan data *master* makanan lokal terstruktur, serta mengatur logika agregasi target makro untuk laporan harian.

## Repositori & Dokumentasi

* **Repositori Aplikasi (Frontend):** Tempat pengembangan kode sumber aplikasi seluler (*Flutter*) yang aktif dioperasikan pada *branch* pengembangan tim (`rian-dev`).
* **Dokumentasi API (Backend):** Dokumentasi *Swagger* resmi untuk *endpoint server* yang digunakan untuk keperluan integrasi *database*, layanan autentikasi, dan operasi data.
