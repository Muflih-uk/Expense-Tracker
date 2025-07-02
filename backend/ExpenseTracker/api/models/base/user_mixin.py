from django.db import models


class UserMixin(models.Model):
    class Meta:
        abstract = True

    name = models.CharField(max_length=200)
    email = models.EmailField(max_length=200, unique=True, db_index=True)
