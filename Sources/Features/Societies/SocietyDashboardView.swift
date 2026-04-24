import DesignSystem
import Networking
import Observation
import SwiftUI

struct SocietyDashboardView: View {
    @State private var model: SocietyDashboardViewModel
    private let society: Society

    init(api: ReadingSocietyAPI, society: Society) {
        self.society = society
        self._model = State(wrappedValue: SocietyDashboardViewModel(api: api, society: society))
    }

    var body: some View {
        ScrollView {
            content
                .padding(RSSpacing.large)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(RSColor.backgroundDefault)
        .navigationTitle(society.name)
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
            FeatureLoadingView(title: "Opening \(society.name)", message: "Fetching the current book, discussion, members, and recent activity.")
        case let .failed(message):
            FeatureErrorView(title: "Society dashboard could not be loaded", message: message) {
                Task {
                    await model.reload()
                }
            }
        case let .loaded(payload):
            LoadedSocietyDashboardView(payload: payload, api: model.api)
        }
    }
}

@MainActor
@Observable
final class SocietyDashboardViewModel {
    let api: ReadingSocietyAPI
    var state: LoadState<SocietyDashboardPayload> = .idle

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
            state = .loaded(try await api.societyDashboard(society.id))
            hasLoaded = true
        } catch {
            state = .failed(FeatureDisplay.message(for: error, fallback: "The society dashboard could not be loaded."))
        }
    }
}

private struct LoadedSocietyDashboardView: View {
    let payload: SocietyDashboardPayload
    let api: ReadingSocietyAPI

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            header
            quickLinks
            currentBook

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: RSSpacing.large)], alignment: .leading, spacing: RSSpacing.large) {
                discussionPanel
                membersPanel
            }

            activityPanel
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            RSBadge(payload.society.visibility?.rawValue.replacingOccurrences(of: "_", with: " ") ?? "Private")

            Text(payload.society.name)
                .font(RSTypography.h1)
                .foregroundStyle(RSColor.textPrimary)

            Text(payload.society.description ?? "A private society for shared reading.")
                .font(RSTypography.bodyLarge)
                .foregroundStyle(RSColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var quickLinks: some View {
        HStack(spacing: RSSpacing.medium) {
            NavigationLink {
                SocietyLibraryView(api: api, society: payload.society)
            } label: {
                Label("Library", systemImage: "books.vertical")
                    .font(RSTypography.control)
                    .foregroundStyle(RSColor.textPrimary)
                    .frame(minHeight: 44)
                    .padding(.horizontal, RSSpacing.large)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(RSColor.borderDefault, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    @ViewBuilder
    private var currentBook: some View {
        if let currentBook = payload.currentBook {
            RSCard {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.small) {
                        Text("CURRENT READING")
                            .font(RSTypography.caption)
                            .foregroundStyle(RSColor.accentOrnament)

                        SocietyBookRow(societyBook: currentBook, baseURL: api.client.baseURL)
                    }

                    if let societyId = currentBook.societyId {
                        NavigationLink {
                            BookRoomView(api: api, societyId: societyId, societyBook: currentBook)
                        } label: {
                            Text("Open book room")
                                .font(RSTypography.control)
                                .foregroundStyle(RSColor.accentPrimary)
                        }
                    }
                }
            }
        } else {
            RSCard {
                VStack(alignment: .leading, spacing: RSSpacing.medium) {
                    Text("No current reading")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    Text("Select or import a book for this society and the reading room will appear here.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            }
        }
    }

    private var discussionPanel: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("NEXT DISCUSSION")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if let discussion = payload.nextDiscussion {
                    Text(discussion.title)
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)

                    if let scheduledAt = discussion.scheduledAt {
                        FeatureMetadataPill(text: scheduledAt)
                    }
                } else {
                    Text("No discussion scheduled")
                        .font(RSTypography.h3)
                        .foregroundStyle(RSColor.textPrimary)
                }
            }
        }
    }

    private var membersPanel: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("MEMBERS")
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.accentOrnament)

                if payload.members.isEmpty {
                    Text("No active members returned.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                } else {
                    ForEach(payload.members.prefix(5)) { member in
                        HStack {
                            Text(member.displayName ?? member.user?.name ?? "Reader")
                                .font(RSTypography.body)
                                .foregroundStyle(RSColor.textPrimary)

                            Spacer()

                            Text(member.role?.rawValue.uppercased() ?? "MEMBER")
                                .font(RSTypography.caption)
                                .foregroundStyle(RSColor.textMuted)
                        }
                    }
                }
            }
        }
    }

    private var activityPanel: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text("Recent activity")
                .font(RSTypography.h2)
                .foregroundStyle(RSColor.textPrimary)

            let activities = payload.recentActivity ?? []
            if activities.isEmpty {
                RSCard {
                    Text("No recent activity returned for this society.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            } else {
                VStack(spacing: RSSpacing.medium) {
                    ForEach(Array(activities.enumerated()), id: \.offset) { _, activity in
                        RSCard {
                            Text(FeatureDisplay.text(for: activity))
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
