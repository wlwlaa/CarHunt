import SwiftUI
import Combine

struct CardSettingView: View {
    @ObservedObject var viewModel: CardSettingViewModel

    var body: some View {
        Text("card settings view")
        Button ("open collection") {
            viewModel.openCollection()
        }
    }
    

}
