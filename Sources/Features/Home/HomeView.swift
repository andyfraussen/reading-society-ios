import DesignSystem
import Networking
import Observation
import SwiftUI

public struct HomeView: View {
    @State private var model: HomeViewModel
    private let onSignOut: () -> Void

    public init(api: ReadingSocietyAPI, onSignOut: @escaping () -> Void) {
        self._model = State(wrappedValue: HomeViewModel(api: api))
        self.onSignOut = onSignOut
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(RSSpacing.large)
                    .frame(maxWidth: 980, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onSignOut) {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
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
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            LoadingHomeView()
        case let .failed(message):
            ErrorHomeView(message: message) {
                Task {
                    await model.reload()
                }
            }
        case let .loaded(payload):
            LoadedHomeView(payload: payload, baseURL: model.api.client.baseURL)
        }
    }
}

@MainActor
@Observable
final class HomeViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(HomePayload)
        case failed(String)
    }

    let api: ReadingSocietyAPI
    private var hasLoaded = false

    var state: State = .idle

    init(api: ReadingSocietyAPI) {
        self.api = api
    }

    func load() async {
        guard !hasLoaded else {
            return
        }

        await fetch()
    }

    func reload() async {
        await fetch()
    }

    private func fetch() async {
        state = .loading

        do {
            state = .loaded(try await api.home())
            hasLoaded = true
        } catch {
            state = .failed(Self.message(for: error))
        }
    }

    private static func message(for error: Error) -> String {
        if let apiError = error as? APIClient.APIError {
            switch apiError {
            case let .transportStatus(status, response):
                if status == 401 {
                    return "Your session has expired. Sign out, then sign in again."
                }

                if let message = response?.message, !message.isEmpty {
                    return message
                }

                return "The home record could not be loaded."
            case .invalidURL:
                return "The API address is invalid."
            case .invalidResponse:
                return "The server returned an invalid response."
            case .emptyResponse:
                return "The server returned an empty response."
            }
        }

        return error.localizedDescription
    }
}

private struct LoadedHomeView: View {
    let payload: HomePayload
    let baseURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            header

            if let societyBook = payload.currentlyReading {
                CurrentBookPanel(societyBook: societyBook, baseURL: baseURL)
            } else {
                EmptyCurrentBookPanel(activeSociety: payload.activeSociety)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: RSSpacing.large) {
                UpcomingDiscussionPanel(discussion: payload.upcomingDiscussion)
                DueReadingPanel(items: payload.dueReadingItems ?? [])
            }

            RecentNotesPanel(notes: payload.recentNotes)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            RSBadge(payload.activeSociety?.name ?? "Private society")

            Text("Welcome, \(payload.user.name)")
                .font(RSTypography.h1)
                .foregroundStyle(RSColor.textPrimary)

            Text(payload.activeSociety?.description ?? "Your reading room is ready for the next shared book, note, and discussion.")
                .font(RSTypography.bodyLarge)
                .foregroundStyle(RSColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 280), spacing: RSSpacing.large)
        ]
    }
}

private struct CurrentBookPanel: View {
    let societyBook: SocietyBook
    let baseURL: URL

    var body: some View {
        RSCard {
            HStack(alignment: .top, spacing: RSSpacing.large) {
                BookCoverThumbnail(path: societyBook.book?.coverImagePath, baseURL: baseURL, width: 78, height: 118)

                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.small) {
                        Text("CURRENT READING ROOM")
                            .font(RSTypography.caption)
                            .foregroundStyle(RSColor.accentOrnament)

                        Text(societyBook.book?.title ?? "Untitled book")
                            .font(RSTypography.h2)
                            .foregroundStyle(RSColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let authors = societyBook.book?.authors, !authors.isEmpty {
                            Text(authors.joined(separator: ", "))
                                .font(RSTypography.body)
                                .foregroundStyle(RSColor.textSecondary)
                        }
                    }

                    ProgressView(value: Double(societyBook.averageProgressPercentage ?? 0), total: 100)
                        .tint(RSColor.accentPrimary)
                        .background(RSColor.borderDefault)

                    HStack(spacing: RSSpacing.large) {
                        StatBlock(value: "\(societyBook.averageProgressPercentage ?? 0)%", label: "Average progress")
                        StatBlock(value: "\(societyBook.notesCount ?? 0)", label: "Notes")
                        StatBlock(value: "\(societyBook.quotesCount ?? 0)", label: "Quotes")
                    }
                }
            }
        }
    }
}

private struct EmptyCurrentBookPanel: View {
    let activeSociety: Society?

