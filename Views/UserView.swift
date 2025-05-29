import SwiftUI

// MARK: - UserView (Main Tab and Navigation Container)
struct UserView: View {
    @StateObject private var apiListViewModel = APIListViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        TabView {
            // Tab 1: All APIs
            NavigationStack {
                APIListView(viewModel: apiListViewModel)
            }
            .accessibilityIdentifier("allAPIsTabContent")
            .tabItem {
                Label("All APIs", systemImage: "list.bullet")
            }
            // Tab 2: Favorite APIs
            NavigationStack {
                FavoritesListView(viewModel: favoritesViewModel)
            }
            .accessibilityIdentifier("favoritesTabContent")
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .onAppear {
                Task {
                    print("UserView: Favorites Tab appeared, loading favorites.")
                    await favoritesViewModel.loadFavorites()
                }
            }
            .onReceive(apiListViewModel.$favoriteIDs) { _ in
                 Task {
                    print("UserView: Favorite IDs changed in APIListViewModel, reloading favorites in FavoritesViewModel.")
                    await favoritesViewModel.loadFavorites()
                }
            }
        }
    }
}

// MARK: - Previews

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}

struct APIListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            APIListView(viewModel: APIListViewModel())
        }
    }
}

struct FavoritesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavoritesListView(viewModel: FavoritesViewModel())
        }
    }
}
