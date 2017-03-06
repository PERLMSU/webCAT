from django import forms
from django.contrib.auth import authenticate
from django.utils.translation import ugettext_lazy as _

from collections import OrderedDict
from django.conf import settings

import string

from django.contrib.auth import authenticate
from django.contrib.auth.forms import AuthenticationForm