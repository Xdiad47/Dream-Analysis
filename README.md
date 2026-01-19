# 🌙 Dream Analysis AI

An AI-powered mobile application that analyzes dreams and provides personalized interpretations using advanced Natural Language Processing and Retrieval-Augmented Generation.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white)
![LangChain](https://img.shields.io/badge/LangChain-121212?style=flat&logo=chainlink&logoColor=white)

## ✨ Features

- 📝 **Dream Journaling** - Record and save your dreams with timestamps, mood tags, and themes
- 🤖 **AI-Powered Analysis** - Get intelligent dream interpretations using LangChain and RAG
- 🧠 **Psychology-Backed** - Insights based on cognitive behavioral therapy and dream research
- 📊 **Pattern Recognition** - Identify recurring themes, symbols, and emotions in your dreams
- 🔒 **Secure & Private** - Your dreams are stored securely with Firebase and user-isolated data
- 🌐 **Offline Support** - Local caching with sync when online
- 📱 **Cross-Platform** - Native experience on Android and iOS
- 🎨 **Dark Mode** - Optimized night-themed UI for comfortable late-night journaling

## 🏗️ Architecture

### Mobile App (Flutter)

- **Architecture**: MVVM (Model-View-ViewModel) pattern for separation of concerns
- **State Management**: Provider/Riverpod for reactive UI updates
- **Navigation**: Navigator 2.0 / go_router for structured routing
- **Storage**: 
  - Cloud: Firebase Firestore for dream entries and metadata
  - Local: Hive/shared_preferences for offline cache and preferences
- **UI Framework**: Material Design 3 with custom theming
- **REST Integration**: Dio/HTTP client for backend communication

### Backend (Python/FastAPI)

- **Framework**: FastAPI with async endpoints
- **NLP Processing**: NLTK for text preprocessing and sentiment analysis
- **AI Integration**: 
  - LangChain for orchestration
  - Groq API as LLM reasoning engine
  - ChromaDB as vector store for RAG
- **Knowledge Base**: Curated dream symbols and psychology research
- **Deployment**: Railway/Render with HTTPS
- **Database**: Optional PostgreSQL for analytics and logs

## 🛠️ Tech Stack

### Mobile App
- Flutter/Dart
- Firebase Authentication
- Firebase Firestore
- Hive (local storage)
- Provider/Riverpod (state management)
- Dio (HTTP client)

### Backend
- Python 3.9+
- FastAPI
- LangChain
- Groq API (LLM)
- NLTK (Natural Language Processing)
- ChromaDB (Vector Database)
- Uvicorn/Gunicorn (ASGI server)

## 🚀 Getting Started

### Prerequisites

```bash
# Flutter SDK (3.0+)
flutter --version

# Python (3.9+)
python --version

# Firebase CLI (optional, for setup)
firebase --version
```

---

## 📱 Mobile App Setup (Flutter)

### Step 1: Clone the Repository

```bash
git clone https://github.com/Xdiad47/dream-analysis-ai.git
cd dream-analysis-ai
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1. **Create a Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add Android and/or iOS apps

2. **Download Configuration Files:**
   - **Android:** Download `google-services.json` → Place in `android/app/`
   - **iOS:** Download `GoogleService-Info.plist` → Place in `ios/Runner/`

3. **Enable Firebase Services:**
   - **Authentication:** Enable Email/Password sign-in
   - **Firestore Database:** Create database in production mode
   - **Security Rules:** Set up rules for user data isolation

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/dreams/{dreamId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

### Step 4: Configure API Base URL

Create/update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with your deployed backend URL
  static const String baseUrl = 'https://your-backend-url.onrender.com';

  // API endpoints
  static const String interpretEndpoint = '/interpret';
  static const String patternsEndpoint = '/patterns';
  static const String healthEndpoint = '/health';
}
```

### Step 5: Run the App

```bash
# Check for issues
flutter doctor

# Run on device/emulator
flutter run
```

---

## 🐍 Backend Setup (FastAPI + LangChain)

### Step 1: Navigate to Backend Directory

```bash
cd backend
```

### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

**Example `requirements.txt`:**

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
langchain==0.1.0
langchain-groq==0.0.1
chromadb==0.4.18
nltk==3.8.1
pydantic==2.5.0
python-dotenv==1.0.0
requests==2.31.0
python-multipart==0.0.6
```

### Step 4: Download NLTK Data

Run in Python shell (first time only):

```python
import nltk
nltk.download('punkt')
nltk.download('wordnet')
nltk.download('vader_lexicon')
nltk.download('stopwords')
```

### Step 5: Configure Environment Variables

Create `.env` file in backend directory:

```env
# Groq API Configuration
GROQ_API_KEY=your_groq_api_key_here

# ChromaDB Configuration
CHROMA_DB_DIR=./chroma_storage

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:*,https://your-frontend-domain.com

# Optional: Database
DATABASE_URL=postgresql://user:password@localhost:5432/dreams

# Server Configuration
HOST=0.0.0.0
PORT=8000
```

**Get Groq API Key:**
1. Go to [Groq Console](https://console.groq.com/)
2. Sign up and create an API key
3. Copy and paste into `.env`

### Step 6: Initialize Vector Database

Create a script to populate ChromaDB with dream symbols:

```bash
python scripts/init_knowledge_base.py
```

### Step 7: Run the Backend

```bash
# Development mode with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production mode
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Step 8: Test the API

**Health Check:**
```bash
curl http://localhost:8000/health
```

**Interpret Dream:**
```bash
curl -X POST http://localhost:8000/interpret \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-user-123",
    "dream_text": "I was flying over a city at night, feeling free and powerful.",
    "mood": "excited",
    "tags": ["flying", "freedom", "night"]
  }'
```

---

## 📡 API Documentation

### Endpoint: Interpret Dream

**POST** `/interpret`

**Request Body:**
```json
{
  "user_id": "firebase-uid",
  "dream_text": "I was lost in a dark forest chasing a shadow.",
  "mood": "anxious",
  "tags": ["fear", "uncertainty"],
  "intensity": 7
}
```

**Response:**
```json
{
  "interpretation": {
    "summary": "You described a dream about being lost and pursuing something unclear.",
    "themes": ["uncertainty", "search for direction", "inner conflict"],
    "psychological_insight": "Dreams of being lost in dark places often relate to feeling unsure about life decisions or overwhelmed by current challenges.",
    "suggested_reflection": "Consider journaling about areas of your life where you feel directionless or pressured to make decisions.",
    "symbols": {
      "forest": "The unconscious mind, hidden emotions",
      "shadow": "Aspects of yourself you're avoiding or not acknowledging",
      "darkness": "Uncertainty, fear of the unknown"
    }
  },
  "confidence": 0.82,
  "processing_time_ms": 1234
}
```

### Endpoint: Pattern Analysis

**POST** `/patterns`

**Request Body:**
```json
{
  "user_id": "firebase-uid",
  "dream_ids": ["dream1", "dream2", "dream3"]
}
```

**Response:**
```json
{
  "recurring_themes": ["uncertainty", "water", "running"],
  "emotion_trends": {
    "anxiety": 65,
    "excitement": 20,
    "sadness": 15
  },
  "common_symbols": ["ocean", "flying", "falling"],
  "insights": "Your dreams show a pattern of..."
}
```

---

---

## 🎯 How It Works

### Dream Interpretation Flow

1. **User Input:** User writes dream in Flutter app
2. **Local Processing:** Basic metadata extraction (word count, sentiment)
3. **API Request:** Dream sent to FastAPI backend
4. **NLP Processing:** NLTK extracts entities, themes, emotions
5. **RAG Query:** ChromaDB retrieves relevant dream psychology context
6. **LLM Generation:** Groq API generates personalized interpretation
7. **Response:** Structured interpretation returned to app
8. **Storage:** Dream and interpretation saved to Firestore

### RAG (Retrieval-Augmented Generation)

The backend uses RAG to enhance interpretations:

1. **Knowledge Base:** Curated dream symbols, psychological research, example interpretations
2. **Vector Store:** ChromaDB indexes knowledge with embeddings
3. **Query:** User's dream is embedded and similar documents retrieved
4. **Context Injection:** Retrieved knowledge is injected into LLM prompt
5. **Generation:** LLM produces contextually-aware interpretation

---

## 🔒 Security & Privacy

- **Authentication:** Firebase Auth with secure token validation
- **Data Isolation:** Firestore security rules ensure users only access their own dreams
- **API Security:** Backend validates Firebase tokens for authenticated requests
- **Environment Variables:** Sensitive keys stored in `.env`, never committed
- **HTTPS:** All API communication over secure connections
- **Data Anonymization:** Optional research mode strips personally identifiable info

---

## 🚧 Roadmap & Future Enhancements

- [ ] In-app onboarding tutorial
- [ ] Advanced analytics dashboard (emotion trends, sleep quality correlation)
- [ ] Export dream journal as PDF
- [ ] Multi-language support for non-English dreams
- [ ] Voice recording for dream entry
- [ ] Widget for quick dream logging
- [ ] Dream sharing with privacy controls
- [ ] Integration with sleep tracking apps (Apple Health, Google Fit)
- [ ] Community features (anonymous dream sharing, discussions)
- [ ] Premium features (unlimited interpretations, advanced analytics)

---

## 🐛 Troubleshooting

### Issue: Backend not connecting from Flutter app

**Solution:**
1. Check `api_config.dart` has correct backend URL
2. Ensure backend is running: `curl http://your-backend-url/health`
3. Check CORS settings in backend `.env`
4. Verify no firewall blocking the connection

### Issue: "NLTK data not found"

**Solution:**
```python
import nltk
nltk.download('all')  # Downloads all NLTK data
```

### Issue: ChromaDB initialization fails

**Solution:**
1. Delete existing `chroma_storage/` directory
2. Run `python scripts/init_knowledge_base.py` again
3. Check write permissions on storage directory

### Issue: Groq API rate limit

**Solution:**
1. Check your API key quota at [Groq Console](https://console.groq.com/)
2. Implement request throttling in Flutter app
3. Consider upgrading Groq plan for higher limits

---

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [LangChain Documentation](https://python.langchain.com/)
- [Groq API Documentation](https://console.groq.com/docs)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Xdiad47/dream-analysis-ai/issues).

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Diadem Nath**

Senior Mobile App Developer | Flutter & Backend Integration Specialist

5+ years of experience building production-ready mobile applications with Flutter, native Android/iOS, and AI-powered features. Passionate about combining psychology, data science, and user experience to create meaningful tools.

- 🌐 GitHub: [@Xdiad47](https://github.com/Xdiad47)
- 💼 LinkedIn: [Diadem Nath](https://www.linkedin.com/in/diadem-nath-a5396152/)
- 📧 Email: [mail2diadem@gmail.com](mailto:mail2diadem@gmail.com)
- 💻 Portfolio: [More Projects](https://github.com/Xdiad47?tab=repositories)

---

## 🙏 Acknowledgments

- Flutter and Dart teams for the incredible framework
- FastAPI for the blazing-fast Python web framework
- LangChain for RAG orchestration
- Groq for powerful LLM API
- Firebase for backend infrastructure
- Dream psychology research community
- Open-source contributors

---

## ⭐ Show Your Support

If you found this project helpful or interesting, please consider giving it a star! It helps others discover the project and motivates continued development.

---

**Built with ❤️ using Flutter, FastAPI, LangChain, and AI**

*Dream Analysis AI - Unlock the Hidden Meanings in Your Dreams*
