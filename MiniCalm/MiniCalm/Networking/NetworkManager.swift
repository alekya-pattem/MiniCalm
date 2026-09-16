import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchSessions() async throws -> [Session] {
        guard let url = URL(string: "https://gist.githubusercontent.com/Manojsuthar2000/441d8e745e124afe601fb85fb1c49a31/raw/sessions.json") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        do {
            let result = try JSONDecoder().decode(SessionResponse.self, from: data)
            return result.sessions
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
