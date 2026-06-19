
<div align="center">

<br/>

<!-- PROJECT LOGO / BANNER -->
<img src="https://github.com/user-attachments/assets/0399d929-5597-4c01-881b-d26556d2c98d" alt="NewsWave Banner" width="100%" />

<br/>
<br/>

<!-- # 📰 NewsWave -->
<h1 style="
  display:flex;
  align-items:center;
  justify-content:center;
  gap:12px;
  line-height:1;
">
 <!-- <img width="1024" height="1024" alt="icon_1024x1024" src="https://github.com/user-attachments/assets/d3c62407-3a37-484d-9424-cd6cc8db9f4b" /> -->
  <img
    src="https://github.com/user-attachments/assets/d3c62407-3a37-484d-9424-cd6cc8db9f4b"
    alt="NewsWave App Icon"
    width="25"
    height="25"
    style="border-radius:10px; display:block;"
  />
  <span style="display:block;">NewsWave</span>
</h1>


### *Your world, curated — in real time.*
<!--### *Your world, curated — in real time. بلغتك، كما تريد.*-->

A **production-grade Flutter news application** delivering breaking headlines, personalized feeds, and offline-first reading — fully bilingual (English / Arabic) with reactive RTL support, all wrapped in a polished, modern UI.

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.io)
[![Hive](https://img.shields.io/badge/Hive-Local_DB-FF7043?style=for-the-badge&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
[![NewsAPI](https://img.shields.io/badge/NewsAPI-v2-E53935?style=for-the-badge&logo=rss&logoColor=white)](https://newsapi.org)
[![i18n](https://img.shields.io/badge/i18n-EN_%7C_AR-6f42c1?style=for-the-badge&logo=googletranslate&logoColor=white)](#-localization--i18n)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

<br/>

[Features](#-features-at-a-glance) · [Screenshots](#-screenshots) · [Architecture](#-architecture-overview) · [Localization](#-localization--i18n) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [Project Structure](#-project-structure) · [Roadmap](#-roadmap)

<br/>

</div>

---

## 🌊 What is NewsWave?

NewsWave is a **full-featured, production-ready news reader** built entirely in Flutter. It aggregates live news from [NewsAPI.org](https://newsapi.org), organizes articles by category, and keeps your reading experience fast — even when you're offline, thanks to intelligent Hive-backed caching.

Whether you're exploring as a guest, or signed in with a personalized profile, NewsWave adapts to you. Authenticated users get a tailored onboarding experience where they choose their country, hobbies, and preferred news categories — shaping a feed that's truly theirs.

> Built to showcase real-world Flutter patterns: clean architecture, reactive state management, secure authentication, offline-first data, full app-wide localization (EN/AR) with RTL support, and a UI that users will actually want to come back to.

---

## ✨ Features at a Glance

| Category | Features |
|---|---|
| 🔐 **Authentication** | Sign Up, Sign In, Forgot Password, Deep-Link Password Recovery, Guest Mode |
| 📰 **News Feed** | Breaking Headlines Carousel, "For You" paginated feed, 7 categories |
| 🔍 **Search** | Full-text search with 500ms debounce, infinite scroll, page-size 15 |
| 🌍 **Localization** | Full English / Arabic support, reactive RTL/LTR layout switching, locale-aware API requests |
| 💾 **Offline** | Hive local cache for headlines & recommended articles per page |
| 🎨 **Theming** | Light / Dark mode with animated toggle, locale-aware typography (Poppins / Cairo) |
| 🧭 **Onboarding** | 3-step profile wizard (name, country/hobby, category preferences) |
| 📌 **Favorites** | Save articles locally, persisted across sessions via Hive |
| 🗂️ **Categories** | General, Business, Technology, Sports, Health, Entertainment, Science |
| 🚀 **Navigation** | Custom page transitions: Fade, Slide, Shared-Axis |
| 👤 **Profile** | Update display name, theme preference, language preference, sign out |

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
- English locale fetches `top-headlines` from NewsAPI; Arabic locale fetches `everything` with curated Arabic-language category queries, since `top-headlines` has no reliable Arabic coverage
- Displayed as a full-bleed horizontal carousel with glassmorphism overlays
- Page size: 10 articles, cached in Hive under `cached_headlines`

**2. "For You" Recommended Feed**
- Mirrors the same locale-aware endpoint switch as the carousel, filtered by the active category
- Rendered as a paginated list with a visible **Page X of Y** counter
- Page size: 5 articles — each page individually cached (`rec_page_N`)
- Lazy-loads the next page when the user scrolls within 3 items of the bottom (`infiniteScrollThreshold`)

**Categories** are managed globally via `CategoryCubit` and surfaced as animated `FilterChip` pills, with category labels pulled from the active `AppLocalizations`. Switching categories triggers a fresh paginated fetch while preserving cached pages already loaded. Both the headlines and recommended feed cubits subscribe to `LocaleCubit`'s stream, so switching the app language re-fetches and re-localizes the feed automatically — no manual refresh required.

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

## 🌍 Localization & i18n

NewsWave is fully localized into **English and Arabic**, driven by a reactive `LocaleCubit` rather than a static, restart-required setting.

- **`flutter_localizations` + ARB files** — all UI strings (navigation, dialogs, errors, validation messages, category labels, hobby labels) are generated through `AppLocalizations`, with zero hardcoded copy in the widget tree
- **`LocaleCubit`** — a `Cubit<Locale>` that persists the chosen language to a dedicated Hive `settings_box`, restores it on cold launch, and exposes a one-tap `toggle()` between English and Arabic
- **Reactive RTL/LTR layout** — `Directionality` flips automatically with the locale; layout-sensitive widgets use `EdgeInsetsDirectional` and locale-aware icon mirroring (e.g. back/forward chevrons) instead of hardcoded left/right values
- **Locale-aware typography** — `AppTheme.of(locale: ..., brightness: ...)` swaps the active font family (Poppins for English, Cairo for Arabic) at the `ThemeData` level
- **Locale-aware data fetching** — `HomeCubit` and `HeadlinesCubit` both subscribe to `LocaleCubit`'s stream and re-fetch automatically when the language changes, so headlines, the recommended feed, and category labels stay in sync with the active locale without any manual screen refresh
- **On-device article translation** — articles fetched for the Arabic locale are passed through an `ArticleTranslationRepository`, which translates and caches the title/description/content per article so repeat views don't re-hit the translation API
- **Language picker** — a dedicated `LanguagePickerDialog` lets the user choose their language explicitly from the Drawer or Profile Settings, in addition to the quick `toggle()` shortcut

```
LocaleCubit
 ├── init()        → reads persisted locale from Hive on app start
 ├── setLocale(_)  → persists + emits a new Locale
 └── toggle()      → flips between Locale('en') and Locale('ar')
```

---

## 🔍 Advanced Search & Pagination

Search is built on a dedicated `SearchCubit` with these production-level details:

- **Debouncing** — 500ms `searchDebounce` timer; no API call fires until the user pauses typing
- **`SearchService`** — a thin, plain-Dio service wired through the service locator (a `@RestApi`-annotated `SearchServicesRetrofit` interface also exists in the codebase as an alternative typed-client implementation, generated via `build_runner`)
- **Paginated results** — page size 15, with a `paginationWindowSize` of 5 for the visible page controls
- **Max API results cap** — hard limit of 100 results respects NewsAPI's free-tier constraints
- **Infinite scroll** — triggers at 3 items from the bottom of the current page
- **Search scope** — queries the `/v2/everything` endpoint with `searchIn: 'title'` for higher-precision results

---

## 🎨 Theming & UI/UX

- **Light & Dark themes** fully defined via `AppTheme.light` / `AppTheme.dark` using Material 3 `ColorScheme`
- **Brand palette**: Primary `#1A73E8` (Google Blue), Dark `#0D47A1`, Accent `#FF6B35`
- **Typography**: locale-aware font selection — Poppins for English, Cairo for Arabic — applied at the `ThemeData` level via `AppTheme.of(locale: ...)`
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
      <img width="293" height="614" alt="set_new_password" src="https://github.com/user-attachments/assets/8b53ef68-cdf6-4680-961a-903a2dbce6eb" />
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
      <img width="293" height="614" alt="home_view" src="https://github.com/user-attachments/assets/58118132-8b1b-4a7d-8a91-dd70bb25f109" />
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
     <img width="293" height="614" alt="saved_articles_view" src="https://github.com/user-attachments/assets/a102cedd-3752-459b-8d9c-7d35f07b6a1e" />
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
     <img width="290" height="604" alt="profile_settings_view" src="https://github.com/user-attachments/assets/57ae01ae-4221-4fdb-bb38-e1d88abfd45c" />
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
│   ├── di/                        # service_locator.dart (GetIt setup)
│   ├── locale/                    # LocaleCubit, LanguagePickerDialog, LanguageOption
│   ├── translation/                # ArticleTranslationRepository, TranslationService
│   ├── network/                   # NetworkInfo (Socket-based), ConnectivityCubit
│   ├── browser/                   # In-app WebView (InAppBrowserView)
│   ├── repositories/               # HomeRepository (news + cache orchestration)
│   ├── models/                    # Article, Source (Hive + JSON)
│   ├── pagination/                # PaginationMeta, pagination bar widgets
│   ├── router/                    # AppRouter, AppRoutes
│   ├── secrets/                   # AppSecrets (reads .env)
│   ├── services/                  # LocalDatabaseHive (Hive init, box helpers)
│   ├── supabase/                  # AuthLocalDataSource, AuthRemoteDataSource, exceptions
│   ├── theme/                     # AppTheme, AppColors, ThemeCubit
│   ├── helpers/                    # EmptyState, ErrorState, ShimmerBox, category l10n extension
│   └── widgets/                   # Shared: ArticleCard, SaveButton, ShareButton,
│                                  #         OfflineBanner, AppDrawer
│
├── l10n/                          # ARB files + generated AppLocalizations + context.l10n extension
│
└── features/
    ├── auth/                      # AuthCubit, AuthRepository, Auth + Onboarding views
    │   ├── cubit/                 #   auth_cubit.dart · auth_listener_cubit.dart
    │   ├── data/                  #   auth_repository.dart (interface + impl)
    │   └── views/                 #   SignIn, SignUp, ForgotPassword, UpdatePassword, Onboarding
    ├── home/                      # HomeView, HomeCubit (headlines + paginated "For You" feed)
    │   ├── cubit/                 #   home_cubit.dart (single cubit drives both data streams)
    │   ├── services/              #   home_services.dart (Dio-backed NewsAPI calls)
    │   └── views/                 #   home_view.dart, article_detail_view.dart
    ├── Headlines/                 # HeadlinesCubit + HeadlinesView (full-screen, paginated list)
    ├── search/                    # SearchCubit, SearchService, SearchView
    ├── favorites/                 # FavoritesCubit (Hive-backed), FavoritesView
    ├── profile/                   # ProfileSettingsView (theme, language, account)
    └── splash/                    # SplashView (session restore + routing logic)
```

**Data flow per feature:**

```
UI (View)
  └─► Cubit (state logic)
        └─► Repository (interface)
              └─► Impl (Supabase / Dio / Hive)
```

The `core` layer has **zero dependency on any feature**. Features may only depend on `core`, never on each other. All cross-cutting singletons — `Dio`, `NetworkInfo`, `LocaleCubit`, `ThemeCubit`, repositories, and services — are wired through a single `setupServiceLocator()` entry point using `GetIt`.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter 3.x | Cross-platform UI |
| **Language** | Dart 3.x | Null-safe, strong-typed |
| **State Management** | `flutter_bloc` / Cubit | Predictable reactive state |
| **Dependency Injection** | `get_it` | Centralized service locator (`setupServiceLocator()`) |
| **Backend / Auth** | Supabase | Auth, Postgres DB, Realtime |
| **News Data** | NewsAPI v2 | Headlines, everything, and search endpoints |
| **Localization** | `flutter_localizations` + ARB | English / Arabic UI strings, reactive locale switching |
| **Translation** | MyMemory Translation API | On-the-fly article translation for the Arabic locale, Hive-cached |
| **HTTP Client** | Dio | Shared instance registered as a lazy singleton in the DI container |
| **Local Database** | Hive | NoSQL key-value, offline cache, locale & theme persistence |
| **Environment** | `flutter_dotenv` | Secrets management via `.env` |
| **Routing** | `onGenerateRoute` | Named routes with custom transitions |
| **Fonts** | Poppins (EN) / Cairo (AR) | Locale-aware brand typography |
| **Dev Tools** | DevicePreview | Multi-device debug preview |
| **Code Generation** | `build_runner` | Hive adapters, generated `AppLocalizations` |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A [NewsAPI.org](https://newsapi.org/register) API key (free tier)
- A [Supabase](https://supabase.com) project with Auth enabled

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/news_app.git
cd news_app
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

Required for Hive TypeAdapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Generated `AppLocalizations` classes are produced automatically by the Flutter toolchain from the ARB files under `lib/l10n/` on `flutter pub get` / `flutter run` — no extra command needed, as long as `generate: true` is set under `flutter:` in `pubspec.yaml`.

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
news_app/
├── .env                          # ← create this (see setup)
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # App entry: Supabase, Hive, DI, BlocProviders, MaterialApp
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart        # API urls, pagination sizes, cache keys, NewsCategory enum
│   │   │   └── app_images.dart           # Asset path constants
│   │   ├── cubits/
│   │   │   └── category_cubit.dart       # Global active-category state
│   │   ├── di/
│   │   │   └── service_locator.dart      # GetIt setup — every singleton/factory lives here
│   │   ├── locale/
│   │   │   ├── locale_cubit.dart         # LocaleCubit (persists to Hive `settings_box`)
│   │   │   ├── language_option.dart
│   │   │   └── language_picker_dialog.dart
│   │   ├── translation/
│   │   │   ├── translation_service.dart            # MyMemory API client
│   │   │   └── article_translation_repository.dart # Per-article translate + Hive cache
│   │   ├── network/
│   │   │   ├── network_info.dart         # Socket-based connectivity check (no 3rd-party plugin)
│   │   │   └── connectivity_cubit.dart   # Debounced connectivity state
│   │   ├── browser/
│   │   │   ├── view/in_app_browser_view.dart
│   │   │   └── widgets/                  # error_page_widget.dart, nav_icon_widget.dart
│   │   ├── repositories/
│   │   │   └── home_repository.dart      # Orchestrates network + cache + translation for news
│   │   ├── models/
│   │   │   ├── article_model.dart        # @HiveType Article + Source + extensions
│   │   │   ├── article_model.g.dart      # Generated Hive adapter
│   │   │   ├── article_detail_args.dart
│   │   │   └── news_api_response.dart
│   │   ├── pagination/
│   │   │   ├── helpers/nav_button.dart
│   │   │   └── widgets/                  # pagination_bar_widget.dart, load_more_footer.dart
│   │   ├── router/
│   │   │   ├── app_router.dart           # onGenerateRoute + transition builders
│   │   │   └── app_routes.dart           # Route name constants
│   │   ├── secrets/
│   │   │   └── app_secrets.dart          # Reads .env values
│   │   ├── services/
│   │   │   └── local_database_hive.dart  # Hive init, box helpers
│   │   ├── supabase/
│   │   │   ├── auth_local_data_source.dart
│   │   │   ├── auth_remote_data_source.dart
│   │   │   └── auth_exception.dart       # Sealed AuthUserException hierarchy
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Brand color palette
│   │   │   ├── app_theme.dart            # Light + Dark ThemeData, locale-aware fonts
│   │   │   ├── theme_cubit.dart          # ThemeCubit (persists to Hive)
│   │   │   └── model/theme_model.dart
│   │   ├── helpers/
│   │   │   ├── category_localization_x.dart  # NewsCategory → localized label extension
│   │   │   ├── empty_state.dart
│   │   │   ├── error_state.dart
│   │   │   └── shimmer_box.dart
│   │   └── widgets/
│   │       ├── drawer/
│   │       │   ├── authenticated_header_widget.dart
│   │       │   ├── guest_header_widget.dart
│   │       │   ├── category_item.dart
│   │       │   └── drawer_item.dart
│   │       ├── article_card_widget.dart
│   │       ├── save_button_widget.dart
│   │       ├── share_button_widget.dart
│   │       ├── offline_banner.dart
│   │       └── app_snack_bar.dart
│   ├── l10n/
│   │   ├── app_en.arb                    # English source strings
│   │   ├── app_ar.arb                    # Arabic translations
│   │   ├── app_localizations_x.dart      # `context.l10n` extension
│   │   └── gen_l10n/app_localizations.dart  # Auto-generated by Flutter
│   └── features/
│       ├── auth/
│       │   ├── cubit/
│       │   │   ├── auth_cubit.dart       # signIn/Up/Out, guest, password reset
│       │   │   └── auth_listener_cubit.dart
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   └── auth_repository_impl.dart
│       │   └── views/
│       │       ├── sign_in_view.dart
│       │       ├── sign_up_view.dart
│       │       ├── forgot_password_view.dart
│       │       ├── update_password_view.dart
│       │       └── onboarding_view.dart  # 3-page PageView wizard
│       ├── home/
│       │   ├── cubit/home_cubit.dart     # Drives both headlines + paginated "For You" feed
│       │   ├── services/home_services.dart  # Dio calls: top-headlines / everything / recommended
│       │   └── views/
│       │       ├── home_view.dart
│       │       └── article_detail_view.dart
│       ├── Headlines/
│       │   ├── cubit/headlines_cubit.dart
│       │   ├── widgets/                  # glass_category_row.dart, glass_category_card.dart
│       │   └── views/headlines_view.dart
│       ├── search/
│       │   ├── cubit/search_cubit.dart
│       │   ├── services/
│       │   │   ├── search_services.dart            # Plain-Dio SearchService (used by SearchCubit)
│       │   │   └── search_services_retrofit.dart    # @RestApi alternative client
│       │   └── views/search_view.dart
│       ├── favorites/
│       │   ├── cubit/favorite_cubit.dart
│       │   ├── services/favorite_services.dart
│       │   └── views/favorites_view.dart
│       ├── profile/
│       │   └── views/profile_settings_view.dart  # Theme, language, account
│       └── splash/
│           └── view/splash_view.dart
├── assets/
│   └── images/icons/             # App icon assets
└── docs/
    └── screenshots/              # ← add your screenshots here
```

---

## ⚙️ Key Implementation Details

**Pagination architecture:** Each page of recommended articles is independently cached using the key prefix `rec_page_N`. On cache hit, the UI renders instantly; on miss, a Dio call is made and the result is written to Hive before emission. This means pages the user has already seen are always available offline.

**Auth deep-link handling:** The `navigatorKey` is registered at the `MaterialApp` level and used inside `main()` to intercept `AuthChangeEvent.passwordRecovery` from Supabase's auth stream — routing the user to `UpdatePasswordView` regardless of which screen they're currently on.

**Dio via dependency injection:** A single `Dio` instance is built once inside `service_locator.dart` (base URL, auth header, conditional logging interceptor in non-release builds) and registered as a lazy singleton with `GetIt`. Every feature service (`HomeServices`, `SearchService`, etc.) receives that same instance through constructor injection rather than instantiating its own client.

**Reactive locale switching:** `LocaleCubit` is the single source of truth for the active `Locale`. `HomeCubit` and `HeadlinesCubit` both subscribe to its stream on construction and re-fetch their data whenever the language changes, so a language switch ripples through the feed, category labels, and theme typography without any screen needing to be manually rebuilt or popped.

**Article model cleanliness:** The `ArticleExtension` strips HTML tags, resolves HTML entities, and removes NewsAPI's `[+N chars]` truncation suffix from `content` — so the UI always receives clean, renderable text, in either language.

---

## 🗺️ Roadmap

Based on the current codebase, these are the most impactful improvements that would push NewsWave from portfolio-ready to production-ready:

- [ ] **Push Notifications** — Supabase Realtime or FCM integration for breaking news alerts, with locale-aware topic subscriptions
- [ ] **Social Auth** — Google / Apple Sign-In via Supabase OAuth providers
- [ ] **Native Share Sheet polish** — refine in-app browser navigation guards and share result messaging
- [ ] **Personalized Feed Algorithm** — Weight recommended articles by onboarding category preferences
- [ ] **Dedicated Translation Provider** — move off the free-tier MyMemory endpoint to a production translation API with proper rate-limit handling
- [ ] **Unit & Widget Tests** — Cubit state tests (including locale-switch behavior), widget golden tests for core components
- [ ] **CI/CD Pipeline** — GitHub Actions for lint, test, and Flutter build on each PR
- [ ] **Additional Locales** — extend the existing ARB-based localization beyond English / Arabic
- [ ] **Accessibility** — Semantic labels, sufficient color contrast audit, dynamic text scaling

> ✅ ~~Connectivity Banner~~ and ~~Localization (i18n)~~ — both shipped: connectivity is detected via a dependency-free `Socket`-based `NetworkInfo`, and the app is fully localized into English and Arabic with reactive RTL support.

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
