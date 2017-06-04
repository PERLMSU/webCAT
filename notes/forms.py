from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date


class AddFeedbackForm(forms.Form):
    # category_pk = forms.IntegerField()
    note = forms.CharField()   
