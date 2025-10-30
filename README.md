## Date App API

Backend service for a dating-style recommendation app built with Laravel 12, JWT authentication, and Swagger documentation.

**Maintainer:** Nur Wahid Azhar  
**Email:** nur.wahid.azhar@gmail.com  
**Portfolio:** https://porto-ku.excitech.id/user?id=nur.wahid.azhar

### Features

- JWT-based authentication (register, login, logout, refresh, and profile lookup)
- People recommendations with pagination and reaction state (like/dislike)
- Liked-people listing for the authenticated user
- Reaction counters cached on the `people` table
- Hourly cronjob that emails an admin when a profile gathers more than 50 likes
- Complete OpenAPI 3 docs via L5 Swagger

### Requirements

- PHP 8.2+
- Composer
- Node 18+ (for asset pipeline, optional if you only hit APIs)
- A database supported by Laravel (MySQL, PostgreSQL, SQLite, etc.)

### Getting Started

1. Install dependencies:
   ```bash
   composer install
   npm install # optional, only if you need the Vite assets
   ```

2. Configure environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   php artisan jwt:secret
   ```
   Update database credentials and mail settings in `.env`. Set `ADMIN_EMAIL` (default `admin@example.com`) and optionally `POPULAR_PERSON_THRESHOLD`.

3. Run database migrations and seeders:
   ```bash
   php artisan migrate --seed
   ```
   Seeds include a dummy account `test@example.com` / `password` and 21 female profiles.

4. Serve the API:
   ```bash
   php artisan serve
   ```
   Base URL defaults to `http://127.0.0.1:8000`.

5. (Optional) Start background workers:
   - Queue: `php artisan queue:work` (mailer uses queued delivery)
   - Scheduler: either set up `* * * * * php artisan schedule:run` in cron or use `php artisan schedule:work`.

### API Documentation

Generate the OpenAPI spec and view Swagger UI:

```bash
php artisan l5-swagger:generate
php artisan serve
```

- Swagger UI: `http://127.0.0.1:8000/api/documentation`
- Raw JSON: `http://127.0.0.1:8000/api/documentation.json`

### Authentication Flow

1. `POST /api/auth/register` – create account, returns JWT
2. `POST /api/auth/login` – authenticate with email/password, returns JWT
3. `GET /api/auth/me` – fetch current user (Bearer token required)
4. `POST /api/auth/logout` – invalidate current token
5. `POST /api/auth/refresh` – refresh token before expiry

Include `Authorization: Bearer <token>` on protected routes.

### People & Reactions

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| GET | `/api/people` | Paginated recommended people |
| GET | `/api/people/liked` | Paginated liked people for current user |
| POST | `/api/people/{id}/like` | Like a person |
| POST | `/api/people/{id}/dislike` | Dislike a person |

Responses use the `PersonResource` payload documented in Swagger.

### Cronjob & Notifications

The command `notify:popular-people` runs hourly (configured in `bootstrap/app.php`) and:

- Finds people with `likes_count >= POPULAR_PERSON_THRESHOLD`
- Sends `App\Mail\PersonHitThreshold` to `ADMIN_EMAIL`
- Sets `notified_at` to avoid duplicate messages

To trigger manually:

```bash
php artisan notify:popular-people
```

### Testing

```bash
php artisan test
```

Configure a testing database in `.env.testing` if needed.
