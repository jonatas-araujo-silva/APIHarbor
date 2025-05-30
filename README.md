![apiharbor-search-animation](https://github.com/user-attachments/assets/b1af1d18-5f24-4280-aed6-0340e0ea5f79)# API Harbor 🚢

[![Swift Version](https://img.shields.io/badge/Swift-5.x-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![CI Status](https://github.com/jonatas-araujo-silva/APIHarbor/actions/workflows/main.yml/badge.svg)](https://github.com/jonatas-araujo-silva/APIHarbor/actions/workflows/main.yml)
API Harbor is an iOS application developed to showcase modern iOS development skills using Swift and SwiftUI. It functions as a directory for public APIs, allowing users to browse, search, and manage a list of their favorite APIs. This project demonstrates capabilities in UI/UX design with SwiftUI, local data persistence using SQLite (via GRDB.swift), handling data (from a local JSON source), comprehensive testing, and CI/CD automation.

## 🌟 Features

  * **Browse Public APIs:** Displays a list of public APIs loaded from a local JSON file (as the live `https://api.publicapis.org/entries` endpoint was experiencing accessibility issues during development).
  * **Search & Filter:** Users can search the API list by name, description, or category.
  * **Favorites System:**
      * Mark/unmark APIs as favorites with engaging animations.
      * Favorite status persists locally using an SQLite database managed by GRDB.swift.
  * **Dedicated Favorites List:** View all favorited APIs in a separate tab.
  * **iOS Native UI/UX:**
      * Clean, intuitive interface built entirely with SwiftUI.
      * Utilizes `TabView` for main navigation and `NavigationStack` for hierarchical views.
      * **Gestures:** Tap to favorite/unfavorite, pull-to-refresh on the main API list, and swipe-to-delete on the favorites list.
      * **Animations:** Smooth list updates, screen transitions, and animated favorite button interactions.
  * **Error Handling & User Feedback:** Displays loading states and appropriate messages for errors or empty states.

## 📸 Screenshots & GIFs

| All APIs List                                       | Favorites List                                     | Search & Animations                               |
| :--------------------------------------------------: | :------------------------------------------------: | :-----------------------------------------------: |
| `![All APIs List Screenshot]![apiharbor-listview](https://github.com/user-attachments/assets/049c74de-72a4-44ef-8b85-6ab341b82c6e)
` | `![Favorites List Screenshot]![apiharbor-favorites](https://github.com/user-attachments/assets/349f4b90-629d-4f03-a6ea-803ce355c710)
` | `![Search and Favorite Animation GIF]![apiharbor-search-animation](https://github.com/user-attachments/assets/c4ff38f0-b28d-4623-8dd6-a4225c077320)
 |
| *Browse the main directory of APIs.* | *Managing a personal list of saved favorites.* | *Interactive search and animated favoriting.* |

## 🛠️ Technologies & Architecture

  * **Language:** Swift
  * **UI Framework:** SwiftUI
  * **Target Platform:** iOS
  * **Architecture:** MVVM (Model-View-ViewModel)
  * **Data Source:**
      * Primary API directory loaded from a bundled **local JSON file** (`api_directory.json`).
      * User favorites stored in a local **SQLite database** via **GRDB.swift**.
  * **Networking:** `URLSession` (abstraction in `NetworkService`, currently adapted for local JSON).
  * **Dependency Management:**
      * Swift Package Manager (SPM) for GRDB.swift.
      * Bundler for managing Ruby gems (Fastlane).
  * **Testing:**
      * **XCTest** framework for Unit Tests (ViewModel logic) and UI Tests (key user flows).
      * **SwiftLint** for static code analysis and style enforcement.
  * **CI/CD (Automation):**
      * **Fastlane** for local automation of linting, testing, and building.
      * **GitHub Actions** for continuous integration.

## 📂 Project Structure (Overview)

The project adheres to the MVVM architectural pattern for a clear separation of concerns:

  * **Models:** (`PublicAPIEntry.swift`, `FavoriteAPI.swift`) - Data structures.
  * **Views:** (`UserView.swift`, `APIListView.swift`, etc.) - UI elements.
  * **ViewModels:** (`APIListViewModel.swift`, `FavoritesViewModel.swift`) - UI logic and data preparation.
  * **Services:** (`NetworkService.swift`, `DatabaseManager.swift`) - Data access and external interactions.
  * **`fastlane/`**: Fastlane configuration.
  * **`.github/workflows/`**: GitHub Actions workflow.

## ⚙️ Setup & Installation

**Prerequisites:**

  * Xcode (latest stable version recommended)
  * Homebrew (for installing SwiftLint and xcbeautify)
  * Ruby (managed by `rbenv` recommended) & Bundler

**Steps:**

1.  **Clone the Repository:**

    ```bash
    git clone [https://github.com/jonatas-araujo-silva/APIHarbor.git](https://github.com/jonatas-araujo-silva/APIHarbor.git)
    cd APIHarbor
    ```

2.  **Install Required Tools (if not already present):**

    ```bash
    brew install swiftlint
    brew install xcbeautify
    ```

3.  **Install Ruby Gems (Fastlane):**

    ```bash
    bundle install
    ```

4.  **Open in Xcode:**
    Open the `APIHarbor.xcodeproj` file.

5.  **Build and Run:**

      * Select an iOS Simulator.
      * Press Run (Cmd+R).

## 🧪 Testing

  * **Unit & UI Tests:** Run via Product \> Test (Cmd+U) in Xcode or `bundle exec fastlane tests` in Terminal.
  * **Static Analysis (SwiftLint):** Integrated into the build process and can be run via `bundle exec fastlane lint`.

## 🚀 CI/CD Pipeline

This project uses GitHub Actions and Fastlane to automate:

  * **Linting:** Code style checks with SwiftLint.
  * **Testing:** Execution of unit and UI tests.
  * **Building:** Creation of a simulator build.
    This pipeline is triggered on pushes and pull requests to `main` and `develop` branches. Check the "Actions" tab on the GitHub repository for run history.

## 👤 Author

  * **Jonatas Araujo**
  * GitHub: [jonatas-araujo-silva](https://github.com/jonatas-araujo-silva)

-----
