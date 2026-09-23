from django.contrib import admin
from django.urls import include, path
from django.views.generic import RedirectView
from rest_framework.authtoken.views import obtain_auth_token


from api.urls import router

admin.autodiscover()
admin.site.enable_nav_sidebar = False

urlpatterns = [
    # Root URL redirects to API
    path('', RedirectView.as_view(url='/api/', permanent=False), name='root'),
    
    path('admin/', admin.site.urls),
    path('rest/', include('rest_framework.urls')),
    path('api/', include('api.urls')),  # Include all API URLs including auth
]