# Deploy Guide — Field Notes (Render backend + Vercel frontend, all free)

## 0) Push to GitHub first
Render + Vercel both deploy from a GitHub repo.
```powershell
cd 'C:\Users\nahid\OneDrive\Desktop\JobHunter\Field Notes'
git init
git add backend app
git commit -m "Field Notes: backend + flutter app"
# create a repo on github.com, then:
git remote add origin https://github.com/<you>/fieldnotes.git
git push -u origin main
```
Keep `backend/` and `app/` as two folders in ONE repo (monorepo).

---

## 1) Backend on Render (free) + Postgres (free)

1. **Create Postgres (free):**
   - https://dashboard.render.com → New → **PostgreSQL** → Free plan → Create.
   - Open it → copy the **External Database URL**, looks like:
     `postgresql://user:pass@host:5432/dbname`
   - Convert to PostgreSQL JDBC form (credentials in query params):
     `jdbc:postgresql://host:5432/dbname?user=user&password=pass&sslmode=require`

2. **Create Web Service:**
   - New → **Web Service** → select your repo.
   - Settings:
     - **Root Directory:** `backend`
     - **Runtime:** Docker (auto-detected from `backend/Dockerfile`)
     - **Plan:** Free
     - **Health check path:** `/api/health`
   - **Environment variables:**
     | Key | Value |
     |---|---|
     | `JDBC_DATABASE_URL` | the jdbc url from step 1 |
     | `JWT_SECRET` | any long random string (32+ chars) |
     | `CORS_ALLOWED_ORIGINS` | `https://<your-vercel-app>.vercel.app` (after step 2, come back and set exact URL) |
     | `DDL_AUTO` | `update` |
   - Deploy. Wait until Live. Note your URL: `https://fieldnotes-api-xxxx.onrender.com`
   - Test: `https://<your-api>.onrender.com/api/health` → `{"status":"UP",...}`
   - ⚠️ Free Render sleeps after inactivity — first request can take ~50s (cold start). Normal.

3. **Seed a demo user (optional, from your PC):**
```powershell
Invoke-RestMethod -Method Post -Uri 'https://<your-api>.onrender.com/api/auth/register' `
  -ContentType 'application/json' `
  -Body '{"name":"Demo","email":"demo@test.com","password":"demo123"}'
```

## 2) Frontend (Flutter Web) on Vercel (free)

1. Create a Vercel project for this repo and set its **Root Directory** to `app`.
   The GitHub Action deploys through the Vercel CLI, so it builds Flutter on
   GitHub Actions rather than relying on Flutter being installed on Vercel.
   Disable Vercel's automatic Git deployments for this project to avoid
   duplicate deployments.
2. In the Vercel project settings, find the project's **Project ID** and the
   owning **Team/Account ID** (Organization ID). Create a Vercel access token.
3. In the GitHub repository, add these under **Settings → Secrets and variables
   → Actions → Repository secrets**:

   | Secret | Value |
   |---|---|
   | `API_BASE_URL` | `https://<your-api>.onrender.com` |
   | `VERCEL_TOKEN` | The Vercel access token |
   | `VERCEL_ORG_ID` | The Vercel Team/Account ID |
   | `VERCEL_PROJECT_ID` | The Vercel project ID |

4. Push a change under `app/` or `.github/workflows/vercel-web.yml` to `main`
   or `master`, or run **Build and Deploy Flutter Web** manually from the
   GitHub Actions tab. The workflow analyzes and tests the app, builds Flutter
   web with the API URL, and deploys it to Vercel.
5. After the first successful deployment, open the Vercel URL and set
   Render's `CORS_ALLOWED_ORIGINS` to that exact URL, then redeploy the backend.

## 3) After both are live
- Open the Vercel URL → Register (online) → create customer/site/note.
- Backend data lands in Render Postgres (check Render → Postgres → Tables).
- Mobile (APK) still works against either backend: change `API_BASE_URL`
  dart-define or `lib/core/config.dart` default.

## Files added for deployment
- `backend/Dockerfile` — multi-stage Java 25 build, honors `$PORT`.
- `backend/render.yaml` — one-click Render blueprint (rootDir backend).
- `backend/.dockerignore`
- `backend/src/.../HealthController.java` — `/api/health` for Render checks.
- `backend/src/.../CorsConfig.java` — allows the Vercel origin.
- `backend/src/main/resources/application.properties` — env-var driven
  (local MySQL still the default; Render Postgres via `JDBC_DATABASE_URL`).
- `app/vercel.json` and `app/.vercelignore` — deploy the Flutter web output as static files.
- `app/lib/core/config.dart` — `--dart-define=API_BASE_URL` support.
- `.github/workflows/vercel-web.yml` — CI builds and deploys Flutter web to Vercel.
