import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let smallImageURL: String
    var isLiked: Bool
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt.toDate()
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.smallImageURL = result.urls.small
        self.isLiked = result.likedByUser
    }
}

