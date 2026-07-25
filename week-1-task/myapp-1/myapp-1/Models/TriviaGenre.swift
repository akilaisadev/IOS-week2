import SwiftUI

enum TriviaGenre: Int, CaseIterable, Identifiable {
    case any = 0
    case generalKnowledge = 9
    case books = 10
    case film = 11
    case music = 12
    case videoGames = 15
    case scienceNature = 17
    case computers = 18
    case mathematics = 19
    case sports = 21
    case geography = 22
    case history = 23
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .any: return "Any Genre"
        case .generalKnowledge: return "General Knowledge"
        case .books: return "Books"
        case .film: return "Film"
        case .music: return "Music"
        case .videoGames: return "Video Games"
        case .scienceNature: return "Science & Nature"
        case .computers: return "Computers"
        case .mathematics: return "Mathematics"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        }
    }
    
    var iconName: String {
        switch self {
        case .any: return "sparkles"
        case .generalKnowledge: return "globe.desk.fill"
        case .books: return "book.closed.fill"
        case .film: return "film.fill"
        case .music: return "music.note"
        case .videoGames: return "gamecontroller.fill"
        case .scienceNature: return "leaf.fill"
        case .computers: return "desktopcomputer"
        case .mathematics: return "x.squareroot"
        case .sports: return "sportscourt.fill"
        case .geography: return "map.fill"
        case .history: return "clock.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .any: return .purple
        case .generalKnowledge: return .blue
        case .books: return .brown
        case .film: return .red
        case .music: return .pink
        case .videoGames: return .orange
        case .scienceNature: return .green
        case .computers: return .cyan
        case .mathematics: return .indigo
        case .sports: return .yellow
        case .geography: return .mint
        case .history: return .brown
        }
    }
}
