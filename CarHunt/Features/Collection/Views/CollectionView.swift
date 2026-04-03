import SwiftUI
import SwiftData
import UIKit

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
            VStack(spacing: 12) {
                Picker("Sort", selection: sortBinding) {
                    ForEach(CardSortType.allCases, id: \.self) { sortType in
                        Text(sortType.title).tag(sortType)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.cards.isEmpty {
                    ScrollView {
                        emptyState
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.cards, id: \.id) { card in
                                CardView(card: card.asUIModel)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .padding()
            .navigationTitle("Collection")
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
            Spacer(minLength: 88)
            
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private extension CardDataModel {
    var asUIModel: CardUIModel {
        CardUIModel(
            id: abs(id.hashValue),
            carImage: UIImage(data: carImage) ?? UIImage(systemName: "car.fill") ?? UIImage(),
            make: make,
            model: model,
            bodyType: bodyType,
            numGrade: numGrade,
            year: year,
            power: power,
            engineType: engineType,
            userName: userName,
            downVotes: downVotes,
            notes: notes,
            date: date
        )
    }
}
