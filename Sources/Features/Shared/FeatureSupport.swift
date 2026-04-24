import DesignSystem
import Foundation
import Networking
import SwiftUI

enum LoadState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

struct FeatureLoadingView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("Loading")

                Text(title)
                    .font(RSTypography.h1)
                    .foregroundStyle(RSColor.textPrimary)

                Text(message)
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RSCard {
                ProgressView()
                    .tint(RSColor.accentPrimary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
    }
}

struct FeatureErrorView: View {
    let title: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                RSBadge("Unavailable")

                Text(title)
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

struct FeatureMetadataPill: View {
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

struct SocietyBookRow: View {
    let societyBook: SocietyBook
    var baseURL: URL?

    var body: some View {
        HStack(alignment: .top, spacing: RSSpacing.medium) {
            if let baseURL {
                BookCoverThumbnail(path: societyBook.book?.coverImagePath, baseURL: baseURL)
            }

            VStack(alignment: .leading, spacing: RSSpacing.small) {
                Text(societyBook.book?.title ?? "Untitled book")
                    .font(RSTypography.h3)
                    .foregroundStyle(RSColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let authors = societyBook.book?.authors, !authors.isEmpty {
                    Text(authors.joined(separator: ", "))
                        .font(RSTypography.small)
                        .foregroundStyle(RSColor.textSecondary)
                }

                HStack(spacing: RSSpacing.small) {
                    if let status = societyBook.status {
                        FeatureMetadataPill(text: status.rawValue.replacingOccurrences(of: "_", with: " "))
                    }

                    FeatureMetadataPill(text: "\(societyBook.averageProgressPercentage ?? 0)%")
                }
            }
        }
    }
}

struct BookCoverThumbnail: View {
    let path: String?
    let baseURL: URL
    var width: CGFloat = 54
    var height: CGFloat = 82

    var body: some View {
        Group {
            if let url = FeatureImageURL.url(for: path, baseURL: baseURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        ProgressView()
                            .tint(RSColor.accentPrimary)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(RSColor.borderDefault, lineWidth: 1)
        )
    }

    private var placeholder: some View {
        ZStack {
            RSColor.backgroundSubtle

            Image(systemName: "book.closed")
                .foregroundStyle(RSColor.textMuted)
        }
    }
}

enum FeatureImageURL {
    static func url(for path: String?, baseURL: URL) -> URL? {
        guard let path = path?.trimmedNilIfBlank else {
            return nil
        }

        if let absoluteURL = URL(string: path), absoluteURL.scheme != nil {
            return absoluteURL
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = normalizedPath(path)
        components?.query = nil
        components?.fragment = nil
        return components?.url
    }

    private static func normalizedPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return path
        }

        if path.hasPrefix("storage/") {
            return "/\(path)"
        }

        return "/storage/\(path)"
    }
}

enum FeatureDisplay {
    static func message(for error: Error, fallback: String) -> String {
        if let apiError = error as? APIClient.APIError {
            switch apiError {
            case let .transportStatus(status, response):
                if status == 401 {
                    return "Your session has expired. Sign out, then sign in again."
                }

                if let validationMessage = response?.errors?.values.first?.first {
                    return validationMessage
                }

                if let message = response?.message, !message.isEmpty {
                    return message
                }

                return fallback
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
        let preferredKeys = ["title", "name", "action", "body", "description", "due_date", "created_at"]
        let parts = preferredKeys.compactMap { key -> String? in
            guard let value = object[key] else {
                return nil
            }

            return text(for: value)
        }

        return parts.isEmpty ? "Record" : parts.joined(separator: ", ")
    }
}

extension String {
    var trimmedNilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var trimmedValue: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