    var body: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text(activeSociety == nil ? "No society selected" : "No active book yet")
                    .font(RSTypography.h3)
                    .foregroundStyle(RSColor.textPrimary)

                Text(activeSociety == nil ? "Create or join a society from the API backed society screens coming next." : "Select a book for the society and this room will show progress, notes, quotes, and upcoming discussion.")
                    .font(RSTypography.body)
                    .foregroundStyle(RSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct UpcomingDiscussionPanel: View {
    let discussion: Discussion?

    var body: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("NEXT DISCUSSION")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if let discussion {
                    Text(discussion.title)
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    if let description = discussion.description {
                        Text(description)
                            .font(RSTypography.body)
                            .foregroundStyle(RSColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let scheduledAt = discussion.scheduledAt {
                        MetadataRow(label: "Scheduled", value: scheduledAt)
                    }
                } else {
                    Text("No discussion scheduled")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    Text("When a discussion is scheduled, its title, notes, and meeting details will appear here.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct DueReadingPanel: View {
    let items: [JSONValue]

    var body: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("READING DUE")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if items.isEmpty {
                    Text("Nothing due")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    Text("Reading plan items with due dates will be gathered here.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                } else {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Text(HomeDisplay.text(for: item))
                            .font(RSTypography.body)
                            .foregroundStyle(RSColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct RecentNotesPanel: View {
    let notes: [Note]

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text("Recent marginalia")
                .font(RSTypography.h2)
                .foregroundStyle(RSColor.textPrimary)

            if notes.isEmpty {
                RSCard {
                    Text("No notes yet. The first saved annotation will appear here as an archival slip.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                VStack(spacing: RSSpacing.medium) {
                    ForEach(notes) { note in
                        NoteSlip(note: note)
                    }
                }
            }
        }
    }
}

private struct NoteSlip: View {
    let note: Note

    var body: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.small) {
                if let title = note.title, !title.isEmpty {
                    Text(title)
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)
                }

                Text(note.body)
                    .font(RSTypography.body)
                    .foregroundStyle(RSColor.textSecondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: RSSpacing.small) {
                    if let position = note.positionValue {
                        MetadataPill(text: position)
                    }

                    if let createdAt = note.createdAt {
                        MetadataPill(text: createdAt)
                    }
                }
            }
        }
    }
}

private struct LoadingHomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("Loading")

                Text("Opening the reading room")
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text("Fetching the active society, current book, notes, and reading plan.")
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
            }

            RSCard {
                ProgressView()
                    .tint(RSColor.accentPrimary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
    }
}

private struct ErrorHomeView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("Unavailable")

                Text("The reading room could not be opened")
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text(message)
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RSButton("Retry", variant: .primary, action: onRetry)
                .frame(maxWidth: 260)
        }
    }
}

private struct StatBlock: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xxSmall) {
            Text(value)
                .font(RSTypography.h3)
                .foregroundStyle(RSColor.textPrimary)

            Text(label.uppercased())
                .font(RSTypography.caption)
                .foregroundStyle(RSColor.textMuted)
        }
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label.uppercased())
                .font(RSTypography.caption)
                .foregroundStyle(RSColor.textMuted)

            Spacer()

            Text(value)
                .font(RSTypography.caption)
                .foregroundStyle(RSColor.textPrimary)
        }
    }
}

private struct MetadataPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(RSTypography.caption)
            .foregroundStyle(RSColor.textMuted)
            .padding(.vertical, RSSpacing.xxSmall)
            .padding(.horizontal, RSSpacing.xSmall)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(RSColor.borderDefault, lineWidth: 1)
            )
    }
}

private enum HomeDisplay {
    static func text(for value: JSONValue) -> String {
        switch value {
        case let .string(string):
            return string
        case let .number(number):
            return number.formatted()
        case let .bool(bool):
            return bool ? "Yes" : "No"
        case let .object(object):
            return objectText(object)
        case let .array(values):
            return values.map(text(for:)).joined(separator: ", ")
        case .null:
            return "No details"
        }
    }

    private static func objectText(_ object: [String: JSONValue]) -> String {
        let title = stringValue(object["title"]) ?? stringValue(object["name"])
        let dueDate = stringValue(object["due_date"]) ?? stringValue(object["dueDate"])

        switch (title, dueDate) {
        case let (.some(title), .some(dueDate)):
            return "\(title), due \(dueDate)"
        case let (.some(title), .none):
            return title
        case let (.none, .some(dueDate)):
            return "Due \(dueDate)"
        case (.none, .none):
            return "Reading item"
        }
    }

    private static func stringValue(_ value: JSONValue?) -> String? {
        guard case let .string(string) = value else {
            return nil
        }

        return string
    }
}
