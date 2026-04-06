import SwiftUI
import Combine

struct CardSettingRootView: View {
    @StateObject private var viewModel: CardSettingViewModel

    init(router: any AppRouting) {
        _viewModel = StateObject(wrappedValue: CardSettingViewModel(router: router))
    }

    var body: some View {
        CardSettingView(viewModel: viewModel)
    }
}
