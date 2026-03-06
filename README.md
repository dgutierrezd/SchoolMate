# SchoolMate AI

AI-powered academic co-pilot for parents. Track homework, generate flashcards, and chat with an AI that knows each child's academic profile.

## Tech Stack

- **iOS**: SwiftUI, iOS 17+, Swift 5.9+
- **Backend**: Node.js + TypeScript, Express.js
- **Database**: PostgreSQL via Supabase
- **AI**: OpenAI GPT-4o (chat), Anthropic Claude (flashcards)
- **Auth**: Supabase Auth (Email, Apple Sign In)
- **Push**: Firebase Cloud Messaging

## Getting Started

### Backend

```bash
cd backend
npm install
cp .env.example .env
# Fill in .env with your API keys
npm run dev
```

### iOS

1. Open Xcode and create a new project (iOS App, SwiftUI)
2. Set bundle ID to `com.yourname.schoolmateai`
3. Add all Swift files from `iOS/SchoolMateAI/` to the project
4. Add Supabase Swift SDK via SPM: `https://github.com/supabase/supabase-swift`
5. Enable capabilities: Sign in with Apple, Push Notifications
6. Update `Config` in `SchoolMateAIApp.swift` with your URLs
7. Build and run on simulator or device

### Database

Run `database/schema.sql` in your Supabase SQL editor to create all tables and RLS policies.

## Project Structure

```
SchoolMateAI/
├── iOS/SchoolMateAI/     # SwiftUI iOS app
│   ├── App/              # App entry point, delegate
│   ├── Core/             # Auth, navigation, theme
│   ├── Features/         # Dashboard, homework, flashcards, AI chat, settings
│   ├── Models/           # Data models
│   ├── Services/         # API client and service layer
│   ├── Localization/     # en/es strings
│   └── Resources/        # Info.plist, assets
├── backend/              # Node.js API
│   └── src/
│       ├── routes/       # API endpoints
│       ├── services/     # AI services (OpenAI, Claude)
│       ├── middleware/   # Auth, rate limiting
│       └── config/       # Supabase config
└── database/             # SQL schema
```

## Environment Variables

See `backend/.env.example` for required configuration.
