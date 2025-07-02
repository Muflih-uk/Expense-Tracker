from django.conf import settings
from django.urls import path, include
from django.conf.urls.static import static
from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token
from api.views import *

app_name = 'api'

router = routers.DefaultRouter()

# Version endpoint
router.register(r'version', VersionViewSet, basename='Version')

# User endpoints
router.register(r'users', UserViewSet, basename='User')

# Category endpoints
router.register(r'categories', CategoryViewSet, basename='Category')

# Account endpoints
router.register(r'accounts', AccountViewSet, basename='Account')

# Transaction endpoints
router.register(r'transactions', TransactionViewSet, basename='Transaction')

urlpatterns = [
    # Router URLs (ViewSets)
    path('', include(router.urls)),
    
    # Authentication endpoints
    path('auth/signup/', signup, name='signup'),
    path('auth/signin/', signin, name='signin'),
    path('auth/logout/', logout, name='logout'),
    
    # Dashboard endpoints
    path('dashboard/', dashboard, name='dashboard'),
    path('dashboard/quick-stats/', quick_stats, name='quick_stats'),
    
    # Token authentication (Django REST Framework default)
    path('token/', obtain_auth_token, name="login"),
]

# Add media URLs for development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
