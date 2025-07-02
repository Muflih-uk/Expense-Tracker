from django.core.management.base import BaseCommand
from django.db import transaction

class Command(BaseCommand):
    help = 'Hello World'

    def add_arguments(self, parser):
        parser.add_argument('version', type=int, help="Indicates version number of the QA data")

    @transaction.atomic
    def handle(self, *args, **kwargs):
        version = kwargs['version']
        print(f"Hello World - {version}")

