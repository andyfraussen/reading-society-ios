import DesignSystem
import Networking
import Observation
import SwiftUI

struct BookRoomView: View {
    @State private var model: BookRoomViewModel
    private let societyBook: SocietyBook

    init(api: ReadingSocietyAPI, societyId: EntityID, societyBook: SocietyBook) {
        self.societyBook = societyBook
        self._model = State(wrappedValue: BookRoomViewModel(api: api, societyId: societyId, societyBookId: societyBook.id))
    }

    var body: some View {
        ScrollView {
            content
                .padding(RSSpacing.large)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(RSColor.backgroundDefault)
        .navigationTitle(societyBook.book?.title ?? "Book room")
        .task {
            await model.load()
        }
        .refreshable {
            await model.reload()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            FeatureLoadingView(title: "Opening the book room", message: "Fetching reading plan, discussion, notes, and quotes.")
        case let .failed(message):
            FeatureErrorView(title: "Book room could not be loaded", message: message) {
                Task {
                    await model.reload()
                }
            }
        case let .loaded(payload):
            LoadedBookRoomView(model: model, payload: payload)
        }
    }
}

@MainActor
@Observable
final class BookRoomViewModel {
    var state: LoadState<BookRoomPayload> = .idle
    var actionErrorMessage: String?
    var isSubmittingAction = false

    private let api: ReadingSocietyAPI
    private let societyId: EntityID
    private let societyBookId: EntityID
    private var hasLoaded = false

    init(api: ReadingSocietyAPI, societyId: EntityID, societyBookId: EntityID) {
        self.api = api
        self.societyId = societyId
        self.societyBookId = societyBookId
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
            state = .loaded(try await api.bookRoom(societyId, societyBook: societyBookId))
            hasLoaded = true
        } catch {
            state = .failed(FeatureDisplay.message(for: error, fallback: "The book room could not be loaded."))
        }
    }

    func updateProgress(percentage: Int, position: String) async -> Bool {
        guard !isSubmittingAction else {
            return false
        }

        isSubmittingAction = true
        actionErrorMessage = nil

        do {
            _ = try await api.updateProgress(
                societyId,
                societyBook: societyBookId,
                request: UpdateProgressRequest(
                    positionType: .percentage,
                    positionValue: position.trimmedNilIfBlank,
                    percentage: percentage
                )
            )
            await reload()
            isSubmittingAction = false
            return true
        } catch {
            actionErrorMessage = FeatureDisplay.message(for: error, fallback: "Progress could not be updated.")
            isSubmittingAction = false
            return false
        }
    }

    func createNote(title: String, body: String, position: String, visibility: Networking.Visibility) async -> Bool {
        guard !isSubmittingAction else {
            return false
        }

        isSubmittingAction = true
        actionErrorMessage = nil

        do {
            _ = try await api.createNote(
                societyId,
                request: StoreNoteRequest(
                    societyBookId: societyBookId,
                    visibility: visibility,
                    title: title.trimmedNilIfBlank,
                    body: body.trimmedValue,
                    positionType: position.trimmedNilIfBlank == nil ? nil : .custom,
                    positionValue: position.trimmedNilIfBlank,
                    spoilerLevel: SpoilerLevel.none
                )
            )
            await reload()
            isSubmittingAction = false
            return true
        } catch {
            actionErrorMessage = FeatureDisplay.message(for: error, fallback: "The note could not be saved.")
            isSubmittingAction = false
            return false
        }
    }

    func createQuote(text: String, commentary: String, position: String, visibility: Networking.Visibility) async -> Bool {
        guard !isSubmittingAction else {
            return false
        }

        isSubmittingAction = true
        actionErrorMessage = nil

        do {
            _ = try await api.createQuote(
                societyId,
                request: StoreQuoteRequest(
                    societyBookId: societyBookId,
                    text: text.trimmedValue,
                    commentary: commentary.trimmedNilIfBlank,
                    positionType: position.trimmedNilIfBlank == nil ? nil : .custom,
                    positionValue: position.trimmedNilIfBlank,
                    spoilerLevel: SpoilerLevel.none,
                    visibility: visibility
                )
            )
            await reload()
            isSubmittingAction = false
            return true
        } catch {
            actionErrorMessage = FeatureDisplay.message(for: error, fallback: "The quote could not be saved.")
            isSubmittingAction = false
            return false
        }
    }
}

private struct LoadedBookRoomView: View {
    let model: BookRoomViewModel
    let payload: BookRoomPayload
    @State private var activeSheet: BookRoomSheet?

    private enum BookRoomSheet: Identifiable {
        case progress
        case note
        case quote

        var id: String {
            switch self {
            case .progress:
                return "progress"
            case .note:
                return "note"
            case .quote:
                return "quote"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            header
            actions
            stats

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: RSSpacing.large)], alignment: .leading, spacing: RSSpacing.large) {
                readingPlan
                upcomingDiscussion
            }

