# 🔔 Fitur Notifikasi - ManKu (Manajemen Keuangan)

## Overview
Dokumen ini berisi saran fitur notifikasi untuk aplikasi ManKu yang akan meningkatkan engagement user dan membantu pengelolaan keuangan yang lebih baik.

---

## 1. 🚨 Notifikasi Budgeting (Rem Darurat)

### 1.1 **Goal Budget Alert**
**Trigger:** Ketika saldo tujuan mencapai milestone tertentu

**Contoh:**
- ✅ "🎉 Luar Biasa! Target 'Beli Rumah' sudah 50% tercapai! Rp 250M dari Rp 500M"
- ⚠️ "📊 Target 'Liburan ke Bali' masih 20%. Tambah Rp 50K/hari untuk capai target!"
- 🎯 "💪 Tinggal 25% lagi! Target 'Dana Darurat' hampir tercapai"

**Timing:**
- Milestone: 25%, 50%, 75%, 90%, 100%
- Pagi (9 AM): Reminder progress harian
- Akhir bulan: Summary progress bulanan

**Priority:** HIGH (P0)

### 1.2 **Spending Limit Warning**
**Trigger:** Pengeluaran mendekati/melebihi budget kategori

**Contoh:**
- ⚠️ "Hati-hati! Pengeluaran 'Makanan' sudah 80% dari budget bulan ini (Rp 800K/1M)"
- 🔴 "ALERT: Budget 'Entertainment' terlampaui! Rp 1.2M dari Rp 1M. Hemat Rp 50K/hari"
- 💡 "Sisa budget 'Transport' tinggal Rp 150K. 5 hari lagi bulan baru"

**Timing:**
- 70%: Warning kuning
- 90%: Warning oranye
- 100%: Alert merah
- Real-time saat transaksi input

**Priority:** HIGH (P0)

### 1.3 **Monthly Balance Alert**
**Trigger:** Saldo bulanan negatif atau mendekati nol

**Contoh:**
- 🚨 "Defisit Bulan Ini: -Rp 500K. Income < Pengeluaran. Cek pengeluaran di kategori 'Shopping'"
- ⚠️ "Saldo bulan ini tinggal Rp 100K. Kurangi pengeluaran non-esensial"
- ✅ "Surplus Rp 2M bulan ini! 🎉 Alokasikan ke 'Dana Darurat' atau investasi"

**Timing:**
- Real-time: Saat balance < 0
- Mid-month (15): Proyeksi akhir bulan
- End-month (28): Summary bulanan

**Priority:** HIGH (P0)

---

## 2. 📅 Pengingat Tagihan & Transaksi Berulang (Billing Alerts)

### 2.1 **Recurring Transaction Reminder**
**Trigger:** Tagihan/transaksi berulang mendekati jatuh tempo

**Contoh:**
- 📆 "Reminder: Bayar listrik PLN Rp 250K besok (25 Des)"
- 💰 "Cicilan rumah Rp 5M jatuh tempo 3 hari lagi. Saldo cukup ✓"
- ⚠️ "Tagihan internet Indihome Rp 350K jatuh tempo hari ini. Saldo kurang Rp 100K!"

**Features:**
- User bisa set recurring bills: Listrik, Air, Internet, Cicilan, Asuransi, dll
- Frequency: Harian, Mingguan, Bulanan, Tahunan
- Reminder: 3 hari sebelum, 1 hari sebelum, hari-H
- Auto-detect: AI deteksi transaksi berulang dari history

**Timing:**
- 3 hari sebelum: Soft reminder (pagi 9 AM)
- 1 hari sebelum: Medium reminder (pagi + sore)
- Hari-H: Urgent reminder (pagi, siang, sore)

**Priority:** HIGH (P0)

### 2.2 **Subscription Tracker**
**Trigger:** Langganan bulanan (Netflix, Spotify, dll)

**Contoh:**
- 💳 "Netflix Rp 199K akan dipotong besok. Auto-debit dari kartu *1234"
- 📱 "5 langganan aktif: Netflix, Spotify, YouTube, Canva, iCloud (Total: Rp 500K/bulan)"
- ⚠️ "Langganan Spotify Premium tidak digunakan 30 hari terakhir. Pertimbangkan cancel?"

