# Expense Tracker REST API

A comprehensive Django REST Framework API for tracking personal expenses and income.

## Features

### Core Features
- **User Authentication**: Sign up, sign in, logout with token-based authentication
- **Expense Management**: Add, view, edit, and delete expenses
- **Income Tracking**: Track income transactions separately from expenses
- **Category Management**: Organize transactions by categories
- **Account Management**: Manage multiple accounts with balance tracking
- **Advanced Filtering**: Filter by date, amount, category, account, and more
- **Summary Reports**: Get expense summaries for different time periods

### Advanced Features
- **Date Filtering**: Filter by today, week, month, year, or custom date range
- **Category-based Tracking**: Assign categories to transactions for better organization
- **Account Balance Tracking**: Automatic balance calculation based on transactions
- **Receipt Upload**: Optional image upload for transaction receipts
- **Tags Support**: Add tags to transactions for advanced filtering
- **Dashboard**: Comprehensive overview with charts and statistics
- **Monthly Trends**: Track spending patterns over time

## API Endpoints

### Authentication
- `POST /api/auth/signup/` - User registration
- `POST /api/auth/signin/` - User login
- `POST /api/auth/logout/` - User logout
- `POST /api/token/` - Get authentication token

### Users
- `GET /api/users/` - List users (own profile only)

### Categories
- `GET /api/categories/` - List categories
- `POST /api/categories/` - Create category
- `GET /api/categories/{id}/` - Get category details
- `PUT /api/categories/{id}/` - Update category
- `DELETE /api/categories/{id}/` - Delete category
- `GET /api/categories/with_stats/` - Get categories with transaction statistics
- `GET /api/categories/{id}/transactions/` - Get transactions for a category

### Accounts
- `GET /api/accounts/` - List accounts
- `POST /api/accounts/` - Create account
- `GET /api/accounts/{id}/` - Get account details
- `PUT /api/accounts/{id}/` - Update account
- `DELETE /api/accounts/{id}/` - Delete account
- `GET /api/accounts/with_balance/` - Get accounts with current balance
- `GET /api/accounts/summary/` - Get account summary
- `GET /api/accounts/{id}/transactions/` - Get transactions for an account
- `GET /api/accounts/{id}/balance_history/` - Get balance history for an account

### Transactions
- `GET /api/transactions/` - List transactions
- `POST /api/transactions/` - Create transaction
- `GET /api/transactions/{id}/` - Get transaction details
- `PUT /api/transactions/{id}/` - Update transaction
- `DELETE /api/transactions/{id}/` - Delete transaction
- `GET /api/transactions/summary/` - Get transaction summary
- `GET /api/transactions/expenses/` - Get only expense transactions
- `GET /api/transactions/income/` - Get only income transactions
- `GET /api/transactions/by_category/` - Get transactions by category

### Dashboard
- `GET /api/dashboard/` - Get comprehensive dashboard data
- `GET /api/dashboard/quick-stats/` - Get quick statistics

## Request/Response Examples

### Sign Up
```json
POST /api/auth/signup/
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "securepassword123"
}

Response:
{
    "token": "your-auth-token",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    }
}
```

### Sign In
```json
POST /api/auth/signin/
{
    "email": "john@example.com",
    "password": "securepassword123"
}

Response:
{
    "token": "your-auth-token",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    }
}
```

### Create Category
```json
POST /api/categories/
Authorization: Token your-auth-token
{
    "title": "Food & Dining"
}

Response:
{
    "id": 1,
    "title": "Food & Dining",
    "user": 1
}
```

### Get Categories with Stats
```json
GET /api/categories/with_stats/?period=month
Authorization: Token your-auth-token

Response:
[
    {
        "id": 1,
        "title": "Food & Dining",
        "total_amount": 150.00,
        "transaction_count": 5
    },
    {
        "id": 2,
        "title": "Transportation",
        "total_amount": 75.00,
        "transaction_count": 3
    }
]
```

### Create Transaction
```json
POST /api/transactions/
Authorization: Token your-auth-token
{
    "title": "Grocery Shopping",
    "amount": "50.00",
    "transaction_type": "expense",
    "category": 1,
    "account": 1,
    "date": "2024-01-15",
    "notes": "Weekly groceries",
    "tags": "food, essentials"
}

Response:
{
    "id": 1,
    "title": "Grocery Shopping",
    "amount": "50.00",
    "transaction_type": "expense",
    "category": 1,
    "category_detail": {
        "id": 1,
        "title": "Food & Dining"
    },
    "account": 1,
    "account_detail": {
        "id": 1,
        "title": "Main Account"
    },
    "date": "2024-01-15",
    "notes": "Weekly groceries",
    "tags": "food, essentials",
    "user": 1,
    "created_at": "2024-01-15T10:30:00Z"
}
```

### Get Dashboard Summary
```json
GET /api/dashboard/?period=month
Authorization: Token your-auth-token

Response:
{
    "period": {
        "type": "month",
        "start_date": "2024-01-01",
        "end_date": "2024-01-31"
    },
    "summary": {
        "total_income": "3000.00",
        "total_expenses": "1500.00",
        "net_amount": "1500.00",
        "transaction_count": 25,
        "total_account_balance": "5000.00"
    },
    "category_breakdown": [
        {
            "category__title": "Food & Dining",
            "total": "500.00",
            "count": 10
        },
        {
            "category__title": "Transportation",
            "total": "300.00",
            "count": 5
        }
    ],
    "account_summary": [
        {
            "id": 1,
            "title": "Main Account",
            "initial_balance": "1000.00",
            "current_balance": "3500.00",
            "change": "2500.00"
        }
    ],
    "recent_transactions": [...],
    "monthly_trend": [...],
    "top_categories": [...]
}
```

