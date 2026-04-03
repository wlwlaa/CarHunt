import SwiftUI

enum AppTab {
    case camera
    case collection
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .camera

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView(isActive: selectedTab == .camera)
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
