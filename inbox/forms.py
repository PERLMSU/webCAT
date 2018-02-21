from django import forms
from django.forms import ModelForm

from .models import *

class AddRevisionNotesForm(forms.Form):
    revision_notes = forms.CharField()
    draft_pk = forms.ModelChoiceField(queryset=Draft.objects.all())

class ApproveEditDraftForm(forms.Form):
    draft_text = forms.CharField()
    draft_pk = forms.ModelChoiceField(queryset=Draft.objects.all())

