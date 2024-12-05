import XCTest
import SwiftData
@testable import GitListApp

final class RepositoryListViewModelTests: XCTestCase {
    
    var viewModel: RepositoryListViewModel!
    var mockUseCase: MockFetchRepositoriesUseCase!
    let container = try! ModelContainer(for: RepositoryEntity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchRepositoriesUseCase()
        context = ModelContext(container)
        
        let expectation = self.expectation(description: "ViewModel initialized")
        
        Task { @MainActor in
            self.viewModel = RepositoryListViewModel(context: self.context, fetchUseCase: self.mockUseCase)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        context = nil
        super.tearDown()
    }
    
    func testLoadMoreRepositories() async {
        mockUseCase.mockRepositories = [
            RepositoryEntity(id: 1, name: "Repo 1", repoDescription: "Desc", ownerLogin: "Owner", ownerAvatarUrl: ""),
            RepositoryEntity(id: 2, name: "Repo 2", repoDescription: "Desc", ownerLogin: "Owner", ownerAvatarUrl: "")
        ]
        
        XCTAssertNotNil(viewModel)
        
        await viewModel.loadMoreRepositories()
        
        print("Loaded repositories count: \(await viewModel.repositories.count)")
        
        await MainActor.run {
            XCTAssertFalse(viewModel.repositories.isEmpty, "Repositories should not be empty after loading")
            
            XCTAssertEqual(viewModel.repositories.count, 2, "There should be two repositories after loading")
        }
    }
    
    @MainActor func testDeleteRepository() async {
        let entity = RepositoryEntity(id: 1, name: "Repo 1", repoDescription: "Desc", ownerLogin: "Owner", ownerAvatarUrl: "")
        
        viewModel.repositories = [entity]
        
        let indexSet = IndexSet([0])
        viewModel.deleteRepository(at: indexSet)
        
        XCTAssertTrue(viewModel.repositories.isEmpty, "Repositories should be empty after deletion")
    }
}

final class MockFetchRepositoriesUseCase: FetchRepositoriesUseCaseProtocol {
    var mockRepositories: [RepositoryEntity] = []
    
    func execute(page: Int) async throws -> [RepositoryEntity] {
        return mockRepositories
    }
    
    func fetchFromLocal() -> [RepositoryEntity] {
        return mockRepositories
    }
}
