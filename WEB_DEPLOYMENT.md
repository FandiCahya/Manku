# Web Deployment - Upload Struk Feature

## Platform-Specific Features

### 📱 Mobile (Android/iOS)
| Feature | Status | Description |
|---------|--------|-------------|
| 📷 Camera | ✅ Available | Ambil foto struk langsung |
| 🖼️ Gallery | ✅ Available | Pilih dari galeri |
| 🎤 Voice | ✅ Available | Speech to text input |
| 💬 Chat AI | ✅ Available | Text input dengan AI |

### 🌐 Web Browser
| Feature | Status | Description |
|---------|--------|-------------|
| 📷 Camera | ❌ Disabled | Tidak ada kamera di browser |
| 🖼️ File Upload | ✅ Available | Upload file gambar struk |
| 🎤 Voice | ❌ Disabled | Speech-to-text tidak reliable di web |
| 💬 Chat AI | ✅ Available | Text input dengan AI |

## How It Works in Web

### 1. **Upload File Struk (Image Upload)**

**User Flow:**
```
1. Klik icon 📷 (Image/Upload)
2. Modal muncul dengan 1 opsi: "Pilih dari Galeri"
3. Browser native file picker muncul
4. User pilih file gambar (jpg, png, etc)
5. File terupload ke sistem
```

**Supported File Types:**
- ✅ `.jpg` / `.jpeg`
- ✅ `.png`
- ✅ `.webp`
- ✅ `.gif`

**File Size:**
- Max width: 1024px (auto-resized)
- Max height: 1024px (auto-resized)
- Quality: 85% (compressed)

### 2. **Voice Input (Disabled on Web)**

**Why Disabled?**
- `speech_to_text` package tidak support web dengan baik
- Web Speech API memerlukan HTTPS
- Browser compatibility issues (Safari, Firefox limited support)
- Lebih reliable menggunakan text input di web

**Alternative for Web:**
- User dapat mengetik manual di text field
- Copy-paste dari note/document
- Lebih stabil dan universal

## Implementation Details

### Code Changes for Web Support

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// 1. Conditional Camera Option
if (!kIsWeb)
  ListTile(
    leading: Icon(Icons.camera_alt),
    title: Text('Ambil Foto'),
    onTap: () => _pickImage(ImageSource.camera),
  ),

// 2. Conditional Voice Button
IconButton(
  onPressed: kIsWeb ? null : _toggleListening,  // Disabled untuk web
  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
  tooltip: kIsWeb 
      ? 'Voice input tidak tersedia di web' 
      : 'Voice Input',
),

// 3. Disable Speech Init on Web
Future<void> _initSpeech() async {
  if (kIsWeb) {
    _speechAvailable = false;
    return;
  }
  // ... normal initialization
}
```

## Testing on Web

### Local Testing
```bash
# Run in Chrome
flutter run -d chrome

# Run in Edge
flutter run -d edge

# Run web server
flutter run -d web-server --web-port 8080
# Open: http://localhost:8080
```

### Test Upload Image
1. Buka app di browser
2. Go to Add Transaction → Chat AI
3. Klik icon 📷
4. **Hanya muncul "Pilih dari Galeri"** (no camera option)
5. File picker muncul
6. Pilih file gambar (jpg/png)
7. ✅ File uploaded successfully

### Verify Voice Disabled
1. Hover over 🎤 icon
2. Tooltip: "Voice input tidak tersedia di web"
3. Icon berwarna grey (disabled)
4. Klik tidak melakukan apa-apa
5. ✅ Properly disabled

## Build for Production Web

### 1. **Build Web App**
```bash
flutter build web --release

# Output di: build/web/
```

### 2. **Deploy Options**

#### A. Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

#### B. Netlify
```bash
# Drag & drop folder build/web/ ke Netlify
# atau
netlify deploy --prod --dir=build/web
```

#### C. Vercel
```bash
vercel --prod
# Point to: build/web/
```

#### D. GitHub Pages
```bash
# Push build/web/ ke gh-pages branch
git subtree push --prefix build/web origin gh-pages
```

### 3. **HTTPS Requirement**
⚠️ **Important:** Upload file & modern web features require HTTPS!

```
❌ http://example.com  → Some features may not work
✅ https://example.com → All features work
```

## Web-Specific Considerations

### File Upload in Web

**How it works:**
```dart
// image_picker automatically converts to web implementation
final XFile? image = await _imagePicker.pickImage(
  source: ImageSource.gallery,  // Auto becomes file picker on web
  maxWidth: 1024,
  maxHeight: 1024,
  imageQuality: 85,
);

