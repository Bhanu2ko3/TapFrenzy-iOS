import MapKit
import SwiftUI

struct MapTab: View {
    @State private var items: [HubGameSession] = []
    
    var body: some View {
        NavigationStack {
            Map {
                ForEach(items) { session in
                    Marker(
                        "\(session.mode == .frenzySpeed ? "Tap" : (session.mode == .gridMatch ? "Light" : "Quiz")): \(session.finalScore)",
                        coordinate: CLLocationCoordinate2D(latitude: session.locLatitude, longitude: session.locLongitude)
                    )
                    .tint(session.mode == .frenzySpeed ? .blue : (session.mode == .gridMatch ? .purple : .indigo))
                }
            }
            .navigationTitle("Geotags")
            .onAppear {
                let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
                items = [HubGameSession].deserialize(from: rawLedger)
            }
        }
    }
}
