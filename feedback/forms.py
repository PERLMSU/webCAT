from django import forms
from django.forms import ModelForm

from .models import *


class AddCategoryForm(forms.ModelForm):

    name = forms.CharField()
    description = forms.CharField(required=False)

    class Meta:
        model = Category
        fields = ['name','description']


class EditObservationForm(forms.ModelForm):
    observation = forms.CharField()
    observation_pk = forms.ModelChoiceField(queryset=Observation.objects.all(),required=False)
    observation_type = forms.IntegerField(required=False)
    sub_category = forms.ModelChoiceField(queryset=SubCategory.objects.all(),required=True)

    class Meta:
        model = Observation
        fields = ['sub_category', 'observation', 'observation_type']


class EditCommonFeedbackForm(forms.ModelForm):
    feedback_pk = forms.ModelChoiceField(queryset=Feedback.objects.all(),required=False)
    feedback = forms.CharField() 
    sub_category = forms.ModelChoiceField(queryset=SubCategory.objects.all(),required=False)
    observation = forms.ModelChoiceField(queryset=Observation.objects.all(),required=False)

    class Meta:
        model = Feedback
        fields = ['sub_category', 'observation', 'feedback']

class EditExplanationForm(forms.ModelForm):
    explanation_pk = forms.ModelChoiceField(queryset=Explanation.objects.all(),required=False)
    sub_category = forms.ModelChoiceField(queryset=SubCategory.objects.all(),required=False)
    feedback = forms.ModelChoiceField(queryset=Feedback.objects.all(),required=False)
    feedback_explanation = forms.CharField() 
    
    class Meta:
        model = Explanation
        fields = ['feedback_explanation','sub_category','feedback']

class AddSubCategoryForm(forms.ModelForm):

    name = forms.CharField()
    description = forms.CharField(required=False)

    class Meta:
        model = SubCategory
        fields = ['name','description']


class EditCategoryForm(forms.Form):
    name = forms.CharField()
    description = forms.CharField(required=False)	

class EditDraftForm(forms.Form):
    draft_text = forms.CharField(required=False)
    draft = forms.ModelChoiceField(queryset=Draft.objects.all(), required=False)
    student = forms.ModelChoiceField(queryset=Student.objects.all())
    week_num = forms.IntegerField()