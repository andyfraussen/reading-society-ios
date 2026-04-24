import Foundation

public struct LoginRequest: Codable, Equatable, Sendable {
    public let email: String
    public let password: String
    public let deviceName: String?

    public init(email: String, password: String, deviceName: String? = nil) {
        self.email = email
        self.password = password
        self.deviceName = deviceName
    }
}

public struct RegisterRequest: Codable, Equatable, Sendable {
    public let name: String
    public let email: String
    public let password: String
    public let deviceName: String?
    public let timezone: String?
    public let locale: String?

    public init(name: String, email: String, password: String, deviceName: String? = nil, timezone: String? = nil, locale: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
        self.deviceName = deviceName
        self.timezone = timezone
        self.locale = locale
    }
}

public struct UpdateMeRequest: Codable, Equatable, Sendable {
    public let name: String?
    public let email: String?
    public let avatarPath: String?
    public let timezone: String?
    public let locale: String?

    public init(name: String? = nil, email: String? = nil, avatarPath: String? = nil, timezone: String? = nil, locale: String? = nil) {
        self.name = name
        self.email = email
        self.avatarPath = avatarPath
        self.timezone = timezone
        self.locale = locale
    }
}

public struct StoreSocietyRequest: Codable, Equatable, Sendable {
    public let name: String
    public let description: String?
    public let timezone: String?
    public let theme: [String: JSONValue]?
    public let crestIcon: String?

    public init(name: String, description: String? = nil, timezone: String? = nil, theme: [String: JSONValue]? = nil, crestIcon: String? = nil) {
        self.name = name
        self.description = description
        self.timezone = timezone
        self.theme = theme
        self.crestIcon = crestIcon
    }
}

public struct UpdateSocietyRequest: Codable, Equatable, Sendable {
    public let name: String?
    public let description: String?
    public let timezone: String?
    public let theme: [String: JSONValue]?
    public let crestIcon: String?

    public init(name: String? = nil, description: String? = nil, timezone: String? = nil, theme: [String: JSONValue]? = nil, crestIcon: String? = nil) {
        self.name = name
        self.description = description
        self.timezone = timezone
        self.theme = theme
        self.crestIcon = crestIcon
    }
}

public struct InviteMemberRequest: Codable, Equatable, Sendable {
    public let email: String
    public let role: MembershipRole

    public init(email: String, role: MembershipRole) {
        self.email = email
        self.role = role
    }
}

public struct StoreBookRequest: Codable, Equatable, Sendable {
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let isbn10: String?
    public let isbn13: String?
    public let publisher: String?
    public let publishedDate: String?
    public let firstPublishYear: Int?
    public let pageCount: Int?
    public let language: String?
    public let authors: [String]?

    public init(title: String, subtitle: String? = nil, description: String? = nil, isbn10: String? = nil, isbn13: String? = nil, publisher: String? = nil, publishedDate: String? = nil, firstPublishYear: Int? = nil, pageCount: Int? = nil, language: String? = nil, authors: [String]? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.isbn10 = isbn10
        self.isbn13 = isbn13
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.firstPublishYear = firstPublishYear
        self.pageCount = pageCount
        self.language = language
        self.authors = authors
    }
}

public struct UpdateBookRequest: Codable, Equatable, Sendable {
    public let title: String?
    public let subtitle: String?
    public let description: String?
    public let isbn10: String?
    public let isbn13: String?
    public let publisher: String?
    public let publishedDate: String?
    public let firstPublishYear: Int?
    public let pageCount: Int?
    public let language: String?
    public let authors: [String]?

    public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, isbn10: String? = nil, isbn13: String? = nil, publisher: String? = nil, publishedDate: String? = nil, firstPublishYear: Int? = nil, pageCount: Int? = nil, language: String? = nil, authors: [String]? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.isbn10 = isbn10
        self.isbn13 = isbn13
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.firstPublishYear = firstPublishYear
        self.pageCount = pageCount
        self.language = language
        self.authors = authors
    }
}

public struct ImportBookRequest: Codable, Equatable, Sendable {
    public let source: String
    public let workId: String?
    public let editionId: String?
    public let isbn10: String?
    public let isbn13: String?
    public let status: SocietyBookStatus?
    public let startDate: APIDate?
    public let targetEndDate: APIDate?