// File is accessible via:
// - image.path (web blob URL)
// - image.readAsBytes() (Uint8List)
```

**Limitations:**
- No access to device camera directly
- File picker is browser's native dialog
- Must select from existing files
- No "take photo" option

### Browser Compatibility

| Browser | Image Upload | Chat AI | Notes |
|---------|-------------|---------|-------|
| Chrome | ✅ | ✅ | Full support |
| Edge | ✅ | ✅ | Full support |
| Firefox | ✅ | ✅ | Full support |
| Safari | ✅ | ✅ | Full support |
| Opera | ✅ | ✅ | Full support |

## User Experience on Web

### Mobile vs Web Comparison

**Mobile App:**
```
Upload Struk:
📷 Ambil Foto → Camera langsung
🖼️ Galeri → Pilih dari gallery

Voice Input:
🎤 Tap → Mikrofon aktif → Ucapkan → Done
```

**Web Browser:**
```
Upload Struk:
📷 Upload File → File Picker → Pilih gambar → Done
(No camera option)

Voice Input:
🎤 Disabled (grey icon)
💬 Gunakan text input sebagai gantinya
```

## Deployment Checklist

### Before Deploy
- [ ] Test upload di Chrome
- [ ] Test upload di Firefox
- [ ] Test upload di Safari (if Mac available)
- [ ] Verify voice button disabled
- [ ] Verify chat AI works
- [ ] Test dark theme
- [ ] Test responsive design
- [ ] Check console for errors

### After Deploy
- [ ] Test on production URL
- [ ] Verify HTTPS working
- [ ] Test file upload on live site
- [ ] Check performance (lighthouse)
- [ ] Test on mobile browser
- [ ] Test on tablet browser
- [ ] Monitor error logs

## Future Enhancements for Web

### Planned Features
- [ ] **Web Speech API Integration**
  - Browser-native speech recognition
  - Requires HTTPS and user permission
  - Chrome & Edge support
  
- [ ] **Drag & Drop Upload**
  - Drag image file into chat area
  - Visual feedback on hover
  - Multiple file upload
  
- [ ] **Paste from Clipboard**
  - Ctrl+V to paste image
  - Direct from screenshot
  - No file picker needed

- [ ] **Progressive Web App (PWA)**
  - Install as desktop app
  - Offline support
  - Push notifications

## Troubleshooting

### Image Upload Not Working on Web

**Problem:** File picker tidak muncul
```
Solution:
1. Check HTTPS enabled
2. Check browser permissions
3. Clear browser cache
4. Try different browser
```

**Problem:** Large file upload gagal
```
Solution:
1. Check file size < 5MB
2. Check network connection
3. Increase timeout di backend
4. Compress image terlebih dahulu
```

### Voice Button Shows on Web

**Problem:** Voice button tidak disabled
```
Solution:
1. Check kIsWeb import: 
   import 'package:flutter/foundation.dart' show kIsWeb;
2. Rebuild web app:
   flutter clean && flutter build web
```

## API Considerations

### Upload Endpoint (Future Implementation)
```
POST /api/transactions/upload-receipt/
Content-Type: multipart/form-data

{
  "image": <binary file data>,
  "user_id": "...",
  "timestamp": "2024-01-01T10:00:00Z"
}

Response:
{
  "success": true,
  "extracted_data": {
    "total": 25000,
    "items": [...],
    "merchant": "Starbucks",
    "date": "2024-01-01"
  }
}
```

### CORS Configuration (Backend)
```python
# Django settings.py
CORS_ALLOWED_ORIGINS = [
    "https://yourapp.com",
    "https://www.yourapp.com",
]

CORS_ALLOW_CREDENTIALS = True

CSRF_TRUSTED_ORIGINS = [
    "https://yourapp.com",
]
```

## Summary

✅ **Web Support:**
- Image upload via file picker ✅
- Chat AI text input ✅
- Dark theme support ✅
- Responsive design ✅

❌ **Not Supported on Web:**
- Direct camera capture ❌
- Voice/speech input ❌

💡 **Recommendation:**
- Mobile app untuk full features
- Web app untuk desktop convenience
- Both platforms supported equally untuk core functionality (chat AI)
