import SwiftUI
import SwiftData

struct CollectionView: View {
    @StateObject private var viewModel: CardListViewModel
    @State private var selectedCard: CardUIModel?
    
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
                                    Button {
                                        selectedCard = card.asUIModel
                                    } label: {
                                        CardView(card: card.asUIModel)
                                    }
                                    .buttonStyle(.plain)
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
            .fullScreenCover(item: $selectedCard) { card in
                CardDetailsModalView(card: card)
                    .presentationBackground(.clear)
            }
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

private struct CardDetailsModalView: View {
    let card: CardUIModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.2))
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            CardView(card: card)
                .padding(.horizontal, 20)
                .frame(maxWidth: 560)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
    }
}
