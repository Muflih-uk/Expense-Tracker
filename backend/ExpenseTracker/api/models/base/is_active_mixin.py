from django.db import models


class IsActiveMixin(models.Model):
    class Meta:
        abstract = True

    is_active = models.BooleanField(default=True, db_index=True)
