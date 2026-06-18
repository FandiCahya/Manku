# Spending Performance Chart Update

## Changes Made

### Before (Horizontal Segmented Bar)
```
┌────────────────────────────────────────┐
│ Spending Performance              ⋯    │
├────────────────────────────────────────┤
│ ████████████████░░░░░░░░░░             │ ← Horizontal bar
│ ● Mon  ● Tue  ● Wed  ● Thu  ● Fri      │
│ 25K    30K    20K    15K    35K        │
└────────────────────────────────────────┘
```

### After (Vertical Bar Chart with Rounded Tops)
```
┌────────────────────────────────────────┐
│ Spending Performance              ⋯    │
│ 7 Hari Terakhir                        │
├────────────────────────────────────────┤
│        35K  30K  25K  20K  15K         │ ← Amount labels
│         ▓    ▓    ▓    ▓    ▓          │
│         █    █    █    █    █          │
│         █    █    █    █    █          │ ← Rounded bars
│         █    █    █    █    █          │
│         █    █    █    █    █          │
│        Mon  Tue  Wed  Thu  Fri         │ ← Day labels
└────────────────────────────────────────┘
```

## Features

### 1. **Vertical Bar Chart**
- 7 bars untuk 7 hari terakhir
- Height proportional to spending amount
- Min height: 8px (untuk visibility)
- Max height: 120px

### 2. **Rounded Top Bars**
- BorderRadius di bagian atas: 8px
- Creates "oval/rounded" effect
- Smooth gradient (light to dark blue)

### 3. **Visual Enhancements**
- Gradient fill (top lighter, bottom darker)
- Box shadow untuk depth effect
- Amount label di atas bar
- Day label di bawah bar

### 4. **Responsive Design**
- Auto-scale berdasarkan data terbesar
- Equal spacing dengan `Expanded` widget
- Padding: 4px horizontal between bars

### 5. **Dark Theme Support**
- Card background: `#1D3448` (dark blue)
- Text colors adjusted
- Bar gradient tetap blue untuk consistency

## Technical Details

### Layout Structure
```dart
Column
├─ Header (Title + Icon)
├─ Subtitle ("7 Hari Terakhir")
└─ Row (7 bars)
   └─ Each bar:
      ├─ Amount label (top)
      ├─ Rounded container (bar)
      └─ Day label (bottom)
```

### Bar Height Calculation
```dart
final maxDisplayAmount = max(all amounts);
final barHeight = (amount / maxDisplayAmount * 120)
    .clamp(8.0, 120.0);
```

### Styling
```dart
Container(
  height: barHeight,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primary.withOpacity(0.8),  // Lighter top
        primary,                    // Darker bottom
      ],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8),   // Rounded corners
      topRight: Radius.circular(8),
    ),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

## Data Flow

### 1. Get Last 7 Days
```dart
displayDays = trends
  .sort((a, b) => b.date.compareTo(a.date))  // Most recent first
  .take(7)                                    // Get 7 days
  .reversed                                   // Oldest to newest (left to right)
```

### 2. Find Max Amount
```dart
maxDisplayAmount = displayDays
  .map((d) => d.amount)
  .reduce((a, b) => a > b ? a : b);
```

### 3. Render Each Bar
```dart
for (day in displayDays) {
  barHeight = (day.amount / maxDisplayAmount) * 120;
  // Render bar with height
}
```

## Example Output

### With Data
```
Spending Performance                    ⋯
7 Hari Terakhir

35K   30K   25K   20K   15K   10K   5K
 █     █     █     █     █     █    █
 █     █     █     █     █     █    █
 █     █     █     █     █     █    █
 █     █     █     █     █     █    
 █     █     █     █     █         
 █     █     █     █               
Mon   Tue   Wed   Thu   Fri   Sat  Sun
```

### No Data
```
Spending Performance                    ⋯
7 Hari Terakhir

        Belum ada data pengeluaran.
```

### Loading
```
Spending Performance                    ⋯
7 Hari Terakhir

              ⟳ Loading...
```

## Benefits

✅ **Better Data Visualization**
- Easier to compare day-by-day spending
- Height represents amount directly
- Clear visual hierarchy

✅ **Modern Design**
- Rounded bars for softer look
- Gradient adds depth
- Shadow for 3D effect

✅ **More Informative**
- Shows exact amounts above bars
- Clear day labels below
- Subtitle explains timeframe

✅ **Professional Look**
- Clean and minimal
- Consistent with app theme
- Follows Material Design principles

## Color Scheme

**Light Theme:**
- Background: White
- Bars: Blue gradient (#6A89A7)
- Text: Dark gray (#1E1E1E)
- Secondary text: Medium gray (#6B7280)

**Dark Theme:**
- Background: Dark blue (#1D3448)
- Bars: Blue gradient (same)
- Text: White
- Secondary text: White70

## File Modified
- `lib/widgets/spending_trends_chart.dart`

## Testing
```bash
# Run app
flutter run

# Check:
- [ ] 7 bars displayed
- [ ] Rounded tops visible
- [ ] Amounts shown above bars
- [ ] Days shown below bars
- [ ] Gradient visible
- [ ] Shadow visible
- [ ] Dark theme works
- [ ] Empty state works
- [ ] Loading state works
```

## Future Enhancements
- [ ] Add animation on load
- [ ] Add tap to show details
- [ ] Add horizontal grid lines
- [ ] Add Y-axis with amount scale
- [ ] Add comparison with previous week
- [ ] Add filter (week/month/year)
