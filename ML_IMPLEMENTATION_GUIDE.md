# ML-Based Food Recommendation System - Implementation Guide

## Overview

This guide will help you implement a Machine Learning-based food recommendation system for your NutriMate app using Firebase ML Kit and TensorFlow Lite.

## Current Status

✅ You have a CSV dataset with 5000+ food recommendations
✅ Dataset includes: Disease, MealType, FoodName, DietType, Cuisine, Nutrition Info, Ingredients, etc.

## Implementation Approach

Since you mentioned you don't have ML knowledge, we'll use a **hybrid approach**:

1. **Rule-based filtering** (Simple, no ML needed initially)
2. **Content-based filtering** (Simple ML using TFLite)
3. **Collaborative filtering** (Advanced, optional)

---

## Phase 1: Rule-Based Recommendation (No ML Required)

### What it does:

- Filters foods based on user's disease
- Considers meal type (breakfast, lunch, dinner, snacks)
- Filters by diet preference (vegan, vegetarian, non-veg, pescatarian)
- Sorts by nutritional requirements

### Advantages:

- ✅ No ML training needed
- ✅ Fast and reliable
- ✅ Easy to understand and debug
- ✅ Works offline
- ✅ Perfect for your current dataset

### Implementation:

See `lib/services/ml_recommendation_service.dart`

---

## Phase 2: Content-Based ML Recommendation (Simple ML)

### What it does:

- Uses food features (calories, protein, carbs, fats, cuisine, ingredients)
- Calculates similarity between foods
- Recommends similar foods to what user likes
- Learns from user preferences

### Dataset Preparation:

#### 1. Feature Engineering

Convert your CSV data into numerical features:

```python
# features.py
import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder, StandardScaler

# Load your CSV
df = pd.read_csv('disease_food_recommendations_v2.csv')

# Encode categorical features
le_disease = LabelEncoder()
le_mealtype = LabelEncoder()
le_diettype = LabelEncoder()
le_cuisine = LabelEncoder()

df['disease_encoded'] = le_disease.fit_transform(df['Disease'])
df['mealtype_encoded'] = le_mealtype.fit_transform(df['MealType'])
df['diettype_encoded'] = le_diettype.fit_transform(df['DietType'])
df['cuisine_encoded'] = le_cuisine.fit_transform(df['Cuisine'])

# Normalize numerical features
scaler = StandardScaler()
df[['calories_scaled', 'protein_scaled', 'carbs_scaled', 'fats_scaled']] = scaler.fit_transform(
    df[['Calories', 'Protein (g)', 'Carbs (g)', 'Fats (g)']]
)

# Create feature vector
features = df[['disease_encoded', 'mealtype_encoded', 'diettype_encoded',
               'cuisine_encoded', 'calories_scaled', 'protein_scaled',
               'carbs_scaled', 'fats_scaled']].values

# Save for model training
np.save('food_features.npy', features)
df.to_csv('processed_foods.csv', index=False)
```

#### 2. Simple Similarity Model (No Training Needed!)

```python
# similarity_calculator.py
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import json

# Load features
features = np.load('food_features.npy')

# Calculate similarity matrix
similarity_matrix = cosine_similarity(features)

# Save as JSON for Flutter
similarity_dict = {}
for i in range(len(similarity_matrix)):
    # Get top 10 similar items
    similar_indices = np.argsort(similarity_matrix[i])[-11:-1][::-1]
    similarity_dict[str(i)] = similar_indices.tolist()

with open('similarity_matrix.json', 'w') as f:
    json.dump(similarity_dict, f)
```

---

## Phase 3: TensorFlow Lite Model (Advanced ML)

### Option A: Recommendation Model

```python
# train_model.py
import tensorflow as tf
import pandas as pd
import numpy as np

# Load processed data
df = pd.read_csv('processed_foods.csv')
features = np.load('food_features.npy')

# Create a simple neural network
model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, activation='relu', input_shape=(8,)),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(len(features), activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# For demonstration - you'd need actual user interaction data
# This creates synthetic training data
X_train = features
y_train = np.random.randint(0, len(features), len(features))

model.fit(X_train, y_train, epochs=10, batch_size=32, validation_split=0.2)

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save model
with open('food_recommendation_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

### Option B: Classification Model (Simpler)

```python
# train_classifier.py
import tensorflow as tf
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

