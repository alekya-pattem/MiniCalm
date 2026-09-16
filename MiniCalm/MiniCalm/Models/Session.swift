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

extension Session {
    static let placeholder = Session(
        id              : "placeholder",
        title           : "Meditation Session",
        teacher         : "Teacher Name",
        duration_seconds: 600,
        artwork_url     : nil,
        audio_url       : nil,
        is_premium      : false
    )
    
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(duration_seconds ?? 0)) ?? "0:00"
    }
}
