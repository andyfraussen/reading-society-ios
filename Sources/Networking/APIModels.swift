import Foundation

public typealias EntityID = String
public typealias APIDate = String
public typealias APIDateTime = String

public enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: JSONValue].self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .number(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public struct APIEnvelope<Data: Codable & Sendable>: Codable, Equatable, Sendable where Data: Equatable {
    public let data: Data
}

public struct APIResourceWithMeta<Data: Codable & Equatable & Sendable, Meta: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    public let data: Data
    public let meta: Meta?
}

public struct PaginatedResponse<Data: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    public let data: [Data]
    public let links: [String: JSONValue]?
    public let meta: PaginationMeta?
}

public struct PaginationMeta: Codable, Equatable, Sendable {
    public let currentPage: Int?
    public let from: Int?
    public let lastPage: Int?
    public let perPage: Int?
    public let to: Int?
    public let total: Int?
}

public struct ErrorResponse: Codable, Equatable, Sendable {
    public let message: String?
    public let errors: [String: [String]]?
}

public enum MembershipRole: String, Codable, Equatable, Sendable {
    case owner
    case admin
    case member
    case guest
}

public enum MembershipStatus: String, Codable, Equatable, Sendable {
    case active
    case invited
    case pending
    case removed
    case left
}

public enum SocietyVisibility: String, Codable, Equatable, Sendable {
    case `private`
    case inviteOnly = "invite_only"
}

public enum SocietyBookStatus: String, Codable, Equatable, Sendable {
    case nominated
    case selected
    case currentlyReading = "currently_reading"
    case paused
    case finished
    case archived
    case rejected
}

public enum PositionType: String, Codable, Equatable, Sendable {
    case page
    case chapter
    case percentage
    case location
    case custom
}

public enum ReadingPlanCadence: String, Codable, Equatable, Sendable {
    case weekly
    case biweekly
    case custom
}

public enum Visibility: String, Codable, Equatable, Sendable {
    case `private`
    case society
    case discussion
}

public enum SpoilerLevel: String, Codable, Equatable, Sendable {
    case none
    case minor
    case major
}

public enum DiscussionStatus: String, Codable, Equatable, Sendable {
    case scheduled
    case inProgress = "in_progress"
    case completed
    case cancelled
}

public enum LocationType: String, Codable, Equatable, Sendable {
    case inPerson = "in_person"
    case video
    case voice
    case text
}

public enum JournalStatus: String, Codable, Equatable, Sendable {
    case draft
    case generating
    case ready
    case failed
    case published
    case archived
}

public struct User: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let name: String
    public let email: String
    public let avatarPath: String?
    public let timezone: String?
    public let locale: String?
}

public struct Society: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let name: String
    public let slug: String?
    public let description: String?
    public let visibility: SocietyVisibility?
    public let coverImagePath: String?
    public let crestIcon: String?
    public let theme: [String: JSONValue]?
    public let timezone: String?
    public let ownerId: EntityID?
    public let createdAt: APIDateTime?
    public let updatedAt: APIDateTime?
}

public struct Book: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let authors: [String]?
    public let isbn10: String?
    public let isbn13: String?
    public let publisher: String?
    public let publishedDate: String?
    public let firstPublishYear: Int?
    public let pageCount: Int?
    public let language: String?
    public let coverImagePath: String?
    public let canonicalWorkKey: String?
    public let metadataQualityScore: Int?
    public let metadata: [String: JSONValue]?
}

public struct SocietyBook: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let bookId: EntityID?
    public let selectedByUserId: EntityID?
    public let status: SocietyBookStatus?
    public let startDate: APIDate?
    public let targetEndDate: APIDate?
    public let finishedAt: APIDateTime?
    public let currentPositionType: PositionType?
    public let currentPositionValue: String?
    public let averageProgressPercentage: Int?
    public let averageRating: String?
    public let notesCount: Int?
    public let quotesCount: Int?
    public let book: Book?
}

public struct Progress: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID?
    public let userId: EntityID?
    public let societyBookId: EntityID?
    public let positionType: PositionType?
    public let positionValue: String?
    public let percentage: Int?
    public let updatedAt: APIDateTime?
}

public struct ReadingPlan: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyBookId: EntityID?
    public let createdByUserId: EntityID?
    public let title: String
    public let description: String?
    public let startDate: APIDate?
    public let endDate: APIDate?
    public let cadence: ReadingPlanCadence?
    public let items: [ReadingPlanItem]?
}

public struct ReadingPlanItem: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let title: String
    public let description: String?
    public let positionStartType: PositionType?
    public let positionStartValue: String?
    public let positionEndType: PositionType?
    public let positionEndValue: String?
    public let dueDate: APIDate?
    public let sortOrder: Int?
}

public struct Note: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let societyBookId: EntityID?
    public let userId: EntityID?
    public let readingPlanItemId: EntityID?
    public let discussionId: EntityID?
    public let visibility: Visibility?
    public let title: String?
    public let body: String
    public let positionType: PositionType?
    public let positionValue: String?
    public let spoilerLevel: SpoilerLevel?
    public let createdAt: APIDateTime?
    public let updatedAt: APIDateTime?
}

