# Dashboard Flutter - Project Structure

## 📁 Folder Structure

```
lib/
├── main.dart                    # Entry point - Configure app theme & routing
├── constants/
│   ├── colors.dart             # All app colors following Material Design 3
│   └── index.dart              # Export file for easy importing
├── widgets/                     # Reusable UI components
│   ├── top_app_bar.dart        # Top navigation bar with profile & notifications
│   ├── balance_card.dart       # Hero balance display card with mascot
│   ├── stats_grid.dart         # Bento grid with stat cards (Daily Expense, Budget, Income)
│   ├── spending_trends_chart.dart # Weekly spending chart with hover effects
│   ├── bottom_nav_bar.dart     # Bottom navigation with 5 main tabs
│   ├── quick_add_fab.dart      # Floating action button
│   └── index.dart              # Export file for easy importing
├── pages/
│   ├── dashboard_page.dart     # Main dashboard page - combines all widgets
│   └── index.dart              # Export file for easy importing
```

## 🎨 Component Breakdown

### 1. **TopAppBar** (`widgets/top_app_bar.dart`)
- Displays user profile picture & greeting
- Notification button
- Fixed at top of screen

### 2. **BalanceCard** (`widgets/balance_card.dart`)
- Large hero card showing total balance
- Decorative sparkles background
- Mascot avatar with speech bubble
- Shows motivational message

### 3. **StatsGrid** (`widgets/stats_grid.dart`)
- **Daily Expense Card**: Shows today's spending
- **Budget Left Card**: Remaining budget for month
- **Income Card**: Full-width income display with trend indicator
- Uses Bento grid layout pattern

### 4. **SpendingTrendsChart** (`widgets/spending_trends_chart.dart`)
- Interactive bar chart showing 7-day spending
- Hover effects on bars
- Responsive height based on data
- Material Design 3 style

### 5. **BottomNavBar** (`widgets/bottom_nav_bar.dart`)
- 5 navigation items: Dashboard, History, Add, Reports, Profile
- Active state highlighting
- Smooth animations

### 6. **QuickAddFAB** (`widgets/quick_add_fab.dart`)
- Floating action button for quick add action
- Positioned above bottom nav

### 7. **DashboardPage** (`pages/dashboard_page.dart`)
- Main page combining all components
- Handles navigation logic
- Manages state between components

## 🎯 Color System

All colors are defined in `constants/colors.dart` following Material Design 3:
- **Primary**: `#2c5f87`
- **Secondary**: `#794f61`
- **Tertiary**: `#605e20`
- **Background**: `#f4f6ff`
- **Surface variants for depth

## 🚀 How to Use Components

### Import method 1 (Recommended):
```dart
import 'package:my_manage/constants/index.dart';
import 'package:my_manage/widgets/index.dart';
import 'package:my_manage/pages/index.dart';

// Now use components directly
const TopAppBar()
const BalanceCard()
const StatsGrid()
```

### Import method 2 (Specific):
```dart
import 'package:my_manage/widgets/balance_card.dart';
import 'package:my_manage/constants/colors.dart';

const BalanceCard()
```

## 📱 Widget Hierarchy

```
DashboardPage
├── TopAppBar
├── SingleChildScrollView (Main Content)
│   └── Column
│       ├── BalanceCard
│       ├── StatsGrid
│       └── SpendingTrendsChart
├── QuickAddFAB
└── BottomNavBar
```

## 🎨 Theme Configuration

The app uses Material Design 3 with:
- Seed color: Primary brand color
- Custom color palette with semantic colors
- Font family: "Be Vietnam Pro" for body text

## 🔧 Extending the Project

### To add a new component:
1. Create a new file in `lib/widgets/my_component.dart`
2. Implement the widget class
3. Add export to `lib/widgets/index.dart`
4. Import and use in pages

### To add new colors:
1. Add color definition to `lib/constants/colors.dart`
2. Use `AppColors.colorName` throughout the app

### To add new pages:
1. Create a new file in `lib/pages/my_page.dart`
2. Implement the page widget
3. Add export to `lib/pages/index.dart`
4. Add navigation in `DashboardPage`

## 📊 Responsive Design

- Uses responsive widgets (Expanded, Flexible)
- Safe padding and spacing
- Works on mobile, tablet, and desktop
- Material Design 3 adaptive layouts

## 🎬 Getting Started

1. Run `flutter pub get`
2. Run `flutter run`
3. App will display the dashboard with all components

## 📝 Notes

- All components use Material Design 3
- Images are loaded from network (can be replaced with local assets)
- Error handling for image failures with fallback icons
- Smooth animations and transitions throughout
