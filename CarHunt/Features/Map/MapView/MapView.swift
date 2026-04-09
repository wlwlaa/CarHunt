import SwiftUI
import SwiftData

struct MapView: View {
    @StateObject private var viewModel: MapViewModel

    init(context: ModelContext) {
        let storage = CardStorageManager(context: context)
        _viewModel = StateObject(
            wrappedValue: MapViewModel(
                storage: storage,
                networkService: MockCardsNetworkService()
            )
        )
    }

    var body: some View {
        NavigationStack {
            content
        }
    }
}

private extension MapView {
    var headerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
    }

    var content: some View {
        ZStack(alignment: .top) {
            MapViewControllerRepresentable(cards: viewModel.cardsWithLocations)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 16) {
                Spacer(minLength: 0)

                if viewModel.cards.isEmpty {
                    emptyState(
                        title: "No Cars On Map Yet",
                        message: "Add cards to preview car locations on the map."
                    )
                    
                } else if viewModel.cardsWithLocations.isEmpty {
                    emptyState(
                        title: "No Saved Coordinates",
                        message: "Cards were loaded, but none of them contains a saved location."
                    )
                }

                Spacer(minLength: 0)
            }
            .tint(.blue)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            viewModel.loadCards()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .alert(
            "Map Error",
            isPresented: errorAlertBinding,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        )
    }

    func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)

        }
        .frame(maxWidth: 320, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}
