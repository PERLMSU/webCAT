from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date

class AddStudentForm(forms.ModelForm):

    first_name = forms.CharField()
    last_name = forms.CharField()
    student_id = forms.CharField()
    group_number = forms.IntegerField(required=False)

    class Meta:
        model = Student
        fields = ['first_name','last_name','student_id']

    def clean_first_name(self):
        if len(self.cleaned_data['first_name']) > 30:
            raise forms.ValidationError("First name must not be longer than %d characters." % 30)          
        return self.cleaned_data['first_name']

    def clean_last_name(self):
        if len(self.cleaned_data['last_name']) > 30:
            raise forms.ValidationError("Last name must not be longer than %d characters." % 30)          
        return self.cleaned_data['last_name']

class AddGroupForm(forms.ModelForm):

    description = forms.CharField(required=False)
    group_number = forms.IntegerField()

    class Meta:
        model = Group
        fields = ['description','group_number']

    def clean_description(self):
        if len(self.cleaned_data['description']) > 200:
            raise forms.ValidationError("Description name must not be longer than %d characters." % 200)          
        return self.cleaned_data['description']       

class AddClassroomForm(forms.ModelForm):

    description = forms.CharField(required=False)
    course = forms.CharField()

    class Meta:
        model = Classroom
        fields = ['course','description']

    def clean_description(self):
        if len(self.cleaned_data['description']) > 200:
            raise forms.ValidationError("Description name must not be longer than %d characters." % 200)          
        return self.cleaned_data['description']  

    def clean_first_name(self):
        if len(self.cleaned_data['course']) > 20:
            raise forms.ValidationError("Course must not be longer than %d characters." % 20)          
        return self.cleaned_data['course']        