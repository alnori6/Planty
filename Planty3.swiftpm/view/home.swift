import SwiftUI


struct home: View {
    
    @EnvironmentObject var plantyVM: PlantViewModel
    
   
    
    var body: some View {
        
        NavigationStack{
            
            
            VStack(spacing: 24) {
                // Header Section
                
                Text("Welcome to Planty")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color("darkGreen"))
                    .padding(.bottom, 24)
                
                
                HStack(){
                    
                    VStack(spacing: 16){
                        Text("Nomi the Farmer:")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color("darkGreen"))
                        
                        Divider()
                            .frame(width: 180, height: 1)
                        
                        Text("Remember to take care of the living things around you !")
                            .font(.system(size: 20, weight: .regular))
                            .lineLimit(nil)  // ✅ Allows multiple lines
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 4)
                    
                    Image("nomiCircle1")
                        .resizable()
                        .frame(width: 170, height: 170)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(4)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.bottom, 24)
                
                
                
                
                
                
                NavigationLink(destination: PlantGuideIntroView().environmentObject(plantyVM)) {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                        
                        Text("Take Care of Your Plant")
                    }
                    .padding()
                }
                .buttonStyle(interfaceButton())
                
                
            
                NavigationLink(destination: plantsLibraryView().environmentObject(plantyVM)) {
                    HStack(spacing: 8) {
                        Image(systemName: "books.vertical.fill")
                        
                        Text("Plants Library")
                    }
                    .padding()
                }
                .buttonStyle(interfaceButton())
                .padding(.bottom, 24)
              
                
                
                NavigationLink(destination: tipsPage().environmentObject(plantyVM)) {
                    HStack(spacing: 8) {
                        Image("leavSnap")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Take a Plant Photo")
                    }
                    .padding()
                }
                .buttonStyle(interface2Button())
                
                
                Spacer()
            }
            .padding(.top, 56)
            .padding()
            
        }
        
            
            
            
        
    }
}


#Preview {
    home()
        .environmentObject(PlantViewModel())
}
