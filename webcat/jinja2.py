from django.contrib.staticfiles.storage import staticfiles_storage
from django.urls import reverse
from jinja2 import Environment
from django.utils import translation
from webcat import models
import babel.dates

def format_datetime(value, format='medium'):
    if format == 'full':
        format="EEEE, d. MMMM y 'at' HH:mm"
    elif format == 'medium':
        format="EE dd.MM.y HH:mm"
    return babel.dates.format_datetime(value, format)

def environment(**options):
    env = Environment(extensions=['jinja2.ext.i18n'], **options)
    env.globals.update({
        'isinstance': isinstance,
        'static': staticfiles_storage.url,
        'url': reverse,
        'models': models,
        'dir': dir,
    })
    env.filters['datetime'] = format_datetime
    env.install_gettext_translations(translation)
    return env
