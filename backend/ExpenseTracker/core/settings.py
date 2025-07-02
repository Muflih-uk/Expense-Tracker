import os

ENV = os.getenv('ENV', 'LOCAL')

if ENV == "DEV":
    from .dev import *
elif ENV == "QA":
    from .qa import *
else:
    from .local import *

print(ENV, API_VERSION)

