import Foundation

protocol GitHubServiceProtocol {
    func fetchRepositories(page: Int) async throws -> [GitHubRepository]
}

class GitHubService: GitHubServiceProtocol {
    func fetchRepositories(page: Int) async throws -> [GitHubRepository] {
        let urlString = "https://api.github.com/search/repositories?q=swift&sort=stars&order=asc&page=\(page)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return decodedResponse.items
    }
}

struct SearchResponse: Codable {
    let items: [GitHubRepository]
}
