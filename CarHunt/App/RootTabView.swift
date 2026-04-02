import Foundation
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }

            CollectionView()
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
