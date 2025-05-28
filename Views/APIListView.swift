
import SwiftUI

struct APIListView: View {
    @ObservedObject var viewModel: APIListViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.entries.isEmpty {
                ProgressView("Loading APIs...")
                    .padding()
                Spacer()
            }
            else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Error Loading APIs", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadEntries()
                        }
                    }
                }
                Spacer()
            }
            else if viewModel.filteredEntries.isEmpty && !viewModel.searchText.isEmpty {
                 ContentUnavailableView.search(text: viewModel.searchText)
                 Spacer()
            }
            else if viewModel.filteredEntries.isEmpty && viewModel.searchText.isEmpty && !viewModel.isLoading {
                 ContentUnavailableView {
                    Label("No APIs Found", systemImage: "questionmark.folder")
                } description: {
                    Text("There are currently no APIs to display. Try pulling to refresh or check later.")
                }
                Spacer()
            }
            else {
                List {
                    ForEach(viewModel.filteredEntries) { entry in
                        APIListRowView(
                            apiEntry: entry,
                            isFavorite: viewModel.favoriteIDs.contains(entry.id)
                        ) {
                            Task {
                                await viewModel.toggleFavorite(for: entry)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadEntries(isRefresh: true)
                }
            }
        }
        .navigationTitle("API Harbor")
        .searchable(text: $viewModel.searchText, prompt: "Search APIs (Name, Desc, Category)")
        .animation(.default, value: viewModel.filteredEntries) // Animate list changes
        .overlay {
            if viewModel.isLoading && !viewModel.entries.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                }
                .padding(.top)
                .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}
