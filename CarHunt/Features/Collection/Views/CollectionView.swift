import SwiftUI
import SwiftData

struct CollectionView: View {
    @StateObject private var viewModel: CardListViewModel
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(context: ModelContext) {
        let storage = CardStorageManager(context: context)
        _viewModel = StateObject(
            wrappedValue: CardListViewModel(
                storage: storage,
                networkService: MockCardsNetworkService()
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.cards.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            header
                            emptyState
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            header

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.cards, id: \.id) { card in
                                    CardView(card: card.asUIModel)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                viewModel.loadCards()
            }
            .alert(
                "Collection Error",
                isPresented: errorAlertBinding,
                actions: {
                    Button("OK", role: .cancel) {}
                },
                message: {
                    Text(viewModel.errorMessage ?? "Unknown error")
                }
            )
        }
    }
}

private extension CollectionView {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Collection")
                .font(.system(size: 36, weight: .bold))

            Picker("Sort", selection: sortBinding) {
                ForEach(CardSortType.allCases, id: \.self) { sortType in
                    Text(sortType.title).tag(sortType)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var sortBinding: Binding<CardSortType> {
        Binding(
            get: { viewModel.selectedSortType },
            set: { viewModel.applySort($0) }
        )
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

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(.gray)
            
            Text("No Cards In Local Storage")
                .font(.headline)
            
            #if DEBUG
            Text("Use debug action to load cards from mock network service.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.loadMockCardsFromNetwork()
                }
            } label: {
                if viewModel.isLoadingMockCards {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Loading Mock Cards...")
                    }
                } else {
                    Text("Debug: Load Mock Cards")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoadingMockCards)
            #endif
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 72)
    }
}
