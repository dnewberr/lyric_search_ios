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
    let helper: WebViewHelper?
    
    init(url: URL?, helper: WebViewHelper?) {
        self.url = url
        self.helper = helper
    }

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
        webview.navigationDelegate = helper
        webview.uiDelegate = helper
        
        if let url = self.url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webview.load(request)
        }
    }
}

final class WebViewHelper: NSObject, WKNavigationDelegate, WKUIDelegate {
    struct Output {
        var htmlPublisher: AnyPublisher<String, Never>
    }
    
    func bind() -> Output {
        return Output(htmlPublisher: htmlSubject.eraseToAnyPublisher())
    }
    
    let htmlSubject = PassthroughSubject<String, Never>()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let htmlJS = "document.documentElement.innerText.toString()"
        
        webView.evaluateJavaScript(htmlJS) { [weak self] html, error in
            guard let html = html as? String else { return }
            self?.htmlSubject.send(html)
        }
    }
}

struct HTMLView: UIViewRepresentable {
    let savedSong: SavedSong
    let helper: WebViewHelper?
    
    init(savedSong: SavedSong, helper: WebViewHelper? = nil) {
        self.savedSong = savedSong
        self.helper = helper
    }

    func makeUIView(context: UIViewRepresentableContext<HTMLView>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = helper
        webview.uiDelegate = helper

        if let html = self.savedSong.songLyrics?.content {
            webview.loadHTMLString(html, baseURL: nil)
        }

        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<HTMLView>) {
        if let html = self.savedSong.songLyrics?.content {
            webview.loadHTMLString(html, baseURL: nil)
        }
    }
}
