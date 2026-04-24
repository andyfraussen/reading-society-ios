import DesignSystem
import Networking
import Observation
import SwiftUI

public struct SocietiesView: View {
    @State private var model: SocietiesViewModel
    @State private var isPresentingCreate = false

    public init(api: ReadingSocietyAPI) {
        self._model = State(wrappedValue: SocietiesViewModel(api: api))
    }

    public var body: some View {
        NavigationStack {
            content
            .background(RSColor.backgroundDefault)
            .navigationTitle("Society")
            .toolbar {
                if model.canCreateSociety {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingCreate = true
                        } label: {
                            Label("Create society", systemImage: "plus")
                        }
                        .foregroundStyle(RSColor.textPrimary)
                    }
                }
            }
            .task {
                await model.load()
            }
            .refreshable {
                await model.reload()
            }
            .sheet(isPresented: $isPresentingCreate) {
                CreateSocietyView(model: model)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            contained {
                FeatureLoadingView(title: "Opening your society", message: "Fetching the room you own or have joined.")
            }
        case let .failed(message):
            contained {
                FeatureErrorView(title: "Society could not be loaded", message: message) {
                    Task {
                        await model.reload()
                    }
                }
            }
        case let .loaded(societies):
            if let society = societies.first {
                SocietyDashboardView(api: model.api, society: society)
            } else {
                contained {
                    EmptySocietyView {
                        isPresentingCreate = true
                    }
                }
            }
        }
    }

    private func contained<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            content()
                .padding(RSSpacing.large)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

@MainActor
@Observable
final class SocietiesViewModel {
    let api: ReadingSocietyAPI
    var state: LoadState<[Society]> = .idle
    var createErrorMessage: String?
    var isCreating = false

    private var hasLoaded = false

    init(api: ReadingSocietyAPI) {
        self.api = api
    }

    var canCreateSociety: Bool {
        if case let .loaded(societies) = state {
            return societies.isEmpty
        }

        return false
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
            state = .loaded(try await api.societies().data)
            hasLoaded = true
        } catch {
            state = .failed(FeatureDisplay.message(for: error, fallback: "The societies archive could not be loaded."))
        }
    }

    func createSociety(name: String, description: String) async -> Bool {
        guard !isCreating else {
            return false
        }

        isCreating = true
        createErrorMessage = nil

        do {
            _ = try await api.createSociety(
                StoreSocietyRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmedNilIfBlank,
                    timezone: TimeZone.current.identifier
                )
            )
            await reload()
            isCreating = false
            return true
        } catch {
            createErrorMessage = FeatureDisplay.message(for: error, fallback: "The society could not be created.")
            isCreating = false
            return false
        }
    }
}

private struct EmptySocietyView: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("Private society")

                Text("Start a society")
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text("Create your reading room to add books, notes, quotes, and discussions.")
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
            }

            RSButton("Create society", variant: .primary, action: onCreate)
                .frame(maxWidth: 260)
        }
    }
}

private struct LoadedSocietiesView: View {
    let societies: [Society]
    let api: ReadingSocietyAPI

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("\(societies.count) rooms")

                Text("Society archive")
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text("Choose a society to open its dashboard, current reading, members, and library.")
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
            }

            if societies.isEmpty {
                RSCard {
                    Text("No societies yet. Create one to start a shared reading room.")
                        .font(RSTypography.body)
                        .foregroundStyle(RSColor.textSecondary)
                }
            } else {
                VStack(spacing: RSSpacing.medium) {
                    ForEach(societies) { society in
                        NavigationLink {
                            SocietyDashboardView(api: api, society: society)
                        } label: {
                            RSCard {
                                HStack(alignment: .top, spacing: RSSpacing.medium) {
                                    VStack(alignment: .leading, spacing: RSSpacing.small) {
                                        Text(society.name)
                                            .font(RSTypography.h3)
                                            .foregroundStyle(RSColor.textPrimary)

                                        Text(society.description ?? "A private room for shared reading.")
                                            .font(RSTypography.body)
                                            .foregroundStyle(RSColor.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)

                                        HStack(spacing: RSSpacing.small) {
                                            if let visibility = society.visibility {
                                                FeatureMetadataPill(text: visibility.rawValue.replacingOccurrences(of: "_", with: " "))
                                            }

                                            if let timezone = society.timezone {
                                                FeatureMetadataPill(text: timezone)
                                            }
                                        }
                                    }

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

private struct CreateSocietyView: View {
    @Environment(\.dismiss) private var dismiss
    let model: SocietiesViewModel

    @State private var name = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    RSTextField("Name", text: $name)
                    RSTextField("Description", text: $description)

                    if let message = model.createErrorMessage {
                        Text(message)
                            .font(RSTypography.small)
                            .foregroundStyle(RSColor.accentPrimary)
                    }

                    RSButton(model.isCreating ? "Creating" : "Create society") {
                        Task {
                            if await model.createSociety(name: name, description: description) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isCreating)
                    .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isCreating ? 0.55 : 1)
                }
                .padding(RSSpacing.large)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Create society")
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
