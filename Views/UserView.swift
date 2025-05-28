import SwiftUI

// MARK: - ContentView (Main Tab and Navigation Container)
struct UserView: View {
    @StateObject private var apiListViewModel = APIListViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                APIListView(viewModel: apiListViewModel)
            }
            .tabItem {
                Label("All APIs", systemImage: "list.bullet")
            }

            NavigationStack {
                FavoritesListView(viewModel: favoritesViewModel)
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .onAppear {
                Task {
                    await favoritesViewModel.loadFavorites()
                }
            }
            .onReceive(apiListViewModel.$favoriteIDs) { _ in
                 Task {
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
