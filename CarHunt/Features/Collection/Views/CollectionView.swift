import SwiftUI

struct CollectionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 72))
                    .foregroundStyle(.gray)

                Text("Collection Screen")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Here the user will see their saved car cards.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Collection")
        }
    }
}

#Preview {
    CollectionView()
}
