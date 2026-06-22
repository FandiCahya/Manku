# ✅ TESTING CHECKLIST - My Manage App

## 🚀 PRE-TESTING SETUP

```bash
# 1. Clean and rebuild
flutter clean
flutter pub get

# 2. Run on Chrome
flutter run -d chrome
```

---

## 📋 TEST 1: DEBUG CONSOLE

### Expected Behavior:
- [ ] Bug button visible in bottom-right corner (70x70px, prominent)
- [ ] Bug button has glow effect and red badge
- [ ] Tapping bug button opens debug console overlay
- [ ] Console shows initialization log

### Testing Steps:
1. Launch app on Chrome
2. Look for 🐛 bug button bottom-right
3. Tap bug button
4. Console should open showing:
   ```
   🐛 Debug Console Initialized
   📱 App Started - Ready to track transactions
   ```

**Status:** ⬜ PASS / ⬜ FAIL

**Screenshot:** (attach if fails)

---

## 📋 TEST 2: INCOME TRANSACTION LOGGING

### Expected Behavior:
- [ ] Adding income shows debug logs
- [ ] Type sent to API is "income" not "expense"
- [ ] Dashboard API returns income correctly
- [ ] Report API returns income category

### Testing Steps:
1. Open debug console (tap bug button)
2. Add income transaction: "gaji 5000000" or "salary 5000000"
3. Check debug logs for:
   ```
   💾 Web: ========== SAVING TO API ==========
      Type: "income" (length: 6)
      ✅ Saved to API successfully
   
   💰 Web: Fetching transactions list for dashboard...
   💰 "salary": type=income amount=5000000.0
   💰 Dashboard: Income=Rp5000000 ...
   ```

**Status:** ⬜ PASS / ⬜ FAIL

**Screenshot of Debug Logs:** (required)

---

## 📋 TEST 3: INCOME IN DASHBOARD

### Expected Behavior:
- [ ] Income appears in Monthly Balance
- [ ] Balance = Income - Expense (correct calculation)
- [ ] Income amount is correct

### Testing Steps:
1. After adding income transaction
2. Go to Dashboard (Home tab)
3. Check Monthly Balance gauge
4. Verify income is counted correctly

**Expected:**
- Income: Rp 5,000,000
- Expense: (existing expenses)
- Balance: Income - Expense

**Actual:**
- Income: _____________
- Expense: _____________
- Balance: _____________

**Status:** ⬜ PASS / ⬜ FAIL

---

## 📋 TEST 4: INCOME IN REPORT

### Expected Behavior:
- [ ] Spending Performance chart shows blue line (income)
- [ ] Spending Performance chart shows red line (expense)
- [ ] Category Breakdown has "Income" filter
- [ ] Selecting "Income" filter shows income categories

### Testing Steps:
1. Go to Reports page (bottom nav)
2. Check "Transactions" tab
3. Verify Spending Performance chart has 2 lines
4. Scroll down to Category Breakdown
5. Tap "Income" filter chip
6. Verify income categories appear with green IN badges

**Status:** ⬜ PASS / ⬜ FAIL

**Screenshot:** (attach if fails)

---

## 📋 TEST 5: INCOME AFTER RESTART

### Expected Behavior:
- [ ] Close and reopen app
- [ ] Income still appears in Dashboard
- [ ] Income still appears in Report
- [ ] Income category still in breakdown

### Testing Steps:
1. Close browser tab completely
2. Run app again: `flutter run -d chrome`
3. Wait for app to load
4. Open debug console
5. Check Dashboard - verify income is still there
6. Check Report - verify income chart and categories

**After Restart:**
- Income in Dashboard: ⬜ YES / ⬜ NO
- Income in Report Chart: ⬜ YES / ⬜ NO
- Income in Category: ⬜ YES / ⬜ NO

**Status:** ⬜ PASS / ⬜ FAIL

**Screenshot of Debug Logs After Restart:** (required if fails)

---

## 📋 TEST 6: INVESTMENT TAB

### Expected Behavior:
- [ ] Reports page has 2 tabs: "Transactions" and "Investments"
- [ ] Tapping "Investments" tab shows investment page
- [ ] If no data: shows empty state "No investments yet"
- [ ] If has data: shows Portfolio Summary + Investment List

### Testing Steps:
1. Go to Reports page
2. Verify tab bar appears at top
3. Tap "Investments" tab
4. Check what appears:
   - Empty state: "No investments yet" message
   - OR Portfolio Summary card + Investment list

**Status:** ⬜ PASS / ⬜ FAIL

**Screenshot:** (attach)

---

## 📋 TEST 7: INVESTMENT API INTEGRATION

### Expected Behavior (if backend has data):
- [ ] Portfolio Summary shows total value
- [ ] Portfolio Summary shows profit/loss
- [ ] Investment cards display correctly
- [ ] Pull to refresh works

### Testing Steps:
1. In Investments tab
2. If data exists, verify:
   - Portfolio Summary card shows values
   - Individual investment cards show:
     - Symbol (BTC, AAPL, etc.)
     - Quantity and prices
     - Profit/Loss in green (profit) or red (loss)
3. Pull down to refresh
4. Loading indicator appears
5. Data refreshes

**Status:** ⬜ PASS / ⬜ FAIL / ⬜ NO DATA TO TEST

**Screenshot:** (attach if data exists)

---

## 📋 TEST 8: LANGUAGE SWITCHING

### Expected Behavior:
- [ ] Profile > Settings > Language setting exists
- [ ] Can switch between English and Bahasa
- [ ] App text changes to selected language
- [ ] Language persists after restart

### Testing Steps:
1. Go to Profile page
2. Tap Settings
3. Tap Language
4. Switch between English and Bahasa Indonesia
5. Verify UI text changes
6. Restart app
7. Verify language is still selected

**Status:** ⬜ PASS / ⬜ FAIL

---

## 🐛 KNOWN ISSUES

| Issue | Status | Priority |
|-------|--------|----------|
| Income not appearing after restart | 🔍 INVESTIGATING | HIGH |
| Debug console not visible | ✅ FIXED | N/A |
| Investment error | ✅ FIXED | N/A |
| Type inference warnings | ✅ FIXED | N/A |

---

## 📊 OVERALL TEST RESULTS

**Date Tested:** _______________  
**Tested By:** _______________  
**Platform:** Chrome (Web)  
**Flutter Version:** _______________

### Summary:
- Tests Passed: ____ / 8
- Tests Failed: ____ / 8
- Critical Issues: ____
- Minor Issues: ____

### Critical Issues Found:
1. _________________________________
2. _________________________________
3. _________________________________

### Next Steps:
- [ ] Fix critical issues
- [ ] Retest failed tests
- [ ] Deploy to production

---

## 📸 REQUIRED SCREENSHOTS

Please attach screenshots for:

1. **Debug Console** - Bug button visible
2. **Debug Logs** - Income transaction being saved
3. **Dashboard** - Monthly Balance with income
4. **Report** - Spending Performance (2 lines: blue income, red expense)
5. **Category Breakdown** - Income filter selected
6. **Investment Tab** - Empty or with data
7. **After Restart** - Debug logs showing data loading

---

**Created:** June 22, 2026  
**Version:** 1.0  
**Status:** Ready for Testing ✅
