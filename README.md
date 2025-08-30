# PixaBeam Events — Next.js + Supabase (Minimal)

## Quickstart
```bash
npm i
cp .env.example .env.local  # fill URL + anon key
npm run dev
```

## Pages
- `/` — Lists upcoming events (date >= now).
- `/event/[id]` — RSVP form (Yes/No/Maybe) with "Pick a user" dropdown (simulated auth).