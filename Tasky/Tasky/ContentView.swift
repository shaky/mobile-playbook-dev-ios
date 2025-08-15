//
//  ContentView.swift
//  Tasky
//
//  Created by Sven Schleier on 22.05.25.
//

// ContentView.swift
import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var service: ToDoService

    var body: some View {
        VStack {
            Divider()
            ToDoMainView()
        }
        
        .sheet(item: Binding(
            get: { service.deepLinkRequest.map { IdentifiedRequest(request: $0) } },
            set: { _ in service.clearDeepLink() }
        )) { item in
            WebView(request: item.request)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView().environmentObject(ToDoService())
}

