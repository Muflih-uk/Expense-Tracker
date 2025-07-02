from django.conf import settings
from storages.backends.s3boto3 import S3Boto3Storage
from django.conf import settings


if settings.ENV == 'DEV' or settings.ENV == 'QA':
    class StaticStorage(S3Boto3Storage):
        bucket_name = settings.AWS_S3_BUCKET_NAME_STATIC
        region_name = settings.AWS_REGION_NAME


    class PublicStorage(S3Boto3Storage):
        bucket_name = settings.AWS_S3_PUBLIC_BUCKET_NAME
        default_acl = 'public-read'
        file_overwrite = False
        custom_domain = False
        region_name = settings.AWS_REGION_NAME

        def _get_security_token(self):
            return None


    class PrivateFileStorage(S3Boto3Storage):
        bucket_name = settings.AWS_S3_BUCKET_NAME
        default_acl = 'private'
        file_overwrite = False
        custom_domain = False
        region_name = settings.AWS_REGION_NAME

        def _get_security_token(self):
            return None
else:
    PrivateFileStorage = None
    PublicStorage = None
    StaticStorage = None
