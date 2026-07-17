//
//  HistorySheetView.swift
//  myapp-1
//

import SwiftUI

struct HistorySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var historyService = HistoryService.shared
    
    let gameType: GameType?
    
    var filteredRecords: [GameRecord] {
        historyService.getRecords(for: gameType)
    }
    
    var title: String {
        if let type = gameType {
            return "\(type.rawValue) History"
        } else {
            return "All Games History"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if filteredRecords.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Game Records Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Complete a round of \(gameType?.rawValue ?? "any game") to start logging your history!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(record.gameType.color.opacity(0.18))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: record.gameType.iconName)
                                        .font(.headline)
                                        .foregroundColor(record.gameType.color)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(record.gameType.rawValue)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(record.score) PTS")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(record.gameType.color)
                                    }
                                    
                                    HStack {
                                        Text(record.detail)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(record.formattedDate)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HistorySheetView(gameType: .tapFrenzy)
}
