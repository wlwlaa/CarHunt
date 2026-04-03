import SwiftUI

struct CameraView: View {
    let isActive: Bool

    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color(red: 0.08, green: 0.10, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                CameraPreviewView(session: viewModel.cameraService.session)
                    .frame(height: 470)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                Spacer(minLength: 28)

                HStack {
                    Color.clear
                        .frame(width: 56, height: 56)

                    Spacer()

                    Button {
                        viewModel.capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 88, height: 88)

                            Circle()
                                .stroke(.black, lineWidth: 3)
                                .frame(width: 74, height: 74)
                        }
                    }

                    Spacer()

                    Button {
                        viewModel.toggleTorch()
                    } label: {
                        smallControlButton(
                            icon: viewModel.isTorchOn ? "bolt.fill" : "bolt.slash.fill",
                            isActive: viewModel.isTorchOn
                        )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            viewModel.setupCameraIfNeeded()
            if isActive {
                viewModel.startCamera()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.startCamera()
            } else {
                viewModel.turnTorchOff()
                viewModel.stopCamera()
            }
        }
        .navigationBarHidden(true)
    }

    private func smallControlButton(icon: String, isActive: Bool) -> some View {
        Circle()
            .fill(isActive ? Color.yellow.opacity(0.22) : Color.white.opacity(0.08))
            .frame(width: 56, height: 56)
            .overlay(
                Circle()
                    .stroke(
                        isActive ? Color.yellow.opacity(0.65) : Color.white.opacity(0.10),
                        lineWidth: 1
                    )
            )
            .overlay(
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isActive ? .yellow : .white)
            )
    }
}

#Preview {
    CameraView(isActive: true)
        .preferredColorScheme(.dark)
}