**Features:**
- Daftar semua subscription
- Tracking usage (jika bisa integrate)
- Total monthly subscription cost
- Reminder sebelum renewal

**Timing:**
- 2 hari sebelum renewal
- Monthly summary: Total subscription cost
- Quarterly review: Unused subscriptions

**Priority:** MEDIUM (P1)

---

## 3. 📊 Laporan Berkala (Financial Insights & Summary)

### 3.1 **Daily Summary**
**Trigger:** Setiap hari di waktu yang sama

**Contoh:**
- 🌅 "Selamat Pagi! Kemarin kamu hemat Rp 50K. Total pengeluaran Rp 150K"
- 📊 "Daily Recap: Income Rp 0 | Expense Rp 200K | Balance -Rp 200K"
- 💡 "Tip: Pengeluaran tertinggi kemarin: Makanan Rp 100K"

**Timing:** Pagi (8-9 AM)
**Priority:** LOW (P2)

### 3.2 **Weekly Report**
**Trigger:** Setiap Minggu/Senin pagi

**Contoh:**
- 📈 "Weekly Report: Total pengeluaran Rp 1.5M minggu ini. Turun 20% dari minggu lalu! 🎉"
- 💰 "Top spending: Makanan Rp 600K (40%), Transport Rp 400K (27%), Shopping Rp 300K (20%)"
- 🎯 "Progress goals: Beli Rumah +Rp 2M (85%), Dana Darurat +Rp 500K (60%)"

**Timing:** Senin pagi (9 AM)
**Priority:** MEDIUM (P1)

### 3.3 **Monthly Financial Insights**
**Trigger:** Awal bulan baru

**Contoh:**
- 📊 "🎉 Laporan Desember 2024"
  - Income: Rp 10M
  - Expense: Rp 7M
  - Saving: Rp 3M (30%)
  - Top kategori: Makanan Rp 2M, Transport Rp 1.5M
  - Progress goals: +3 tujuan tercapai
  - Saran AI: "Pengeluaran Makanan naik 25%. Coba meal prep untuk hemat!"

**Features:**
- Comprehensive monthly report
- Chart/grafik progress
- AI insights & recommendations
- Comparison with previous months
- Achievement highlights

**Timing:** Tanggal 1 setiap bulan (pagi 9 AM)
**Priority:** HIGH (P0)

### 3.4 **AI Smart Insights**
**Trigger:** Real-time analysis dari spending patterns

**Contoh:**
- 🤖 "AI Notice: Pengeluaran 'Kopi' naik 150% bulan ini (Rp 450K vs Rp 180K). Seduh di rumah bisa hemat Rp 300K!"
- 💡 "Pattern Detected: Kamu selalu belanja online saat malam. Total Rp 2M bulan ini. Set limit?"
- 🎯 "Congrats! Consistency 🔥 3 bulan berturut-turut nabung >Rp 2M/bulan"

**Timing:** Real-time atau weekly digest
**Priority:** MEDIUM (P1)

---

## 4. 🔒 Keamanan & Autentikasi Akun (Security Alerts)

### 4.1 **Login Security Alerts**
**Trigger:** Login dari device/lokasi baru

**Contoh:**
- 🔐 "Login baru terdeteksi dari Chrome, Jakarta (12 Des 2024, 14:30). Bukan kamu? Amankan akun!"
- ⚠️ "Percobaan login gagal 3x dari IP unknown. Ganti password segera!"
- ✅ "Device baru terdaftar: Samsung Galaxy S23. Manage devices di Settings > Security"

**Features:**
- Device management
- Location tracking
- Failed login attempts
- 2FA/Biometric options
- Emergency account lock

**Timing:** Real-time
**Priority:** CRITICAL (P0)

### 4.2 **Suspicious Transaction Alert**
**Trigger:** Transaksi tidak biasa atau mencurigakan

