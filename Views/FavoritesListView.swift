import SwiftUI

struct FavoritesListView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.favoriteAPIs.isEmpty {
                ProgressView("Loading Favorites...")
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView { Label("Error", systemImage: "exclamationmark.triangle") }
                description: { Text(errorMessage) }
                actions: { Button("Retry") { Task { await viewModel.loadFavorites() } } }
                Spacer()
            } else if viewModel.favoriteAPIs.isEmpty {
                ContentUnavailableView("No Favorites Yet", systemImage: "heart.slash", description: Text("Explore APIs and tap the heart to save them here."))
                Spacer()
            } else {
                List {
                    ForEach(viewModel.favoriteAPIs) { favoriteAPI in
                        APIListRowView(
                            apiEntry: favoriteAPI.toPublicAPIEntry(),
                            isFavorite: true,
                            favoriteAction: {
                                Task {
                                    await viewModel.removeFavorite(favoriteAPI)
                                }
                            }
                        )
                    }
                    .onDelete(perform: { indexSet in
                        Task {
                            await viewModel.removeFavorite(at: indexSet)
                        }
                    })
                }
                .listStyle(.plain)
                .animation(.default, value: viewModel.favoriteAPIs)
                .accessibilityIdentifier("favoritesAPIsList")
            }
        }
        .navigationTitle("Favorite APIs")
        .overlay {
            if viewModel.isLoading && !viewModel.favoriteAPIs.isEmpty {
                VStack { ProgressView().scaleEffect(1.2); Spacer() }.padding(.top)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}

extension FavoriteAPI {
    func toPublicAPIEntry() -> PublicAPIEntry {
        return PublicAPIEntry(
            API: self.apiName,
            Description: self.descriptionText,
            Auth: "",
            HTTPS: true,
            Cors: "unknown",  
            Link: self.link,
            Category: self.category
        )
    }
}
