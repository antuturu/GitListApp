import SwiftUI
import SwiftData
import Kingfisher

struct RepositoryListView: View {
    
    @StateObject private var viewModel: RepositoryListViewModel
    @State private var isEditing = false
    @State private var selectedRepository: RepositoryEntity?
    @State private var newName = ""
    @State private var newDescription = ""
    
    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: RepositoryListViewModel(context: context, fetchUseCase: FetchRepositoriesUseCase(context: context, service: GitHubService() as GitHubServiceProtocol) as FetchRepositoriesUseCaseProtocol))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.repositories, id: \.id) { repo in
                        HStack(spacing: 16) {
                            KFImage(URL(string: repo.ownerAvatarUrl))
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(repo.name).font(.headline)
                                Text(repo.repoDescription ?? "No description").font(.subheadline)
                            }
                        }
                        .onTapGesture {
                            startEditing(repo)
                        }
                        .onAppear {
                            if repo == viewModel.repositories.last {
                                Task {
                                    await viewModel.loadMoreRepositories()
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteRepository(at: indexSet)
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                if viewModel.isLoading && viewModel.repositories.isEmpty {
                    ProgressView("Loading repositories...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .navigationTitle("Repositories")
            .toolbar {
                EditButton()
            }
            .sheet(item: $selectedRepository) { repo in
                editView(for: repo)
            }
            .onAppear {
                Task {
                    await viewModel.loadMoreRepositories()
                }
            }
        }
    }
    
    private func startEditing(_ repo: RepositoryEntity) {
        selectedRepository = repo
        newName = repo.name
        newDescription = repo.repoDescription ?? ""
    }
    
    private func editView(for repo: RepositoryEntity) -> some View {
        NavigationView {
            Form {
                TextField("Name", text: $newName)
                TextField("Description", text: $newDescription)
            }
            .navigationTitle("Edit Repository")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.editRepository(repo, newName: newName, newDescription: newDescription)
                        selectedRepository = nil
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selectedRepository = nil
                    }
                }
            }
        }
    }
}