    public init(source: String = "open_library", workId: String? = nil, editionId: String? = nil, isbn10: String? = nil, isbn13: String? = nil, status: SocietyBookStatus? = nil, startDate: APIDate? = nil, targetEndDate: APIDate? = nil) {
        self.source = source
        self.workId = workId
        self.editionId = editionId
        self.isbn10 = isbn10
        self.isbn13 = isbn13
        self.status = status
        self.startDate = startDate
        self.targetEndDate = targetEndDate
    }
}

public struct StoreSocietyBookRequest: Codable, Equatable, Sendable {
    public let bookId: EntityID
    public let status: SocietyBookStatus?
    public let startDate: APIDate?
    public let targetEndDate: APIDate?

    public init(bookId: EntityID, status: SocietyBookStatus? = nil, startDate: APIDate? = nil, targetEndDate: APIDate? = nil) {
        self.bookId = bookId
        self.status = status
        self.startDate = startDate
        self.targetEndDate = targetEndDate
    }
}

public struct UpdateSocietyBookRequest: Codable, Equatable, Sendable {
    public let status: SocietyBookStatus?
    public let startDate: APIDate?
    public let targetEndDate: APIDate?

    public init(status: SocietyBookStatus? = nil, startDate: APIDate? = nil, targetEndDate: APIDate? = nil) {
        self.status = status
        self.startDate = startDate
        self.targetEndDate = targetEndDate
    }
}

public struct ReadingPlanItemRequest: Codable, Equatable, Sendable {
    public let title: String
    public let description: String?
    public let positionStartType: PositionType?
    public let positionStartValue: String?
    public let positionEndType: PositionType?
    public let positionEndValue: String?
    public let dueDate: APIDate?
    public let sortOrder: Int?

    public init(title: String, description: String? = nil, positionStartType: PositionType? = nil, positionStartValue: String? = nil, positionEndType: PositionType? = nil, positionEndValue: String? = nil, dueDate: APIDate? = nil, sortOrder: Int? = nil) {
        self.title = title
        self.description = description
        self.positionStartType = positionStartType
        self.positionStartValue = positionStartValue
        self.positionEndType = positionEndType
        self.positionEndValue = positionEndValue
        self.dueDate = dueDate
        self.sortOrder = sortOrder
    }
}

public struct StoreReadingPlanRequest: Codable, Equatable, Sendable {
    public let title: String
    public let description: String?
    public let startDate: APIDate?
    public let endDate: APIDate?
    public let cadence: ReadingPlanCadence?
    public let items: [ReadingPlanItemRequest]?

    public init(title: String, description: String? = nil, startDate: APIDate? = nil, endDate: APIDate? = nil, cadence: ReadingPlanCadence? = nil, items: [ReadingPlanItemRequest]? = nil) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.cadence = cadence
        self.items = items
    }
}

public struct UpdateReadingPlanRequest: Codable, Equatable, Sendable {
    public let title: String?
    public let description: String?
    public let startDate: APIDate?
    public let endDate: APIDate?
    public let cadence: ReadingPlanCadence?

    public init(title: String? = nil, description: String? = nil, startDate: APIDate? = nil, endDate: APIDate? = nil, cadence: ReadingPlanCadence? = nil) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.cadence = cadence
    }
}

public struct UpdateProgressRequest: Codable, Equatable, Sendable {
    public let positionType: PositionType
    public let positionValue: String?
    public let percentage: Int

    public init(positionType: PositionType, positionValue: String? = nil, percentage: Int) {
        self.positionType = positionType
        self.positionValue = positionValue
        self.percentage = percentage
    }
}

public struct StoreNoteRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let discussionId: EntityID?
    public let visibility: Visibility
    public let title: String?
    public let body: String
    public let positionType: PositionType?
    public let positionValue: String?
    public let spoilerLevel: SpoilerLevel?
    public let tags: [String]?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, discussionId: EntityID? = nil, visibility: Visibility, title: String? = nil, body: String, positionType: PositionType? = nil, positionValue: String? = nil, spoilerLevel: SpoilerLevel? = nil, tags: [String]? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.discussionId = discussionId
        self.visibility = visibility
        self.title = title
        self.body = body
        self.positionType = positionType
        self.positionValue = positionValue
        self.spoilerLevel = spoilerLevel
        self.tags = tags
    }
}

