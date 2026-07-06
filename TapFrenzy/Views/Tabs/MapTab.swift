import MapKit
import SwiftUI

struct IdentifiableLocation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let score: Int
    let mode: AppGameMode
}

struct MapTab: View {
    @State private var items: [HubGameSession] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
    )
    
    var annotations: [IdentifiableLocation] {
        items.map { session in
            IdentifiableLocation(
                id: session.id,
                coordinate: CLLocationCoordinate2D(latitude: session.locLatitude, longitude: session.locLongitude),
                score: session.finalScore,
                mode: session.mode
            )
        }
    }
    
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
                items = [HubGameSession].deserialize(from: rawLedger)
                if let last = items.last {
                    region.center = CLLocationCoordinate2D(latitude: last.locLatitude, longitude: last.locLongitude)
                }
            }
        }
    }
}
