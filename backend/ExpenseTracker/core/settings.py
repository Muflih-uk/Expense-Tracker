import os
from pathlib import Path

import dj_database_url
from dotenv import load_dotenv

from .version import API_VERSION

# Load environment variables from .env
load_dotenv()

ENV = "PROD"
# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv(
    "SECRET_KEY", "django-insecure-cuz$yzg-i9wn3r!(43*ufd@-^r-_g4*@vhq$^e@)q$(jtnz%9j"
)

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "yes")

ALLOWED_HOSTS = os.getenv("ALLOWED_HOSTS", "*").split(",")

# Application definition

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "corsheaders",
    "storages",
    "rest_framework",
    "rest_framework.authtoken",
    "django_filters",
    "api",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "corsheaders.middleware.CorsMiddleware",
]

ROOT_URLCONF = "core.urls"

CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_HEADERS = [
    "authorization",
    "content-type",
]

CORS_ALLOW_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "core.wsgi.application"
AUTH_USER_MODEL = "api.User"


# Database
# https://docs.djangoproject.com/en/3.2/ref/settings/#databases
# Neon Postgres via DATABASE_URL from .env


def _parse_database_url(raw_url):
    """Parse a DATABASE_URL, keeping sslmode=require but dropping options
    (such as channel_binding) that psycopg2's libpq does not support."""
    if "?" in raw_url:
        raw_url, _, query = raw_url.partition("?")
        keep = [p for p in query.split("&") if p.startswith("sslmode=")]
        if keep:
            raw_url = f"{raw_url}?{'&'.join(keep)}"
    config = dj_database_url.parse(raw_url)
    config["CONN_MAX_AGE"] = 60
    return config


DATABASES = {
    "default": _parse_database_url(
        os.getenv(
            "DATABASE_URL",
            "postgresql://neondb_owner:npg_4xpFIwGR0UPD@ep-lingering-paper-b4z0pi2r-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require",
        )
    )
}


# Password validation
# https://docs.djangoproject.com/en/3.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Internationalization
# https://docs.djangoproject.com/en/3.2/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = "UTC"

USE_I18N = True

USE_L10N = True

USE_TZ = True

REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 10,
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework.authentication.TokenAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": ("rest_framework.permissions.IsAuthenticated",),
    "DEFAULT_FILTER_BACKENDS": [
        "django_filters.rest_framework.DjangoFilterBackend",
        "rest_framework.filters.OrderingFilter",
    ],
    "DATETIME_FORMAT": "%Y-%m-%dT%H:%M:%S",
    "DATE_FORMAT": "%Y-%m-%d",
}

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

FILTER_STRING_MODELS = ["exact", "icontains", "istartswith", "iendswith"]
FILTER_NUMBER_MODELS = ["exact", "icontains", "istartswith", "iendswith", "lt", "gt"]
FILTER_EXACT_MODELS = ["exact"]
FILTER_DATE_MODELS = ["lt", "gte"]

VALIDATION_EXPIRE_TIME = 1

# Static files
STATIC_URL = "static/"
STATIC_ROOT = os.path.join(BASE_DIR, "static/")


# S3-compatible storage (Neon Bucket) for media files
# https://docs.djangoproject.com/en/4.2/ref/settings/#storages

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "us-east-2")
AWS_ENDPOINT_URL_S3 = os.getenv("AWS_ENDPOINT_URL_S3")
AWS_STORAGE_BUCKET_NAME = os.getenv("AWS_STORAGE_BUCKET_NAME")
AWS_S3_REGION_NAME = AWS_REGION
AWS_S3_ENDPOINT_URL = AWS_ENDPOINT_URL_S3
AWS_S3_OBJECT_PARAMETERS = {
    "CacheControl": "max-age=86400",
}
AWS_S3_ADDRESSING_STYLE = "path"
AWS_QUERYSTRING_AUTH = False

STORAGES = {
    "default": {
        "BACKEND": "core.storage.PublicStorage",
    },
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage",
    },
}

MEDIA_URL = f"{AWS_ENDPOINT_URL_S3}/"

print(f"{ENV} {API_VERSION} DB={DATABASES['default']['ENGINE']}")
