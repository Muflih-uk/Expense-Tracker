from django.conf import settings
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet


class VersionViewSet(ViewSet):
    authentication_classes = []
    permission_classes = []

    def list(self, request):
        return Response(settings.API_VERSION)
