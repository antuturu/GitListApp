import SwiftData

@Model
final class RepositoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var repoDescription: String?
    var ownerLogin: String
    var ownerAvatarUrl: String

    init(id: Int, name: String, repoDescription: String?, ownerLogin: String, ownerAvatarUrl: String) {
        self.id = id
        self.name = name
        self.repoDescription = repoDescription
        self.ownerLogin = ownerLogin
        self.ownerAvatarUrl = ownerAvatarUrl
    }
}
