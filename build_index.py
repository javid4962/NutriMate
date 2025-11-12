# build_index.py
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.neighbors import NearestNeighbors
import joblib
import os
from scipy.sparse import hstack, csr_matrix

# ==== CONFIG ====
CSV_PATH = "data/disease_food_recommendations_v2.csv"  # update if path differs
ARTIFACT_DIR = "artifacts"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

# ==== LOAD & CLEAN DATA ====
df = pd.read_csv(CSV_PATH).fillna("")
print(f"Loaded {len(df)} rows from CSV.")

# Standardize column names
df.columns = [c.strip() for c in df.columns]
df.rename(columns={
    "Disease": "disease",
    "MealType": "meal_type",
    "FoodName": "food_name",
    "DietType": "diet_type",
    "Cuisine": "cuisine",
    "Calories": "calories",
    "Protein (g)": "protein",
    "Carbs (g)": "carbs",
    "Fats (g)": "fats",
    "Ingredients": "ingredients",
    "PreparationSteps": "preparation_steps",
    "HealthNotes": "health_notes",
}, inplace=True)

# ==== TEXT FEATURES ====
df['meta_text'] = (
    df['food_name'].astype(str) + " " +
    df['ingredients'].astype(str) + " " +
    df['health_notes'].astype(str)
)

tfidf = TfidfVectorizer(max_features=4000, ngram_range=(1, 2))
X_text = tfidf.fit_transform(df['meta_text'])
print("TF-IDF features:", X_text.shape)

# ==== CATEGORICAL FEATURES ====
cat_cols = ['disease', 'meal_type', 'diet_type', 'cuisine']

# ✅ Use sparse_output instead of sparse
ohe = OneHotEncoder(handle_unknown='ignore', sparse_output=True)
X_cat = ohe.fit_transform(df[cat_cols])
print("OneHot features:", X_cat.shape)


# ==== NUMERIC FEATURES ====
num_cols = ['calories', 'protein', 'carbs', 'fats']
df[num_cols] = df[num_cols].apply(pd.to_numeric, errors='coerce').fillna(0.0)
scaler = StandardScaler()
X_num = scaler.fit_transform(df[num_cols])
X_num_sparse = csr_matrix(X_num)
print("Numeric features:", X_num_sparse.shape)

# ==== COMBINE FEATURES ====
X = hstack([X_text, X_cat, X_num_sparse], format='csr')
print("Final feature matrix:", X.shape)

# ==== BUILD NEAREST NEIGHBORS INDEX ====
nn = NearestNeighbors(n_neighbors=50, metric='cosine', algorithm='brute')
nn.fit(X)

# ==== SAVE ARTIFACTS ====
joblib.dump(tfidf, os.path.join(ARTIFACT_DIR, "tfidf.joblib"))
joblib.dump(ohe, os.path.join(ARTIFACT_DIR, "ohe.joblib"))
joblib.dump(scaler, os.path.join(ARTIFACT_DIR, "scaler.joblib"))
joblib.dump(nn, os.path.join(ARTIFACT_DIR, "nn.joblib"))
df.to_pickle(os.path.join(ARTIFACT_DIR, "foods_df.pkl"))

print(f"✅ Index built and saved to '{ARTIFACT_DIR}/'")
