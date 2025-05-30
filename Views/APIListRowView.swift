import SwiftUI

struct APIListRowView: View {
    let apiEntry: PublicAPIEntry
    var isFavorite: Bool
    let favoriteAction: () -> Void

    @State private var animateHeartPop: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(apiEntry.api)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityIdentifier("apiName_\(apiEntry.api)")

                Text(apiEntry.descriptionText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    if let category = apiEntry.category, !category.isEmpty {
                        Text(category)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.teal.opacity(0.15))
                            .foregroundColor(.teal)
                            .clipShape(Capsule())
                    }
                    
                    if !apiEntry.auth.isEmpty {
                        Text("Auth: \(apiEntry.auth)")
                            .font(.caption2)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }

                    Text(apiEntry.https ? "HTTPS" : "HTTP")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((apiEntry.https ? Color.green : Color.pink).opacity(0.15))
                        .foregroundColor(apiEntry.https ? .green : .pink)
                        .clipShape(Capsule())
                }
                .padding(.top, 2)
            }

            Spacer()

            Button {
                favoriteAction()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    animateHeartPop = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    animateHeartPop = false
                }
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.title2)
                    .symbolEffect(.bounce, options: .repeating.speed(1), value: animateHeartPop && isFavorite)
                    .scaleEffect(animateHeartPop ? 1.4 : 1.0)
            }
            .buttonStyle(.plain)
            .padding(.leading, 5)
            .accessibilityIdentifier("favoriteButton_\(apiEntry.api)")
        }
        .padding(.vertical, 8)
    }
}