public struct UpdateNoteRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let discussionId: EntityID?
    public let visibility: Visibility?
    public let title: String?
    public let body: String?
    public let positionType: PositionType?
    public let positionValue: String?
    public let spoilerLevel: SpoilerLevel?
    public let tags: [String]?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, discussionId: EntityID? = nil, visibility: Visibility? = nil, title: String? = nil, body: String? = nil, positionType: PositionType? = nil, positionValue: String? = nil, spoilerLevel: SpoilerLevel? = nil, tags: [String]? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.discussionId = discussionId
        self.visibility = visibility
        self.title = title
        self.body = body
        self.positionType = positionType
        self.positionValue = positionValue
        self.spoilerLevel = spoilerLevel
        self.tags = tags
    }
}

public struct StoreQuoteRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let text: String
    public let commentary: String?
    public let positionType: PositionType?
    public let positionValue: String?
    public let characterName: String?
    public let spoilerLevel: SpoilerLevel?
    public let visibility: Visibility
    public let tags: [String]?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, text: String, commentary: String? = nil, positionType: PositionType? = nil, positionValue: String? = nil, characterName: String? = nil, spoilerLevel: SpoilerLevel? = nil, visibility: Visibility, tags: [String]? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.text = text
        self.commentary = commentary
        self.positionType = positionType
        self.positionValue = positionValue
        self.characterName = characterName
        self.spoilerLevel = spoilerLevel
        self.visibility = visibility
        self.tags = tags
    }
}

public struct UpdateQuoteRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let text: String?
    public let commentary: String?
    public let positionType: PositionType?
    public let positionValue: String?
    public let characterName: String?
    public let spoilerLevel: SpoilerLevel?
    public let visibility: Visibility?
    public let tags: [String]?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, text: String? = nil, commentary: String? = nil, positionType: PositionType? = nil, positionValue: String? = nil, characterName: String? = nil, spoilerLevel: SpoilerLevel? = nil, visibility: Visibility? = nil, tags: [String]? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.text = text
        self.commentary = commentary
        self.positionType = positionType
        self.positionValue = positionValue
        self.characterName = characterName
        self.spoilerLevel = spoilerLevel
        self.visibility = visibility
        self.tags = tags
    }
}

public struct StoreDiscussionRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let title: String
    public let description: String?
    public let scheduledAt: APIDateTime?
    public let durationMinutes: Int?
    public let locationType: LocationType?
    public let locationValue: String?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, title: String, description: String? = nil, scheduledAt: APIDateTime? = nil, durationMinutes: Int? = nil, locationType: LocationType? = nil, locationValue: String? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.title = title
        self.description = description
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        self.locationType = locationType
        self.locationValue = locationValue
    }
}

public struct UpdateDiscussionRequest: Codable, Equatable, Sendable {
    public let societyBookId: EntityID?
    public let readingPlanItemId: EntityID?
    public let title: String?
    public let description: String?
    public let scheduledAt: APIDateTime?
    public let durationMinutes: Int?
    public let locationType: LocationType?
    public let locationValue: String?

    public init(societyBookId: EntityID? = nil, readingPlanItemId: EntityID? = nil, title: String? = nil, description: String? = nil, scheduledAt: APIDateTime? = nil, durationMinutes: Int? = nil, locationType: LocationType? = nil, locationValue: String? = nil) {
        self.societyBookId = societyBookId
        self.readingPlanItemId = readingPlanItemId
        self.title = title
        self.description = description
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        self.locationType = locationType
        self.locationValue = locationValue
    }
}

public struct StoreDiscussionPromptRequest: Codable, Equatable, Sendable {
    public let prompt: String
    public let spoilerLevel: SpoilerLevel?
    public let sortOrder: Int?

    public init(prompt: String, spoilerLevel: SpoilerLevel? = nil, sortOrder: Int? = nil) {
        self.prompt = prompt
        self.spoilerLevel = spoilerLevel
        self.sortOrder = sortOrder
    }
}

public struct StoreJournalRequest: Codable, Equatable, Sendable {
    public let title: String?
    public let summary: String?
    public let content: [String: JSONValue]?

    public init(title: String? = nil, summary: String? = nil, content: [String: JSONValue]? = nil) {
        self.title = title
        self.summary = summary
        self.content = content
    }
}

public struct UpdateJournalRequest: Codable, Equatable, Sendable {
    public let title: String?
    public let summary: String?
    public let content: [String: JSONValue]?
    public let status: JournalStatus?

    public init(title: String? = nil, summary: String? = nil, content: [String: JSONValue]? = nil, status: JournalStatus? = nil) {
        self.title = title
        self.summary = summary
        self.content = content
        self.status = status
    }
}
