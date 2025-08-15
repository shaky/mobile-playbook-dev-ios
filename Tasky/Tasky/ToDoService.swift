import Foundation

let baseURL = "https://mobile.s7ven.info:8000"

struct ToDo: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
}

class ToDoService: ObservableObject {
    @Published var todos: [ToDo] = []
    @Published var accessToken: String?
    @Published var refreshToken: String?

    @Published var deepLinkRequest: URLRequest?
    
    init() {
        loadTokens()
        if let access = accessToken {
            fetchTodos(token: access)
        } else if let refresh = refreshToken {
            refreshAccessToken(refresh)
        }
    }

    func saveTokens(access: String, refresh: String) {
        UserDefaults.standard.setValue(access, forKey: "access_token")
        UserDefaults.standard.setValue(refresh, forKey: "refresh_token")
        accessToken = access
        refreshToken = refresh
    }

    func loadTokens() {
        accessToken = UserDefaults.standard.string(forKey: "access_token")
        refreshToken = UserDefaults.standard.string(forKey: "refresh_token")
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        accessToken = nil
        refreshToken = nil
    }

    func register(username: String, password: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        let body = ["username": username, "password": password]
        postRequest(url: url, json: body) { data, _, _ in
            let msg = String(data: data ?? Data(), encoding: .utf8) ?? "No response"
            completion(msg)
        }
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/token") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = "username=\(username)&password=\(password)".data(using: .utf8)

        URLSession.shared.dataTask(with: req) { data, response, _ in
            guard let data = data else {
                completion(false)
                return
            }
            if let json = try? JSONDecoder().decode([String: String].self, from: data),
               let access = json["access_token"], let refresh = json["refresh_token"] {
                DispatchQueue.main.async {
                    self.saveTokens(access: access, refresh: refresh)
                    self.fetchTodos(token: access)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }.resume()
    }

    
    func handleDeeplink(_ incoming: URL) {
        
        guard incoming.scheme?.lowercased() == "tasky" else { return }
        guard let comps = URLComponents(url: incoming, resolvingAgainstBaseURL: false),
              let urlValue = comps.queryItems?.first(where: { $0.name == "url" })?.value,
              let candidate = URL(string: urlValue),
              ["http","https"].contains(candidate.scheme?.lowercased() ?? "") else { return }

        print(accessToken);
        
        var req = URLRequest(url: candidate)
        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No access token available for Authorization header")
        }

        DispatchQueue.main.async { self.deepLinkRequest = req }
    }

    // optional helper to clear after dismissal
    func clearDeepLink() {
        deepLinkRequest = nil
    }
    
    
    
    
    
    func refreshAccessToken(_ refresh: String) {
        guard let url = URL(string: "\(baseURL)/token/refresh") else { return }
        let body = ["refresh_token": refresh]
        postRequest(url: url, json: body) { data, _, _ in
            guard let data = data,
                  let json = try? JSONDecoder().decode([String: String].self, from: data),
                  let newToken = json["access_token"] else {
                DispatchQueue.main.async {
                    self.clearTokens()
                }
                return
            }
            DispatchQueue.main.async {
                self.saveTokens(access: newToken, refresh: refresh)
                self.fetchTodos(token: newToken)
            }
        }
    }

    func fetchTodos(token: String) {
        guard let url = URL(string: "\(baseURL)/todos") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: req) { data, response, _ in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 401 {
                print("Access token expired, trying to refresh...")
                if let refresh = self.refreshToken {
                    self.refreshAccessToken(refresh)  // this will also re-fetch todos on success
                } else {
                    DispatchQueue.main.async {
                        self.clearTokens()
                    }
                }
                return
            }

            guard let data = data else { return }
            if let todos = try? JSONDecoder().decode([ToDo].self, from: data) {
                DispatchQueue.main.async {
                    self.todos = todos.reversed()
                }
            }
        }.resume()
    }

    func createTodo(title: String, description: String) {
        guard let token = accessToken, let url = URL(string: "\(baseURL)/todo") else { return }
        let body = ["title": title, "description": description]
        postRequest(url: url, json: body, token: token) { data, response, _ in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 401, let refresh = self.refreshToken {
                self.refreshAccessToken(refresh)
                return
            }
            self.fetchTodos(token: token)
        }
    }

    private func postRequest(url: URL, json: [String: String], token: String? = nil,
                             completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = try? JSONEncoder().encode(json)

        URLSession.shared.dataTask(with: req, completionHandler: completion).resume()
    }
    

    
}
