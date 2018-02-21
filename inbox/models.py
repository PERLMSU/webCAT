from __future__ import unicode_literals

import datetime
import calendar

from django.conf import settings
from django.db import models

from django.core.mail import send_mail, EmailMessage, EmailMultiAlternatives
from django.template.loader import render_to_string


from classroom.models import *
from feedback.models import *

# Create your models here.
