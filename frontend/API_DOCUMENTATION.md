# Expense Tracker API Documentation

Backend API for the Expense Tracker application, built with **Django 4.2** + **Django REST Framework 3.14**.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Base URL](#2-base-url)
3. [Authentication](#3-authentication)
4. [Conventions](#4-conventions)
5. [Error Responses](#5-error-responses)
6. [Endpoints](#6-endpoints)
   - [Version](#61-version)
   - [Authentication](#62-authentication)
   - [Users](#63-users)
   - [Categories](#64-categories)
   - [Accounts](#65-accounts)
   - [Transactions](#66-transactions)
   - [Dashboard](#67-dashboard)
7. [Data Models](#7-data-models)
8. [Non-API Routes](#8-non-api-routes)

---

## 1. Overview

| Item | Value |
|---|---|
| Framework | Django 4.2.7, djangorestframework 3.14.0 |
| Auth | Token Authentication (also Session Authentication for browsable API) |
| Database (local) | SQLite (`db.sqlite3`) |
| Pagination | `PageNumberPagination`, page size = **10** |
| Filters | `django-filter`, `SearchFilter`, `OrderingFilter` |
| CORS | Allow all origins (local dev) |
| API version | `2021.06.11.1` (from `core/version.py`); live deployment reports `2024.01.11.06.04` |

---

## 2. Base URL

| Environment | Base URL |
|---|---|
| **Production** | `https://api.dev.projectscranton.com` |
| Local (dev) | `http://127.0.0.1:8000` (endpoints under `/api/`) |

URLs in this document use the **production** host. In production the API is served at the **domain root** (no `/api/` prefix); in local development it is mounted under `/api/`.

Base URL:
```
https://api.dev.projectscranton.com
```

Examples:
- `https://api.dev.projectscranton.com/auth/signin/`
- `https://api.dev.projectscranton.com/transactions/`
- `https://api.dev.projectscranton.com/dashboard/`

> **Live verification (checked [2026-09-22]):** `GET /version/` returns `"2024.01.11.06.04"` — this differs from this repository's `core/version.py` (`2021.06.11.1`), so the deployed build may be ahead of or divergent from this codebase. The root `/` requires authentication (`401 {"detail":"Authentication credentials were not provided."}`), and the `/api/` prefix currently returns `404` on the live host.

---

## 3. Authentication

This API uses **Token Authentication**. Most endpoints require an authenticated user.

Send the token in the HTTP request header:

```
Authorization: Token <your-token-here>
```

Get a token via:

- `POST /api/auth/signup/`
- `POST /api/auth/signin/`
- `POST /api/token/` (DRF default token endpoint)

Logging out deletes the token, so it becomes invalid immediately.

### Scoping

Every resource (categories, accounts, transactions) and profile data is **scoped to the authenticated user**. You can only read/modify your own records.

### Endpoint Access Matrix

| Endpoint | Auth Required |
|---|---|
| `GET /api/version/` | No |
| `POST /api/auth/signup/` | No |
| `POST /api/auth/signin/` | No |
| `POST /api/auth/logout/` | Yes |
| `POST /api/token/` | No |
| All other endpoints | Yes |

---

## 4. Conventions

### Formats

| Item | Format | Example |
|---|---|---|
| Date | `YYYY-MM-DD` | `2026-09-22` |
| Datetime | `YYYY-MM-DDTHH:MM:SS` | `2026-09-22T14:30:00` |
| Decimal amounts | string/number, 2 dp, max 15 digits | `1234.56` |
| Media files (receipts) | relative path under `/media/` | `/media/receipts/receipt.png` |

### Pagination

List endpoints (`GET /api/<resource>/`) are paginated (page size = 10) using query parameter `?page=<n>`:

```json
{
  "count": 42,
  "next": "https://api.dev.projectscranton.com/transactions/?page=2",
  "previous": null,
  "results": [ ... ]
}
```

> Endpoints documented as "array response" below return a **paginated wrapper** when hit via the standard list route; some custom actions return a plain array (noted per endpoint).

### Common Query Parameters (List Endpoints)

| Param | Description | Example |
|---|---|---|
| `page` | Page number | `?page=2` |
| `search` | Free-text search across registered search fields | `?search=groceries` |
| `ordering` | Sort order, prefix `-` for descending | `?ordering=-amount` |

Allowed `ordering` fields are listed per resource below.

---

## 5. Error Responses

### Validation Error — `400 Bad Request`

Field-level errors returned as a dictionary of field → list of messages:

```json
{
  "title": ["This field is required."],
  "password": ["Ensure this field has at least 8 characters."]
}
```

### Authentication Error — `401 Unauthorized`

Missing/invalid token or invalid credentials:

```json
{
  "error": "Invalid credentials"
}
```

Or DRF default:

```json
{
  "detail": "Authentication credentials were not provided."
}
```

### Not Found — `404 Not Found`

```json
{
  "error": "Account not found"
}
```

### Permission Denied — `403 Forbidden`

Returned when an authenticated user accesses another user's resource.

---

## 6. Endpoints

---

### 6.1 Version

#### `GET /api/version/`

Returns the current API version string. **No authentication required.**

**Request:** none

**Response — `200 OK`:**

```json
"2024.01.11.06.04"
```

> This repository's `core/version.py` defines `2021.06.11.1`; the live production host currently reports `2024.01.11.06.04` (verified 2026-09-22).

---

### 6.2 Authentication

#### `POST /api/auth/signup/`

Register a new user and receive an auth token. **No authentication required.**

**Request Body:**

| Field | Type | Required | Rules |
|---|---|---|---|
| `name` | string | Yes | max 200 chars |
| `email` | string | Yes | valid email, max 200 chars, must be unique |
| `password` | string | Yes | write-only, min 8 chars |

**Response — `201 Created`:**

```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Error — `400 Bad Request`:**

```json
{
  "email": ["user with this email already exists."],
  "password": ["Ensure this field has at least 8 characters."]
}
```

---

#### `POST /api/auth/signin/`

Log in with email + password and receive an auth token. **No authentication required.**

**Request Body:**

| Field | Type | Required |
|---|---|---|
| `email` | string | Yes |
| `password` | string | Yes |

**Response — `200 OK`:**

```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Errors:**

| Status | Body |
|---|---|
| `400` | `{"error": "Please provide both email and password"}` |
| `401` | `{"error": "Invalid credentials"}` |

---

#### `POST /api/auth/logout/`

Delete the caller's auth token. **Auth required.**

**Request:** none (token via header)

**Response — `200 OK`:**

```json
{
  "message": "Successfully logged out"
}
```

---

#### `POST /api/token/`

DRF built-in token endpoint. **No authentication required.**

**Request Body:**

| Field | Type | Required | Notes |
|---|---|---|---|
| `username` | string | Yes | Use the **email** (custom user `USERNAME_FIELD`) |
| `password` | string | Yes | |

**Response — `200 OK`:**

```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

**Error — `400 Bad Request`:**

```json
{
  "non_field_errors": ["Unable to log in with provided credentials."]
}
```

---

### 6.3 Users

Authenticated users can only access **their own** profile (`queryset` filtered to `request.user`).

| | |
|---|---|
| Base path | `/api/users/` |
| Auth | Required |
| Search fields | `name`, `email` |
| Ordering fields | `name`, `email` |

#### `GET /api/users/` — List

Uses `UserListSerializer` (`id`, `name`, `email`).

**Query params:** `page`, `search`, `ordering`

**Response — `200 OK`:**

```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}
```

---

#### `POST /api/users/` — Create

**Request Body:**

| Field | Type | Required |
|---|---|---|
| `name` | string | Yes |
| `email` | string | Yes |
| `password` | string | Yes (min 8) |

**Response — `201 Created`:**

```json
{
  "id": 2,
  "name": "John Doe",
  "email": "john@example.com"
}
```

> `password` is write-only and never returned.

---

#### `GET /api/users/{id}/` — Retrieve

**Response — `200 OK`:**

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Error — `404 Not Found`** if `id` is not the caller.

---

#### `PUT /api/users/{id}/` / `PATCH /api/users/{id}/` — Update

**Request Body (all optional on PATCH):**

| Field | Type | Notes |
|---|---|---|
| `name` | string | |
| `email` | string | |
| `password` | string | min 8; hashed via `set_password` |

**Response — `200 OK`:** updated user object (no password).

---

#### `DELETE /api/users/{id}/` — Delete

**Response — `204 No Content`**

---

### 6.4 Categories

User-scoped categories (unique title per user).

| | |
|---|---|
| Base path | `/api/categories/` |
| Auth | Required |
| Search fields | `title` |
| Ordering fields | `title` |

#### `GET /api/categories/` — List

Uses `CategoryListSerializer` (`id`, `title`). Paginated.

**Response — `200 OK`:**

```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    { "id": 1, "title": "Food" },
    { "id": 2, "title": "Transport" }
  ]
}
```

---

#### `POST /api/categories/` — Create

**Request Body:**

| Field | Type | Required |
|---|---|---|
| `title` | string | Yes (max 200, unique per user) |

**Response — `201 Created`:**

```json
{
  "id": 1,
  "title": "Food",
  "user": 1
}
```

**Error — `400`:**

```json
{
  "title": ["A category with this title already exists."]
}
```

---

#### `GET /api/categories/{id}/` — Retrieve

```json
{
  "id": 1,
  "title": "Food",
  "user": 1
}
```

---

#### `PUT /api/categories/{id}/` / `PATCH /api/categories/{id}/` — Update

Same body as create. **Response — `200 OK`:** updated object.

---

#### `DELETE /api/categories/{id}/` — Delete

**Response — `204 No Content`**

---

#### `GET /api/categories/with_stats/` — Categories with Statistics

Returns a **plain array** (not paginated) of categories with transaction totals, sorted by `total_amount` descending.

**Query params:**

| Param | Type | Default | Values |
|---|---|---|---|
| `period` | string | `month` | `today`, `week`, `month`, `year`, or any other value for all-time |

**Response — `200 OK`:**

```json
[
  {
    "id": 1,
    "title": "Food",
    "total_amount": "250.00",
    "transaction_count": 12
  },
  {
    "id": 2,
    "title": "Transport",
    "total_amount": "80.00",
    "transaction_count": 5
  }
]
```

---

#### `GET /api/categories/{id}/transactions/` — Transactions for a Category

Returns a plain array of transactions for that category, ordered by `-date`.

**Response — `200 OK`:**

```json
[
  {
    "id": 10,
    "title": "Groceries",
    "amount": "45.50",
    "transaction_type": "expense",
    "category": { "id": 1, "title": "Food" },
    "account": { "id": 1, "title": "Checking" },
    "date": "2026-09-20",
    "notes": "Weekly shopping",
    "receipt": null,
    "tags": "groceries,weekly",
    "created_at": "2026-09-20T18:30:00"
  }
]
```

**Error — `404`:** `{"error": "Category not found"}`

---

### 6.5 Accounts

User-scoped accounts (unique title per user). Balance is computed dynamically.

| | |
|---|---|
| Base path | `/api/accounts/` |
| Auth | Required |
| Search fields | `title` |
| Ordering fields | `title`, `initial` |

#### `GET /api/accounts/` — List

Uses `AccountListSerializer`. Paginated.

**Response — `200 OK`:**

```json
{
  "count": 2,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "Checking",
      "initial": "1000.00",
      "current_balance": "1450.00",
      "user": 1
    }
  ]
}
```

---

#### `POST /api/accounts/` — Create

**Request Body:**

| Field | Type | Required |
|---|---|---|
| `title` | string | Yes (max 200, unique per user) |
| `initial` | number | No (default `0.00`, decimal ≤15.2) |

**Response — `201 Created`:**

```json
{
  "id": 1,
  "title": "Checking",
  "initial": "1000.00",
  "user": 1,
  "current_balance": "1000.00"
}
```

**Error — `400`:** `{"title": ["An account with this title already exists."]}`

---

#### `GET /api/accounts/{id}/` — Retrieve

```json
{
  "id": 1,
  "title": "Checking",
  "initial": "1000.00",
  "user": 1,
  "current_balance": "1450.00"
}
```

---

#### `PUT /api/accounts/{id}/` / `PATCH /api/accounts/{id}/` — Update

Same body as create. **Response — `200 OK`:** updated object.

---

#### `DELETE /api/accounts/{id}/` — Delete

**Response — `204 No Content`**

---

#### `GET /api/accounts/with_balance/` — All Accounts with Balance

Plain array using `AccountListSerializer` (identical shape to list results).

**Response — `200 OK`:**

```json
[
  {
    "id": 1,
    "title": "Checking",
    "initial": "1000.00",
    "current_balance": "1450.00",
    "user": 1
  }
]
```

---

#### `GET /api/accounts/summary/` — Account Summary

**Response — `200 OK`:**

```json
{
  "total_accounts": 2,
  "total_initial_balance": "3000.00",
  "total_current_balance": "3450.00",
  "total_change": "450.00",
  "accounts": [
    {
      "id": 1,
      "title": "Checking",
      "initial": "1000.00",
      "current_balance": "1450.00",
      "user": 1
    }
  ]
}
```

| Field | Description |
|---|---|
| `total_initial_balance` | Sum of all `initial` values |
| `total_current_balance` | Sum of computed `current_balance` |
| `total_change` | `total_current_balance - total_initial_balance` |

---

#### `GET /api/accounts/{id}/transactions/` — Transactions for an Account

Plain array of that account's transactions, ordered by `-date` (same transaction shape as [6.4](#get-apicategoriesidtransactions--transactions-for-a-category)).

**Error — `404`:** `{"error": "Account not found"}`

---

#### `GET /api/accounts/{id}/balance_history/` — Balance History

Running balance per transaction over a period.

**Query params:**

| Param | Type | Default | Values |
|---|---|---|---|
| `period` | string | `month` | `week` (7d), `month` (30d), `year` (365d) |

**Response — `200 OK`:**

```json
{
  "account": {
    "id": 1,
    "title": "Checking",
    "initial": "1000.00",
    "current_balance": "1450.00",
    "user": 1
  },
  "initial_balance": "1000.00",
  "current_balance": "1450.00",
  "balance_history": [
    {
      "date": "2026-09-15",
      "balance": "1200.00",
      "transaction": {
        "id": 5,
        "title": "Salary",
        "amount": "200.00",
        "type": "income"
      }
    },
    {
      "date": "2026-09-18",
      "balance": "1150.00",
      "transaction": {
        "id": 7,
        "title": "Groceries",
        "amount": "50.00",
        "type": "expense"
      }
    }
  ]
}
```

- `balance` is the running balance **after** that transaction (starts from `initial`).
- Income adds, expense subtracts.

**Error — `404`:** `{"error": "Account not found"}`

---

### 6.6 Transactions

User-scoped income/expense records.

| | |
|---|---|
| Base path | `/api/transactions/` |
| Auth | Required |
| Search fields | `title`, `notes`, `tags` |
| Ordering fields | `title`, `amount`, `date`, `created_at`, `transaction_type`, `category`, `account` |
| Default ordering | `-created_at` |

#### `GET /api/transactions/` — List

Uses `TransactionListSerializer` (category/account nested as `{id, title}`). Paginated.

**Response — `200 OK`:**

```json
{
  "count": 25,
  "next": "https://api.dev.projectscranton.com/transactions/?page=2",
  "previous": null,
  "results": [
    {
      "id": 10,
      "title": "Groceries",
      "amount": "45.50",
      "transaction_type": "expense",
      "category": { "id": 1, "title": "Food" },
      "account": { "id": 1, "title": "Checking" },
      "date": "2026-09-20",
      "notes": "Weekly shopping",
      "receipt": null,
      "tags": "groceries,weekly",
      "created_at": "2026-09-20T18:30:00"
    }
  ]
}
```

**Full filter/query parameter reference (list & filters below):**

| Param | Type | Description |
|---|---|---|
| `title` | string | `title`, `title_icontains`, `title_istartswith`, `title_iendswith` |
| `notes` | string | `notes`, `notes_icontains`, `notes_istartswith` |
| `amount` | number | `amount`, `amount_gte`, `amount_lte`, `amount_gt`, `amount_lt` |
| `date` | date | `date`, `date_gte`, `date_lte`, `date_gt`, `date_lt` |
| `created_at` | datetime | `created_at`, `created_at_gte`, `created_at_lte`, `created_at_gt`, `created_at_lt` |
| `transaction_type` | string | `income` \| `expense` |
| `category` | int | Category ID |
| `account` | int | Account ID |
| `created_from` | datetime | `created_at >= value` |
| `created_to` | datetime | `created_at <= value` |
| `created_exact` | datetime | `created_at = value` |
| `created_after` | datetime | `created_at > value` |
| `created_before` | datetime | `created_at < value` |
| `date_from` | date | `date >= value` |
| `date_to` | date | `date <= value` |
| `date_exact` | date | `date = value` |
| `date_after` | date | `date > value` |
| `date_before` | date | `date < value` |
| `period` | string | Preset range on `created_at`: `today`, `yesterday`, `week`, `last_week`, `month`, `last_month`, `quarter`, `year`, `last_year`, `last_7_days`, `last_30_days`, `last_90_days` |
| `day` | int | Day of month 1–31 (`created_at`) |
| `month` | int | Month 1–12 (`created_at`) |
| `year` | int | Year ≥ 1900 (`created_at`) |
| `weekday` | int | Day of week 0=Mon … 6=Sun (`created_at`) |
| `amount_min` | number | `amount >=` |
| `amount_max` | number | `amount <=` |
| `amount_exact` | number | `amount =` |
| `tags` | string | Tags contains (case-insensitive) |
| `has_receipt` | bool | `true` = has receipt, `false` = none |
| `has_notes` | bool | `true` = has notes, `false` = none |
| `search` | string | Searches `title`, `notes`, `tags` |
| `ordering` | string | See ordering fields above |
| `page` | int | Page number |

**Example:** `GET /api/transactions/?transaction_type=expense&period=month&ordering=-amount`

---

#### `POST /api/transactions/` — Create

**Request Body:**

| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string | Yes | max 200 |
| `amount` | number | Yes | decimal 15.2 |
| `transaction_type` | string | No | `income` \| `expense`, default `expense` |
| `category` | int | Yes | Category ID (must belong to caller) |
| `account` | int | Yes | Account ID (must belong to caller) |
| `date` | date | Yes | `YYYY-MM-DD` |
| `notes` | string | No | text |
| `receipt` | file | No | image upload (`multipart/form-data`) |
| `tags` | string | No | max 500 |

**Response — `201 Created`:**

```json
{
  "id": 11,
  "title": "Groceries",
  "amount": "45.50",
  "transaction_type": "expense",
  "category": 1,
  "category_detail": { "id": 1, "title": "Food" },
  "account": 1,
  "account_detail": { "id": 1, "title": "Checking" },
  "date": "2026-09-20",
  "notes": "Weekly shopping",
  "receipt": null,
  "tags": "groceries",
  "user": 1,
  "created_at": "2026-09-20T18:30:00"
}
```

> For file uploads (`receipt`), use `Content-Type: multipart/form-data`.

**Errors — `400`:**

```json
{
  "category": ["Category must belong to the current user."]
}
```

```json
{
  "account": ["Account must belong to the current user."]
}
```

---

#### `GET /api/transactions/{id}/` — Retrieve

Uses `TransactionSerializer` (includes `category_detail`, `account_detail`, `user`).

**Response — `200 OK`:** same shape as create response.

---

#### `PUT /api/transactions/{id}/` / `PATCH /api/transactions/{id}/` — Update

Same fields as create (all optional on PATCH). **Response — `200 OK`:** updated object.

---

#### `DELETE /api/transactions/{id}/` — Delete

**Response — `204 No Content`**

---

#### `GET /api/transactions/summary/` — Expense Summary

Summary for a period based on `created_at`.

**Query params:**

| Param | Type | Default | Values |
|---|---|---|---|
| `period` | string | `month` | `today`, `yesterday`, `week`, `last_week`, `month`, `last_month`, `quarter`, `year`, `last_year`, or custom |
| `start_date` | date | — | Required (with `end_date`) when using custom range (any `period` value not listed above) |
| `end_date` | date | — | Same as above |

**Response — `200 OK`:**

```json
{
  "period": "month",
  "start_date": "2026-09-01",
  "end_date": "2026-09-30",
  "summary": {
    "total_income": "3000.00",
    "total_expenses": "1250.50",
    "net_amount": "1749.50",
    "transaction_count": 18,
    "income_count": 2,
    "expense_count": 16
  },
  "category_breakdown": [
    { "category__title": "Food", "total": "420.00" },
    { "category__title": "Transport", "total": "180.00" }
  ],
  "account_breakdown": [
    { "account__title": "Checking", "total": "1400.50" }
  ],
  "recent_transactions": [
    {
      "id": 10,
      "title": "Groceries",
      "amount": "45.50",
      "transaction_type": "expense",
      "category": { "id": 1, "title": "Food" },
      "account": { "id": 1, "title": "Checking" },
      "date": "2026-09-20",
      "notes": null,
      "receipt": null,
      "tags": null,
      "created_at": "2026-09-20T18:30:00"
    }
  ]
}
```

`recent_transactions` contains up to **10** newest in the period.

---

#### `GET /api/transactions/expenses/` — Expense Transactions Only

Paginated list of `transaction_type = expense` transactions (same shape as list `results`).

**Query params:** all standard list filters apply.

---

#### `GET /api/transactions/income/` — Income Transactions Only

Paginated list of `transaction_type = income` transactions.

**Query params:** all standard list filters apply.

---

#### `GET /api/transactions/by_category/` — Filter by Category

**Query params:**

| Param | Type | Required |
|---|---|---|
| `category` | int | No (returns all when omitted) |

Paginated transaction list filtered by the given category ID.

---

#### `GET /api/transactions/by_account/` — Filter by Account

**Query params:**

| Param | Type | Required |
|---|---|---|
| `account` | int | No (returns all when omitted) |

Paginated transaction list filtered by the given account ID.

---

#### `GET /api/transactions/date_range/` — Date Range Query

Filters on `created_at` date.

**Query params:**

| Param | Type | Required | Notes |
|---|---|---|---|
| `start_date` | date | Yes | `YYYY-MM-DD` |
| `end_date` | date | Yes | `YYYY-MM-DD` |
| `transaction_type` | string | No | `income` \| `expense` |
| `category` | int | No | Category ID |
| `account` | int | No | Account ID |
| `ordering` | string | No | default `-created_at` |

Paginated transaction list.

**Errors:**

| Status | Body |
|---|---|
| `400` | `{"error": "Both start_date and end_date are required (YYYY-MM-DD format)"}` |
| `400` | `{"error": "Invalid date format. Use YYYY-MM-DD"}` |

---

### 6.7 Dashboard

#### `GET /api/dashboard/` — Full Dashboard Data

**Query params:**

| Param | Type | Default | Values |
|---|---|---|---|
| `period` | string | `month` | `today`, `week`, `month`, `year`, anything else = current month |

Uses the transaction `date` field for period filtering.

**Response — `200 OK`:**

```json
{
  "period": {
    "type": "month",
    "start_date": "2026-09-01",
    "end_date": "2026-09-30"
  },
  "summary": {
    "total_income": "3000.00",
    "total_expenses": "1250.50",
    "net_amount": "1749.50",
    "transaction_count": 18,
    "total_account_balance": "4450.00"
  },
  "category_breakdown": [
    { "category__title": "Food", "total": "420.00", "count": 9 },
    { "category__title": "Transport", "total": "180.00", "count": 4 }
  ],
  "account_summary": [
    {
      "id": 1,
      "title": "Checking",
      "initial_balance": "1000.00",
      "current_balance": "1450.00",
      "change": "450.00"
    }
  ],
  "recent_transactions": [
    {
      "id": 10,
      "title": "Groceries",
      "amount": "45.50",
      "transaction_type": "expense",
      "category": "Food",
      "account": "Checking",
      "date": "2026-09-20"
    }
  ],
  "monthly_trend": [
    { "month": "2026-04", "income": "3000.00", "expenses": "1100.00", "net": "1900.00" },
    { "month": "2026-05", "income": "3000.00", "expenses": "1320.00", "net": "1680.00" },
    { "month": "2026-06", "income": "3200.00", "expenses": "980.00", "net": "2220.00" },
    { "month": "2026-07", "income": "3000.00", "expenses": "1410.00", "net": "1590.00" },
    { "month": "2026-08", "income": "3100.00", "expenses": "1195.00", "net": "1905.00" },
    { "month": "2026-09", "income": "3000.00", "expenses": "1250.50", "net": "1749.50" }
  ],
  "top_categories": [
    { "category__title": "Food", "total": "420.00" },
    { "category__title": "Transport", "total": "180.00" }
  ]
}
```

| Section | Notes |
|---|---|
| `recent_transactions` | Up to **10**, ordered by `-date`, category/account as plain titles |
| `monthly_trend` | Last **6** months, oldest → newest, keyed by `YYYY-MM` |
| `top_categories` | Top **5** expense categories in the period |
| `category_breakdown` | All expense categories in the period, ordered by total desc |

---

#### `GET /api/dashboard/quick-stats/` — Quick Stats

No query params. Uses transaction `date`.

**Response — `200 OK`:**

```json
{
  "today": {
    "income": "0.00",
    "expenses": "45.50",
    "net": "-45.50",
    "count": 1
  },
  "week": {
    "income": "200.00",
    "expenses": "310.00",
    "net": "-110.00",
    "count": 6
  },
  "month": {
    "income": "3000.00",
    "expenses": "1250.50",
    "net": "1749.50",
    "count": 18
  }
}
```

- `week`: current calendar week (Monday–Sunday)
- `month`: current calendar month

---

## 7. Data Models

### User (`api.User`) — custom auth model

| Field | Type | Constraints |
|---|---|---|
| `id` | bigint | auto, read-only |
| `name` | string(200) | required |
| `email` | email(200) | required, unique, indexed, **login field** |
| `password` | string | write-only, min 8 (serializer), hashed with `set_password` |

### Category

| Field | Type | Constraints |
|---|---|---|
| `id` | bigint | auto |
| `title` | string(200) | required, unique per user |
| `user` | FK → User | required (set from authenticated user) |

### Account

| Field | Type | Constraints |
|---|---|---|
| `id` | bigint | auto |
| `title` | string(200) | required, unique per user |
| `initial` | decimal(15,2) | default `0.00` |
| `user` | FK → User | required |
| `current_balance` | decimal(15,2) | **read-only, computed**: `initial + income − expenses` |

### Transaction

| Field | Type | Constraints |
|---|---|---|
| `id` | bigint | auto |
| `title` | string(200) | required |
| `amount` | decimal(15,2) | required |
| `transaction_type` | string(10) | `income` \| `expense`, default `expense` |
| `category` | FK → Category | required, must belong to same user |
| `account` | FK → Account | required, must belong to same user |
| `date` | date | required |
| `notes` | text | optional |
| `receipt` | image | optional, upload path `receipts/` |
| `tags` | string(500) | optional |
| `user` | FK → User | required (set from authenticated user) |
| `created_at` | datetime | auto-now-add, read-only |

---

## 8. Non-API Routes

| Route | Description |
|---|---|
| `/` | Redirects to `/api/` |
| `/admin/` | Django admin |
| `/rest/` | DRF browsable API login pages |
| `/media/<path>` | Media files (e.g. `/media/receipts/...`) — dev only |
| `/__debug__/` | Django Debug Toolbar (LOCAL env only) |

---

## Quick Reference — All Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/version/` | No | API version |
| POST | `/api/auth/signup/` | No | Register + token |
| POST | `/api/auth/signin/` | No | Login + token |
| POST | `/api/auth/logout/` | Yes | Invalidate token |
| POST | `/api/token/` | No | DRF token obtain |
| GET | `/api/users/` | Yes | List own profile |
| POST | `/api/users/` | Yes | Create user |
| GET | `/api/users/{id}/` | Yes | Get user |
| PUT/PATCH | `/api/users/{id}/` | Yes | Update user |
| DELETE | `/api/users/{id}/` | Yes | Delete user |
| GET | `/api/categories/` | Yes | List categories |
| POST | `/api/categories/` | Yes | Create category |
| GET | `/api/categories/{id}/` | Yes | Get category |
| PUT/PATCH | `/api/categories/{id}/` | Yes | Update category |
| DELETE | `/api/categories/{id}/` | Yes | Delete category |
| GET | `/api/categories/with_stats/` | Yes | Categories + stats |
| GET | `/api/categories/{id}/transactions/` | Yes | Category transactions |
| GET | `/api/accounts/` | Yes | List accounts |
| POST | `/api/accounts/` | Yes | Create account |
| GET | `/api/accounts/{id}/` | Yes | Get account |
| PUT/PATCH | `/api/accounts/{id}/` | Yes | Update account |
| DELETE | `/api/accounts/{id}/` | Yes | Delete account |
| GET | `/api/accounts/with_balance/` | Yes | Accounts with balance |
| GET | `/api/accounts/summary/` | Yes | Account summary |
| GET | `/api/accounts/{id}/transactions/` | Yes | Account transactions |
| GET | `/api/accounts/{id}/balance_history/` | Yes | Balance history |
| GET | `/api/transactions/` | Yes | List transactions (+ filters) |
| POST | `/api/transactions/` | Yes | Create transaction |
| GET | `/api/transactions/{id}/` | Yes | Get transaction |
| PUT/PATCH | `/api/transactions/{id}/` | Yes | Update transaction |
| DELETE | `/api/transactions/{id}/` | Yes | Delete transaction |
| GET | `/api/transactions/summary/` | Yes | Period summary |
| GET | `/api/transactions/expenses/` | Yes | Expenses only |
| GET | `/api/transactions/income/` | Yes | Income only |
| GET | `/api/transactions/by_category/` | Yes | Filter by category |
| GET | `/api/transactions/by_account/` | Yes | Filter by account |
| GET | `/api/transactions/date_range/` | Yes | Date range query |
| GET | `/api/dashboard/` | Yes | Full dashboard |
| GET | `/api/dashboard/quick-stats/` | Yes | Today/week/month stats |
