import Foundation

struct GitHubRepository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let owner: Owner
}

struct Owner: Codable {
    let login: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case avatarURL = "avatar_url"
    }
}
