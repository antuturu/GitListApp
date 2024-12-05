import SwiftUI
import Combine
import SwiftData

@MainActor
class RepositoryListViewModel: ObservableObject {
    @Published var repositories: [RepositoryEntity] = []
    @Published var isLoading = false
    private var fetchUseCase: FetchRepositoriesUseCaseProtocol
    private let modifyUseCase: ModifyRepositoryUseCase
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    
    init(context: ModelContext, fetchUseCase: FetchRepositoriesUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
        self.modifyUseCase = ModifyRepositoryUseCase(context: context)
        observeLocalData()
    }
    
    func loadMoreRepositories() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            let newRepositories = try await fetchUseCase.execute(page: currentPage)
            repositories.append(contentsOf: newRepositories)
            currentPage += 1
        } catch {
            print("Error loading repositories: \(error)")
        }
        isLoading = false
    }
    
    private func observeLocalData() {
        Task {
            let fetchedRepositories = fetchUseCase.fetchFromLocal()
            repositories = fetchedRepositories
        }
    }
    
    func deleteRepository(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                let repository = repositories[index]
                do {
                    try modifyUseCase.delete(repository: repository)
                    repositories.remove(at: index)
                } catch {
                    print("Error deleting repository: \(error)")
                }
            }
        }
    }
    
    
    func editRepository(_ repository: RepositoryEntity, newName: String, newDescription: String?) {
        do {
            try modifyUseCase.edit(repository: repository, newName: newName, newDescription: newDescription)
        } catch {
            print("Error editing repository: \(error)")
        }
    }
}
