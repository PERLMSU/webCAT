from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date
from feedback.models import *

class AddFeedbackForm(forms.Form):
    subcategory = forms.ModelChoiceField(queryset=SubCategory.objects.all())
    observation = forms.ModelChoiceField(queryset=Observation.objects.all(),required=False)
    note = forms.CharField(required=False)   
    week_num = forms.IntegerField()

    def clean_note(self):        

        if not self.data.get('observation') and not self.cleaned_data['note']:
            raise forms.ValidationError("Create a customized note and/or choose an observation to save note.")
        return self.cleaned_data['note']