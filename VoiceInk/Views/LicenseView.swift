import SwiftUI

struct LicenseView: View {
    @StateObject private var licenseViewModel = LicenseViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
            Text(L10n.License.management.text)
                .font(.headline)

            if case .licensed = licenseViewModel.licenseState {
                VStack(spacing: 10) {
                    Text(L10n.License.premiumActivated.text)
                        .foregroundColor(.green)

                    Button(role: .destructive, action: {
                        licenseViewModel.removeLicense()
                    }) {
                        Text(L10n.License.removeLicense.text)
                    }
                }
            } else {
                TextField(L10n.License.enterLicenseKey.text, text: $licenseViewModel.licenseKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)

                Button(action: {
                    Task {
                        await licenseViewModel.validateLicense()
                    }
                }) {
                    if licenseViewModel.isValidating {
                        ProgressView()
                    } else {
                        Text(L10n.License.activateLicense.text)
                    }
                }
                .disabled(licenseViewModel.isValidating)
            }
            
            if let message = licenseViewModel.validationMessage {
                Text(message)
                    .foregroundColor(licenseViewModel.licenseState == .licensed ? .green : .red)
                    .font(.caption)
            }
        }
        .padding()
    }
}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView()
    }
} 