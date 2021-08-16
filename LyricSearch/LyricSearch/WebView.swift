//
//  WebView.swift
//  WebView
//
//  Created by Deborah Newberry on 8/15/21.
//

import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webview = WKWebView()

        if let url = self.url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webview.load(request)
        }

        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<WebView>) {
        if let url = self.url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webview.load(request)
        }
    }
}