**Contoh:**
- 🚨 "Transaksi besar terdeteksi: Rp 10M ke 'Unknown'. Konfirmasi ini transaksi kamu?"
- ⚠️ "Pengeluaran tidak biasa: Rp 5M dalam 1 jam. Review transaksi sekarang"
- 🔍 "AI Fraud Detection: 5 transaksi <Rp 100K dalam 10 menit. Pola tidak biasa"

**Features:**
- Anomaly detection
- Transaction verification
- Quick block/report
- Fraud pattern analysis

**Timing:** Real-time (immediate)
**Priority:** CRITICAL (P0)

### 4.3 **Data Privacy Updates**
**Trigger:** Changes in privacy policy atau data access

**Contoh:**
- 📜 "Update Privacy Policy: Lihat perubahan di sini"
- 🔐 "Data kamu aman! Last backup: 2 jam lalu. Auto-backup aktif"
- ⚙️ "Permintaan akses data dari: Analytic Service. Approve/Deny?"

**Timing:** As needed
**Priority:** HIGH (P0)

---

## 5. 🎮 Gamification & Motivasi (Pemicu Kebiasaan)

### 5.1 **Streak & Consistency Rewards**
**Trigger:** User mencapai milestone habit

**Contoh:**
- 🔥 "Streak 7 hari! Kamu input transaksi setiap hari minggu ini. Badge unlocked: 'Consistent Tracker'"
- 🏆 "Achievement: 30 hari berturut-turut nabung >Rp 100K! Reward: Premium features 7 hari gratis"
- ⭐ "Level Up! Kamu naik ke Level 5: 'Budget Master'. New feature unlocked: AI Financial Advisor"

**Features:**
- Daily streak tracking
- Achievement badges
- Level system (1-100)
- Rewards: Premium features, themes, stickers
- Leaderboard (optional, friends only)

**Timing:** Real-time saat achievement
**Priority:** MEDIUM (P1)

### 5.2 **Goal Achievement Celebration**
**Trigger:** Tujuan keuangan tercapai

**Contoh:**
- 🎉 "CONGRATULATIONS! 🎊 Target 'Beli Rumah' TERCAPAI! Rp 500M terkumpul dalam 18 bulan!"
- 💪 "Milestone: 50% dari 'Dana Darurat'! Kamu sudah menabung Rp 15M. Keep going!"
- 🏅 "First Goal Completed! Badge unlocked: 'Goal Achiever'. Share ke teman?"

**Features:**
- Confetti animation in-app
- Social sharing (optional)
- Milestone badges
- Progress photos/timeline
- Next goal suggestion

**Timing:** Real-time saat milestone/completion
**Priority:** HIGH (P0)

### 5.3 **Savings Challenge**
**Trigger:** Periodic challenges untuk motivasi

**Contoh:**
- 💰 "Challenge: 'No Spending Weekend' - Tidak belanja Sabtu-Minggu = Bonus badge!"
- 🎯 "Weekly Challenge: Hemat Rp 100K minggu ini. Progress: Rp 75K (75%). Hampir!"
- 🌟 "30-Day Challenge: Nabung minimal Rp 50K/hari. Join 1,234 users lainnya!"

**Features:**
- Daily/Weekly/Monthly challenges
- Community challenges
- Challenge progress tracking
- Reward system
- Custom challenges

**Timing:** 
- Senin pagi: Weekly challenge
- Tanggal 1: Monthly challenge
- Real-time: Progress updates

**Priority:** MEDIUM (P1)

### 5.4 **Motivational Quotes & Tips**
**Trigger:** Random atau scheduled

**Contoh:**
- 💡 "Financial Tip: 'Investasi terbaik adalah investasi pada diri sendiri' - Warren Buffett"
- 🌟 "Motivation: 'Kamu sudah menabung Rp 50M tahun ini. That's amazing! 🎉'"
- 📚 "Did you know? Rata-rata orang Indonesia menabung 15% dari income. Kamu sudah 25%!"

**Timing:** 
- Pagi (8 AM): Daily motivation
- Random: 2-3x per minggu
- After achievement

**Priority:** LOW (P2)

