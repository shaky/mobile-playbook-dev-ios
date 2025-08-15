//
//  WebView.swift
//  Tasky
//
//  Created by Sven Schleier on 14.08.25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.load(request)          
        return wv
    }
    func updateUIView(_ webView: WKWebView, context: Context) { }
}


struct IdentifiedRequest: Identifiable {
    let id = UUID()          // new ID each deeplink → sheet always opens
    let request: URLRequest
}
//struct IdentifiedURL: Identifiable { let url: URL; var id: URL { url } }
