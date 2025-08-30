# PixaBeam — Supabase Assessment

**Submission date:** 2025-08-30

This bundle includes:
- **sql/schema_and_seed.sql** — full schema with constraints + sample data (10 users, 5 events, 20 RSVPs).
- **web/** — a minimal Next.js 14 (App Router) app using Supabase JS v2.
  - `/` — lists upcoming events
  - `/event/[id]` — RSVP page (Yes/No/Maybe)

## Part 1 — What was implemented

### Tables
- **users** (id, name, email, created_at)
- **events** (id, title, description, date, city, created_by → users.id, created_at)
- **rsvps** (id, user_id → users.id, event_id → events.id, status ∈ Yes/No/Maybe, created_at)

### Keys & Constraints
- `id` are **UUID** with `gen_random_uuid()`
- **PKs** on each table
- **FKs**
  - `events.created_by` → `users.id ON DELETE CASCADE`
  - `rsvps.user_id` → `users.id ON DELETE CASCADE`
  - `rsvps.event_id` → `events.id ON DELETE CASCADE`
- **Uniqueness**: one RSVP per user per event (`UNIQUE(user_id, event_id)`)
- **Checks**: title/name lengths; `status in ('Yes','No','Maybe')`
- **Indexes** on `events.date`, `rsvps.event_id`, `rsvps.user_id`

### Referential Integrity Choices
- Deleting a **user**:
  - Deletes their **events** (via `ON DELETE CASCADE`), which in turn deletes related **rsvps**.
  - Deletes their direct **rsvps** entries as well.
- Deleting an **event** deletes related **rsvps**.

> For production, you may prefer `ON DELETE SET NULL` on `events.created_by` to preserve events even if a user is removed. For this assessment, cascade demonstrates strong referential guarantees.

### How to Export Deliverables in Supabase
1. **Schema SQL dump**: open **SQL Editor** → run the script → click the **download** icon to export.
2. **Database screenshots**: **Table Editor** → each table → screenshot rows/structure.
3. **ER Diagram screenshot**: **Table Editor** → **ERD** tab → screenshot.

---

## Part 2 — Minimal App

### Prerequisites
- Node.js 18+
- A Supabase project (grab `Project URL` and `anon` key from **Project Settings → API**)

### Setup
```bash
cd web
npm i
cp .env.example .env.local
# fill NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY
npm run dev
```

Deploy on Vercel:
- Import the repo, set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` as **Environment Variables**, then **Deploy**.

### Notes
- RLS is **disabled** in this demo for simplicity. For production, enable RLS and add policies.
- "Pick a user" dropdown is provided to simulate auth for RSVPs.

---

## Screens you can capture
- `npm run dev` → take screenshots of the **Events list** and **RSVP page**.
- Supabase **ERD** & **Table Editor** as described above.