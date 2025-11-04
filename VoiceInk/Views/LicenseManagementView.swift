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
        let isLicensed = licenseViewModel.licenseState == .licensed
        let titleKey: LocalizedStringKey = isLicensed ? L10n.Sidebar.voiceInkPro.text : L10n.License.upgradeToPro.text
        let subtitleKey: LocalizedStringKey = isLicensed ? L10n.License.supportMessage.text : L10n.License.heroSubtitle.text

        return VStack(spacing: 24) {
            AppIconView()

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue)

                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(titleKey)
                            .font(.system(size: 32, weight: .bold))

                        Text(L10n.License.versionFormat.format(appVersion))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                    }
                }

                Text(subtitleKey)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if isLicensed {
                    HStack(spacing: 40) {
                        Button {
                            if let url = URL(string: "https://github.com/Beingpax/VoiceInk/releases") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            featureItem(icon: "list.bullet.clipboard.fill", title: L10n.License.changelog.text, color: .blue)
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let url = URL(string: "https://discord.gg/xryDy57nYD") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            featureItem(icon: "bubble.left.and.bubble.right.fill", title: L10n.License.discord.text, color: .purple)
                        }
                        .buttonStyle(.plain)

                        Button {
                            EmailSupport.openSupportEmail()
                        } label: {
                            featureItem(icon: "envelope.fill", title: L10n.License.emailSupport.text, color: .orange)
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let url = URL(string: "https://tryvoiceink.com/docs") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            featureItem(icon: "book.fill", title: L10n.License.docs.text, color: .indigo)
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let url = URL(string: "https://github.com/Beingpax/VoiceInk/issues") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            featureItem(icon: "map.fill", title: L10n.License.roadmap.text, color: .green)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.vertical, 60)
    }

    private var purchaseContent: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "infinity.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                    Text(L10n.License.buyOnceOwnForever.text)
                        .font(.headline)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                Button(action: {
                    if let url = URL(string: "https://tryvoiceink.com/buy") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text(L10n.License.upgradeToVoiceInkPro.text)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)

                HStack(spacing: 40) {
                    featureItem(icon: "bubble.left.and.bubble.right.fill", title: L10n.License.prioritySupport.text, color: .purple)
                    featureItem(icon: "infinity.circle.fill", title: L10n.License.lifetimeAccess.text, color: .blue)
                    featureItem(icon: "arrow.up.circle.fill", title: L10n.License.freeUpdates.text, color: .green)
                    featureItem(icon: "macbook.and.iphone", title: L10n.License.multipleDevices.text, color: .orange)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)

            VStack(spacing: 20) {
                Text(L10n.License.alreadyHaveLicense.text)
                    .font(.headline)

                HStack(spacing: 12) {
                    TextField(L10n.License.enterLicenseKey.text, text: $licenseViewModel.licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .textCase(.uppercase)

                    Button(action: {
                        Task { await licenseViewModel.validateLicense() }
                    }) {
                        if licenseViewModel.isValidating {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(L10n.License.activate.text)
                                .frame(width: 80)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(licenseViewModel.isValidating)
                }

                if let message = licenseViewModel.validationMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.callout)
                }
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }

    private var activatedContent: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                    Text(L10n.License.licenseActive.text)
                        .font(.headline)
                    Spacer()
                    Text(L10n.License.activeStatus.text)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.green))
                        .foregroundStyle(.white)
                }

                Divider()

                if licenseViewModel.activationsLimit > 0 {
                    Text(L10n.License.activationLimitMessage.format(licenseViewModel.activationsLimit))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(L10n.License.allDevicesMessage.text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(32)
            .background(CardBackground(isSelected: false))
            .shadow(color: .black.opacity(0.05), radius: 10)

            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.License.licenseManagement.text)
                    .font(.headline)

                Button(role: .destructive, action: {
                    licenseViewModel.removeLicense()
                }) {
                    Label(L10n.License.deactivateLicense.text, systemImage: "xmark.circle.fill")
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

    private func featureItem(icon: String, title: LocalizedStringKey, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
    }
}

