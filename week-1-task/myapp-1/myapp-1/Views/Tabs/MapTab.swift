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
    
    // default camera position around Colombo (6.9271, 79.8612)
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // interactive map with annotations
                mapView
                
                VStack(spacing: 12) {
                    // mode filter picker at top
                    modePickerView
                    
                    if sessionsWithLocation.isEmpty {
                        emptyStateOverlay
                    }
                    
                    Spacer()
                    
                    // floating recenter button
                    HStack {
                        Spacer()
                        recenterButton
                    }
                    .padding(.horizontal)
                    
                    // selected session detail callout overlay
                    if let session = selectedSession {
                        sessionCalloutCard(for: session)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                recenterMap()
            }
            .onChange(of: selectedMode) { _, _ in
                selectedSession = nil
                recenterMap()
            }
        }
    }
    
    // filter sessions that have valid latitude and longitude for selected mode
    private var sessionsWithLocation: [GameSession] {
        let all = historyService.sessions.filter { $0.hasValidLocation && $0.coordinate != nil }
        if let mode = selectedMode.gameMode {
            return all.filter { $0.mode == mode }
        }
        return all
    }
    
    // interactive map view plotting sessions
    private var mapView: some View {
        Map(position: $cameraPosition) {
            ForEach(sessionsWithLocation) { session in
                if let coordinate = session.coordinate {
                    Annotation(session.mode.title, coordinate: coordinate) {
                        Button {
                            withAnimation {
                                selectedSession = session
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Image(systemName: session.mode.iconName)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(session.mode.color)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedSession?.id == session.id ? Color.primary : Color.white, lineWidth: selectedSession?.id == session.id ? 3 : 1.5)
                                            )
                                    )
                                    .shadow(radius: 4)
                                
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(session.mode.color)
                                    .rotationEffect(.degrees(180))
                                    .offset(y: -3)
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // mode filter picker inside styled container
    private var modePickerView: some View {
        Picker("Filter Mode", selection: $selectedMode) {
            ForEach(ModeSelection.allCases) { selection in
                Text(selection.rawValue).tag(selection)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // overlay displayed when no mapped sessions match filter
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
    
    // button to recenter map on mapped sessions or default coordinates
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
    
    // detail callout card for the selected game session pin
    private func sessionCalloutCard(for session: GameSession) -> some View {
        HStack(spacing: 14) {
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
                    Spacer()
                    Text("\(session.score) pts")
                        .font(.headline)
                        .foregroundColor(session.mode.color)
                }
                
                Text(session.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lat = session.latitude, let lon = session.longitude {
                    Text("Coordinates: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lon))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                withAnimation {
                    selectedSession = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    // center camera region around mapped sessions or default location
    private func recenterMap() {
        if let firstSession = sessionsWithLocation.first, let coordinate = firstSession.coordinate {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                ))
            }
        } else {
            // fallback to Colombo coordinates
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