            recentQuotes
            recentNotes
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .progress:
                ProgressUpdateView(
                    model: model,
                    initialPercentage: payload.societyBook.averageProgressPercentage ?? 0
                )
            case .note:
                NoteComposerView(model: model)
            case .quote:
                QuoteComposerView(model: model)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            RSBadge(payload.societyBook.status?.rawValue.replacingOccurrences(of: "_", with: " ") ?? "Book room")

            Text(payload.book.title)
                .font(RSTypography.h1)
                .foregroundStyle(RSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let authors = payload.book.authors, !authors.isEmpty {
                Text(authors.joined(separator: ", "))
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
            }

            if let description = payload.book.description {
                Text(description)
                    .font(RSTypography.body)
                    .foregroundStyle(RSColor.textSecondary)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var actions: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("ACTIONS")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if let message = model.actionErrorMessage {
                    Text(message)
                        .font(RSTypography.small)
                        .foregroundStyle(RSColor.accentPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: RSSpacing.medium) {
                    ActionButton(title: "Progress", systemImage: "chart.line.uptrend.xyaxis") {
                        activeSheet = .progress
                    }

                    ActionButton(title: "Note", systemImage: "note.text") {
                        activeSheet = .note
                    }

                    ActionButton(title: "Quote", systemImage: "quote.opening") {
                        activeSheet = .quote
                    }
                }
            }
        }
    }

    private var stats: some View {
        RSCard {
            HStack(spacing: RSSpacing.large) {
                StatBlock(value: "\(payload.societyBook.averageProgressPercentage ?? 0)%", label: "Progress")
                StatBlock(value: "\(payload.myNotesCount)", label: "My notes")
                StatBlock(value: "\(payload.societyQuotesCount)", label: "Quotes")
            }
        }
    }

    private var readingPlan: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("READING PLAN")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if let plan = payload.readingPlan {
                    Text(plan.title)
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    if let description = plan.description {
                        Text(description)
                            .font(RSTypography.body)
                            .foregroundStyle(RSColor.textSecondary)
                    }

                    ForEach(plan.items ?? []) { item in
                        VStack(alignment: .leading, spacing: RSSpacing.xxSmall) {
                            Text(item.title)
                                .font(RSTypography.body)
                                .foregroundStyle(RSColor.textPrimary)

                            if let dueDate = item.dueDate {
                                Text("Due \(dueDate)")
                                    .font(RSTypography.caption)
                                    .foregroundStyle(RSColor.textMuted)
                            }
                        }
                    }
                } else {
                    Text("No reading plan")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    Text("When a reading plan is attached, its milestones will appear here.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            }
        }
    }

