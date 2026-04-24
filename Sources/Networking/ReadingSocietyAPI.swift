import Foundation

public struct ReadingSocietyAPI: Sendable {
    public let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func register(_ request: RegisterRequest) async throws -> AuthTokenPayload {
        let response: APIEnvelope<AuthTokenPayload> = try await client.post("/auth/register", body: request)
        return response.data
    }

    public func login(_ request: LoginRequest) async throws -> AuthTokenPayload {
        let response: APIEnvelope<AuthTokenPayload> = try await client.post("/auth/login", body: request)
        return response.data
    }

    public func logout() async throws {
        let _: EmptyResponse = try await client.post("/auth/logout")
    }

    public func me() async throws -> User {
        let response: APIEnvelope<User> = try await client.get("/me")
        return response.data
    }

    public func updateMe(_ request: UpdateMeRequest) async throws -> User {
        let response: APIEnvelope<User> = try await client.patch("/me", body: request)
        return response.data
    }

    public func home() async throws -> HomePayload {
        let response: APIEnvelope<HomePayload> = try await client.get("/home")
        return response.data
    }

    public func societies(queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<Society> {
        try await client.get("/societies", queryItems: queryItems)
    }

    public func createSociety(_ request: StoreSocietyRequest) async throws -> Society {
        let response: APIEnvelope<Society> = try await client.post("/societies", body: request)
        return response.data
    }

    public func society(_ society: EntityID) async throws -> Society {
        let response: APIEnvelope<Society> = try await client.get("/societies/\(pathComponent(society))")
        return response.data
    }

    public func updateSociety(_ society: EntityID, request: UpdateSocietyRequest) async throws -> Society {
        let response: APIEnvelope<Society> = try await client.patch("/societies/\(pathComponent(society))", body: request)
        return response.data
    }

    public func deleteSociety(_ society: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/societies/\(pathComponent(society))")
    }

    public func societyDashboard(_ society: EntityID) async throws -> SocietyDashboardPayload {
        let response: APIEnvelope<SocietyDashboardPayload> = try await client.get("/societies/\(pathComponent(society))/dashboard")
        return response.data
    }

    public func societyMembers(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> [SocietyMember] {
        let response: APIEnvelope<[SocietyMember]> = try await client.get("/societies/\(pathComponent(society))/members", queryItems: queryItems)
        return response.data
    }

    public func societyActivity(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> [Activity] {
        let response: APIEnvelope<[Activity]> = try await client.get("/societies/\(pathComponent(society))/activity", queryItems: queryItems)
        return response.data
    }

    public func invitations(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> [Invitation] {
        let response: APIEnvelope<[Invitation]> = try await client.get("/societies/\(pathComponent(society))/invitations", queryItems: queryItems)
        return response.data
    }

    public func createInvitation(_ society: EntityID, request: InviteMemberRequest) async throws -> Invitation {
        let response: APIEnvelope<Invitation> = try await client.post("/societies/\(pathComponent(society))/invitations", body: request)
        return response.data
    }

    public func deleteInvitation(_ society: EntityID, invitation: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/societies/\(pathComponent(society))/invitations/\(pathComponent(invitation))")
    }

    public func acceptInvitation(token: String) async throws -> SocietyMember {
        let response: APIEnvelope<SocietyMember> = try await client.post("/invitations/\(pathComponent(token))/accept")
        return response.data
    }

    public func searchBooks(query: String, queryItems: [URLQueryItem] = []) async throws -> BookSearchPayload {
        var items = queryItems
        items.append(URLQueryItem(name: "q", value: query))
        return try await client.get("/book-search", queryItems: items)
    }

    public func books(queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<Book> {
        try await client.get("/books", queryItems: queryItems)
    }

    public func createBook(_ request: StoreBookRequest) async throws -> Book {
        let response: APIEnvelope<Book> = try await client.post("/books", body: request)
        return response.data
    }

    public func importBook(_ request: ImportBookRequest) async throws -> Book {
        let response: APIEnvelope<Book> = try await client.post("/books/import", body: request)
        return response.data
    }

    public func book(_ book: EntityID) async throws -> Book {
        let response: APIEnvelope<Book> = try await client.get("/books/\(pathComponent(book))")
        return response.data
    }

    public func updateBook(_ book: EntityID, request: UpdateBookRequest) async throws -> Book {
        let response: APIEnvelope<Book> = try await client.patch("/books/\(pathComponent(book))", body: request)
        return response.data
    }

    public func societyBooks(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<SocietyBook> {
        try await client.get("/societies/\(pathComponent(society))/books", queryItems: queryItems)
    }

    public func attachSocietyBook(_ society: EntityID, request: StoreSocietyBookRequest) async throws -> SocietyBook {
        let response: APIResourceWithMeta<SocietyBook, SocietyBookMeta> = try await client.post("/societies/\(pathComponent(society))/books", body: request)
        return response.data
    }

    public func importSocietyBook(_ society: EntityID, request: ImportBookRequest) async throws -> SocietyBook {
        let response: APIResourceWithMeta<SocietyBook, SocietyBookMeta> = try await client.post("/societies/\(pathComponent(society))/books/import", body: request)
        return response.data
    }

    public func societyBook(_ society: EntityID, societyBook: EntityID) async throws -> SocietyBook {
        let response: APIEnvelope<SocietyBook> = try await client.get("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))")
        return response.data
    }

    public func updateSocietyBook(_ society: EntityID, societyBook: EntityID, request: UpdateSocietyBookRequest) async throws -> SocietyBook {
        let response: APIEnvelope<SocietyBook> = try await client.patch("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))", body: request)
        return response.data
    }

    public func removeSocietyBook(_ society: EntityID, societyBook: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))")
    }

    public func library(_ society: EntityID) async throws -> LibraryPayload {
        let response: APIEnvelope<LibraryPayload> = try await client.get("/societies/\(pathComponent(society))/library")
        return response.data
    }

    public func bookRoom(_ society: EntityID, societyBook: EntityID) async throws -> BookRoomPayload {
        let response: APIEnvelope<BookRoomPayload> = try await client.get("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/room")
        return response.data
    }

    public func readingPlans(_ society: EntityID, societyBook: EntityID, queryItems: [URLQueryItem] = []) async throws -> [ReadingPlan] {
        let response: APIEnvelope<[ReadingPlan]> = try await client.get("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/reading-plans", queryItems: queryItems)
        return response.data
    }

    public func createReadingPlan(_ society: EntityID, societyBook: EntityID, request: StoreReadingPlanRequest) async throws -> ReadingPlan {
        let response: APIEnvelope<ReadingPlan> = try await client.post("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/reading-plans", body: request)
        return response.data
    }

    public func readingPlan(_ readingPlan: EntityID) async throws -> ReadingPlan {
        let response: APIEnvelope<ReadingPlan> = try await client.get("/reading-plans/\(pathComponent(readingPlan))")
        return response.data
    }

    public func updateReadingPlan(_ readingPlan: EntityID, request: UpdateReadingPlanRequest) async throws -> ReadingPlan {
        let response: APIEnvelope<ReadingPlan> = try await client.patch("/reading-plans/\(pathComponent(readingPlan))", body: request)
        return response.data
    }

    public func deleteReadingPlan(_ readingPlan: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/reading-plans/\(pathComponent(readingPlan))")
    }

    public func progress(_ society: EntityID, societyBook: EntityID) async throws -> Progress? {
        let response: APIEnvelope<Progress?> = try await client.get("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/progress")
        return response.data
    }

    public func updateProgress(_ society: EntityID, societyBook: EntityID, request: UpdateProgressRequest) async throws -> Progress? {
        let response: APIEnvelope<Progress?> = try await client.patch("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/progress", body: request)
        return response.data
    }

    public func notes(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<Note> {
        try await client.get("/societies/\(pathComponent(society))/notes", queryItems: queryItems)
    }

    public func createNote(_ society: EntityID, request: StoreNoteRequest) async throws -> Note {
        let response: APIEnvelope<Note> = try await client.post("/societies/\(pathComponent(society))/notes", body: request)
        return response.data
    }

    public func note(_ note: EntityID) async throws -> Note {
        let response: APIEnvelope<Note> = try await client.get("/notes/\(pathComponent(note))")
        return response.data
    }

    public func updateNote(_ note: EntityID, request: UpdateNoteRequest) async throws -> Note {
        let response: APIEnvelope<Note> = try await client.patch("/notes/\(pathComponent(note))", body: request)
        return response.data
    }

    public func deleteNote(_ note: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/notes/\(pathComponent(note))")
    }

    public func quotes(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<Quote> {
        try await client.get("/societies/\(pathComponent(society))/quotes", queryItems: queryItems)
    }

    public func createQuote(_ society: EntityID, request: StoreQuoteRequest) async throws -> Quote {
        let response: APIEnvelope<Quote> = try await client.post("/societies/\(pathComponent(society))/quotes", body: request)
        return response.data
    }

    public func quote(_ quote: EntityID) async throws -> Quote {
        let response: APIEnvelope<Quote> = try await client.get("/quotes/\(pathComponent(quote))")
        return response.data
    }

    public func updateQuote(_ quote: EntityID, request: UpdateQuoteRequest) async throws -> Quote {
        let response: APIEnvelope<Quote> = try await client.patch("/quotes/\(pathComponent(quote))", body: request)
        return response.data
    }

    public func deleteQuote(_ quote: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/quotes/\(pathComponent(quote))")
    }

    public func annotations(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> [Annotation] {
        let response: APIEnvelope<[Annotation]> = try await client.get("/societies/\(pathComponent(society))/annotations", queryItems: queryItems)
        return response.data
    }

    public func discussions(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> PaginatedResponse<Discussion> {
        try await client.get("/societies/\(pathComponent(society))/discussions", queryItems: queryItems)
    }

    public func createDiscussion(_ society: EntityID, request: StoreDiscussionRequest) async throws -> Discussion {
        let response: APIEnvelope<Discussion> = try await client.post("/societies/\(pathComponent(society))/discussions", body: request)
        return response.data
    }

    public func discussion(_ discussion: EntityID) async throws -> Discussion {
        let response: APIEnvelope<Discussion> = try await client.get("/discussions/\(pathComponent(discussion))")
        return response.data
    }

    public func updateDiscussion(_ discussion: EntityID, request: UpdateDiscussionRequest) async throws -> Discussion {
        let response: APIEnvelope<Discussion> = try await client.patch("/discussions/\(pathComponent(discussion))", body: request)
        return response.data
    }

    public func deleteDiscussion(_ discussion: EntityID) async throws {
        let _: EmptyResponse = try await client.delete("/discussions/\(pathComponent(discussion))")
    }

    public func createDiscussionPrompt(_ discussion: EntityID, request: StoreDiscussionPromptRequest) async throws -> Discussion {
        let response: APIEnvelope<Discussion> = try await client.post("/discussions/\(pathComponent(discussion))/prompts", body: request)
        return response.data
    }

    public func journals(_ society: EntityID, queryItems: [URLQueryItem] = []) async throws -> [Journal] {
        let response: APIEnvelope<[Journal]> = try await client.get("/societies/\(pathComponent(society))/journals", queryItems: queryItems)
        return response.data
    }

    public func createJournal(_ society: EntityID, societyBook: EntityID, request: StoreJournalRequest) async throws -> Journal {
        let response: APIEnvelope<Journal> = try await client.post("/societies/\(pathComponent(society))/books/\(pathComponent(societyBook))/journal", body: request)
        return response.data
    }

    public func journal(_ journal: EntityID) async throws -> Journal {
        let response: APIEnvelope<Journal> = try await client.get("/journals/\(pathComponent(journal))")
        return response.data
    }

    public func updateJournal(_ journal: EntityID, request: UpdateJournalRequest) async throws -> Journal {
        let response: APIEnvelope<Journal> = try await client.patch("/journals/\(pathComponent(journal))", body: request)
        return response.data
    }

    public func generateJournal(_ journal: EntityID) async throws -> Journal {
        let response: APIEnvelope<Journal> = try await client.post("/journals/\(pathComponent(journal))/generate")
        return response.data
    }

    private func pathComponent(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
    }
}
