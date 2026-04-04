import SwiftUI
import SwiftData

enum AppTab {
    case camera
    case collection
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .camera
    @StateObject private var router = AppRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraRootView(
                isActive: selectedTab == .camera && router.presented == nil,
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
        }
        .tint(.blue)
        .environmentObject(router)
        .sheet(item: $router.presented) { route in
            switch route {
            case .camera:
                EmptyView()

            case .cardSettings:
                NavigationStack {
                    CardSettingView()
                        .navigationTitle("Card Settings")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Close") {
                                    router.dismissPresented()
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    RootTabView()
}