### Create Account
```json
POST /api/accounts/
Authorization: Token your-auth-token
{
    "title": "Food & Dining"
}

Response:
{
    "id": 1,
    "title": "Food & Dining",
    "initial": "5000.00",
    "user": 3,
    "current_balance": "5000.00"
}
```

## Filtering and Query Parameters

### Transaction Filtering

#### Date Filtering
- `date_from`: Filter from date (YYYY-MM-DD)
- `date_to`: Filter to date (YYYY-MM-DD)
- `date_exact`: Filter by exact date (YYYY-MM-DD)
- `date_after`: Filter after date (YYYY-MM-DD)
- `date_before`: Filter before date (YYYY-MM-DD)
- `period`: Filter by predefined periods:
  - `today` - Today's transactions
  - `yesterday` - Yesterday's transactions
  - `week` - Current week (Monday to Sunday)
  - `last_week` - Previous week
  - `month` - Current month
  - `last_month` - Previous month
  - `quarter` - Current quarter
  - `year` - Current year
  - `last_year` - Previous year
  - `last_7_days` - Last 7 days
  - `last_30_days` - Last 30 days
  - `last_90_days` - Last 90 days
- `day`: Filter by day of month (1-31)
- `month`: Filter by month (1-12)
- `year`: Filter by year (e.g., 2024)
- `weekday`: Filter by day of week (0=Monday, 6=Sunday)

#### Amount Filtering
- `amount_min`: Minimum amount
- `amount_max`: Maximum amount
- `amount_exact`: Exact amount

#### Transaction Type & Category Filtering
- `transaction_type`: Filter by 'income' or 'expense'
- `category`: Filter by category ID
- `account`: Filter by account ID

#### Content Filtering
- `tags`: Filter by tags (case-insensitive contains)
- `has_receipt`: Filter transactions with/without receipts (true/false)
- `has_notes`: Filter transactions with/without notes (true/false)
- `search`: Search in title, notes, and tags

#### Text Search Options
- `title__exact`: Exact title match
- `title__icontains`: Title contains (case-insensitive)
- `title__istartswith`: Title starts with (case-insensitive)
- `title__iendswith`: Title ends with (case-insensitive)
- `notes__exact`: Exact notes match
- `notes__icontains`: Notes contains (case-insensitive)
- `notes__istartswith`: Notes starts with (case-insensitive)

### Category Stats Filtering
- `period`: Filter stats by period ('today', 'week', 'month', 'year')

### Sorting
- `ordering`: Sort by any field (prefix with '-' for descending)
- Examples: `?ordering=date`, `?ordering=-amount`, `?ordering=title`

### Pagination
- `page`: Page number
- `page_size`: Items per page (default: 10)

## Date Filtering Examples

### Basic Date Range
```
GET /api/transactions/?date_from=2024-01-01&date_to=2024-01-31
```

### Predefined Periods
```
GET /api/transactions/?period=today
GET /api/transactions/?period=week
GET /api/transactions/?period=month
GET /api/transactions/?period=quarter
GET /api/transactions/?period=year
GET /api/transactions/?period=last_7_days
GET /api/transactions/?period=last_30_days
```

### Specific Date Components
```
GET /api/transactions/?month=12&year=2024
GET /api/transactions/?day=15
GET /api/transactions/?weekday=5
```

### Combined Filters
```
GET /api/transactions/?period=month&transaction_type=expense&amount_min=100
GET /api/transactions/?date_from=2024-01-01&category=1&has_receipt=true
GET /api/transactions/?period=week&account=2&ordering=-amount
```

### Date Range Endpoint
```
GET /api/transactions/date_range/?start_date=2024-01-01&end_date=2024-01-31&transaction_type=expense
```

## Installation and Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

4. Create a superuser:
   ```bash
   python manage.py createsuperuser
   ```

5. Run the development server:
   ```bash
   python manage.py runserver
   ```

6. Access the API at `http://localhost:8000/api/`

## Database Models

### User
- `name`: User's full name
- `email`: Unique email address
- `password`: Hashed password

### Category
- `title`: Category name
- `user`: Foreign key to User

### Account
- `title`: Account name
- `initial`: Initial balance
- `user`: Foreign key to User
- `current_balance`: Calculated current balance

### Transaction
- `title`: Transaction title
- `amount`: Transaction amount
- `transaction_type`: 'income' or 'expense'
- `category`: Foreign key to Category
- `account`: Foreign key to Account
- `date`: Transaction date
- `notes`: Optional notes
- `receipt`: Optional image upload
- `tags`: Optional tags for filtering
- `user`: Foreign key to User

## Security Features

- Token-based authentication
- User data isolation (users can only access their own data)
- Input validation and sanitization
- CSRF protection
- Secure password hashing

## REST Framework Interface

The API includes Django REST Framework's browsable API interface. You can:

1. Visit any endpoint in your browser to see the interactive interface
2. Test API calls directly from the browser
3. View detailed documentation for each endpoint
4. See request/response schemas

Example: Visit `http://localhost:8000/api/transactions/` to see the interactive transaction list interface. # expenseTracker
# ExpenseTracker
