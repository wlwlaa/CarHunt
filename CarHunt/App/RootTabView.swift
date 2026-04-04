import SwiftUI

enum AppTab {
    case camera
    case collection
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .camera
    @StateObject private var router = CameraRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraRootView(router: router)
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
    }
}

#Preview {
    RootTabView()
}
