import SwiftUI

struct ToDoMainView: View {
    @StateObject private var service = ToDoService()
    @State private var username = ""
    @State private var password = ""
    @State private var title = ""
    @State private var description = ""
    @State private var message = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if service.accessToken == nil {
                        Text("Tasky").font(.largeTitle)
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button("Register") {
                                service.register(username: username, password: password) { msg in
                                    message = msg
                                }
                            }
                            Button("Login") {
                                service.login(username: username, password: password) { success in
                                    message = success ? "Login success" : "Login failed"
                                }
                            }
                        }
                        Text(message).foregroundColor(.red)
                    } else {
                        Text("To-Dos").font(.title2)
                        TextField("Title", text: $title).textFieldStyle(.roundedBorder)
                        TextField("Description", text: $description).textFieldStyle(.roundedBorder)
                        Button("Add To-Do") {
                            service.createTodo(title: title, description: description)
                            title = ""
                            description = ""
                        }
                        Divider()
                        ForEach(service.todos) { todo in
                            VStack(alignment: .leading) {
                                Text(todo.title).bold()
                                Text(todo.description).font(.subheadline)
                            }.padding(4)
                        }
                    }
                }.padding()
            }
            .navigationTitle("Tasky")
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if service.accessToken != nil {
                            Button("Logout") {
                                service.clearTokens()
                            }
                        }
                    }
                }
        }
    }
}
