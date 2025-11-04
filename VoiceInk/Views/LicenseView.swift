import SwiftUI

struct LicenseView: View {
    @StateObject private var licenseViewModel = LicenseViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
<<<<<<< HEAD
Text(NSLocalizedString("License Management", comment: "License Management"))
=======
            Text("License Management")
>>>>>>> upstream/main
                .font(.headline)
            
            if case .licensed = licenseViewModel.licenseState {
                VStack(spacing: 10) {
<<<<<<< HEAD
Text(NSLocalizedString("Premium Features Activated", comment: "Premium Features Activated"))
=======
                    Text("Premium Features Activated")
>>>>>>> upstream/main
                        .foregroundColor(.green)
                    
                    Button(role: .destructive, action: {
                        licenseViewModel.removeLicense()
                    }) {
<<<<<<< HEAD
Text(NSLocalizedString("Remove License", comment: "Remove License"))
                    }
                }
            } else {
TextField(NSLocalizedString("Enter License Key", comment: "Enter License Key"), text: $licenseViewModel.licenseKey)
=======
                        Text("Remove License")
                    }
                }
            } else {
                TextField("Enter License Key", text: $licenseViewModel.licenseKey)
>>>>>>> upstream/main
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
<<<<<<< HEAD
Text(NSLocalizedString("Activate License", comment: "Activate License"))
=======
                        Text("Activate License")
>>>>>>> upstream/main
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