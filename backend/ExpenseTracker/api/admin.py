from django.apps import apps
from django.contrib import admin

models = apps.get_models()

admin.site.site_header = 'Admin'
admin.site.site_title = 'Admin'
admin.site.index_title = 'Admin'


for model in models:
    try:
        admin.site.register(model)
    except admin.sites.AlreadyRegistered:
        pass