### 5.5 **Habit Reminder**
**Trigger:** User belum input transaksi hari ini

**Contoh:**
- ⏰ "Hey! Sudah input pengeluaran hari ini? Butuh 30 detik aja ✨"
- 🔔 "Jangan lupa tracking! Terakhir input 2 hari lalu. Keep your streak alive!"
- 💪 "Evening Reminder: Review pengeluaran hari ini sebelum tidur"

**Timing:**
- Sore (6 PM): Jika belum input hari ini
- Malam (9 PM): Final reminder

**Priority:** MEDIUM (P1)

---

## 📋 Prioritas Implementasi

### Phase 1 - MVP (P0) - Critical & High Impact
1. ✅ Goal Budget Alert (Milestone notifications)
2. ✅ Spending Limit Warning (Budget overspending)
3. ✅ Monthly Balance Alert (Deficit warning)
4. ✅ Recurring Transaction Reminder (Bill reminders)
5. ✅ Login Security Alerts (Security)
6. ✅ Suspicious Transaction Alert (Fraud detection)
7. ✅ Monthly Financial Insights (Monthly report)
8. ✅ Goal Achievement Celebration (Motivation)

**Timeline:** 2-3 bulan

### Phase 2 - Enhancement (P1) - Medium Impact
1. ✅ Subscription Tracker
2. ✅ Weekly Report
3. ✅ AI Smart Insights
4. ✅ Streak & Consistency Rewards
5. ✅ Savings Challenge
6. ✅ Habit Reminder

**Timeline:** 3-4 bulan

### Phase 3 - Nice to Have (P2) - Low Impact
1. ✅ Daily Summary
2. ✅ Motivational Quotes & Tips
3. ✅ Advanced gamification features

**Timeline:** 4-6 bulan

---

## 🔧 Implementasi Teknis

### Tech Stack Recommendation

#### 1. **Firebase Cloud Messaging (FCM)**
- Push notifications (Android & iOS & Web)
- Topic-based messaging
- Device group messaging
- Free tier cukup untuk MVP

#### 2. **Local Notifications** 
- `flutter_local_notifications` package
- Untuk reminder yang tidak perlu server
- Offline-capable
- Scheduled notifications

#### 3. **Background Jobs**
- `workmanager` package
- Untuk periodic checks (daily/weekly)
- Battery-efficient

#### 4. **Notification Channels** (Android)
```dart
Channels:
- urgent_alerts      (Sound + Vibrate + Heads-up)
- financial_insights (Sound only)
- achievements       (Sound + LED)
- reminders          (Silent)
- security           (Sound + Vibrate + Bypass DND)
```

### Backend Requirements

#### 1. **Notification Service**
```
POST /api/notifications/send
GET  /api/notifications/history
PUT  /api/notifications/preferences
POST /api/notifications/mark-read
```

#### 2. **Cron Jobs**
- Daily: 8 AM - Daily summary
- Weekly: Monday 9 AM - Weekly report  
- Monthly: 1st day 9 AM - Monthly insights
- Real-time: Budget alerts, security alerts

#### 3. **AI Analysis**
- Spending pattern detection
- Anomaly detection
- Smart insights generation
- Personalized recommendations

### Database Schema

```sql
-- Notification Settings
CREATE TABLE notification_settings (
  user_id UUID PRIMARY KEY,
  budget_alerts BOOLEAN DEFAULT TRUE,
  bill_reminders BOOLEAN DEFAULT TRUE,
  financial_insights BOOLEAN DEFAULT TRUE,
  security_alerts BOOLEAN DEFAULT TRUE,
  gamification BOOLEAN DEFAULT TRUE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Notification History
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID,
  type VARCHAR(50), -- 'budget', 'bill', 'security', etc
  title VARCHAR(255),
  body TEXT,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP,
  read_at TIMESTAMP
);

-- Recurring Bills
CREATE TABLE recurring_bills (
  id UUID PRIMARY KEY,
  user_id UUID,
  name VARCHAR(255),
  amount DECIMAL(15,2),
  frequency VARCHAR(20), -- 'daily', 'weekly', 'monthly'
  due_day INT,
  reminder_days_before INT[],
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP
);
```

