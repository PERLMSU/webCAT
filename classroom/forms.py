from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date
from userprofile.models import Profile


class AddEditRotationForm(forms.ModelForm):
    start_week = forms.IntegerField(min_value=1,required=True)
    length = forms.IntegerField(min_value=1,required=True)
    classroom = forms.ModelChoiceField(queryset=Classroom.objects.all(),widget=forms.HiddenInput())
    semester = forms.ModelChoiceField(queryset=Semester.objects.all(),widget=forms.HiddenInput())    

    class Meta:
        model = Rotation
        fields = ['start_week','length','semester','classroom']

    def clean_start_week(self):        
        semester = Semester.objects.get(id=self.data.get('semester') or None)
        classroom = Classroom.objects.get(id=self.data.get('classroom') or None)  
        rotations = Rotation.objects.filter(semester=semester,classroom=classroom)

        if Rotation.objects.filter(semester=semester,classroom=classroom,start_week=self.cleaned_data['start_week']):
            raise forms.ValidationError("Rotation already exists at this start week.")
        for rotation in rotations:
            if self.cleaned_data['start_week'] < rotation.start_week+rotation.length:
                raise forms.ValidationError("Rotation cannot exist within another rotation.")
        if int(self.cleaned_data['start_week'])+int(self.data.get('length')) > semester.get_number_weeks():
            raise forms.ValidationError("Rotation cannot be longer than the semester length.")
        return self.cleaned_data['start_week']

class EditClassroomForm(forms.Form):
    course = forms.CharField(required=True)
    description = forms.CharField(required=False)
   # num_weeks = forms.IntegerField(required=True)
    current_week = forms.IntegerField(required=True)
    current_classroom = forms.BooleanField(required=False)
    current_semester = forms.ModelChoiceField(queryset=Semester.objects.all(),required=True)

    # def clean_current_semester():
    #     try self.cleaned_data['current_semester']

    def clean_current_week(self):

        semester = Semester.objects.get(id=self.data.get('current_semester') or None)
       # raise Exception("hello")
        if (self.cleaned_data['current_week'])< 1 or (int(self.cleaned_data['current_week'])) > int(semester.get_number_weeks()):
            raise forms.ValidationError("Current week must be in range of the number of weeks of the course.")
        return self.cleaned_data['current_week']    

class AddStudentForm(forms.ModelForm):

    first_name = forms.CharField()
    notes = forms.CharField(required=False)
    last_name = forms.CharField()
    student_id = forms.CharField()
    group_number = forms.IntegerField(required=False)
    classroom_pk = forms.IntegerField(required=False,widget=forms.HiddenInput())

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

class AddGroupForm(forms.Form):

    group_number = forms.IntegerField()
    rotation = forms.ModelChoiceField(queryset=Rotation.objects.all())

    # def clean_description(self):
    #     if len(self.cleaned_data['description']) > 200:
    #         raise forms.ValidationError("Description name must not be longer than %d characters." % 200)          
    #     return self.cleaned_data['description']       

class AddClassroomForm(forms.ModelForm):

    description = forms.CharField(required=False)
    course = forms.CharField()
    current_semester = forms.ModelChoiceField(queryset=Semester.objects.all())
    #num_weeks = forms.IntegerField()

    class Meta:
        model = Classroom
        fields = ['course','description','current_semester']

    def clean_description(self):
        if len(self.cleaned_data['description']) > 200:
            raise forms.ValidationError("Description name must not be longer than %d characters." % 200)          
        return self.cleaned_data['description']  

    def clean_course(self):
        if len(self.cleaned_data['course']) > 20:
            raise forms.ValidationError("Course must not be longer than %d characters." % 20)          
        return self.cleaned_data['course'] 

class AssignInstructorForm(forms.Form):
    instructor_id = forms.ModelChoiceField(queryset=Profile.objects.all(),required=False)
    group_description = forms.CharField(required=False)
    group_num = forms.IntegerField()
    rotation_group_id = forms.ModelChoiceField(queryset=RotationGroup.objects.all())


class AssignMultipleGroupsForm(forms.Form):
	CHOICES = tuple(RotationGroup.objects.all().values_list('id','group__group_number').order_by('group__group_number'))

	group_numbers = forms.MultipleChoiceField(
	    required=True,
	    widget=forms.CheckboxSelectMultiple,
	    choices = CHOICES,
	)  

	# def __init__(self, *args, **kwargs):
	# 	global CHOICES_GLOBAL
	# 	self.user = kwargs.pop('user', None)
	# 	# if self.user == None:
	# 	# 	CHOICES_GLOBAL = tuple()
	# 	# else:
	# 	CHOICES_GLOBAL = tuple(Group.objects.filter(classroom=self.user.current_classroom).values_list('id','group_number').order_by('group_number'))

	# 	super(AssignMultipleGroupsForm, self).__init__(*args, **kwargs)


class AssignMultipleStudentsForm(forms.Form):
	all_students = Student.objects.all().values_list('id','first_name','last_name').order_by('last_name')

	students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

	CHOICES_students = tuple(students_full_name)    
	#raise Exception("wutt")
	students = forms.MultipleChoiceField(
	    required=True,
	    widget=forms.CheckboxSelectMultiple,
	    choices=CHOICES_students,
	)

	def clean_students(self):
	    value = self.cleaned_data['students']
	    if len(value) > 4:
	        raise forms.ValidationError("You can't select more than 4 students.")
	    return value    