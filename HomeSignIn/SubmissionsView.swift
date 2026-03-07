import SwiftUI

struct SubmissionsView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showRecentlyDeleted = false

    var body: some View {
        Group {
            if store.visitors.isEmpty {
                ContentUnavailableView(
                    "No Sign-ins Yet",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text("Visitor sign-ins will appear here.")
                )
            } else {
                List {
                    ForEach(store.visitors) { visitor in
                        VisitorRow(visitor: visitor, onDelete: { store.softDelete(visitor) })
                    }
                    .onDelete(perform: store.softDelete)
                }
            }
        }
        .navigationTitle("Sign-ins (\(store.visitors.count))")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !store.deletedVisitors.isEmpty {
                    Button {
                        showRecentlyDeleted = true
                    } label: {
                        Label("Recently Deleted", systemImage: "trash.circle")
                    }
                }
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showRecentlyDeleted) {
            NavigationStack {
                RecentlyDeletedView()
            }
        }
    }
}

// MARK: - Recently Deleted

private struct RecentlyDeletedView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(store.deletedVisitors) { visitor in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(visitor.fullName.trimmed.isEmpty ? "(No name)" : visitor.fullName)
                            .font(.headline)
                        if let deletedAt = visitor.deletedAt {
                            Text("Deleted \(deletedAt, style: .relative) ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Auto-removed \(expiryDate(from: deletedAt), style: .date)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Spacer()
                    Button("Restore") {
                        store.restore(visitor)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.vertical, 2)
            }
            .onDelete(perform: store.permanentlyDelete)
        }
        .navigationTitle("Recently Deleted")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
        .overlay {
            if store.deletedVisitors.isEmpty {
                ContentUnavailableView(
                    "No Recently Deleted Items",
                    systemImage: "trash",
                    description: Text("Deleted sign-ins appear here for 30 days.")
                )
            }
        }
    }

    private func expiryDate(from deletedAt: Date) -> Date {
        deletedAt.addingTimeInterval(30 * 24 * 60 * 60)
    }
}

// MARK: - VisitorRow

private struct VisitorRow: View {
    let visitor: Visitor
    var onDelete: () -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(visitor.fullName.trimmed.isEmpty ? "(No name)" : visitor.fullName)
                    .font(.headline)
                Spacer()
                Text(Self.dateFormatter.string(from: visitor.timestamp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }

            if !visitor.phone.isEmpty || !visitor.email.isEmpty {
                HStack(spacing: 16) {
                    if !visitor.phone.isEmpty {
                        Label(visitor.phone, systemImage: "phone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if !visitor.email.isEmpty {
                        Label(visitor.email, systemImage: "envelope")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if visitor.hasAgent {
                HStack(spacing: 4) {
                    Image(systemName: "briefcase.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        if !visitor.agentName.isEmpty {
                            Text(visitor.agentName)
                                .font(.subheadline.bold())
                                .foregroundStyle(.blue)
                        }
                        if !visitor.agentBrokerage.isEmpty {
                            Text(visitor.agentBrokerage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !visitor.agentPhone.isEmpty {
                            Text(visitor.agentPhone)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
