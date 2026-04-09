import SwiftUI
import SwiftData

struct CollectionView: View {
    @StateObject private var viewModel: CardListViewModel
    @State private var selectedCard: CardUIModel?
    @EnvironmentObject private var router: AppRouter
    
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
            content
        }
    }
}

private extension CollectionView {
    @ViewBuilder
    var content: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else {
                if viewModel.cards.isEmpty {
                    emptyCollectionScrollView
                } else {
                    cardsScrollView
                }
            }
        }
        .padding(.top, 4)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            viewModel.loadCards()
            presentPendingCollectionCardIfNeeded()
        }
        .onChange(of: viewModel.cards) { _ in
            presentPendingCollectionCardIfNeeded()
        }
        .onChange(of: router.pendingCollectionCardID) { _ in
            presentPendingCollectionCardIfNeeded()
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

    func presentPendingCollectionCardIfNeeded() {
        guard let cardID = router.pendingCollectionCardID else { return }
        guard let pendingCard = viewModel.cards.first(where: { $0.id == cardID }) else { return }

        selectedCard = pendingCard.asUIModel(maxPixelSize: CardUIModel.ImagePixelSize.expanded)
        router.pendingCollectionCardID = nil
    }

    var emptyCollectionScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                emptyState
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    var loadingView: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            Spacer()
            
            VStack(alignment: .center, spacing: 8) {
                Text("Loading cards")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ProgressView()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var cardsScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                header
                cardGrid
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.cards, id: \.id) { card in
                cardButton(for: card)
            }
        }
    }

    func cardButton(for card: CardDataModel) -> some View {
        let compactUIModel = card.asUIModel(maxPixelSize: CardUIModel.ImagePixelSize.compact)
        return Button {
            selectedCard = card.asUIModel(maxPixelSize: CardUIModel.ImagePixelSize.expanded)
        } label: {
            CardView(card: compactUIModel)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    viewModel.deleteCard(card)
                }
            }
        }
    }

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
    @State private var isVisible = false
    @State private var cardTilt: Double = -8

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(isVisible ? 0.2 : 0))
                .ignoresSafeArea()
                .onTapGesture {
                    closeWithAnimation()
                }

            CardView(card: card, style: .expanded)
                .padding(.horizontal, 20)
                .frame(maxWidth: 560)
                .scaleEffect(isVisible ? 1 : 0.94)
                .offset(y: isVisible ? 0 : 24)
                .opacity(isVisible ? 1 : 0)
                .rotationEffect(.degrees(cardTilt))
        }
        .overlay(alignment: .topTrailing) {
            Button {
                closeWithAnimation()
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
        .onAppear {
            cardTilt = -8
            withAnimation(.spring(response: 1.15, dampingFraction: 0.24, blendDuration: 0.18)) {
                isVisible = true
                cardTilt = 0
            }
        }
    }

    private func closeWithAnimation() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isVisible = false
        }

        Task {
            try? await Task.sleep(nanoseconds: 180_000_000)
            dismiss()
        }
    }
}


#Preview("Card grid") {
    @Previewable @Environment(\.modelContext) var modelContext
    CollectionView(context: modelContext)
        .environmentObject(AppRouter())
}

#Preview("Progress indicator") {
    VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Collection")
                .font(.system(size: 36, weight: .bold))

            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Spacer()
        
        VStack(alignment: .center, spacing: 8) {
            Text("Loading cards")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ProgressView()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        Spacer()
        
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
}
