#!/usr/bin/env python3
"""
ML Data Preparation Script for NutriMate Food Recommendations

This script processes your CSV dataset and prepares it for machine learning.
Run this script to create the processed data files needed for the Flutter app.

Requirements:
pip install pandas numpy scikit-learn

Usage:
python prepare_ml_data.py
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder, StandardScaler
import json
import os

def main():
    print("🍽️ NutriMate ML Data Preparation")
    print("=" * 50)

    # Load your CSV data
    csv_path = "assets/data/disease_food_recommendations_v2.csv"

    if not os.path.exists(csv_path):
        print(f"❌ CSV file not found at {csv_path}")
        print("Please ensure your CSV file is in the assets/data/ directory")
        return

    print(f"📂 Loading data from {csv_path}...")
    df = pd.read_csv(csv_path, engine='python')
    print(f"✅ Loaded {len(df)} food recommendations")

    # Display basic info
    print("\n📊 Dataset Overview:")
    print(f"   Diseases: {df['Disease'].nunique()}")
    print(f"   Meal Types: {df['MealType'].nunique()}")
    print(f"   Diet Types: {df['DietType'].nunique()}")
    print(f"   Cuisines: {df['Cuisine'].nunique()}")

    # Encode categorical features
    print("\n🔄 Encoding categorical features...")

    le_disease = LabelEncoder()
    le_mealtype = LabelEncoder()
    le_diettype = LabelEncoder()
    le_cuisine = LabelEncoder()

    df['disease_encoded'] = le_disease.fit_transform(df['Disease'])
    df['mealtype_encoded'] = le_mealtype.fit_transform(df['MealType'])
    df['diettype_encoded'] = le_diettype.fit_transform(df['DietType'])
    df['cuisine_encoded'] = le_cuisine.fit_transform(df['Cuisine'])

    # Normalize numerical features
    print("📏 Normalizing numerical features...")
    scaler = StandardScaler()
    df[['calories_scaled', 'protein_scaled', 'carbs_scaled', 'fats_scaled']] = scaler.fit_transform(
        df[['Calories', 'Protein (g)', 'Carbs (g)', 'Fats (g)']]
    )

    # Create feature vector for similarity calculation
    features = df[['disease_encoded', 'mealtype_encoded', 'diettype_encoded',
                   'cuisine_encoded', 'calories_scaled', 'protein_scaled',
                   'carbs_scaled', 'fats_scaled']].values

    # Calculate similarity matrix per disease group
    print("🧮 Calculating food similarities per disease...")
    from sklearn.metrics.pairwise import cosine_similarity

    # Compute global similarity matrix for sample check
    similarity_matrix = cosine_similarity(features)

    similarity_dict = {}
    for disease in df['Disease'].unique():
        disease_df = df[df['Disease'] == disease]
        disease_indices = disease_df.index.tolist()

        if len(disease_indices) < 2:
            # If only one food for this disease, no similarities
            for idx in disease_indices:
                similarity_dict[str(idx)] = []
            continue

        # Features for this disease group (exclude disease_encoded)
        disease_features = disease_df[['mealtype_encoded', 'diettype_encoded', 'cuisine_encoded',
                                       'calories_scaled', 'protein_scaled', 'carbs_scaled', 'fats_scaled']].values

        # Compute similarity within the group
        disease_similarity = cosine_similarity(disease_features)

        # For each food in the group, find top similar (excluding self)
        for local_idx, global_idx in enumerate(disease_indices):
            # Get top 10 similar items (excluding self)
            similar_local = np.argsort(disease_similarity[local_idx])[-11:-1][::-1]
            similar_global = [disease_indices[local] for local in similar_local]
            similarity_dict[str(global_idx)] = similar_global

    # Save processed data
    print("💾 Saving processed data...")

    # Save similarity matrix
    with open('assets/data/similarity_matrix.json', 'w') as f:
        json.dump(similarity_dict, f, indent=2)

    # Save processed foods with encodings
    df.to_csv('assets/data/processed_foods.csv', index=False)

    # Save feature matrix
    np.save('assets/data/food_features.npy', features)

    # Save encoders for future use
    np.save('assets/data/label_encoders.npy', {
        'disease': le_disease.classes_,
        'mealtype': le_mealtype.classes_,
        'diettype': le_diettype.classes_,
        'cuisine': le_cuisine.classes_,
    })

    print("\n✅ Data preparation complete!")
    print("\n📁 Generated files:")
    print("   • assets/data/similarity_matrix.json")
    print("   • assets/data/processed_foods.csv")
    print("   • assets/data/food_features.npy")
    print("   • assets/data/label_encoders.npy")

    print("\n🎯 Next steps:")
    print("   1. Add these files to your Flutter assets in pubspec.yaml")
    print("   2. Update your ML service to use the similarity matrix")
    print("   3. Test the recommendations in your app!")

    # Show sample recommendations
    print("\n🔍 Sample similarity check:")
    sample_food = df.iloc[0]
    similar_indices = similarity_dict['0'][:3]

    print(f"   Food: {sample_food['FoodName']}")
    print("   Similar foods:")
    for idx in similar_indices:
        similar_food = df.iloc[idx]
        similarity_score = similarity_matrix[0][idx]
        print(f"     - {similar_food['FoodName']}: {similarity_score:.3f}")

if __name__ == "__main__":
    main()
