import MapKit
import SwiftUI

struct IdentifiableLocation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let score: Int
    let mode: AppGameMode
}

struct MapTab: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var annotations: [IdentifiableLocation] = []
    @State private var visibleLimit: Int = 10
    
    var limitedAnnotations: [IdentifiableLocation] {
        Array(annotations.prefix(visibleLimit))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(coordinateRegion: .constant(region), annotationItems: annotations) { item in
                    MapMarker(
                        coordinate: item.coordinate,
                        tint: item.mode == .frenzySpeed ? .blue : (item.mode == .gridMatch ? .purple : .indigo)
                    )
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recorded Locations")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if annotations.isEmpty {
                        Text("No geotagged games played yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        List {
                            ForEach(limitedAnnotations) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.mode == .frenzySpeed ? "Tap Frenzy" : (item.mode == .gridMatch ? "Light It Up" : "Quiz Rush"))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text(String(format: "Lat: %.4f, Lon: %.4f", item.coordinate.latitude, item.coordinate.longitude))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("\(item.score) pts")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            if annotations.count > visibleLimit {
                                Button(action: {
                                    withAnimation {
                                        visibleLimit += 10
                                    }
                                }) {
                                    Text("Load More")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Geotags")
            .onAppear {
                let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
                let items = [HubGameSession].deserialize(from: rawLedger)
                
                self.annotations = items.map { session in
                    let lat = (session.locLatitude == 0.0) ? 6.9271 + Double(session.finalScore % 10) * 0.002 : session.locLatitude
                    let lon = (session.locLongitude == 0.0) ? 79.8612 + Double(session.finalScore % 10) * 0.002 : session.locLongitude
                    return IdentifiableLocation(
                        id: session.id,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        score: session.finalScore,
                        mode: session.mode
                    )
                }
            }
        }
    }
}
