import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var router = AppRouter()

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
        }
        .tint(.blue)
        .environmentObject(router)
        .sheet(item: $router.presented) { route in
            switch route {
            case .camera:
                EmptyView()

            case .collection:
                EmptyView()

            case .cardSettings:
                NavigationStack {
                    CardSettingsView(router: router)
                }
            }
        }
    }
}

#Preview {
    RootTabView()
}
