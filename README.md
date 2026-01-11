# TeklifimGelsin Task – Bulletin Feature (Flutter)

This project is a simplified, two-screen implementation of TeklifimGelsin’s **Weekly Financial Bulletin** feature.

It includes:
- **Bulletin List** (paginated, infinite scroll, pull-to-refresh)
- **Bulletin Detail** (Markdown rendering + link handling)

## ✅ Features

### Bulletin List Screen
- Fetches bulletin posts from a **live API** (paginated)
- **Infinite scrolling**: automatically loads next page when reaching the bottom
- Uses `_meta` object from API to determine `currentPage` / `totalPages`
- **Pull-to-refresh**: clears list and fetches page 1 again
- Loading & error UI states
- Tap an item to navigate to detail screen (passes `pathname`)

#### (Bonus) Date Handling from API
The list response includes `created_at` (e.g. `"Mon, 05 Jan 2026 07:45:26 GMT"`).  
This project can optionally:
- Parse the API date and display a **relative time** on the card (e.g. `Bugün`, `Dün`, `3 gün önce`)
- Or display a localized formatted date (e.g. `5 Ocak 2026`)

#### (Bonus) Date Range Categorization / Grouping
Bulletins can be categorized/grouped by date range, for example:
- **Bugün**
- **Son 7 Gün**
- **Son 30 Gün**
- **Daha Eski**

This can be used to render the list as **sectioned list** with headers.

### Bulletin Detail Screen
- Fetches bulletin detail by `pathname`
- Renders `content` (Markdown) using `flutter_markdown`
- Opens links using `url_launcher`

## 🧱 Tech Stack
- Flutter (null safety)
- **Riverpod** (StateNotifier + providers)
- **Dio** (network layer)
- `flutter_markdown` (Markdown rendering)
- `cached_network_image` (image caching)
- `url_launcher` (open links)
- `google_fonts` (Inter font)

## 📡 API Endpoints

### 1) Bulletin List (Paginated)
- **GET** `https://api2.teklifimgelsin.com/api/blog/blogs`
- Query params:
  - `type=bulletin`
  - `page`
  - `per_page`

### 2) Bulletin Detail
- **GET** `https://api2.teklifimgelsin.com/api/getBlogPost`
- Query params:
  - `pathname`

## 📁 Project Structure

lib/
   main.dart
   theme/
     app_theme.dart
   models/
     bulletin_post.dart
     pagination_meta.dart
   services/
     bulletin_service.dart
   providers/
     providers.dart
   screens/
     bulletin_list_screen.dart
     bulletin_detail_screen.dart
