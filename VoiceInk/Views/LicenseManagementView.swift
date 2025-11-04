import SwiftUI

struct LicenseManagementView: View {
    @StateObject private var licenseViewModel = LicenseViewModel()
    @Environment(\.colorScheme) private var colorScheme
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                heroSection
                
                // Main Content
                VStack(spacing: 32) {
                    if case .licensed = licenseViewModel.licenseState {
                        activatedContent
                    } else {
                        purchaseContent
                    }
                }
                .padding(32)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var heroSection: some View {
<<<<<<< HEAD
        let isLicensed = licenseViewModel.licenseState == .licensed
        let titleKey: LocalizedStringKey = isLicensed ? L10n.Sidebar.voiceInkPro.text : L10n.License.upgradeToPro.text
        let subtitleKey: LocalizedStringKey = isLicensed ? L10n.License.supportMessage.text : L10n.License.heroSubtitle.text

        return VStack(spacing: 24) {
            AppIconView()

=======
        VStack(spacing: 24) {
            // App Icon
            AppIconView()
            
            // Title Section
>>>>>>> upstream/main
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue)
<<<<<<< HEAD

                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(titleKey)
                            .font(.system(size: 32, weight: .bold))

                        Text(L10n.License.versionFormat.format(appVersion))
=======
                    
                    HStack(alignment: .lastTextBaseline, spacing: 8) { 
                        Text(licenseViewModel.licenseState == .licensed ? "VoiceInk Pro" : "Upgrade to Pro")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("v\(appVersion)")
>>>>>>> upstream/main
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                    }
                }
<<<<<<< HEAD

                Text(subtitleKey)
=======
                
                Text(licenseViewModel.licenseState == .licensed ?
                     "Thank you for supporting VoiceInk" :
                     "Transcribe what you say to text instantly with AI")
>>>>>>> upstream/main
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

<<<<<<< HEAD
                if isLicensed {
=======
                if case .licensed = licenseViewModel.licenseState {
>>>>>>> upstream/main
                    HStack(spacing: 40) {
                        Button {
                            if let url = URL(string: "https://github.com/Beingpax/VoiceInk/releases") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
<<<<<<< HEAD
                            featureItem(icon: "list.bullet.clipboard.fill", title: L10n.License.changelog.text, color: .blue)
                        }
                        .buttonStyle(.plain)

=======
                            featureItem(icon: "list.bullet.clipboard.fill", title: "Changelog", color: .blue)
                        }
                        .buttonStyle(.plain)
                        
>>>>>>> upstream/main
                        Button {
                            if let url = URL(string: "https://discord.gg/xryDy57nYD") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
<<<<<<< HEAD
                            featureItem(icon: "bubble.left.and.bubble.right.fill", title: L10n.License.discord.text, color: .purple)
                        }
                        .buttonStyle(.plain)

                        Button {
                            EmailSupport.openSupportEmail()
                        } label: {
                            featureItem(icon: "envelope.fill", title: L10n.License.emailSupport.text, color: .orange)
                        }
                        .buttonStyle(.plain)

=======
                            featureItem(icon: "bubble.left.and.bubble.right.fill", title: "Discord", color: .purple)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            EmailSupport.openSupportEmail()
                        } label: {
                            featureItem(icon: "envelope.fill", title: "Email Support", color: .orange)
                        }
                        .buttonStyle(.plain)
                        
>>>>>>> upstream/main
                        Button {
                            if let url = URL(string: "https://tryvoiceink.com/docs") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
<<<<<<< HEAD
                            featureItem(icon: "book.fill", title: L10n.License.docs.text, color: .indigo)
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let url = URL(string: "https://github.com/Beingpax/VoiceInk/issues") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            featureItem(icon: "map.fill", title: L10n.License.roadmap.text, color: .green)
=======
                            featureItem(icon: "book.fill", title: "Docs", color: .indigo)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            if let url = URL(string: "https://buymeacoffee.com/beingpax") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            animatedTipJarItem()
>>>>>>> upstream/main
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.vertical, 60)
    }
<<<<<<< HEAD

    private var purchaseContent: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
=======
    
    private var purchaseContent: some View {
        VStack(spacing: 40) {
            // Purchase Card
            VStack(spacing: 24) {
                // Lifetime Access Badge
>>>>>>> upstream/main
                HStack {
                    Image(systemName: "infinity.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
<<<<<<< HEAD
                    Text(L10n.License.buyOnceOwnForever.text)
=======
                    Text("Buy Once, Own Forever")
>>>>>>> upstream/main
                        .font(.headline)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
<<<<<<< HEAD

=======
                
                // Purchase Button 
>>>>>>> upstream/main
                Button(action: {
                    if let url = URL(string: "https://tryvoiceink.com/buy") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
<<<<<<< HEAD
                    Text(L10n.License.upgradeToVoiceInkPro.text)
=======
                    Text("Upgrade to VoiceInk Pro")
>>>>>>> upstream/main
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
<<<<<<< HEAD

                HStack(spacing: 40) {
                    featureItem(icon: "bubble.left.and.bubble.right.fill", title: L10n.License.prioritySupport.text, color: .purple)
                    featureItem(icon: "infinity.circle.fill", title: L10n.License.lifetimeAccess.text, color: .blue)
                    featureItem(icon: "arrow.up.circle.fill", title: L10n.License.freeUpdates.text, color: .green)
                    featureItem(icon: "macbook.and.iphone", title: L10n.License.multipleDevices.text, color: .orange)
=======
                
                // Features Grid
                HStack(spacing: 40) {
                    featureItem(icon: "bubble.left.and.bubble.right.fill", title: "Priority Support", color: .purple)
                    featureItem(icon: "infinity.circle.fill", title: "Lifetime Access", color: .blue)
                    featureItem(icon: "arrow.up.circle.fill", title: "Free Updates", color: .green)
                    featureItem(icon: "macbook.and.iphone", title: "Multiple Devices", color: .orange)
>>>>>>> upstream/main
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)

<<<<<<< HEAD
            VStack(spacing: 20) {
                Text(L10n.License.alreadyHaveLicense.text)
                    .font(.headline)

                HStack(spacing: 12) {
                    TextField(L10n.License.enterLicenseKey.text, text: $licenseViewModel.licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .textCase(.uppercase)

=======
            // License Activation
            VStack(spacing: 20) {
                Text("Already have a license?")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    TextField("Enter your license key", text: $licenseViewModel.licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .textCase(.uppercase)
                    
>>>>>>> upstream/main
                    Button(action: {
                        Task { await licenseViewModel.validateLicense() }
                    }) {
                        if licenseViewModel.isValidating {
                            ProgressView()
                                .controlSize(.small)
                        } else {
<<<<<<< HEAD
                            Text(L10n.License.activate.text)
=======
                            Text("Activate")
>>>>>>> upstream/main
                                .frame(width: 80)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(licenseViewModel.isValidating)
                }
<<<<<<< HEAD

=======
                
>>>>>>> upstream/main
                if let message = licenseViewModel.validationMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.callout)
                }
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)
<<<<<<< HEAD
        }
    }

    private var activatedContent: some View {
        VStack(spacing: 32) {
=======
            
            // Already Purchased Section
            VStack(spacing: 20) {
                Text("Already purchased?")
                    .font(.headline)

                HStack(spacing: 12) {
                    Text("Manage your license and device activations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        if let url = URL(string: "https://polar.sh/beingpax/portal/request") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("License Management Portal")
                            .frame(width: 180)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
    
    private var activatedContent: some View {
        VStack(spacing: 32) {
            // Status Card
>>>>>>> upstream/main
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
<<<<<<< HEAD
                    Text(L10n.License.licenseActive.text)
                        .font(.headline)
                    Spacer()
                    Text(L10n.License.activeStatus.text)
=======
                    Text("License Active")
                        .font(.headline)
                    Spacer()
                    Text("Active")
>>>>>>> upstream/main
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.green))
                        .foregroundStyle(.white)
                }
<<<<<<< HEAD

                Divider()

                if licenseViewModel.activationsLimit > 0 {
                    Text(L10n.License.activationLimitMessage.format(licenseViewModel.activationsLimit))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(L10n.License.allDevicesMessage.text)
=======
                
                Divider()
                
                if licenseViewModel.activationsLimit > 0 {
                    Text("This license can be activated on up to \(licenseViewModel.activationsLimit) devices")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("You can use VoiceInk Pro on all your personal devices")
>>>>>>> upstream/main
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)
<<<<<<< HEAD

            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.License.licenseManagement.text)
=======
            
            // Deactivation Card
            VStack(alignment: .leading, spacing: 16) {
                Text("License Management")
>>>>>>> upstream/main
                    .font(.headline)

                Button(role: .destructive, action: {
                    licenseViewModel.removeLicense()
                }) {
<<<<<<< HEAD
                    Label(L10n.License.deactivateLicense.text, systemImage: "xmark.circle.fill")
=======
                    Label("Deactivate License", systemImage: "xmark.circle.fill")
>>>>>>> upstream/main
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
<<<<<<< HEAD

    private func featureItem(icon: String, title: LocalizedStringKey, color: Color) -> some View {
=======
    
    private func featureItem(icon: String, title: String, color: Color) -> some View {
>>>>>>> upstream/main
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
<<<<<<< HEAD

=======
            
>>>>>>> upstream/main
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
    }
<<<<<<< HEAD
}

=======
    
    @State private var heartPulse = false
    
    private func animatedTipJarItem() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.pink)
                .scaleEffect(heartPulse ? 1.3 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true),
                    value: heartPulse
                )
                .onAppear {
                    heartPulse = true
                }
            
            Text("Tip Jar")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
    }
}


>>>>>>> upstream/main
