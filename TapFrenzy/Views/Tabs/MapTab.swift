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
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: annotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(item.mode == .frenzySpeed ? .blue : (item.mode == .gridMatch ? .purple : .indigo))
                        
                        Text("\(item.score)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
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
