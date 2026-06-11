# Chat Transaction Features

## Fitur yang Tersedia

### 1. 📝 Text Input (Chat AI)
Ceritakan transaksi Anda dengan bahasa natural, AI akan memproses dan menyimpannya.

**Contoh:**
- "Saya beli kopi 25000"
- "Makan siang di restoran 50000"
- "Isi bensin 100000"

### 2. 📷 Image Upload (Receipt Scanner)
Upload foto struk belanja untuk diproses secara otomatis.

**Cara Menggunakan:**
1. Klik icon 📷 (Image)
2. Pilih sumber:
   - **Kamera**: Ambil foto langsung
   - **Galeri**: Pilih dari galeri foto
3. Foto akan diproses dan data transaksi akan diekstrak

**Status:** 🚧 Fitur dalam pengembangan (OCR API belum diimplementasi)

### 3. 🎤 Voice Input (Speech to Text)
Gunakan suara untuk input transaksi tanpa mengetik.

**Cara Menggunakan:**
1. Klik icon 🎤 (Microphone)
2. Icon berubah merah saat mendengarkan
3. Ucapkan transaksi Anda
4. Tekan icon lagi untuk berhenti
5. Text akan muncul di input field

**Bahasa:** Indonesia (id_ID)

### 4. 💾 Chat History
Semua percakapan disimpan secara lokal menggunakan SharedPreferences.

**Fitur:**
- Auto-save setiap pesan
- Auto-load saat buka chat
- Button hapus history (icon 🗑️)
- Konfirmasi sebelum menghapus

## Permissions yang Diperlukan

### Android
- `CAMERA` - untuk ambil foto struk
- `RECORD_AUDIO` - untuk voice input
- `READ_EXTERNAL_STORAGE` - untuk akses galeri
- `WRITE_EXTERNAL_STORAGE` - untuk simpan gambar (Android 12 ke bawah)
- `READ_MEDIA_IMAGES` - untuk akses galeri (Android 13+)

### iOS (perlu konfigurasi di Info.plist)
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`

## Dependencies

```yaml
# Image & Media
image_picker: ^1.0.7

# Speech Recognition
speech_to_text: ^6.6.0

# Permissions
permission_handler: ^11.3.0
```

## Testing

### Test Voice Input
1. Pastikan di perangkat fisik (emulator biasanya tidak support microphone)
2. Berikan izin microphone saat diminta
3. Klik icon microphone
4. Ucapkan: "Beli kopi dua puluh lima ribu"

### Test Image Upload
1. Klik icon image
2. Pilih Camera atau Gallery
3. Ambil/pilih gambar
4. Lihat response dari sistem

### Test Chat History
1. Kirim beberapa pesan
2. Tutup modal
3. Buka lagi - pesan sebelumnya muncul
4. Klik icon trash untuk hapus history

## API Endpoints

### Chat Transaction
```
POST /api/transactions/chat-input/
Content-Type: application/json

{
  "text": "Saya beli kopi 25000"
}

Response:
{
  "success": true,
  "message": "Transaction saved",
  "extracted_data": {
    "amount": 25000,
    "category_hint": "Food",
    "description": "beli kopi",
    "type": "expense",
    "date": "2024-01-01"
  }
}
```

## Troubleshooting

### Voice tidak bekerja
- Pastikan permission RECORD_AUDIO diberikan
- Test di perangkat fisik, bukan emulator
- Periksa apakah bahasa Indonesia tersedia di perangkat

### Camera tidak bekerja
- Pastikan permission CAMERA diberikan
- Test di perangkat fisik dengan kamera

### Chat history tidak tersimpan
- Periksa permission storage
- Pastikan SharedPreferences initialized

## Roadmap

- [ ] Implementasi OCR untuk receipt scanning
- [ ] Integrasi dengan Google ML Kit
- [ ] Support multi-language untuk voice
- [ ] Batch upload multiple receipts
- [ ] Export chat history
