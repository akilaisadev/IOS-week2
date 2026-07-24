//
//  MapTab.swift
//  myapp-1
//
//  tab view displaying gameplay locations on an interactive map
//

import SwiftUI
import MapKit
import CoreLocation

struct MapTab: View {
    @ObservedObject private var historyService = HistoryService.shared
    @State private var selectedMode: ModeSelection = .all
    @State private var selectedSession: GameSession? = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapView
                
                VStack(spacing: 12) {
                    modePickerView
                    
                    if sessionsWithLocation.isEmpty {
                        emptyStateOverlay
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        recenterButton
                    }
                    .padding(.horizontal)
                    if let session = selectedSession {
                        sessionCalloutCard(for: session)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Colors.secondaryBackground.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                recenterMap()
            }
            .onChange(of: selectedMode) { _, _ in
                selectedSession = nil
                recenterMap()
            }
        }
    }
    private var sessionsWithLocation: [GameSession] {
        let all = historyService.sessions.filter { $0.hasValidLocation && $0.coordinate != nil }
        if let mode = selectedMode.gameMode {
            return all.filter { $0.mode == mode }
        }
        return all
    }
    private var mapView: some View {
        Map(position: $cameraPosition) {
            MapPolyline(coordinates: sessionsWithLocation.compactMap { $0.coordinate })
                .stroke(Color.purple.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 8]))
            
            ForEach(sessionsWithLocation) { session in
                if let coordinate = session.coordinate {
                    let isSelected = (selectedSession?.id == session.id)
                    
                    Annotation(session.mode.title, coordinate: coordinate) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                selectedSession = session
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Image(systemName: session.mode.iconName)
                                    .font(.system(size: isSelected ? 20 : 14))
                                    .foregroundColor(.white)
                                    .padding(isSelected ? 12 : 8)
                                    .background(
                                        Circle()
                                            .fill(session.mode.color)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: isSelected ? 3 : 1.5)
                                            )
                                            .shadow(color: session.mode.color.opacity(0.5), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                                    )
                                
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: isSelected ? 14 : 10))
                                    .foregroundColor(session.mode.color)
                                    .rotationEffect(.degrees(180))
                                    .offset(y: -2)
                            }
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .animation(.spring(), value: isSelected)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    private var modePickerView: some View {
        Picker("Filter Mode", selection: $selectedMode) {
            ForEach(ModeSelection.allCases) { selection in
                Text(selection.rawValue).tag(selection)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    private var emptyStateOverlay: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "mappin.slash")
                    .foregroundColor(.orange)
                Text("No Mapped Games Yet")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            
            Text("Play a round with location enabled to see your pins here!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(10)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
    private var recenterButton: some View {
        Button {
            withAnimation {
                recenterMap()
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
    private func sessionCalloutCard(for session: GameSession) -> some View {
        AppCard(padding: AppTheme.Spacing.small) {
            HStack(spacing: AppTheme.Spacing.small) {
                Image(systemName: session.mode.iconName)
                    .font(.title2)
                    .foregroundColor(session.mode.color)
                    .frame(width: 44, height: 44)
                    .background(session.mode.color.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.mode.title)
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Spacer()
                        Text("\(session.score) pts")
                            .font(.headline)
                            .foregroundColor(session.mode.color)
                    }
                    
                    Text(session.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    if let lat = session.latitude, let lon = session.longitude {
                        Text("Coordinates: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lon))")
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Button {
                    withAnimation {
                        selectedSession = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal)
    }
    private func recenterMap() {
        if let firstSession = sessionsWithLocation.first, let coordinate = firstSession.coordinate {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                ))
            }
        } else {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            }
        }
    }
}

#Preview {
    MapTab()
}
