import Foundation
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }

            CollectionView(context: modelContext)
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    RootTabView()
}
