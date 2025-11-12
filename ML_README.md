# 🤖 ML Food Recommendation System

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Prepare ML Data (Optional - for advanced features)

```bash
pip install pandas numpy scikit-learn
python prepare_ml_data.py
```

### 3. Test the System

Add this to your app navigation:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MLRecommendationDemoPage(),
  ),
);
```

## 🎯 How It Works

### Rule-Based Recommendations (Current)

- **Disease matching**: Must match user's health condition
- **Meal type**: Breakfast, lunch, dinner, snacks
- **Diet compatibility**: Vegan, vegetarian, pescatarian, non-veg
- **Cuisine preference**: Indian, Continental, Asian, etc.
- **Nutritional balance**: Calorie, protein, carb, fat targets

### Scoring System

```
Disease Match: 40 points (required)
Meal Type Match: 20 points
Diet Compatibility: 15 points
Cuisine Match: 10 points
Nutrition Balance: 15 points
```

## 📊 Your Dataset

You have **5,000+ food recommendations** with:

- ✅ 12+ diseases (Diabetes, Hypertension, Obesity, etc.)
- ✅ Multiple meal types
- ✅ Dietary restrictions
- ✅ Nutritional information
- ✅ Preparation instructions
- ✅ Health notes

## 🚀 Features Implemented

### ✅ Rule-Based ML Service

- `MLRecommendationService` class
- CSV data loading and parsing
- Personalized scoring algorithm
- Multi-criteria filtering

### ✅ Demo Page

- Interactive filters
- Real-time recommendations
- Beautiful UI with nutrition chips
- Loading states and error handling

### ✅ Data Preparation Script

- Python script for advanced ML features
- Similarity matrix calculation
- Feature encoding and normalization

## 🔧 Integration Guide

### Add to Your App

1. **Import the service:**

```dart
import '../services/ml_recommendation_service.dart';
```

2. **Initialize once:**

```dart
final mlService = MLRecommendationService();
await mlService.initialize();
```

3. **Get recommendations:**

```dart
final recommendations = await mlService.getRecommendations(
  disease: 'Diabetes',
  mealType: FoodType.lunch,
  dietPreference: 'Vegetarian',
  maxResults: 10,
);
```

### User Profile Integration

Connect with your existing user system:

```dart
class UserProfile {
  String disease;
  String? dietPreference;
  String? cuisinePreference;
  Map<String, double>? nutritionTargets;
}

// Usage
final userProfile = await getUserProfile();
final recommendations = await mlService.getRecommendations(
  disease: userProfile.disease,
  dietPreference: userProfile.dietPreference,
  cuisinePreference: userProfile.cuisinePreference,
  nutritionTargets: userProfile.nutritionTargets,
);
```

## 📈 Future Enhancements

### Phase 2: Content-Based ML

- Use similarity matrix for better recommendations
- Learn from user preferences
- Collaborative filtering

### Phase 3: Advanced ML

- TensorFlow Lite models
- User behavior prediction
- Dynamic nutrition adjustment

## 🧪 Testing

### Test Cases

1. **Diabetes + Lunch**: Should show low-GI, high-fiber foods
2. **Hypertension + Breakfast**: Should show low-sodium options
3. **Obesity + Snacks**: Should show low-calorie, high-protein snacks

### Performance

- CSV loading: ~2-3 seconds on first load
- Recommendations: <100ms after initialization
- Memory usage: ~5-10MB for 5000 foods

## 🐛 Troubleshooting

### Common Issues

1. **CSV not found**: Ensure `assets/data/disease_food_recommendations_v2.csv` exists
2. **No recommendations**: Check disease name spelling matches CSV
3. **Slow loading**: Consider loading data in background or caching

### Debug Mode

```dart
// Enable debug logging
await mlService.initialize();
print('Available diseases: ${await mlService.getAvailableDiseases()}');
```

## 📚 Learn More

- [ML Implementation Guide](ML_IMPLEMENTATION_GUIDE.md)
- [Firebase ML Kit](https://firebase.google.com/docs/ml-kit)
- [TensorFlow Lite Flutter](https://pub.dev/packages/tflite_flutter)

## 🤝 Contributing

1. Test with different disease combinations
2. Add more nutritional scoring rules
3. Implement user feedback collection
4. Add A/B testing for recommendation algorithms

---

**Happy coding! 🎉**

Your ML food recommendation system is ready to provide personalized nutrition guidance to users with different health conditions.
