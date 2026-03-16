import SwiftUI
import UIKit

// MARK: - IPA Artwork

struct IpaArtworkView: View {
    let title: String
    let iconURL: String?
    var size: CGFloat = 60

    var body: some View {
        Group {
            if let iconURL, let url = URL(string: iconURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholderContent
                    }
                }
            } else {
                placeholderContent
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * 0.22))
    }

    private var placeholderContent: some View {
        ZStack {
            LinearGradient(
                colors: [.orange, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(String(title.prefix(1)).uppercased())
                .font(.system(size: size * 0.40, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Agreement Sheet

struct AgreementSheetView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(L10n.agreementBody)
                        .font(.body)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("agreement.heading.title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("agreement.accept") {
                        model.acceptAgreement()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
