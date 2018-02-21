from django import forms
from django.forms import ModelForm

from .models import *

class AddRevisionNotesForm(forms.Form):
    revision_notes = forms.CharField()
    draft_pk = forms.ModelChoiceField(queryset=Draft.objects.all())

class ApproveEditDraftForm(forms.Form):
    draft_text = forms.CharField()
    draft_pk = forms.ModelChoiceField(queryset=Draft.objects.all())


class EditDraftForm(forms.Form):
    draft_text = forms.CharField(required=False)
    draft = forms.ModelChoiceField(queryset=Draft.objects.all(), required=False)
    student = forms.ModelChoiceField(queryset=Student.objects.all())
    week_num = forms.IntegerField()