//
//  TaskyApp.swift
//  Tasky
//
//  Created by Sven Schleier on 22.05.25.
//

import SwiftUI

@main
struct TaskyApp: App {
    
    @StateObject var service = ToDoService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                    .environmentObject(service)
                    .onOpenURL { url in
                        service.handleDeeplink(url)
                    }
        }
    }
}