df = pd.read_csv('processed_foods.csv')

# Features: nutrition + encoded categories
X = df[['calories_scaled', 'protein_scaled', 'carbs_scaled', 'fats_scaled',
        'diettype_encoded', 'cuisine_encoded']].values

# Target: disease category
y = df['disease_encoded'].values

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Simple classifier
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(6,)),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(len(np.unique(y)), activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

model.fit(X_train, y_train, epochs=20, batch_size=32, validation_data=(X_test, y_test))

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('disease_classifier.tflite', 'wb') as f:
    f.write(tflite_model)
```

---

## Firebase ML Kit Integration

### 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  # Existing dependencies...

  # ML Kit
  google_ml_kit: ^0.18.0
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1

  # For CSV processing
  csv: ^6.0.0
```

### 2. Add TFLite Model to Assets

```yaml
flutter:
  assets:
    - assets/ml/food_recommendation_model.tflite
    - assets/ml/similarity_matrix.json
    - assets/data/disease_food_recommendations_v2.csv
    - assets/data/processed_foods.csv
```

---

## Recommended Approach for You

### 🎯 Start with Phase 1 (Rule-Based)

**Why?**

- No ML training required
- Works with your existing CSV data
- Fast implementation
- Easy to understand and maintain
- Provides good results for your use case

### 📊 Your Dataset is Perfect For:

1. **Multi-criteria filtering**

   - Disease type
   - Meal type
   - Diet preference
   - Cuisine preference
   - Nutritional requirements

2. **Scoring system**
   - Calculate match score based on user profile
   - Rank foods by relevance
   - Personalize based on preferences

### 🚀 Future Enhancement (Phase 2)

Once you have user interaction data:

- Track which foods users order
- Track ratings/favorites
- Use this data to train a proper ML model
- Implement collaborative filtering

---

## Step-by-Step Implementation Plan

### Week 1: Data Preparation

1. ✅ CSV file ready (You have this!)
2. Create data loader service
3. Parse CSV in Flutter
4. Store in local database (SQLite) or Firestore

### Week 2: Rule-Based System

1. Implement filtering logic
2. Create scoring algorithm
3. Add personalization based on user profile
4. Test with different disease types

### Week 3: UI Integration

1. Display recommendations
2. Add filters (meal type, cuisine, diet)
3. Implement search functionality
4. Add favorites/ratings

### Week 4: Analytics & Improvement

1. Track user interactions
2. Collect feedback
3. Refine recommendation logic
4. Prepare for ML model training

---

## Data Collection for Future ML

To train a proper ML model later, collect:

```dart
class UserInteraction {
  String userId;
  String foodId;
  String disease;
  String mealType;
  DateTime timestamp;

  // Interaction types
  bool viewed;
  bool ordered;
  bool favorited;
  int? rating; // 1-5 stars

  // Context
  String timeOfDay;
  String dayOfWeek;
}
```

Store in Firestore:

```
users/{userId}/interactions/{interactionId}
```

---

## Cost Considerations

### Rule-Based (Phase 1)

- **Cost**: FREE
- **Complexity**: Low
- **Maintenance**: Easy

### TFLite Model (Phase 2)

- **Training**: One-time (can use Google Colab FREE)
- **Inference**: FREE (runs on device)
- **Model size**: ~1-5 MB

### Firebase ML Kit

- **Custom models**: FREE (up to 1000 downloads/month)
- **AutoML**: Paid (but not needed for your case)

---

## Tools You'll Need

### For ML Model Training (Optional - Phase 3)

1. **Google Colab** (FREE)

   - No installation needed
   - Free GPU access
   - Perfect for beginners

2. **Python Libraries**

   ```bash
   pip install tensorflow pandas numpy scikit-learn
   ```

3. **Dataset Tools**
   - Excel/Google Sheets for data cleaning
   - Python for preprocessing

---

## Next Steps

1. **Immediate**: Implement rule-based system (I'll provide code)
2. **Short-term**: Collect user interaction data
3. **Long-term**: Train ML model with real user data

Would you like me to:

1. ✅ Create the rule-based recommendation service?
2. ✅ Create CSV parser for your dataset?
3. ✅ Create the UI components for recommendations?
4. Create Python scripts for ML model training?

Let me know which parts you'd like me to implement first!
