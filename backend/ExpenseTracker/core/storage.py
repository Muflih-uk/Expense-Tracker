import os

from storages.backends.s3boto3 import S3Boto3Storage


class PublicStorage(S3Boto3Storage):
    bucket_name = os.getenv('AWS_STORAGE_BUCKET_NAME')
    default_acl = None
    file_overwrite = False
    querystring_auth = False
    addressing_style = 'path'

    def _get_security_token(self):
        return None