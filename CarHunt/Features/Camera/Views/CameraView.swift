import SwiftUI

struct CameraView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 72))
                    .foregroundStyle(.gray)

                Text("Camera Screen")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Here will be the in-app camera for spotting cars.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Camera")
        }
    }
}

#Preview {
    CameraView()
}
