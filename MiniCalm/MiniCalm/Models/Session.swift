import Foundation

struct SessionResponse: Codable {
    let sessions: [Session]
}

struct Session: Codable, Identifiable {
    public let id                   : String?
    public let title                : String?
    public let teacher              : String?
    public let duration_seconds     : Int?
    public let artwork_url          : String?
    public let audio_url            : String?
    public let is_premium           : Bool?
}
