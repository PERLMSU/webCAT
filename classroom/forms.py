from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date



class AddStudentForm(forms.ModelForm):

    first_name = forms.CharField()
    notes = forms.CharField(required=False)
    last_name = forms.CharField()
    student_id = forms.CharField()
    group_number = forms.IntegerField(required=False)

    class Meta:
        model = Student
        fields = ['first_name','last_name','student_id','notes']

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

class AssignInstructorForm(forms.Form):
    instructor_id = forms.IntegerField()
    group_description = forms.CharField()
    group_num = forms.IntegerField()


class AssignMultipleGroupsForm(forms.Form):
    CHOICES = tuple(Group.objects.all().values_list('id','group_number').order_by('group_number'))
    #raise Exception("wutt")
    group_numbers = forms.MultipleChoiceField(
        required=True,
        widget=forms.CheckboxSelectMultiple,
        choices=CHOICES,
    )

class AssignMultipleStudentsForm(forms.Form):
    all_students = Student.objects.all().values_list('id','first_name','last_name').order_by('last_name')

    students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

    CHOICES = tuple(students_full_name)
    #raise Exception("wutt")
    students = forms.MultipleChoiceField(
        required=True,
        widget=forms.CheckboxSelectMultiple,
        choices=CHOICES,
    )

    def clean_students(self):
        value = self.cleaned_data['students']
        if len(value) > 4:
            raise forms.ValidationError("You can't select more than 4 students.")
        return value    