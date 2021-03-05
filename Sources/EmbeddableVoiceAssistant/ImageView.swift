//
//  ImageView.swift
//  
//
//  Created by Andrii Horishnii on 25.02.2021.
//

import SwiftUI

public let imageBundle = Bundle.embeddableVoiceAssistantModule

private class EVABundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var embeddableVoiceAssistantModule: Bundle = {
        let bundleName = "EmbeddableVoiceAssistant_EmbeddableVoiceAssistant"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: EVABundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,

            // Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/").
            Bundle(for: EVABundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),

            Bundle(for: EVABundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named EmbeddableVoiceAssistant_EmbeddableVoiceAssistant")
    }()
}

public func AssetImage(_ name: String) -> UIImage? {
    UIImage(named: name, in: imageBundle, compatibleWith: nil)
}

struct ImageView: View {
    var name: String

    var body: some View {
        if let uiImage = AssetImage(name) {
            Image(uiImage: uiImage)
        } else {
            EmptyView()
        }
    }
}
