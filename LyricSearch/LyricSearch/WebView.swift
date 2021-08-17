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
    let helper = WebViewHelper()

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = helper
        webview.uiDelegate = helper

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

class WebViewHelper: NSObject, WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let htmlJS = "document.documentElement.innerText.toString()"
        
        webView.evaluateJavaScript(htmlJS) { html, error in
            guard let html = html as? String else { return }
            print(html)
        }
    }
}
