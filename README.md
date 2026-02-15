# Budjar - Modern Expense Tracker 💰

A beautiful and modern expense tracking application built with Flutter. Track your expenses, manage budgets, and gain insights into your spending habits with elegant charts and analytics.

## ✨ Features

### 🏠 Dashboard

- **Financial Overview**: Quick summary of total balance, monthly income, and expenses
- **Beautiful Charts**: Visual representation of spending by category
- **Budget Progress**: Track your budget goals with progress indicators
- **Recent Transactions**: Quick access to your latest financial activities

### 📊 Smart Analytics

- **Spending Insights**: Detailed breakdown of expenses by category
- **Trend Analysis**: Monthly and yearly spending trends
- **Savings Rate**: Track your saving goals and progress
- **Custom Reports**: Generate reports for specific time periods

### 💳 Account Management

- **Multiple Accounts**: Support for checking, savings, credit cards, cash, and investment accounts
- **Balance Tracking**: Real-time balance updates with transactions
- **Account Types**: Categorize accounts with custom colors and icons

### 🎯 Budget Control

- **Smart Budgets**: Set monthly, weekly, or yearly budget limits
- **Progress Tracking**: Visual progress bars and percentage indicators
- **Budget Alerts**: Get notified when approaching or exceeding budget limits
- **Category Budgets**: Set specific budgets for different expense categories

### 📱 Modern UI/UX

- **Material Design 3**: Clean and modern interface following latest design principles
- **Dark/Light Theme**: Automatic theme switching based on system preference
- **Responsive Design**: Works perfectly on phones and tablets
- **Smooth Animations**: Delightful transitions and micro-interactions

### 🔒 Premium Features

- **Unlimited Accounts**: Create as many accounts as you need
- **Advanced Analytics**: Detailed reports and insights
- **Data Export**: Export your data to CSV format
- **Cloud Backup**: Secure cloud synchronization
- **Custom Categories**: Create unlimited custom categories
- **Recurring Transactions**: Automate regular income and expenses

## 🏗️ Architecture

The app follows clean architecture principles with clear separation of concerns:

```
lib/
├── components/          # Reusable UI components
├── database/           # SQLite database management
├── models/             # Data models
├── providers/          # State management with Provider
├── screens/            # App screens and pages
├── theme/              # App theming and styles
└── utils/              # Utilities and constants
```

### 🗄️ Database Schema

- **Accounts**: Store bank accounts and financial accounts
- **Categories**: Organize transactions by type (food, transport, etc.)
- **Transactions**: Record all income and expense transactions
- **Budgets**: Set and track spending limits

### 📊 State Management

- **Provider Pattern**: Efficient state management with Flutter Provider
- **Real-time Updates**: Automatic UI updates when data changes
- **Local Storage**: All data stored locally with SQLite for privacy and performance

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.7.2)
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/budjar.git
   cd budjar
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **sqflite**: Local SQLite database
- **provider**: State management
- **fl_chart**: Beautiful charts and graphs
- **google_fonts**: Typography
- **intl**: Internationalization and formatting
- **uuid**: Unique ID generation
- **shared_preferences**: Local preferences storage

## 🎨 Screenshots

[Screenshots will be added here]

## 🛣️ Roadmap

- [ ] **Transaction Management**: Full CRUD operations for transactions
- [ ] **Advanced Analytics**: More detailed reports and insights
- [ ] **Export/Import**: Data backup and restore functionality
- [ ] **Recurring Transactions**: Automatic transaction creation
- [ ] **Multi-currency Support**: Support for different currencies
- [ ] **Cloud Sync**: Backup data to cloud services
- [ ] **Notifications**: Budget alerts and reminders
- [ ] **Categories Management**: Custom category creation and editing
- [ ] **Search & Filter**: Advanced transaction search capabilities
- [ ] **Settings**: App customization and preferences

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages that made this project possible
- Material Design team for the beautiful design system

---

**Made with ❤️ by [Your Name]**

_Transform your financial habits with Budjar - where every expense tells a story._
