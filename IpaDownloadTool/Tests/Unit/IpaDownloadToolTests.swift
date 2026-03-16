import XCTest
@testable import IpaDownloadTool

final class IpaDownloadToolTests: XCTestCase {
    func testManifestURLExtractionPrefersQueryItem() {
        let extractor = ManifestExtractor()
        let url = URL(string: "itms-services://?action=download-manifest&url=https://example.com/app.plist")!

        XCTAssertEqual(
            extractor.manifestURL(from: url)?.absoluteString,
            "https://example.com/app.plist"
        )
    }

    func testDisplayFileNameIncludesVersionWhenAvailable() {
        let record = IpaRecord(
            id: "1",
            title: "Demo",
            version: "1.2.3",
            bundleIdentifier: nil,
            downloadURL: "https://example.com/demo.ipa",
            iconURL: nil,
            fromPageURL: nil,
            createdAt: .now,
            localFileName: nil
        )

        XCTAssertEqual(record.displayFileName, "Demo(v1.2.3).ipa")
    }
}
