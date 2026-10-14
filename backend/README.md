# Field Notes — Backend (Spring Boot + MySQL)

## Run
1. Start **MySQL** in XAMPP Control Panel (port 3306, user `root`, no password).
2. Optional: create DB (auto-created anyway):
   ```sql
   CREATE DATABASE IF NOT EXISTS fieldnotes;
   ```
3. Run:
   ```powershell
   cd backend
   ./mvnw spring-boot:run
   ```
   API at `http://localhost:8080`.

## Auth
- `POST /api/auth/register` → `{ name, email, password }` → `{ token, userId, name, email }`
- `POST /api/auth/login` → `{ email, password }` → `{ token, ... }`
- All other endpoints need header: `Authorization: Bearer <token>`

## APIs
- Customers: `GET/POST /api/customers`, `GET/PUT/DELETE /api/customers/{id}`
- Sites: `GET /api/sites?customerId=1`, `POST /api/sites` `{name, address, customerId}`, `GET/PUT/DELETE /api/sites/{id}`
- Notes: `GET /api/notes?siteId=&status=&q=` (search title/desc/site/customer + filter), `POST /api/notes` `{siteId, title, description, location, dateTime, status}`, `GET/PUT/DELETE /api/notes/{id}`

## Design notes (for viva)
- Relations: User 1—N Customer 1—N Site 1—N FieldNote; every row has `user_id` for data isolation.
- Sites/Notes responses include related names via **JOIN FETCH** (no duplicated customer/site data).
- Note search uses one JPQL query with JOINs across note→site→customer.
- Passwords hashed with BCrypt; JWT (jjwt 0.12.6) stateless auth.
