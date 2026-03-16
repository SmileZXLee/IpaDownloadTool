import AVFoundation
import SwiftUI
import UIKit
import WebKit

struct BrowserView: View {
    @ObservedObject var model: AppModel
    @StateObject private var browser = BrowserController()

    var body: some View {
        NavigationStack {
            NativeWebView(browser: browser)
                .overlay(alignment: .top) {
                    if browser.isLoading {
                        ProgressView(value: browser.progress)
                            .progressViewStyle(.linear)
                            .animation(.easeInOut, value: browser.progress)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        AddressBar(browser: browser) {
                            browser.scannerPresented = true
                        } onPaste: { string in
                            browser.addressText = string
                            browser.load(string)
                        }
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        Button { browser.goBack() } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!browser.canGoBack)

                        Spacer()

                        Button { browser.goForward() } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!browser.canGoForward)

                        Spacer()

                        Button { browser.reload() } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(!browser.hasLoadedPage)

                        Spacer()

                        Button { browser.openInSafari() } label: {
                            Image(systemName: "safari")
                        }
                        .disabled(!browser.hasLoadedPage)
                    }
                }
        }
        .task {
            syncCallbacks()
            browser.bootstrapIfNeeded(lastLoadedURL: model.settings.lastLoadedURL)
        }
        .onChange(of: model.pendingBrowserLoadURL) { _, newValue in
            guard let newValue else { return }
            browser.addressText = newValue
            browser.load(newValue)
            model.pendingBrowserLoadURL = nil
        }
        .confirmationDialog(
            "browser.directIPA.title",
            isPresented: Binding(
                get: { browser.pendingDirectIPAURL != nil },
                set: { if !$0 { browser.pendingDirectIPAURL = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("browser.directIPA.download") {
                browser.downloadPendingIpa()
            }
            Button("browser.directIPA.visit") {
                browser.visitPendingIpaAsPage()
            }
            Button("common.cancel", role: .cancel) {
                browser.pendingDirectIPAURL = nil
            }
        } message: {
            Text("browser.directIPA.message")
        }
        .confirmationDialog(
            "browser.provision.title",
            isPresented: Binding(
                get: { browser.pendingProvisionURL != nil },
                set: { if !$0 { browser.pendingProvisionURL = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("browser.provision.openSafari") {
                browser.openPendingProvisionInSafari()
            }
            Button("common.cancel", role: .cancel) {
                browser.pendingProvisionURL = nil
            }
        } message: {
            Text("browser.provision.message")
        }
        .sheet(isPresented: $browser.scannerPresented) {
            ScannerSheet { value in
                browser.scannerPresented = false
                browser.addressText = value
                browser.load(value)
            }
        }
    }

    private func syncCallbacks() {
        browser.settingsProvider = { model.settings }
        browser.onRememberURL = { value in
            model.updateLastLoadedURL(value)
        }
        browser.onVisitedPage = { title, url, host, faviconURL in
            model.registerVisitedPage(title: title, url: url, host: host, faviconURL: faviconURL)
        }
        browser.onManifestRecord = { record in
            model.upsertRecord(record)
        }
        browser.onDirectIPARecord = { record in
            model.upsertRecord(record, present: false)
            model.startDownload(for: record.id)
        }
        browser.onNotice = { title, message in
            model.notice = AppNotice(title: title, message: message)
        }
    }
}

// MARK: - Address Bar

private struct AddressBar: View {
    @ObservedObject var browser: BrowserController
    let onScan: () -> Void
    let onPaste: (String) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: browser.hasLoadedPage ? "lock.fill" : "globe")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("browser.address.placeholder", text: $browser.addressText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .font(.subheadline)
                .onSubmit {
                    browser.load(browser.addressText)
                }

            Divider()
                .frame(height: 16)

            PasteButton(payloadType: String.self) { strings in
                guard let first = strings.first else { return }
                onPaste(first)
            }
            .labelStyle(.iconOnly)
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderless)

            Button(action: onScan) {
                Image(systemName: "qrcode.viewfinder")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary, in: .capsule)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - WebView Bridge

private struct NativeWebView: UIViewRepresentable {
    @ObservedObject var browser: BrowserController

    func makeUIView(context: Context) -> WKWebView {
        browser.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Browser Controller

@MainActor
final class BrowserController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    @Published var addressText = ""
    @Published var currentTitle = ""
    @Published var progress = 0.0
    @Published var isLoading = false
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var hasLoadedPage = false
    @Published var pendingDirectIPAURL: String?
    @Published var pendingProvisionURL: String?
    @Published var scannerPresented = false

    let extractor = ManifestExtractor()
    let webView: WKWebView

    var settingsProvider: (() -> AppSettings)?
    var onRememberURL: ((String) -> Void)?
    var onVisitedPage: ((String, String, String, String?) -> Void)?
    var onManifestRecord: ((IpaRecord) -> Void)?
    var onDirectIPARecord: ((IpaRecord) -> Void)?
    var onNotice: ((String, String) -> Void)?

    private var ignoredDirectIPAURL: String?
    private var didBootstrap = false

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
    }

    func bootstrapIfNeeded(lastLoadedURL: String) {
        guard !didBootstrap else { return }
        didBootstrap = true
        guard !lastLoadedURL.isEmpty else { return }
        addressText = lastLoadedURL
        load(lastLoadedURL, remember: false)
    }

    func load(_ rawValue: String, remember: Bool = true) {
        guard let normalized = extractor.normalizedURLString(from: rawValue),
              let encoded = normalized.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let url = URL(string: encoded) ?? URL(string: normalized)
        else {
            onNotice?(
                L10n.string("notice.invalidLink.title"),
                L10n.string("notice.invalidLink.message")
            )
            return
        }

        addressText = normalized
        if remember {
            onRememberURL?(normalized)
        }
        webView.load(URLRequest(url: url))
    }

    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func reload() { webView.reload() }

    func openInSafari() {
        guard let url = webView.url else { return }
        UIApplication.shared.open(url)
    }

    func downloadPendingIpa() {
        guard let pendingDirectIPAURL, let url = URL(string: pendingDirectIPAURL) else { return }
        let record = extractor.makeDirectIpaRecord(from: url, sourcePageURL: webView.url?.absoluteString)
        onDirectIPARecord?(record)
        self.pendingDirectIPAURL = nil
    }

    func visitPendingIpaAsPage() {
        guard let pendingDirectIPAURL else { return }
        ignoredDirectIPAURL = pendingDirectIPAURL
        let url = pendingDirectIPAURL
        self.pendingDirectIPAURL = nil
        load(url, remember: false)
    }

    func openPendingProvisionInSafari() {
        defer { pendingProvisionURL = nil }
        guard let pendingProvisionURL, let url = URL(string: pendingProvisionURL) else { return }
        UIApplication.shared.open(url)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        hasLoadedPage = true
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        currentTitle = webView.title ?? addressText
        addressText = webView.url?.absoluteString ?? addressText
        progress = 1
        persistVisit()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        onNotice?(L10n.string("notice.loadFailed.title"), error.localizedDescription)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        progress = webView.estimatedProgress
        let settings = settingsProvider?() ?? AppSettings()

        if let host = url.host?.lowercased(),
           settings.blockedHosts.contains(host),
           !settings.developerMode {
            onNotice?(L10n.string("notice.blockedAccess.title"), L10n.blockedHostMessage(host))
            decisionHandler(.cancel)
            return
        }

        if extractor.isMobileProvisionLink(url, patterns: settings.mobileProvisionRules) {
            pendingProvisionURL = url.absoluteString
            decisionHandler(.cancel)
            return
        }

        if extractor.isDirectIpaLink(url) {
            let absolute = url.absoluteString
            if ignoredDirectIPAURL == absolute {
                ignoredDirectIPAURL = nil
            } else {
                pendingDirectIPAURL = absolute
                decisionHandler(.cancel)
                return
            }
        }

        if let manifestURL = extractor.manifestURL(from: url) {
            decisionHandler(.cancel)
            Task {
                await handleManifest(manifestURL)
            }
            return
        }

        decisionHandler(.allow)
    }

    private func handleManifest(_ manifestURL: URL) async {
        do {
            let record = try await extractor.fetchManifestRecord(
                manifestURL: manifestURL,
                sourcePageURL: webView.url?.absoluteString
            )
            onManifestRecord?(record)
        } catch {
            onNotice?(L10n.string("notice.extractionFailed.title"), error.localizedDescription)
        }
    }

    private func persistVisit() {
        let titleScript = "document.title"
        let faviconScript = """
        (() => {
            const icons = [...document.querySelectorAll("link[rel~='icon']")];
            return icons[0]?.href ?? null;
        })();
        """

        webView.evaluateJavaScript(titleScript) { [weak self] title, _ in
            guard let self, let currentURL = self.webView.url else { return }
            let titleValue = (title as? String) ?? self.webView.title ?? currentURL.host ?? currentURL.absoluteString
            self.webView.evaluateJavaScript(faviconScript) { favicon, _ in
                let faviconURL = favicon as? String
                self.onVisitedPage?(titleValue, currentURL.absoluteString, currentURL.host ?? currentURL.absoluteString, faviconURL)
            }
        }
    }
}

// MARK: - QR Scanner Sheet

private struct ScannerSheet: View {
    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    QRScannerView(onScan: onScan)
                        .clipShape(.rect(cornerRadius: 24))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        }

                    Text("browser.scanner.instruction")
                        .foregroundStyle(.white.opacity(0.8))
                        .font(.subheadline)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.close") { dismiss() }
                }
            }
        }
    }
}

private struct QRScannerView: UIViewRepresentable {
    let onScan: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        context.coordinator.configure(previewView: view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let session = AVCaptureSession()
        private let onScan: (String) -> Void
        private var didScan = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func configure(previewView: PreviewView) {
            guard !session.isRunning else { return }

            previewView.videoPreviewLayer.session = session
            previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                startSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async { self.startSession() }
                    }
                }
            default:
                break
            }
        }

        private func startSession() {
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input)
            else { return }

            let output = AVCaptureMetadataOutput()
            guard session.canAddOutput(output) else { return }

            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
            session.commitConfiguration()
            session.startRunning()
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !didScan,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let value = object.stringValue
            else { return }

            didScan = true
            session.stopRunning()
            onScan(value)
        }
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
