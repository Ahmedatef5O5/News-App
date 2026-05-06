<div align="center">

<br/>

<!-- PROJECT LOGO / BANNER -->
<img src="docs/assets/banner.png" alt="NewsWave Banner" width="100%" />

<br/>
<br/>

# 📰 NewsWave

### *Your world, curated — in real time.*

A **production-grade Flutter news application** delivering breaking headlines, personalized feeds, and offline-first reading — all wrapped in a polished, modern UI.

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.io)
[![Hive](https://img.shields.io/badge/Hive-Local_DB-FF7043?style=for-the-badge&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
[![NewsAPI](https://img.shields.io/badge/NewsAPI-v2-E53935?style=for-the-badge&logo=rss&logoColor=white)](https://newsapi.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

<br/>

[Features](#-features-at-a-glance) · [Screenshots](#-screenshots) · [Architecture](#-architecture-overview) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [Project Structure](#-project-structure) · [Roadmap](#-roadmap)

<br/>

</div>

---

## 🌊 What is NewsWave?

NewsWave is a **full-featured, production-ready news reader** built entirely in Flutter. It aggregates live news from [NewsAPI.org](https://newsapi.org), organizes articles by category, and keeps your reading experience fast — even when you're offline, thanks to intelligent Hive-backed caching.

Whether you're exploring as a guest, or signed in with a personalized profile, NewsWave adapts to you. Authenticated users get a tailored onboarding experience where they choose their country, hobbies, and preferred news categories — shaping a feed that's truly theirs.

> Built to showcase real-world Flutter patterns: clean architecture, reactive state management, secure authentication, offline-first data, and a UI that users will actually want to come back to.

---

## ✨ Features at a Glance

| Category | Features |
|---|---|
| 🔐 **Authentication** | Sign Up, Sign In, Forgot Password, Deep-Link Password Recovery, Guest Mode |
| 📰 **News Feed** | Breaking Headlines Carousel, "For You" paginated feed, 7 categories |
| 🔍 **Search** | Full-text search with 500ms debounce, infinite scroll, page-size 15 |
| 💾 **Offline** | Hive local cache for headlines & recommended articles per page |
| 🎨 **Theming** | Light / Dark mode with animated toggle, Poppins typography |
| 🧭 **Onboarding** | 3-step profile wizard (name, country/hobby, category preferences) |
| 📌 **Favorites** | Save articles locally, persisted across sessions via Hive |
| 🗂️ **Categories** | General, Business, Technology, Sports, Health, Entertainment, Science |
| 🚀 **Navigation** | Custom page transitions: Fade, Slide, Shared-Axis |
| 👤 **Profile** | Update display name, theme preference, sign out |

---

## 🔐 Authentication & Security

NewsWave uses **Supabase Auth** as the identity layer, with a clean `AuthRepository` abstraction so the data source can be swapped without touching the UI or state layers.

**Auth flows supported:**
- ✅ Email + Password Sign Up (with optional phone number)
- ✅ Email + Password Sign In
- ✅ Forgot Password (email link)
- ✅ Deep-link Password Recovery — the app intercepts `AuthChangeEvent.passwordRecovery` at the root level and routes directly to the Update Password screen
- ✅ Guest Mode — browse the app without an account; guest state is a first-class `AuthGuest` state in the Cubit
- ✅ Session persistence — `restoreSession()` on cold launch; user stays signed in across restarts
- ✅ Profile creation is handled server-side via a **Supabase trigger**, ensuring atomicity between the `auth.users` table and the public `profiles` table

```
AuthUserState
 ├── AuthInitial
 ├── AuthLoading
 ├── AuthAuthenticated(user, profile)   ← may need onboarding
 ├── AuthGuest
 ├── AuthUnauthenticated
 └── AuthError(message)
```

---

## 📰 Dynamic News Feed & Categories

The Home screen is split into two independent data streams:

**1. Breaking Headlines Carousel**
- Fetches `top-headlines` from NewsAPI
- Displayed as a full-bleed horizontal carousel with glassmorphism overlays
- Page size: 10 articles, cached in Hive under `cached_headlines`

**2. "For You" Recommended Feed**
- Fetches from `everything` endpoint, filtered by the active category
- Rendered as a paginated list with a visible **Page X of Y** counter
- Page size: 5 articles — each page individually cached (`rec_page_N`)
- Lazy-loads the next page when the user scrolls within 3 items of the bottom (`infiniteScrollThreshold`)

**Categories** are managed globally via `CategoryCubit` and surfaced as animated `FilterChip` pills. Switching categories triggers a fresh paginated fetch while preserving cached pages already loaded.

---

## 💾 Offline Support & Local Caching

All caching is handled through a **Hive** abstraction (`LocalDatabaseHive`) using a single box keyed by `articles_box`.

| Cache Key | Contents |
|---|---|
| `cached_headlines` | Latest top-headlines articles |
| `cached_recommended` | Most recent recommended page |
| `rec_page_N` | Individual page N of recommended articles |
| `favorite_articles` | User-saved articles (persisted indefinitely) |

Articles are serialized as `@HiveType` objects with generated adapters, ensuring blazing-fast reads and zero JSON overhead on the hot path. The `Article` model includes computed extensions (`cleanContent`, `cleanDescription`, `formattedDate`, `shortAuthor`) that strip NewsAPI's HTML fragments and truncation markers before any data hits the UI.

---

## 🔍 Advanced Search & Pagination

Search is built on a dedicated `SearchCubit` with these production-level details:

- **Debouncing** — 500ms `searchDebounce` timer; no API call fires until the user pauses typing
- **Retrofit + Dio** — type-safe HTTP client generated via `@RestApi` annotation
- **Paginated results** — page size 15, with a `paginationWindowSize` of 5 for the visible page controls
- **Max API results cap** — hard limit of 100 results respects NewsAPI's free-tier constraints
- **Infinite scroll** — triggers at 3 items from the bottom of the current page
- **Search scope** — queries the `/v2/everything` endpoint with `searchIn: 'title'` for higher-precision results

---

## 🎨 Theming & UI/UX

- **Light & Dark themes** fully defined via `AppTheme.light` / `AppTheme.dark` using Material 3 `ColorScheme`
- **Brand palette**: Primary `#1A73E8` (Google Blue), Dark `#0D47A1`, Accent `#FF6B35`
- **Typography**: Poppins font family across all text styles with carefully tuned weights
- **Animated shimmer** — custom `ShimmerBox` with `AnimationController` for skeleton loading states on both carousel cards and list rows
- **Theme persistence** — `ThemeCubit` saves and restores the user's mode preference via Hive
- **Animated background** — auth screens feature a subtle `_AnimatedBackground` widget using `SingleTickerProviderStateMixin`
- **Custom page transitions** — Fade (auth flows), Slide (list views), Shared-Axis (article detail)
- **Device preview** — `DevicePreview` enabled in debug mode for rapid multi-device testing

---

## 📱 Screenshots
<!--
> 📂 **To add your screenshots:** Place images inside `docs/screenshots/` in your repository, then replace the placeholder paths below. Recommended format: PNG, width 390px (iPhone 14 viewport). For a video demo, upload an `.mp4` or `.gif` to `docs/assets/` and embed it similarly.
-->
<br/>



<table>
  <tr>
    <td align="center" valign="top">
      <img width="290" height="599" alt="sign_up_view" src="https://github.com/user-attachments/assets/6e7cbe72-2b7a-4dcb-9700-dd270a564887" />
      <br/><sub><b>Sign Up</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="sign_in_view" src="https://github.com/user-attachments/assets/302f1e95-ca31-46f4-9040-a8516994d7b2" />
      <br/><sub><b>Sign In</b></sub>
    </td>
    <td align="center" valign="top">
      <img width="290" height="599" alt="reset_password_view" src="https://github.com/user-attachments/assets/0b5b2476-71df-40e6-8285-8555fee5a003" />
      <br/><sub><b>Forgot Password</b></sub>
    </td>
    <td align="center" valign="top">
      <img width="293" height="610" alt="set_new_password" src="https://github.com/user-attachments/assets/8b53ef68-cdf6-4680-961a-903a2dbce6eb" />
      <br/><sub><b>Update Password</b></sub>
    </td>
  </tr>

  <tr>
    <td align="center" valign="top">
      <img width="290" height="599" alt="onboarding_step_one" src="https://github.com/user-attachments/assets/642d0a6f-c214-456d-9cf5-a155fcdc351d" />
      <br/><sub><b>Onboarding — Step 1</b><br/><i>Name & Details</i></sub>
    </td>
    <td align="center" valign="top">
      <img width="290" height="599" alt="onboarding_step_two" src="https://github.com/user-attachments/assets/1837ea9a-44b7-43a9-be8a-54d00e2b90e0" />
      <br/><sub><b>Onboarding — Step 2</b><br/><i>Country & Hobby</i></sub>
    </td>
    <td align="center" valign="top">
      <img width="290" height="599" alt="onboarding_step_three" src="https://github.com/user-attachments/assets/b9d4d86f-c695-4aa2-877c-e55a3901a94a" />
      <br/><sub><b>Onboarding — Step 3</b><br/><i>News Categories</i></sub>
    </td>
    <td align="center" valign="top">
      <img width="293" height="611" alt="home_view" src="https://github.com/user-attachments/assets/58118132-8b1b-4a7d-8a91-dd70bb25f109" />
      <br/><sub><b>Home View</b><br/><i>(Light Mode)</i></sub>
    </td>
  </tr>

  <tr>
    <td align="center" valign="top">
     <img width="290" height="599" alt="home_feed_view" src="https://github.com/user-attachments/assets/b5f815a7-1e3d-4be8-a2d2-0a2029ee8a67" />
      <br/><sub><b>Home View</b><br/><i>(Dark Mode)</i></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="article_details_view" src="https://github.com/user-attachments/assets/e7535c0f-bd07-4b87-bf1a-81107e330d7f" />
      <br/><sub><b>Article Details</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="search_view" src="https://github.com/user-attachments/assets/e95f7d4a-52a1-43dd-97a8-a3c0b02c817c" />
      <br/><sub><b>Search View</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="293" height="611" alt="saved_articles_view" src="https://github.com/user-attachments/assets/a102cedd-3752-459b-8d9c-7d35f07b6a1e" />
      <br/><sub><b>Saved Articles</b></sub>
    </td>
  </tr>
  
  <tr>
    <td align="center" valign="top">
     <img width="290" height="599" alt="drawer_app" src="https://github.com/user-attachments/assets/f71d9ad8-d921-4562-a2d2-038fbdf3e424" />
      <br/><sub><b>App Drawer</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="headlines_view_all" src="https://github.com/user-attachments/assets/3dccc65d-7f0c-4bcf-9eb1-d46ea2a00d4e" />
      <br/><sub><b>Headlines (View All)</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="for_you_pagination" src="https://github.com/user-attachments/assets/7f7b3d0a-9cb2-4c40-b8fe-ba7eda93d2b1" />
      <br/><sub><b>For You Section</b></sub>
    </td>
    <td align="center" valign="top">
     <img width="290" height="599" alt="profile_settings_view" src="https://github.com/user-attachments/assets/57ae01ae-4221-4fdb-bb38-e1d88abfd45c" />
      <br/><sub><b>Profile Settings</b></sub>
    </td>
  </tr>

</table>
<br/>
<!--
> 💡 **How to add your screenshots to GitHub:**
> 1. Create a `docs/screenshots/` folder in the root of your repository.
> 2. Drag and drop your `.png` files with the exact filenames shown above.
> 3. Commit and push — the images will render automatically in this README.
> 4. For a video demo, upload a `.gif` (created with [LICEcap](https://www.cockos.com/licecap/) or [ScreenToGif](https://www.screentogif.com/)) to `docs/assets/demo.gif` and embed it at the top of this file.
-->


## 🏗️ Architecture Overview

NewsWave follows a **feature-first, clean-ish layered architecture** with a shared `core` module:

```
lib/
├── core/                          # Shared infrastructure
│   ├── constants/                 # AppConstants, NewsCategory enum
│   ├── cubits/                    # CategoryCubit (global)
│   ├── models/                    # Article, Source (Hive + JSON)
│   ├── router/                    # AppRouter, AppRoutes
│   ├── secrets/                   # AppSecrets (reads .env)
│   ├── services/                  # DioClient (singleton), LocalDatabaseHive
│   ├── theme/                     # AppTheme, AppColors, ThemeCubit
│   └── widgets/                   # Shared: CategoryChips, ShimmerBox,
│                                  #         EmptyState, ErrorState, AppDrawer
│
└── features/
    ├── auth/                      # AuthCubit, AuthRepository, Auth Views
    │   ├── cubit/                 #   auth_cubit.dart · auth_state.dart
    │   ├── data/                  #   auth_repository.dart (interface + impl)
    │   └── views/                 #   SignIn, SignUp, ForgotPassword, UpdatePassword
    ├── Home/                      # HomeView, HeadlinesCubit, RecommendedCubit
    ├── Headlines/                 # HeadlinesView (full-screen carousel list)
    ├── search/                    # SearchCubit, SearchServicesRetrofit, SearchView
    ├── favorites/                 # FavoritesCubit (Hive-backed), FavoritesView
    ├── profile/                   # ProfileSettingsView
    ├── onboarding/                # 3-step OnboardingView wizard
    └── splash/                    # SplashView (session restore + routing logic)
```

**Data flow per feature:**

```
UI (View)
  └─► Cubit (state logic)
        └─► Repository (interface)
              └─► Impl (Supabase / Retrofit / Hive)
```

The `core` layer has **zero dependency on any feature**. Features may only depend on `core`, never on each other.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter 3.x | Cross-platform UI |
| **Language** | Dart 3.x | Null-safe, strong-typed |
| **State Management** | `flutter_bloc` / Cubit | Predictable reactive state |
| **Backend / Auth** | Supabase | Auth, Postgres DB, Realtime |
| **News Data** | NewsAPI v2 | Headlines & search endpoints |
| **HTTP Client** | Dio + Retrofit | Type-safe REST, singleton client |
| **Local Database** | Hive | NoSQL key-value, offline cache |
| **Environment** | `flutter_dotenv` | Secrets management via `.env` |
| **Routing** | `onGenerateRoute` | Named routes with custom transitions |
| **Fonts** | Poppins | Consistent brand typography |
| **Dev Tools** | DevicePreview | Multi-device debug preview |
| **Code Generation** | `build_runner` | Hive adapters, Retrofit clients |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A [NewsAPI.org](https://newsapi.org/register) API key (free tier)
- A [Supabase](https://supabase.com) project with Auth enabled

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/news_wave.git
cd news_wave
```

### 2. Configure Environment Variables

Create a `.env` file in the project root:

```env
# .env
NEWS_API_KEY=your_newsapi_key_here
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

> ⚠️ Never commit `.env` to version control. It is already listed in `.gitignore`.

### 3. Supabase Setup

In your Supabase dashboard:

1. Enable **Email Auth** under Authentication → Providers.
2. Create a `profiles` table with at least these columns:

```sql
create table public.profiles (
  id          uuid references auth.users on delete cascade primary key,
  first_name  text,
  last_name   text,
  country     text,
  hobby       text,
  categories  text[],
  is_onboarded boolean default false
);
```

3. Create a **trigger** to auto-insert a profile row on new user sign-up:

```sql
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

4. Enable **deep-link redirect** for password recovery (add your app's redirect URL in Authentication → URL Configuration).

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run Code Generation

Required for Hive TypeAdapters and Retrofit clients:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Run the App

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device_id>
```

---

## 📁 Project Structure

```
news_wave/
├── .env                          # ← create this (see setup)
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # App entry: Supabase init, Hive init, BlocProviders
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart        # API urls, pagination sizes, cache keys
│   │   │   ├── app_images.dart           # Asset path constants
│   │   │   └── app_constants.dart        # NewsCategory enum
│   │   ├── cubits/
│   │   │   └── category_cubit.dart       # Global active-category state
│   │   ├── models/
│   │   │   ├── article_model.dart        # @HiveType Article + Source + extensions
│   │   │   └── article_model.g.dart      # Generated Hive adapter
│   │   ├── router/
│   │   │   ├── app_router.dart           # onGenerateRoute + transition builders
│   │   │   └── app_routes.dart           # Route name constants
│   │   ├── secrets/
│   │   │   └── app_secrets.dart          # Reads .env values
│   │   ├── services/
│   │   │   ├── dio_client.dart           # Singleton Dio with base config & logging
│   │   │   └── local_database_hive.dart  # Hive init, box helpers
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Brand color palette
│   │   │   ├── app_theme.dart            # Light + Dark ThemeData
│   │   │   ├── theme_cubit.dart          # ThemeCubit (persists to Hive)
│   │   │   └── model/theme_model.dart
│   │   └── widgets/
│   │       ├── drawer/
│   │       │   ├── app_drawer.dart
│   │       │   └── guest_header_widget.dart
│   │       ├── category_chips.dart       # Animated FilterChip row
│   │       ├── empty_state.dart
│   │       ├── error_state.dart
│   │       └── shimmer/
│   │           ├── shimmer_box.dart
│   │           ├── article_card_skeleton.dart
│   │           └── carousel_card_skeleton.dart
│   └── features/
│       ├── auth/
│       │   ├── cubit/
│       │   │   ├── auth_cubit.dart       # signIn/Up/Out, guest, password reset
│       │   │   └── auth_state.dart       # AuthInitial|Loading|Authenticated|Guest|Error
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   └── auth_repository_impl.dart
│       │   └── views/
│       │       ├── sign_in_view.dart
│       │       ├── sign_up_view.dart
│       │       ├── forgot_password_view.dart
│       │       └── update_password_view.dart
│       ├── Home/
│       │   └── views/
│       │       ├── home_view.dart
│       │       └── article_details_view.dart
│       ├── Headlines/
│       │   └── views/headlines_view.dart
│       ├── search/
│       │   ├── Search_cubit/search_cubit.dart
│       │   ├── services/search_services_retrofit.dart  # @RestApi
│       │   └── views/search_view.dart
│       ├── favorites/
│       │   ├── favorite_cubit/favorite_cubit.dart
│       │   └── views/favorites_view.dart
│       ├── profile/
│       │   └── views/profile_settings_view.dart
│       ├── onboarding/
│       │   └── views/onboarding_view.dart  # 3-page PageView wizard
│       └── splash/
│           └── view/splash_view.dart
├── assets/
│   └── images/icons/             # App icon assets
└── docs/
    └── screenshots/              # ← add your screenshots here
```

---

## ⚙️ Key Implementation Details

**Pagination architecture:** Each page of recommended articles is independently cached using the key prefix `rec_page_N`. On cache hit, the UI renders instantly; on miss, a Retrofit call is made and the result is written to Hive before emission. This means pages the user has already seen are always available offline.

**Auth deep-link handling:** The `navigatorKey` is registered at the `MaterialApp` level and used inside `main()` to intercept `AuthChangeEvent.passwordRecovery` from Supabase's auth stream — routing the user to `UpdatePasswordView` regardless of which screen they're currently on.

**Singleton Dio client:** `DioClient._()` uses a private constructor and a static `_instance` field. All features share the same configured `Dio` instance with base URL, auth header injection, logging interceptor, and retry logic.

**Article model cleanliness:** The `ArticleExtension` strips HTML tags, resolves HTML entities, and removes NewsAPI's `[+N chars]` truncation suffix from `content` — so the UI always receives clean, renderable text.

---

## 🗺️ Roadmap

Based on the current codebase, these are the most impactful improvements that would push NewsWave from portfolio-ready to production-ready:

- [ ] **Push Notifications** — Supabase Realtime or FCM integration for breaking news alerts
- [ ] **Social Auth** — Google / Apple Sign-In via Supabase OAuth providers
- [ ] **Article Web View** — In-app `WebView` or `url_launcher` to open full articles
- [ ] **Share Article** — Native share sheet via `share_plus`
- [ ] **Personalized Feed Algorithm** — Weight recommended articles by onboarding category preferences
- [ ] **Connectivity Banner** — Real-time offline/online indicator using `connectivity_plus`
- [ ] **Unit & Widget Tests** — Cubit state tests, widget golden tests for core components
- [ ] **CI/CD Pipeline** — GitHub Actions for lint, test, and Flutter build on each PR
- [ ] **Localization (i18n)** — `flutter_localizations` + ARB files for Arabic and English
- [ ] **Accessibility** — Semantic labels, sufficient color contrast audit, dynamic text scaling

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change. For pull requests:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

---

<div align="center">

Built with ❤️ using Flutter

<br/>

*If this project helped you, please consider giving it a ⭐ — it means a lot!*

</div>
