# 🦋 Emowall AI 2.0
### *Your Family's Silent Guardian*

> Built from Dubai 🇦🇪 · Powered by Seven Brains 🧠 · Made for Kerala 🌿

[![Flutter](https://img.shields.io/badge/Flutter-3.27.0-02569B?logo=flutter)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.0.12-00E676)](https://github.com/Emobies05/Emobies-AP-135)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen?logo=android)](https://play.google.com)
[![License](https://img.shields.io/badge/License-MIT-FF5500)](LICENSE)
[![Closed Testing](https://img.shields.io/badge/Play%20Store-Closed%20Testing-blue?logo=googleplay)](https://play.google.com/apps/testing/com.emobies.emowall)

---

## 🛡️ What is Emowall?

Emowall AI 2.0 is the world's first **multi-generational AI safety platform** — one app that protects your entire family.

Built entirely on a phone 📱 using Termux + Acode, deployed from Dubai to the world.

---

## 📱 Eight Screens, One App

| Mode | For | Features |
|------|-----|----------|
| 🛡️ **Guardian Mode** | Children & Women | SOS, Safe Zone, Sound Detection |
| ⚔️ **Shield Mode** | Men, Elderly, College | Ragging Detection, Fall Detection, Evidence Recorder |
| ♿ **Care Mode** | Blind, Deaf, Speech-impaired | Voice alerts, Vibration SOS, LED flash |
| 🗣️ **Guardian AI** | Elder Care | Voice-activated emergency response |
| 👩‍👶 **Digital Amma** | Babies & Mothers | Baby cry detection, Lullabies AI |
| 👨‍⚕️ **Child Doctor AI** | Children | Mental health, mood tracking, therapy |
| ♀️ **Women's Health** | Women | Gentle health companion AI |
| 🔍 **Media Verifier** | Everyone | AI-powered image & video authentication |

---

## 🆕 What's New in v1.0.12

- ✅ **Media Verifier** — Brand new AI forensics feature powered by Gemini Vision
  - Detects REAL / EDITED / AI_GENERATED media
  - Supports images (gallery + camera) and videos
  - Forensic confidence score + detailed analysis
  - Built-in 10MB file size guard
- ✅ **API Key Security** — Gemini key now secured via `dart-define` (no hardcoded secrets)
- ✅ **Women's Health AI** — Import path fixed, fully stable
- ✅ **Build pipeline** — All CI/CD errors resolved

---

## 🧠 Seven Brains, One Guardian

Emowall AI 2.0 uses a multi-AI architecture where each AI has a specific role.

### 🧠 Brain 1 — Claude (Anthropic)
**Role: Chief Architect & Code Engineer**
- Full codebase understanding (Flutter, Node.js, Dart)
- Creates complete files (main.dart, pubspec.yaml, screens)
- Deep reasoning for complex features
- Security review and bug fixing
- Used for: Feature building, file creation, architecture decisions

---

### 🧠 Brain 2 — Gemini (Google)
**Role: In-App AI Assistant & Vision Intelligence**
- Powers the Emowall chatbot inside Emobies app
- Malayalam + English voice understanding
- Baby cry detection and child emotion analysis
- **Media Verifier forensics** (image/video authentication)
- Used for: Real-time in-app AI responses, voice features, media analysis

---

### 🧠 Brain 3 — ChatGPT (OpenAI)
**Role: Content & Communication Strategist**
- App store descriptions and marketing copy
- Privacy policy and legal text drafting
- Used for: Content creation, user communication

---

### 🧠 Brain 4 — Cursor AI
**Role: IDE-Level Code Refactor Engine**
- Real-time code completion inside editor
- Auto-fix linting errors and warnings
- Used for: Day-to-day coding assistance, live editing

---

### 🧠 Brain 5 — GitHub Copilot
**Role: Commit-Level Code Guardian (Ralph)**
- Runs flutter test on every push
- Detects broken imports and missing dependencies
- Used for: CI/CD health, test coverage, code consistency

---

### 🧠 Brain 6 — DeepSeek
**Role: Logic & Algorithm Specialist**
- Complex algorithm design (ragging detection logic)
- Mathematical models (health tracking formulas)
- Used for: Heavy computation, detection algorithms

---

### 🧠 Brain 7 — Perplexity AI
**Role: Research & Real-Time Intelligence**
- Latest Flutter/Android updates research
- Find best packages and libraries
- Used for: Research, package selection, staying updated

---

## 🤝 How They Work Together

```
Human (Dwin) → defines product goals
      ↓
Claude → builds architecture + full files
      ↓
Cursor/Copilot → refines code in editor + CI
      ↓
Gemini → powers live AI features in app
      ↓
DeepSeek → optimizes complex algorithms
      ↓
ChatGPT → writes user-facing content
      ↓
Play Store → Users 🌍
```

---

## 🚀 Build & Deploy

```bash
# Clone repo
git clone -b Emowall-Ai-2.0 https://github.com/Emobies05/Emobies-AP-135.git

# Install dependencies
flutter pub get

# Build AAB (with secure API key injection)
flutter build appbundle --release \
  --dart-define=GEMINI_API_KEY=$YOUR_GEMINI_KEY
```

### GitHub Actions (Auto Build)
Every push to `Emowall-Ai-2.0` branch triggers automatic AAB build via `.github/workflows/flutter.yml`

```yaml
- run: flutter build appbundle --release \
    --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}
```

---

## 📦 Tech Stack

```
Frontend:    Flutter 3.27.0 (Dart)
AI:          Gemini API (Google) — Chat + Vision
Backend:     Node.js + Express (Railway)
Build:       GitHub Actions
Store:       Google Play Console
Fonts:       Syne + JetBrains Mono + Space Grotesk
```

---

## 🔐 Key Dependencies

```yaml
flutter_tts: ^4.0.2          # Voice alerts
speech_to_text: ^7.0.0       # Voice commands
sensors_plus: ^5.0.0         # Fall/accident detection
flutter_local_notifications  # SOS alerts
flutter_sound: ^9.2.13       # Audio recording
google_fonts: ^6.2.1         # Typography
permission_handler: ^11.0.0  # Device permissions
image_picker: ^1.0.0         # Media Verifier image/video input
http: ^1.0.0                 # Gemini API calls
```

---

## 🛡️ Guardrails (All AIs Must Follow)

- Never hardcode API keys or secrets — use `dart-define` + GitHub Secrets
- Keep dark neo-crypto aesthetic (`#07080B`, `#00E5FF`, `#7C3AED`)
- Never remove ButterflyLogo or core screens
- Always keep Malayalam + English support
- Prioritize user safety above all features

---

## 🗺️ Roadmap

| Version | Status | Highlights |
|---------|--------|------------|
| 1.0.10 | ✅ Released | Core 7 screens |
| 1.0.11 | ✅ Closed Testing | Women's Health AI stable |
| 1.0.12 | 🔄 Uploading | Media Verifier, API security |
| 1.1.0 | 🔜 Planned | Subscription model, multi-language |
| Production | 🎯 ~Mar 22 | 14-day closed test complete |

---

## 📄 Privacy Policy

[https://emobies05.github.io/public-/emowall-privacy-policy.html](https://emobies05.github.io/public-/emowall-privacy-policy.html)

---

## 🦋 Vision

> *"No single AI is perfect. But seven AIs working together —*
> *that's Emowall. The world's most intelligent safety platform."*

**Emowall AI 2.0 — Built by Dwin from Dubai 🇦🇪, Powered by Seven Brains 🧠✨**

---

*Package: `com.emobies.emowall` · Version: `1.0.12 (112)` · Min SDK: 24*
