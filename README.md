# 🌱 **Planty - WWDC24 Project**  
**An interactive plant-care gamification app using SwiftUI, CoreML, Vision, and MapKit.**  

---

## 📖 **Overview**  
**Planty** is a smart, gamified plant-care app designed to educate users on plant care while integrating **AI-based plant classification, semi-real-time growth tracking, and scheduled watering notifications**. The app blends **education, AI, and sustainability** into an engaging experience for plant lovers, helping them **learn more about plants, explore medicinal uses, and discover traditional knowledge**.

---

## 🚀 **Features**  
- **📸 AI Plant Classification:** Uses **CoreML & Vision** to classify plant images and provide details about their care needs.  
- **💧 Smart Watering System:** Implements a **structured two-time watering system** with a **3-hour delay** for the second watering.  
- **🔔 Watering & Growth Notifications:** Sends reminders using **UserNotifications** when it’s time to water the plant.  
- **🗺️ Location-Based Growth Insights:** Uses **MapKit & CoreLocation** to display where the plant naturally grows.  
- **🌿 Growth Simulation:** Encourages users to water their plant regularly to reach **5 levels of happiness**.  
- **⏳ Timer-Based Watering System:** Ensures **3-hour gaps** between waterings to prevent overwatering.  
- **🔍 CSV-Based Plant Data Handling:** Loads and searches plant data efficiently.  
- **📚 Plant Library:** Allows users to **save discovered plants** and access them later.  

---

## 🛠️ **Apple Technologies Used**  

| **Technology**      | **Usage** |
|--------------------|----------|
| **SwiftUI** | UI design and interactive components. |
| **CoreML & Vision** | AI-powered plant classification. |
| **UserNotifications** | Scheduled reminders for watering. |
| **MapKit & CoreLocation** | Displays where the plant naturally grows. |
| **File Handling (CSV)** | Loads and processes plant data. |
| **UserDefaults** | Saves user preferences and plant selections. |

---

## 📸 **Screenshots & Functionalities**  

### **1️⃣ AI-Based Plant Classification**  
- Users **take a photo or upload an image** to classify the plant.  
- **CoreML & Vision** recognize the plant and fetch information.  

