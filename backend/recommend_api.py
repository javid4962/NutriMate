from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import os

# from openai import OpenAI   # ⛔ Commented out since we're skipping image generation

# client = OpenAI(api_key="YOUR_API_KEY")  # ⛔ Commented out

app = FastAPI(title="NutriMate ML Recommendation API")

# -----------------------------------------------------------
# ✅ CORS setup
# -----------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # use specific origins later for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------------------------------------
# ✅ Load dataset
# -----------------------------------------------------------
DATASET_PATH = "backend/data/disease_food_recommendations_v2.csv"


if not os.path.exists(DATASET_PATH):
    raise FileNotFoundError(f"Dataset not found: {DATASET_PATH}")

df = pd.read_csv(DATASET_PATH)
print(f"✅ Loaded dataset: {len(df)} rows, columns: {list(df.columns)}")

# Normalize columns for consistency
df.columns = df.columns.str.strip()
df.columns = df.columns.str.lower()

# Rename columns if necessary
df.rename(
    columns={
        "disease": "disease",
        "mealtype": "meal_type",
        "foodname": "food_name",
        "diettype": "diet_type",
        "cuisine": "cuisine",
        "calories": "calories",
        "protein (g)": "protein",
        "carbs (g)": "carbs",
        "fats (g)": "fats",
        "ingredients": "ingredients",
        "preparationsteps": "preparation_steps",
        "healthnotes": "health_notes",
    },
    inplace=True,
)

print(f"✅ Normalized columns: {list(df.columns)}")

# -----------------------------------------------------------
# ✅ Endpoints
# -----------------------------------------------------------

@app.get("/")
def root():
    return {"message": "NutriMate ML Recommendation API is running 🚀"}


@app.get("/available_diseases")
def get_available_diseases():
    diseases = sorted(df["disease"].dropna().unique().tolist())
    return diseases


@app.get("/available_diet_types")
def get_available_diet_types():
    diet_types = sorted(df["diet_type"].dropna().unique().tolist())
    return diet_types


@app.get("/available_cuisines/{disease}")
def get_available_cuisines(disease: str):
    subset = df[df["disease"].str.lower() == disease.lower()]
    cuisines = sorted(subset["cuisine"].dropna().unique().tolist())
    return cuisines


@app.post("/recommend")
def recommend(payload: dict):
    """
    Returns food recommendations based on filters.
    If no 'disease' is provided, returns all food items (default: 50).
    """
    disease = payload.get("disease", "").strip().lower()
    meal_type = payload.get("meal_type", "").strip().lower()
    diet_type = payload.get("diet_type", "").strip().lower()
    cuisine = payload.get("cuisine", "").strip().lower()
    max_results = int(payload.get("max_results", 50))

    # Copy original dataset
    filtered = df.copy()

    # Apply filters only if provided
    if disease:
        filtered = filtered[filtered["disease"].str.lower() == disease]
    if meal_type:
        filtered = filtered[filtered["meal_type"].str.lower().str.contains(meal_type, na=False)]
    if diet_type:
        filtered = filtered[filtered["diet_type"].str.lower().str.contains(diet_type, na=False)]
    if cuisine:
        filtered = filtered[filtered["cuisine"].str.lower().str.contains(cuisine, na=False)]

    # If no filters match or all empty → fallback to all food items
    if filtered.empty or not disease:
        filtered = df.head(max_results)

    results = filtered.head(max_results)
    response = []

    for _, row in results.iterrows():
        food_name = row.get("food_name", "")
        cuisine_type = row.get("cuisine", "")
        diet_type = row.get("diet_type", "")

        # ✅ Placeholder image (no OpenAI call)
        image_url = "https://placehold.co/512x512?text=Food+Image"

        response.append({
            "disease": row.get("disease", ""),
            "meal_type": row.get("meal_type", ""),
            "food_name": food_name,
            "diet_type": diet_type,
            "cuisine": cuisine_type,
            "calories": row.get("calories", 0),
            "protein": row.get("protein", 0),
            "carbs": row.get("carbs", 0),
            "fats": row.get("fats", 0),
            "ingredients": row.get("ingredients", ""),
            "preparation_steps": row.get("preparation_steps", ""),
            "health_notes": row.get("health_notes", ""),
            "image_url": image_url,
        })

    return response