---

## 🎨 UI/UX Considerations

### 1. **Notification Center**
- In-app notification inbox
- Filter by type (Budget, Bills, Insights, etc)
- Mark as read/unread
- Archive notifications
- Search history

### 2. **Settings & Preferences**
- Granular control per notification type
- Quiet hours (Tidak ganggu: 10 PM - 7 AM)
- Notification sound selection
- Vibration patterns
- LED color (Android)

### 3. **Smart Delivery**
- Don't send if user is active in app
- Batch non-urgent notifications
- Respect quiet hours
- Timezone aware
- Frequency capping (max 10/day)

### 4. **Rich Notifications**
- Action buttons: "View", "Snooze", "Dismiss"
- Expandable content
- Images (charts, progress bars)
- Quick actions (Pay bill, View report)

---

## 📊 Success Metrics (KPIs)

### Engagement Metrics
- Notification open rate (Target: >40%)
- Click-through rate (Target: >25%)
- In-app action rate (Target: >15%)
- Daily active users (Target: +30%)

### Financial Behavior
- Transaction input frequency (Target: Daily)
- Budget adherence rate (Target: >70%)
- Goal completion rate (Target: +20%)
- Savings rate (Target: +15%)

### Retention
- 7-day retention (Target: >60%)
- 30-day retention (Target: >40%)
- Churn rate (Target: <15%)

### User Satisfaction
- Notification usefulness rating (Target: >4/5)
- Opt-out rate (Target: <10%)
- Feature adoption (Target: >50%)

---

## 🚀 Quick Start Implementation

### Step 1: Setup FCM (Week 1)
```bash
# 1. Add Firebase to project
flutter pub add firebase_core firebase_messaging

# 2. Configure Android & iOS
# Follow: https://firebase.google.com/docs/flutter/setup

# 3. Request permissions
# iOS: Add to Info.plist
# Android: Auto-granted
```

### Step 2: Local Notifications (Week 1)
```bash
flutter pub add flutter_local_notifications
flutter pub add timezone
```

### Step 3: Background Processing (Week 2)
```bash
flutter pub add workmanager
```

### Step 4: Backend Integration (Week 2-3)
- Create notification service endpoints
- Setup cron jobs
- Implement AI analysis triggers

### Step 5: UI Components (Week 3-4)
- Notification center page
- Settings page
- Toast/Snackbar handlers
- Rich notification templates

---

## 💡 Best Practices

### Do's ✅
1. **Personalize** - Use user's name, specific amounts
2. **Actionable** - Provide clear next steps
3. **Timely** - Send at relevant moments
4. **Value-driven** - Focus on user benefit
5. **Opt-out easy** - Respect user preferences
6. **Test thoroughly** - A/B test messages
7. **Track metrics** - Monitor engagement

### Don'ts ❌
1. **Don't spam** - Max 10 notifications/day
2. **Don't be vague** - "Check app" → "Budget exceeded Rp 500K"
3. **Don't ignore timezone** - Send at user's local time
4. **Don't use jargon** - Simple, clear language
5. **Don't neglect quiet hours** - Respect sleep time
6. **Don't force** - Allow granular control
7. **Don't forget analytics** - Track everything

---

## 📞 Support & Maintenance

### Monitoring
- Notification delivery rate
- Failed sends
- Crash reports
- User feedback

### Updates
- Monthly review of effectiveness
- Quarterly feature additions
- A/B testing new messages
- User feedback integration

---

## 🎯 Expected Outcomes

### Short-term (3 months)
- ✅ 40% increase in daily active users
- ✅ 60% of users enable notifications
- ✅ 25% click-through rate on alerts
- ✅ Reduced budget overruns by 30%

### Long-term (6-12 months)
- ✅ 70% user retention rate
- ✅ 50% increase in goal completions
- ✅ 80% user satisfaction rating
- ✅ Premium conversion rate +15%

---

**Dibuat:** Desember 2024  
**Author:** ManKu Development Team  
**Version:** 1.0
