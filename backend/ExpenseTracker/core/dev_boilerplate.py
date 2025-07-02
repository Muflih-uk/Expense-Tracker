from boto3.session import Session
from .base import *

ENV = 'DEV'
API_SITE = "https://api.dev.projectscranton.com"
WWW_SITE = "https://dev.projectscranton.com"

DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': '',
            'USER': "",
            'PASSWORD': "",
            'HOST': '',
            'PORT': '5432'
        }
    }

AWS_ACCESS_KEY_ID = ''
AWS_SECRET_ACCESS_KEY = ''
AWS_REGION_NAME = "ap-south-1"

# STATICFILES_STORAGE = "django_s3_storage.storage.StaticS3Storage"
AWS_S3_BUCKET_NAME_STATIC = ""
AWS_S3_CUSTOM_DOMAIN_STATIC = '%s.s3.amazonaws.com' % AWS_S3_BUCKET_NAME_STATIC
STATIC_URL = "https://%s/" % AWS_S3_CUSTOM_DOMAIN_STATIC
STATIC_ROOT = "/"

DEFAULT_FILE_STORAGE = "django_s3_storage.storage.S3Storage"
AWS_S3_BUCKET_NAME = ""
AWS_S3_PUBLIC_BUCKET_NAME = ""

# Email Configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# noinspection SpellCheckingInspection
EMAIL_HOST = 'email-smtp.us-east-1.amazonaws.com'
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST_USER = ''
EMAIL_HOST_PASSWORD = ''
DEFAULT_FROM_EMAIL = ""

boto3_session = Session(aws_access_key_id=AWS_ACCESS_KEY_ID,
                        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                        region_name=AWS_REGION_NAME)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'watchtower': {
            'class': 'watchtower.CloudWatchLogHandler',
            'boto3_session': boto3_session,
            'log_group': 'api',
            'stream_name': 'dev',
            'formatter': 'simple',
            'create_log_group': False,
            'create_log_stream': False,
        },
    },
    'loggers': {
        'watchtower': {
            'handlers': ['watchtower'],
            'level': 'INFO',
            'propagate': False,
        },
    },
    'formatters': {
        'simple': {
            'format': 'LEVEL: {levelname} TIME: {asctime} PROCESS: {process:d} THREAD: {thread:d} MESSAGE: {message}',
            'style': '{',
        }
    }
}

