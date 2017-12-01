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
    draft_pk = forms.IntegerField()

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

    subcategory_pk = forms.IntegerField(required=True)

    observation_pk = forms.IntegerField(required=False)

    #or make a whole new one
    observation = forms.CharField(required=False)
    #positive, negative, neutral, other?
    observation_type = forms.CharField(required=False)

    #already exists, or make a new one (pick one or the other)
    feedback_pk = forms.IntegerField(required=False)
    feedback = forms.CharField(required=False)

     #already exists, or make a new one (pick one or the other)
    feedback_explanation_pk = forms.IntegerField(required=False)  
    feedback_explanation = forms.CharField(required=False)



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
    student_pk = forms.IntegerField()
    week_num = forms.IntegerField()