import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var router: AppRouter
    private let cardAutofillService: CardAutofillServicing

    init() {
        _router = StateObject(wrappedValue: AppRouter())
        let networkService = URLSessionNetworkService(baseURL: Self.cardsFromImageBaseURL)
        self.cardAutofillService = CardAutofillService(networkService: networkService)
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            CameraRootView(
                isActive: router.selectedTab == .camera && router.presented == nil,
                router: router
            )
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
                .tag(AppTab.camera)

            CollectionView(context: modelContext)
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.collection)
            
            MapView(context: modelContext)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(AppTab.map)
            
        }
        .tint(.blue)
        .environmentObject(router)
        .sheet(item: $router.presented) { route in
            switch route {
            case .camera:
                EmptyView()

            case .map:
                EmptyView()

            case .collection:
                EmptyView()

            case .cardSettings:
                NavigationStack {
                    CardSettingsView(
                        router: router,
                        storage: CardStorageManager(context: modelContext),
                        initialCard: router.presentedCardSettingsCard ?? .draft,
                        initialDataModel: router.presentedCardSettingsDraftDataModel,
                        initialPhotoData: router.presentedCardSettingsPhotoData,
                        cardAutofillService: cardAutofillService
                    )
                }
            }
        }
    }

    private static var cardsFromImageBaseURL: URL {
        if let envValue = ProcessInfo.processInfo.environment["CARHUNT_API_BASE_URL"],
           let url = URL(string: envValue) {
            return url
        }

        if let plistValue = Bundle.main.object(forInfoDictionaryKey: "CARHUNT_API_BASE_URL") as? String,
           let url = URL(string: plistValue) {
            return url
        }

        return URL(string: "https://localhost:8443")!
    }
}

#Preview {
    RootTabView()
}
