import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }

            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
        }
        .tint(.indigo)
    }
}

#Preview {
    ContentView()
}
