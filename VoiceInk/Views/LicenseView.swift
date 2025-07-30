import SwiftUI

struct LicenseView: View {
    @StateObject private var licenseViewModel = LicenseViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
Text(NSLocalizedString("License Management", comment: "License Management"))
                .font(.headline)
            
            if case .licensed = licenseViewModel.licenseState {
                VStack(spacing: 10) {
Text(NSLocalizedString("Premium Features Activated", comment: "Premium Features Activated"))
                        .foregroundColor(.green)
                    
                    Button(role: .destructive, action: {
                        licenseViewModel.removeLicense()
                    }) {
Text(NSLocalizedString("Remove License", comment: "Remove License"))
                    }
                }
            } else {
TextField(NSLocalizedString("Enter License Key", comment: "Enter License Key"), text: $licenseViewModel.licenseKey)
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
Text(NSLocalizedString("Activate License", comment: "Activate License"))
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