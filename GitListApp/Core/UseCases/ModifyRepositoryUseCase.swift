import SwiftUI
import SwiftData

class ModifyRepositoryUseCase {
    var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }

    func delete(repository: RepositoryEntity) throws {
        context.delete(repository)
        try context.save()
    }

    func edit(repository: RepositoryEntity, newName: String, newDescription: String?) throws {
        repository.name = newName
        repository.repoDescription = newDescription
        try context.save()
    }
}
