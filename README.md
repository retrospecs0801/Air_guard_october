# 🚀 Project README
### Team Name- yusufhabibyh4
#### Project Name- AirGuard
#### Problem Statement (P)- Lack of real-time, personalized awareness of individual pollution exposure inhighly polluted urban environments
#### Track- Open innovation ("build for bharat")
#### Team Members
Yusuf Habib – Backend Developer <br>
Anushka Srivastava – Research & Strategy Lead <br>
Saumya Verma – Frontend & Designing <br>
Mohd Adnan Khan – Testing & QA Lead <br>
## 🌍AirGuard  
*Real-Time Air Quality Monitoring & Alert System*
Even in the same city, people experience different pollution exposure. Someone who spends more time outdoors breathes far more polluted air than someone mostly indoors. <br>
*AirGuard tracks every outdoor session using geofencing and combines duration × live AQI to calculate each user’s personal exposure score.*<br>
This app helps users understand how much polluted air they personally breathe every day using live AQI data and geofencing.  
At the end of the day, the app also generates a personalized recovery plan (breathing + diet suggestions) using the Gemini API.

---
# link for testing  [https://jocular-taffy-92e528.netlify.app/]
## 📚Table of Contents  
- [Features](#features)
- [Tech Stack & Dependencies](#tech-stack--dependencies)  
- [Installation & Setup](#installation--setup)  
- [How the App Works](#how-the-app-works)  
- [Directory Structure](#Directory-Structure)

---


## 🧩Features

### *1. Real-Time AQI Tracking*
- Fetches live AQI from WAQI API  
- Shows current AQI and PM2.5 around the user  

### *2. Score factor*
- User sets home location  
- Geofence detects when user leaves/enters home

#### Dynamic Score Formula <br>
dartfinalExposureScore = baseScore * vulnerabilityMultiplier * protectionFactor <br>
where: <br>
baseScore = time_outside * AQI <br>
vulnerabilityMultiplier = 1.0 + (sum of negative factors) <br>
protectionFactor = 1.0 - (sum of positive factors) <br>

### *3. Daily Exposure Summary*
Displays:  
1. Today’s time outdoors  
2. Average AQI  
3. Total exposure score  

### *4. Auto generated recovery plan*
 1. Score 0–100 → Low (Simple breathing exercises (2–3 guided breathing rounds))<br>
 2. Score 101–250 → Moderate (Recovery: Hydration + light movement (1 hydration action + 2 light movements / stretches))<br>
 3. Score 251–400 → High (Mask + avoid exposure + diet + breathing (mask reminder, 2 dietary tips, 1 breathing + light indoor activity))<br>
 4. Score 400 → Critical (Doctor recommendation + immediate actions (call-to-action, emergency tips, reduce exposure now))<br>
 
### *4. Health Profile & Risk Personalization*
1. Users can declare asthma or other respiratory conditions.
2. Risk thresholds adjust based on individual vulnerability.
3. Alerts are personalized to exposure level and health status.
4. Provides tailored precautions and safer route suggestions.

### *5. Low-Pollution Route Optimization Map*
1. Interactive map with air quality heat zones across the city.
2. Shows both the normal route and a cleaner alternative.
3. Highlights the healthier path with a message like “40% less pollution exposure.

### *6. Future Exposure Simulation*
1. Exposure Prediction: Forecasts your upcoming pollution exposure based on recent trends and current lifestyle patterns.
2. Smart Simulation Mode: Lets you simulate how following recommended actions can reduce future exposure.
3. Visual Projection Graphs: Extends weekly and monthly analytics with predicted values shown distinctly for clarity.
4. Actionable Health Insights: Quantifies potential reduction (e.g., “Reduce exposure by 32%”) to encourage preventive decisions.
---
## 💻Tech Stack & Dependencies 

### Tech Stack
1. Flutter for framework<br>
2. Dart for Language

### Dependencies
geolocator – For live GPS tracking and geofencing<br>
WAQI API – For live AQI and PM2.5 data

---

## 📥Installation & Setup  
Download Flutter SDK<br>
Configure System Environment Variables<br>
Install Android studio<br>
Set up Android Studio for Flutter<br>
Accept Android Licenses / Configure SDK<br>
Verify Installation — Run flutter doctor<br>
Create a New Flutter Project<br>
and
### *1. Clone the repository*
bash
git clone [https://github.com/retrospecs0801/yusufhabibyh4_AirGuard]

cd air_guard


---

### *2. Install dependencies*
bash
flutter pub get


---
Set up your wireless device.<br>
and 
### *4. Run the application*
bash
flutter run


## 📱How the app works? 
(refer the video for detailed explaination)
1. Click on the set home buttton.
2. Walk about 15 m away from the location in order to get outside the preset home location
3. Session starts as you get out of the preset home location
4. Once you get back to the home location it will show the total exposure (which is equal to the time outside * AQI of the location.
5. Scroll down to see the recovery option click on it.
6. It shows the solutions to follow according to the level of exposure.
7. Click on the task to start your recovery sesssion.
8. Complete them.
9. YEAH!! you have countered your AQI exposure.

---


## 📁 Directory Structure
```
pollution-exposure-app/
├── lib/
│   ├── main.dart                              # App entry point with home screen
│   │
│   ├── services/
│   │   ├── location_service.dart              # GPS & geofencing logic
│   │   ├── storage_service.dart               # SharedPreferences wrapper
│   │   ├── exposure_service.dart              # Exposure time tracking
│   │   └── pollution_service.dart             # AQI API integration
│   │
│   ├── recovery/
│   │   ├── recovery_module.dart               # Entry point for recovery feature
│   │   ├── recovery_screen.dart               # Main recovery screen with tasks
│   │   │
│   │   ├── models/
│   │   │   ├── exposure_level.dart            # Exposure level definitions
│   │   │   └── recovery_task.dart             # Task data models
│   │   │
│   │   ├── services/
│   │   │   └── gemini_service.dart            # AI-powered insights
│   │   │
│   │   └── widgets/
│   │       ├── task_card.dart                 # Reusable task card widget
│   │       ├── guided_breathing.dart          # Basic breathing exercise
│   │       └── completion_screen.dart         # Success screen
│   │
│   ├── analytics/
│   │   ├── analytics_module.dart              # Entry point for analytics
│   │   ├── analytics_screen.dart              # Main analytics dashboard
│   │   │
│   │   ├── models/
│   │   │   └── exposure_data_point.dart       # Chart data model
│   │   │
│   │   ├── services/
│   │   │   ├── analytics_service.dart         # Data processing & calculations
│   │   │   └── chart_service.dart             # Chart data generation
│   │   │
│   │   └── widgets/
│   │       ├── exposure_chart.dart            # Line chart for exposure trends
│   │       ├── stats_card.dart                # Summary statistics card
│   │       └── time_range_selector.dart       # Week/Month/Year selector
│   │
│   └── community/
│       ├── community_screen.dart              # Forum main screen
│       │
│       ├── models/
│       │   ├── forum_post.dart                # Post data model
│       │   └── comment.dart                   # Comment data model
│       │
│       ├── services/
│       │   └── community_service.dart         # Mock forum data
│       │
│       └── widgets/
│           ├── post_card.dart                 # Individual post widget
│           ├── comment_card.dart              # Comment widget
│           └── create_post_dialog.dart        # New post form
│
├── android/                                   # Android-specific files
├── ios/                                       # iOS-specific files
├── web/                                       # Web-specific files
├── test/                                      # Unit & widget tests
│
├── pubspec.yaml                               # Dependencies & assets

```

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `main.dart` | Home screen with real-time exposure tracking & UI |
| `exposure_service.dart` | Core logic for inside/outside home detection |
| `pollution_service.dart` | Fetches AQI data from WAQI API |
| `recovery_module.dart` | AI-powered recovery plan with personalized tasks |
| `gemini_service.dart` | Google Gemini API integration for health insights |
| `analytics_module.dart` | Data visualization with charts & trends |
| `community_screen.dart` | User forum for sharing experiences |
| `guided_breathing.dart` | Interactive breathing exercise with timer |
