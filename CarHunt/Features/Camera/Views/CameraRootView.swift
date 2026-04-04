import SwiftUI

struct CameraRootView: View {
    @StateObject var router: CameraRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            CameraView(isActive: true,
                       viewModel: CameraViewModel(router: router))
                .environmentObject(router)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .camera:
                        CameraView(isActive: true,
                                   viewModel: CameraViewModel(router: router))

                    case .cardSettings:
                        CardSettingView()
                    }
                }
        }
    }
}
