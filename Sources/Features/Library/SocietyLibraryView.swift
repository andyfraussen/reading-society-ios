import DesignSystem
import Networking
import Observation
import SwiftUI

struct SocietyLibraryView: View {
    @State private var model: SocietyLibraryViewModel
    @State private var isPresentingImport = false
    private let society: Society

    init(api: ReadingSocietyAPI, society: Society) {
        self.society = society
        self._model = State(wrappedValue: SocietyLibraryViewModel(api: api, society: society))
    }

    var body: some View {
        ScrollView {
            content
                .padding(RSSpacing.large)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(RSColor.backgroundDefault)
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingImport = true
                } label: {
                    Label("Import book", systemImage: "plus")
                }
                .foregroundStyle(RSColor.textPrimary)
            }
        }
        .task {
            await model.load()
        }
        .refreshable {
            await model.reload()
        }
        .sheet(isPresented: $isPresentingImport) {
            BookImportView(api: model.api, societyId: society.id) {
                Task {
                    await model.reload()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            FeatureLoadingView(title: "Opening the library", message: "Fetching current, nominated, and finished books for \(society.name).")
        case let .failed(message):
            FeatureErrorView(title: "Library could not be loaded", message: message) {
                Task {
                    await model.reload()
                }
            }
        case let .loaded(payload):
            LoadedLibraryView(api: model.api, society: society, payload: payload)
        }
    }
}

@MainActor
@Observable
final class SocietyLibraryViewModel {
    let api: ReadingSocietyAPI
    var state: LoadState<LibraryPayload> = .idle

    private let society: Society
    private var hasLoaded = false

    init(api: ReadingSocietyAPI, society: Society) {
        self.api = api
        self.society = society
    }

    func load() async {
        guard !hasLoaded else {
            return
        }

        await reload()
    }

    func reload() async {
        state = .loading

        do {
            state = .loaded(try await api.library(society.id))
            hasLoaded = true
        } catch {
            state = .failed(FeatureDisplay.message(for: error, fallback: "The library could not be loaded."))
        }
    }
}

private struct LoadedLibraryView: View {
    let api: ReadingSocietyAPI
    let society: Society
    let payload: LibraryPayload

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge(society.name)

                Text("Library")
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text("The society catalogue, grouped by reading state.")
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
            }

            LibrarySection(title: "Currently reading", books: payload.currentlyReading, api: api, societyId: society.id)
            LibrarySection(title: "Nominated", books: payload.nominated, api: api, societyId: society.id)
            LibrarySection(title: "Finished", books: payload.finished, api: api, societyId: society.id)
        }
    }
}

private struct LibrarySection: View {
    let title: String
    let books: [SocietyBook]
    let api: ReadingSocietyAPI
    let societyId: EntityID

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text(title)
                .font(RSTypography.h2)
                .foregroundStyle(RSColor.textPrimary)

            if books.isEmpty {
                RSCard {
                    Text("No books in this section.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            } else {
                VStack(spacing: RSSpacing.medium) {
                    ForEach(books) { societyBook in
                        NavigationLink {
                            BookRoomView(api: api, societyId: societyId, societyBook: societyBook)
                        } label: {
                            RSCard {
                                HStack(alignment: .top, spacing: RSSpacing.medium) {
                                    SocietyBookRow(societyBook: societyBook, baseURL: api.client.baseURL)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(RSColor.textMuted)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct BookImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: BookImportViewModel
    @State private var query = ""

    private let baseURL: URL
    let onImported: () -> Void

    init(api: ReadingSocietyAPI, societyId: EntityID, onImported: @escaping () -> Void) {
        self._model = State(wrappedValue: BookImportViewModel(api: api, societyId: societyId))
        self.baseURL = api.client.baseURL
        self.onImported = onImported
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.medium) {
                        RSBadge("Open Library")

                        Text("Import a book")
                            .font(RSTypography.h1)
                            .foregroundStyle(RSColor.textPrimary)

                        Text("Search by title, author, or ISBN, then add a result to this society.")
                            .font(RSTypography.bodyLarge)
                            .foregroundStyle(RSColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(alignment: .bottom, spacing: RSSpacing.medium) {
                        RSTextField("Search", text: $query)

                        Button {
                            Task {
                                await model.search(query: query)
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(query.trimmedValue.isEmpty || model.isSearching)
                    }

                    if let message = model.errorMessage {
                        Text(message)
                            .font(RSTypography.small)
                            .foregroundStyle(RSColor.accentPrimary)
                    }

                    if model.isSearching {
                        ProgressView()
                            .tint(RSColor.accentPrimary)
                            .frame(maxWidth: .infinity)
                    }

                    VStack(spacing: RSSpacing.medium) {
                        ForEach(model.results) { result in
                            RSCard {
                                HStack(alignment: .top, spacing: RSSpacing.medium) {
                                    BookCoverThumbnail(path: result.coverUrl, baseURL: baseURL)

                                    VStack(alignment: .leading, spacing: RSSpacing.medium) {
                                        VStack(alignment: .leading, spacing: RSSpacing.small) {
                                            Text(result.title)
                                                .font(RSTypography.h3)
                                                .foregroundStyle(RSColor.textPrimary)
                                                .fixedSize(horizontal: false, vertical: true)

                                            if let authors = result.authors, !authors.isEmpty {
                                                Text(authors.joined(separator: ", "))
                                                    .font(RSTypography.body)
                                                    .foregroundStyle(RSColor.textSecondary)
                                            }

                                            HStack(spacing: RSSpacing.small) {
                                                if let year = result.firstPublishYear {
                                                    FeatureMetadataPill(text: "\(year)")
                                                }

                                                if result.alreadySaved == true {
                                                    FeatureMetadataPill(text: "saved")
                                                }
                                            }
                                        }

                                        RSButton(model.importingID == result.id ? "Importing" : "Import", variant: .secondary) {
                                            Task {
                                                if await model.importBook(result) {
                                                    onImported()
                                                    dismiss()
                                                }
                                            }
                                        }
                                        .disabled(model.importingID != nil)
                                        .opacity(model.importingID != nil ? 0.55 : 1)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(RSSpacing.large)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Import")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@MainActor
@Observable
private final class BookImportViewModel {
    var results: [BookSearchResult] = []
    var errorMessage: String?
    var isSearching = false
    var importingID: String?

    private let api: ReadingSocietyAPI
    private let societyId: EntityID

    init(api: ReadingSocietyAPI, societyId: EntityID) {
        self.api = api
        self.societyId = societyId
    }

    func search(query: String) async {
        let trimmedQuery = query.trimmedValue
        guard !trimmedQuery.isEmpty else {
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            results = try await api.searchBooks(query: trimmedQuery).data
        } catch {
            errorMessage = FeatureDisplay.message(for: error, fallback: "Book search failed.")
        }

        isSearching = false
    }

    func importBook(_ result: BookSearchResult) async -> Bool {
        guard importingID == nil else {
            return false
        }

        importingID = result.id
        errorMessage = nil

        do {
            _ = try await api.importSocietyBook(
                societyId,
                request: ImportBookRequest(
                    source: result.source ?? "open_library",
                    workId: result.workId,
                    editionId: result.editionId,
                    isbn10: result.isbn10,
                    isbn13: result.isbn13,
                    status: .nominated
                )
            )
            importingID = nil
            return true
        } catch {
            errorMessage = FeatureDisplay.message(for: error, fallback: "The book could not be imported.")
            importingID = nil
            return false
        }
    }
}
