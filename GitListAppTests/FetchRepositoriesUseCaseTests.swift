import XCTest
import SwiftData
@testable import GitListApp

final class FetchRepositoriesUseCaseTests: XCTestCase {
    
    var useCase: FetchRepositoriesUseCase!
    var mockService: MockGitHubService!
    var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        let container = try! ModelContainer(for: RepositoryEntity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = ModelContext(container)
        useCase = FetchRepositoriesUseCase(context: context, service: mockService)
    }
    
    override func tearDown() {
        useCase = nil
        mockService = nil
        context = nil
        super.tearDown()
    }
    
    func testFetchRepositoriesSuccessfully() async throws {
        let repositories = try await useCase.execute(page: 1)
        XCTAssertEqual(repositories.count, 30)
    }
    
    func testFetchFromLocal() {
        // Предварительно вставляем данные в локальное хранилище
        let entity = RepositoryEntity(id: 1, name: "Local Repo", repoDescription: "Local Desc", ownerLogin: "LocalUser", ownerAvatarUrl: "")
        context.insert(entity)
        
        let localRepos = useCase.fetchFromLocal()
        XCTAssertEqual(localRepos.first?.name, "Local Repo")
    }
}

final class MockGitHubService: GitHubServiceProtocol {
    var mockRepositories: [GitHubRepository] = []
    
    func fetchRepositories(page: Int) async throws -> [GitHubRepository] {
        return mockRepositories
    }
}