public struct Quote: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let societyBookId: EntityID?
    public let userId: EntityID?
    public let readingPlanItemId: EntityID?
    public let text: String
    public let commentary: String?
    public let positionType: PositionType?
    public let positionValue: String?
    public let characterName: String?
    public let spoilerLevel: SpoilerLevel?
    public let visibility: Visibility?
    public let createdAt: APIDateTime?
    public let updatedAt: APIDateTime?
}

public struct Discussion: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let createdByUserId: EntityID?
    public let title: String
    public let description: String?
    public let scheduledAt: APIDateTime?
    public let durationMinutes: Int?
    public let locationType: LocationType?
    public let locationValue: String?
    public let status: DiscussionStatus?
    public let prompts: [DiscussionPrompt]?
}

public struct DiscussionPrompt: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID?
    public let source: String?
    public let prompt: String
    public let spoilerLevel: SpoilerLevel?
    public let sortOrder: Int?
}

public struct Journal: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyBookId: EntityID?
    public let societyId: EntityID?
    public let title: String
    public let summary: String?
    public let status: JournalStatus?
    public let generatedByUserId: EntityID?
    public let content: [String: JSONValue]?
    public let createdAt: APIDateTime?
    public let updatedAt: APIDateTime?
}

public struct SocietyMember: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let userId: EntityID?
    public let role: MembershipRole?
    public let status: MembershipStatus?
    public let displayName: String?
    public let joinedAt: APIDateTime?
    public let lastSeenAt: APIDateTime?
    public let user: User?
}

public struct Invitation: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let email: String?
    public let role: MembershipRole?
    public let expiresAt: APIDateTime?
    public let acceptedAt: APIDateTime?
    public let createdAt: APIDateTime?
}

public struct Activity: Codable, Equatable, Sendable, Identifiable {
    public let id: EntityID
    public let societyId: EntityID?
    public let userId: EntityID?
    public let action: String?
    public let subjectType: String?
    public let subjectId: EntityID?
    public let metadata: [String: JSONValue]?
    public let createdAt: APIDateTime?
}

public struct HomePayload: Codable, Equatable, Sendable {
    public let user: User
    public let activeSociety: Society?
    public let currentlyReading: SocietyBook?
    public let upcomingDiscussion: Discussion?
    public let recentNotes: [Note]
    public let dueReadingItems: [JSONValue]?
}

public struct SocietyDashboardPayload: Codable, Equatable, Sendable {
    public let society: Society
    public let currentBook: SocietyBook?
    public let readingProgress: [JSONValue]?
    public let nextDiscussion: Discussion?
    public let recentActivity: [JSONValue]?
    public let members: [SocietyMember]
}

public struct LibraryPayload: Codable, Equatable, Sendable {
    public let currentlyReading: [SocietyBook]
    public let finished: [SocietyBook]
    public let nominated: [SocietyBook]
}

public struct BookRoomPayload: Codable, Equatable, Sendable {
    public let societyBook: SocietyBook
    public let book: Book
    public let readingPlan: ReadingPlan?
    public let upcomingDiscussion: Discussion?
    public let myNotesCount: Int
    public let societyQuotesCount: Int
    public let recentQuotes: [Quote]
    public let recentNotes: [Note]
}

public struct SocietyBookMeta: Codable, Equatable, Sendable {
    public let alreadyInSociety: Bool?
}

public struct AuthTokenPayload: Codable, Equatable, Sendable {
    public let user: User
    public let token: String
}

public struct BookSearchPayload: Codable, Equatable, Sendable {
    public let data: [BookSearchResult]
    public let meta: BookSearchMeta?
}

public struct BookSearchMeta: Codable, Equatable, Sendable {
    public let query: String?
    public let providers: [String]?
    public let resultCount: Int?
}

public struct BookSearchResult: Codable, Equatable, Sendable, Identifiable {
    public var id: String { [source, sourceId, workId, editionId, bookId, title].compactMap { $0 }.joined(separator: ":") }

    public let source: String?
    public let sourceId: String?
    public let workId: String?
    public let editionId: String?
    public let bookId: EntityID?
    public let alreadySaved: Bool?
    public let title: String
    public let subtitle: String?
    public let authors: [String]?
    public let firstPublishYear: Int?
    public let publishedDate: String?
    public let publisher: String?
    public let isbn10: String?
    public let isbn13: String?
    public let language: String?
    public let pageCount: Int?
    public let coverUrl: String?
    public let metadataQualityScore: Int?
}

public enum Annotation: Codable, Equatable, Sendable, Identifiable {
    case note(id: EntityID, title: String?)
    case quote(id: EntityID, text: String)

    public var id: EntityID {
        switch self {
        case let .note(id, _), let .quote(id, _):
            id
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case title
        case text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let id = try container.decode(EntityID.self, forKey: .id)

        switch type {
        case "note":
            self = .note(id: id, title: try container.decodeIfPresent(String.self, forKey: .title))
        case "quote":
            self = .quote(id: id, text: try container.decode(String.self, forKey: .text))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown annotation type.")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .note(id, title):
            try container.encode("note", forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(title, forKey: .title)
        case let .quote(id, text):
            try container.encode("quote", forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(text, forKey: .text)
        }
    }
}
