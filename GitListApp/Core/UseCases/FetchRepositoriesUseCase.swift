import SwiftData
import SwiftUI

protocol FetchRepositoriesUseCaseProtocol {
    func execute(page: Int) async throws -> [RepositoryEntity]
    func fetchFromLocal() -> [RepositoryEntity]
}

class FetchRepositoriesUseCase: FetchRepositoriesUseCaseProtocol {
    private let context: ModelContext
    private let service: GitHubServiceProtocol
    
    init(context: ModelContext, service: GitHubServiceProtocol) {
        self.context = context
        self.service = service
    }
    
    func execute(page: Int) async throws -> [RepositoryEntity] {
        let repositories = try await GitHubService().fetchRepositories(page: page)
        do {
            for repo in repositories {
                let entity = RepositoryEntity(
                    id: repo.id,
                    name: repo.name,
                    repoDescription: repo.description,
                    ownerLogin: repo.owner.login,
                    ownerAvatarUrl: repo.owner.avatarURL
                )
                context.insert(entity)
            }
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        return repositories.map { repo in
            RepositoryEntity(
                id: repo.id,
                name: repo.name,
                repoDescription: repo.description,
                ownerLogin: repo.owner.login,
                ownerAvatarUrl: repo.owner.avatarURL
            )
        }
    }
    
    func fetchFromLocal() -> [RepositoryEntity] {
        var fetchRequest = FetchDescriptor<RepositoryEntity>()
        fetchRequest.fetchLimit = 30
        return (try? context.fetch(fetchRequest)) ?? []
    }
}
