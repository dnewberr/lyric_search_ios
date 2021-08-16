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
    let navigationHelper = WebViewHelper()

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = navigationHelper

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

class WebViewHelper: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview didFinishNavigation")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("webviewDidCommit")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceiveAuthenticationChallenge")
        completionHandler(.performDefaultHandling, nil)
    }
}