    private var upcomingDiscussion: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("DISCUSSION")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if let discussion = payload.upcomingDiscussion {
                    Text(discussion.title)
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    if let scheduledAt = discussion.scheduledAt {
                        FeatureMetadataPill(text: scheduledAt)
                    }
                } else {
                    Text("No upcoming discussion")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)
                }
            }
        }
    }

    private var recentQuotes: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text("Recent quotes")
                .font(RSTypography.h2)
                .foregroundStyle(RSColor.textPrimary)

            if payload.recentQuotes.isEmpty {
                RSCard {
                    Text("No quotes saved for this book yet.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            } else {
                ForEach(payload.recentQuotes) { quote in
                    RSCard {
                        VStack(alignment: .leading, spacing: RSSpacing.small) {
                            Text(quote.text)
                                .font(RSTypography.bodyLarge)
                                .foregroundStyle(RSColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            if let commentary = quote.commentary {
                                Text(commentary)
                                    .font(RSTypography.body)
                                    .foregroundStyle(RSColor.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }

    private var recentNotes: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text("Recent notes")
                .font(RSTypography.h2)
                .foregroundStyle(RSColor.textPrimary)

            if payload.recentNotes.isEmpty {
                RSCard {
                    Text("No notes saved for this book yet.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            } else {
                ForEach(payload.recentNotes) { note in
                    RSCard {
                        VStack(alignment: .leading, spacing: RSSpacing.small) {
                            if let title = note.title {
                                Text(title)
                                    .font(RSTypography.h3)
                                    .foregroundStyle(RSColor.textPrimary)
                            }

                            Text(note.body)
                                .font(RSTypography.body)
                                .foregroundStyle(RSColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RSSpacing.xSmall) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))

                Text(title)
                    .font(RSTypography.caption)
            }
            .foregroundStyle(RSColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 72)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(RSColor.borderDefault, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ProgressUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    let model: BookRoomViewModel

    @State private var percentage: Int
    @State private var position = ""

    init(model: BookRoomViewModel, initialPercentage: Int) {
        self.model = model
        self._percentage = State(wrappedValue: initialPercentage)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: RSSpacing.large) {
                VStack(alignment: .leading, spacing: RSSpacing.medium) {
                    RSBadge("Progress")

                    Text("Update progress")
                        .font(RSTypography.h1)
                        .foregroundStyle(RSColor.textPrimary)

                    Text("\(percentage)%")
                        .font(RSTypography.h2)
                        .foregroundStyle(RSColor.accentPrimary)
                }

                Slider(
                    value: Binding(
                        get: { Double(percentage) },
                        set: { percentage = Int($0.rounded()) }
                    ),
                    in: 0...100,
                    step: 1
                )
                .tint(RSColor.accentPrimary)

                RSTextField("Position", text: $position, helper: "Optional page, chapter, location, or marker.")

                if let message = model.actionErrorMessage {
                    Text(message)
                        .font(RSTypography.small)
                        .foregroundStyle(RSColor.accentPrimary)
                }

                RSButton(model.isSubmittingAction ? "Saving" : "Save progress") {
                    Task {
                        if await model.updateProgress(percentage: percentage, position: position) {
                            dismiss()
                        }
                    }
                }
                .disabled(model.isSubmittingAction)
                .opacity(model.isSubmittingAction ? 0.55 : 1)

                Spacer()
            }
            .padding(RSSpacing.large)
            .background(RSColor.backgroundDefault)
            .navigationTitle("Progress")
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

private struct NoteComposerView: View {
    @Environment(\.dismiss) private var dismiss
    let model: BookRoomViewModel

    @State private var title = ""
    @State private var bodyText = ""
    @State private var position = ""
    @State private var visibility: Networking.Visibility = .society

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.medium) {
                        RSBadge("Marginalia")

                        Text("New note")
                            .font(RSTypography.h1)
                            .foregroundStyle(RSColor.textPrimary)
                    }

                    RSTextField("Title", text: $title, helper: "Optional")
                    RSTextField("Position", text: $position, helper: "Optional page, chapter, location, or marker.")
                    VisibilityPicker(selection: $visibility)
                    TextEditorField(label: "Body", text: $bodyText)

                    if let message = model.actionErrorMessage {
                        Text(message)
                            .font(RSTypography.small)
                            .foregroundStyle(RSColor.accentPrimary)
                    }

                    RSButton(model.isSubmittingAction ? "Saving" : "Save note") {
                        Task {
                            if await model.createNote(title: title, body: bodyText, position: position, visibility: visibility) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(bodyText.trimmedValue.isEmpty || model.isSubmittingAction)
                    .opacity(bodyText.trimmedValue.isEmpty || model.isSubmittingAction ? 0.55 : 1)
                }
                .padding(RSSpacing.large)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Note")
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

private struct QuoteComposerView: View {
    @Environment(\.dismiss) private var dismiss
    let model: BookRoomViewModel

    @State private var quoteText = ""
    @State private var commentary = ""
    @State private var position = ""
    @State private var visibility: Networking.Visibility = .society

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.medium) {
                        RSBadge("Quotation")

                        Text("New quote")
                            .font(RSTypography.h1)
                            .foregroundStyle(RSColor.textPrimary)
                    }

                    TextEditorField(label: "Quote", text: $quoteText)
                    TextEditorField(label: "Commentary", text: $commentary, minHeight: 96)
                    RSTextField("Position", text: $position, helper: "Optional page, chapter, location, or marker.")
                    VisibilityPicker(selection: $visibility)

                    if let message = model.actionErrorMessage {
                        Text(message)
                            .font(RSTypography.small)
                            .foregroundStyle(RSColor.accentPrimary)
                    }

                    RSButton(model.isSubmittingAction ? "Saving" : "Save quote") {
                        Task {
                            if await model.createQuote(text: quoteText, commentary: commentary, position: position, visibility: visibility) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(quoteText.trimmedValue.isEmpty || model.isSubmittingAction)
                    .opacity(quoteText.trimmedValue.isEmpty || model.isSubmittingAction ? 0.55 : 1)
                }
                .padding(RSSpacing.large)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Quote")
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

private struct VisibilityPicker: View {
    @Binding var selection: Networking.Visibility

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xSmall) {
            Text("Visibility")
                .font(RSTypography.small)
                .foregroundStyle(RSColor.textSecondary)

            Picker("Visibility", selection: $selection) {
                Text("Society").tag(Networking.Visibility.society)
                Text("Private").tag(Networking.Visibility.private)
                Text("Discussion").tag(Networking.Visibility.discussion)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct TextEditorField: View {
    let label: String
    @Binding var text: String
    var minHeight: CGFloat = 144

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xSmall) {
            Text(label)
                .font(RSTypography.small)
                .foregroundStyle(RSColor.textSecondary)

            TextEditor(text: $text)
                .font(RSTypography.body)
                .foregroundStyle(RSColor.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(RSSpacing.small)
                .frame(minHeight: minHeight)
                .background(RSColor.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(RSColor.borderDefault, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
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
