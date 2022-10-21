//
//  MultiTabView.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/14/22.
//
import SwiftUI

struct MultiTabView: View {
    var body: some View {
        TabView{
            
            TryETAPI()
                .tabItem{
                    Label("ET API",systemImage: "keyboard")
                }
             
            Tab1View()
                .tabItem{
                    Label("Tab 1",systemImage: "keyboard")
                }
            GpsMapPictureView()
                .tabItem{
                    Label("Watering needs",systemImage: "leaf.circle")
                }
            WebView(url:URL(string:"https://aiclub.world/privacy")!)
                .tabItem{
                    Label("Web page",systemImage: "eyes.inverse")
                }

        }
    }
}

struct Tab1View: View {
    var body: some View {
        Text("Page 1")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct Tab2View: View {
    var body: some View {
        Text("Page 2")
    }
}

struct Tab3View: View {
    var body: some View {
        Text("Page 3")
    }
}

struct MultiTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            MultiTabView()
        }
    }
}
