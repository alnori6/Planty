//
//  tipsSheet.swift
//  Planty
//
//  Created by Noori on 23/02/2025.
//


import SwiftUI

struct tipsPage: View {
    
    @EnvironmentObject var plantyVM: PlantViewModel
    @EnvironmentObject var cameraModel : CameraModel
    
    let columns = [
        GridItem(.flexible()),  // Equal spacing for all columns
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        NavigationStack {
            
            Text("Tips to help !")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color("darkGreen"))
                .padding(.bottom, 24)
                .padding(.top, 24)
            
            LazyVGrid(columns: columns, spacing: 24) {
                VStack(spacing: 8) {
                    Image("sample1")
                        .resizable()
                        .frame(width: 168, height: 196)
                    Text("Not too close")
                        .font(.system(size: 24, weight: .medium))
                }
                VStack(spacing: 8) {
                    Image("sample2")
                        .resizable()
                        .frame(width: 168, height: 196)
                    Text("Multi-species")
                        .font(.system(size: 24, weight: .medium))
                }
                VStack(spacing: 8) {
                    Image("sample3")
                        .resizable()
                        .frame(width: 168, height: 196)
                    Text("Not too Far")
                        .font(.system(size: 24, weight: .medium))
                }
                VStack(spacing: 8) {
                    Image("sample4")
                        .resizable()
                        .frame(width: 168, height: 196)
                    Text("Just Right !")
                        .font(.system(size: 24, weight: .medium))
                }
            }
            .padding(.bottom, 24)
        }
        .padding()
        
    }
}


#Preview {
    tipsPage()
        .environmentObject(PlantViewModel())
        .environmentObject(CameraModel())
}
