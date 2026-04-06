import SwiftUI
import Combine

@MainActor
struct CameraRootView: View {
    let isActive: Bool
    @StateObject private var viewModel: CameraViewModel

    init(isActive: Bool, router: any AppRouting) {
        self.isActive = isActive
        _viewModel = StateObject(wrappedValue: CameraViewModel(router: router))
    }

    var body: some View {
        CameraView(isActive: isActive, viewModel: viewModel)
    }
}
