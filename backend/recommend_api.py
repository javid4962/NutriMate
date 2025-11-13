from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import os
import threading

app = FastAPI(title="NutriMate ML Recommendation API")

# -----------------------------------------------------------
# CORS
# -----------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------------------------------------
# Dataset Loading (Safe for Render)
# -----------------------------------------------------------

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_PATH = os.path.join(BASE_DIR, "data", "disease_food_recommendations_v2.csv")

df = None
_ready = False
_lock = threading.Lock()

def load_dataset():
    """Lazy-load the dataset without blocking app startup."""
    global df, _ready
    with _lock:
        if _ready:  # already loaded
            return

        try:
            if not os.path.exists(DATASET_PATH):
                raise FileNotFoundError(f"Dataset not found at: {DATASET_PATH}")

            print(f"📥 Loading dataset from: {DATASET_PATH}")
            df_local = pd.read_csv(DATASET_PATH)

            # Normalize & rename
            df_local.columns = df_local.columns.str.strip().str.lower()
            df_local.rename(
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

            df = df_local
            _ready = True
            print(f"✅ Dataset loaded: {len(df)} rows")
        except Exception as e:
            print(f"❌ Failed to load dataset: {e}")
            df = pd.DataFrame()
            _ready = False


@app.on_event("startup")
def on_startup():
    # Load the dataset in a background thread
    threading.Thread(target=load_dataset, daemon=True).start()


# -----------------------------------------------------------
# Health Check Endpoints
# -----------------------------------------------------------

@app.get("/health")
def health():
    """Basic health endpoint to confirm API is alive."""
    return {"status": "ok"}

@app.get("/ready")
def ready():
    """Check if dataset is fully loaded."""
    return {"dataset_ready": _ready}


# -----------------------------------------------------------
# API Endpoints
# -----------------------------------------------------------

@app.get("/")
def root():
    return {"message": "NutriMate ML Recommendation API is running 🚀"}


@app.get("/available_diseases")
def get_available_diseases():
    load_dataset()
    return sorted(df["disease"].dropna().unique().tolist())


@app.get("/available_diet_types")
def get_available_diet_types():
    load_dataset()
    return sorted(df["diet_type"].dropna().unique().tolist())


@app.get("/available_cuisines/{disease}")
def get_available_cuisines(disease: str):
    load_dataset()
    subset = df[df["disease"].str.lower() == disease.lower()]
    return sorted(subset["cuisine"].dropna().unique().tolist())


@app.post("/recommend")
def recommend(payload: dict):
    load_dataset()

    disease = payload.get("disease", "").strip().lower()
    meal_type = payload.get("meal_type", "").strip().lower()
    diet_type = payload.get("diet_type", "").strip().lower()
    cuisine = payload.get("cuisine", "").strip().lower()
    max_results = int(payload.get("max_results", 50))

    filtered = df.copy()

    if disease:
        filtered = filtered[filtered["disease"].str.lower() == disease]
    if meal_type:
        filtered = filtered[
            filtered["meal_type"].str.lower().str.contains(meal_type, na=False)
        ]
    if diet_type:
        filtered = filtered[
            filtered["diet_type"].str.lower().str.contains(diet_type, na=False)
        ]
    if cuisine:
        filtered = filtered[
            filtered["cuisine"].str.lower().str.contains(cuisine, na=False)
        ]

    if filtered.empty or not disease:
        filtered = df.head(max_results)

    results = filtered.head(max_results)

    response = []
    for _, row in results.iterrows():
        response.append({
            "disease": row["disease"],
            "meal_type": row.get("meal_type", ""),
            "food_name": row.get("food_name", ""),
            "diet_type": row.get("diet_type", ""),
            "cuisine": row.get("cuisine", ""),
            "calories": row.get("calories", 0),
            "protein": row.get("protein", 0),
            "carbs": row.get("carbs", 0),
            "fats": row.get("fats", 0),
            "ingredients": row.get("ingredients", ""),
            "preparation_steps": row.get("preparation_steps", ""),
            "health_notes": row.get("health_notes", ""),
            "image_url": "https://placehold.co/512x512?text=Food+Image",
        })

    return response