![classification](https://github.com/user-attachments/assets/11433b1e-83f3-4a8b-9dec-32aa0a1b13a1)

![classification2](https://github.com/user-attachments/assets/c4be6c97-cd8d-4b89-8654-98b53706e82b)


---

## 📷 **App Screenshots**  

| Welcome Screen | Plant Selection | Plant Care | Growth Stage | Palnt Library | 
|---------------|----------------|------------|--------------|
| <img width="966" alt="onBoarding" src="https://github.com/user-attachments/assets/06e485c1-7210-457e-98a0-a6f98d5be62a" /> | <img width="337" alt="plantSelect" src="https://github.com/user-attachments/assets/9bd893de-58af-4325-8094-41a828bb8490" /> |![plantCare2](https://github.com/user-attachments/assets/322dba40-789d-4efc-b885-a49c3267118e) |  ![plantCare3](https://github.com/user-attachments/assets/ad870e76-1389-4b80-a201-a9b750c4b18d) | ![IMG_2989](https://github.com/user-attachments/assets/c735391a-6d23-4269-b731-4f8ab5b15af8)
 


---

## 🎯 **App Flow & Features**  

### 🏡 **Home & Plant Guide**  
- The app begins with an **interactive plant-care guide** that explains the game’s rules.  
- Users **select their preferred plant** to grow.  
- Once selected, the guide is **skipped on future launches**.

![home](https://github.com/user-attachments/assets/8645fab7-31c3-48ca-9775-70eb90965e72)


---

### 💧 **Smart Watering System**  
- Users **must water their plant twice a day**.  
- The second watering requires a **3-hour interval** from the first.  
- If missed, the plant **gets thirsty** → then **wilts** → eventually **dies**.  

![plantCare2](https://github.com/user-attachments/assets/9e02270f-37f5-4734-a847-6d8598a92bee)


---

### ⏰ **Smart Notifications**  
- **Daily reminders** (9 AM & 9 PM) notify users to water their plant.  
- A **3-hour countdown** ensures the user doesn’t overwater.  
- If the plant is neglected, **alert notifications** appear.  



---

### 🌱 **Growth Tracking**  
- Each plant has **5 growth stages**.  
- Consistent watering **increases growth**.  
- Once fully grown, users receive a **congratulatory message**.  

 ![plantCare1](https://github.com/user-attachments/assets/98386969-1cb6-43fd-938e-f1e230c45436)


---

### 📊 **AI-Based Plant Classification**  
- **Users take a photo or upload an image** to classify the plant.  
- A **CoreML model** identifies plant species.  
- The app provides **scientific names, traditional uses, and regional information**.  

![result1](https://github.com/user-attachments/assets/0e2adb41-a5d5-4080-bf62-3a2692d72fa6)

![result2](https://github.com/user-attachments/assets/a648e0b9-fe24-4599-b491-234c3613441e)

![result3](https://github.com/user-attachments/assets/7e65d68b-69c4-4f93-9f55-8a2f0e368dda)


---

## ⚠️ **Playground Issues & Fixes**  

While testing **CoreML models in Swift Playgrounds**, several issues were encountered:  

### 🚨 **Issue: The CoreML model file is not recognized in Playgrounds**  
- Simply dragging and dropping the `.mlmodel` file into Playgrounds **does not work**.  
- The system does not automatically compile the model for usage.  

### 🛠 **Solution: Extract & Compile `.mlmodelc`**  
To ensure that Playgrounds recognizes the CoreML model, follow these steps:  

1. **Extract the `.mlmodelc` from the `.mlmodel`**  
   - Open a **normal Xcode project** and add the `.mlmodel` file.  
   - Xcode will generate a compiled `.mlmodelc` file.  

2. **Use the terminal to compile the `.mlmodelc` manually**  
   - Open Terminal and navigate to the directory where the `.mlmodel` is stored.  
   - Run the following command:  
     ```sh
     xcrun coremlcompiler compile MyModel.mlmodel MyCompiledModel
     ```
   - This will generate the **compiled model (`.mlmodelc`)**, which Playgrounds can read.  

3. **Manually add the `.mlmodelc` path in the Playground Package**  
   - Go to the **Resources** folder of your Playground project.  
   - Update the file path in the **Package.swift** file.  

📷 **Visual Guide:**  
https://miro.com/app/board/uXjVLgC4A0M=/?share_link_id=334668474493

---

## 📂 **Project Structure**  

```
Planty/
│── 📂 Assets/
│   ├── 📷 Images/
│   ├──  Appicon/
│   ├──  Colours/
│── 📂 Models/
│   ├── plant.swift
│── 📂 ViewModels/
│   ├── PlantViewModel.swift
│   ├── CameraModel.swift
│   ├── ImagePicker.swift
│── 📂 Views/
│   ├── CameraView.swift
│   ├── PlantDetailView.swift
│   ├── OnboardingView.swift
│   ├── PlantGuideIntroView.swift
│   ├── PlantCareView.swift
│   ├── plantsLibraryView.swift
│   ├── tipsPage.swift
│   ├── FinalGrowthView.swift
│   ├── home.swift
│── 📄 MyApp.swift
│── 📄 Package.swift
│── 📄 README.md
```

---

## 🎯 **Future Improvements**  
✅ **More Plant Data** → Expand the plant library with **regional medicinal uses**.  
✅ **Better AI Classification** → Train a **custom CoreML model** with more plant images.  
✅ **Social Sharing** → Allow users to **share their plant progress**.  
✅ **AR Plant Care** → Use **ARKit** to visualize plant growth in real-time.  
✅ **More Interactive Gameplay** → Add **challenges & rewards** for plant care.  

---

## 📜 **Conclusion**  
🌱 **Planty** is a unique app that gamifies plant care using **AI, notifications, and interactive tracking**. By leveraging **SwiftUI, CoreML, and MapKit**, it offers a fun and educational experience for plant lovers. Whether you're a beginner or an expert, Planty will help you **discover, care for, and appreciate plants** in a new way.  

🚀 **Thank you for checking out Planty!** 🌿✨  

---

### **🔗 Connect With Me**  
- 📩 Email: [your_eng.noori6@hotmail.com](mailto:eng.noori6@hotmail.com)  
- 🔗 GitHub: [github.com/yourprofile](https://github.com/alnori6)  

---

**🌱 Happy Planting! 🌿**
