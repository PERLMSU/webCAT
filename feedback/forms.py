from django import forms
from django.forms import ModelForm
# from django.contrib.auth import authenticate
# from django.utils.translation import ugettext_lazy as _
# from django.conf import settings

# import string

# from django.contrib.auth import authenticate
# from django.contrib.auth.forms import AuthenticationForm

from .models import *

class AddRevisionNotesForm(forms.Form):
    revision_notes = forms.CharField()
    draft_pk = forms.ModelChoiceField(queryset=Draft.objects.all())

class AddCategoryForm(forms.ModelForm):

    name = forms.CharField()
    description = forms.CharField(required=False)

    class Meta:
        model = Category
        fields = ['name','description']

# class AddCommonFeedbackForm(forms.ModelForm):

#     # feedback = forms.CharField(required=False)
#     # observation = forms.CharField(required=False)
#     problem = forms.CharField(required=False)
#     solution = forms.CharField(required=False)
#     solution_explanation = forms.CharField(required=False)

#     class Meta:
#         model = CommonFeedback
#         fields = ['problem','solution','solution_explanation']

class AddFeedbackPieceForm(forms.Form):
    #pull common observations that already exist

    subcategory_pk = forms.ModelChoiceField(queryset=SubCategory.objects.all(),required=True)

    observation_pk = forms.ModelChoiceField(queryset=Observation.objects.all(),required=False)

    #or make a whole new one
    observation = forms.CharField(required=False)
    #positive, negative, neutral, other?
    observation_type = forms.CharField(required=False)

    #already exists, or make a new one (pick one or the other)
    feedback_pk = forms.ModelChoiceField(queryset=Feedback.objects.all(),required=False)
    feedback = forms.CharField(required=False)

     #already exists, or make a new one (pick one or the other)
    feedback_explanation_pk = forms.ModelChoiceField(queryset=Explanation.objects.all(),required=False) 
    feedback_explanation = forms.CharField(required=False)

    def clean_observation(self):        

        if not self.data.get('observation_pk') and not self.cleaned_data['observation']:
            raise forms.ValidationError("Observation is required for feedback piece. Either select from an existing or create a new observation.")
        return self.cleaned_data['observation']

    def clean_feedback(self):        

        if not self.data.get('feedback_pk') and not self.cleaned_data['feedback']:
            raise forms.ValidationError("Feedback is required for feedback piece. Either select from an existing or create new feedback.") 
        return self.cleaned_data['feedback']

    def clean_feedback_explanation(self):        

        if not self.data.get('feedback_explanation_pk') and not self.cleaned_data['feedback_explanation']:
            raise forms.ValidationError("Feedback explanation is required for feedback piece. Either select from an existing or create new feedback explanation.") 
        return self.cleaned_data['feedback_explanation']

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
    draft_text = forms.CharField()
    draft = forms.ModelChoiceField(queryset=Draft.objects.all(), required=False)
    student = forms.ModelChoiceField(queryset=Student.objects.all())
    week_num = forms.IntegerField()