from django import forms
from django.forms import ModelForm
from django.contrib.auth.models import User
from .models import *
from datetime import date
from userprofile.models import Profile


class AddSemesterForm(forms.ModelForm):
    date_begin = forms.DateField()
    date_end = forms.DateField()
    title = models.CharField(max_length=200)

    class Meta:
        model = Semester  
        fields = ['date_begin','date_end','title']

class AddEditRotationForm(forms.ModelForm):
    start_week = forms.IntegerField(min_value=1,required=True)
    end_week = forms.IntegerField(min_value=1,required=True)
    rotation_pk = forms.ModelChoiceField(queryset=Rotation.objects.all(),widget=forms.HiddenInput(),required=False)
  #  length = forms.IntegerField(min_value=1,required=False)
    classroom = forms.ModelChoiceField(queryset=Classroom.objects.all(),widget=forms.HiddenInput(),required=False)
    semester = forms.ModelChoiceField(queryset=Semester.objects.all(),widget=forms.HiddenInput(),required=False)    

    class Meta:
        model = Rotation
        fields = ['start_week','end_week']


    # def clean_classroom(self):
    #     # try:
    #     #     classroom = Classroom.objects.get(id=self.data.get('classroom'))
    #     # except Classroom.DoesNotExist:
    #     try:
    #         rotation = Rotation.objects.get(id=self.data.get('rotation_pk'))
    #         return rotation.classroom
    #     except Rotation.DoesNotExist:
    #         return self.cleaned_data['classroom']                

    # def clean_semester(self):
    #     # try:
    #     #     semester = Classroom.objects.get(id=self.data.get('semester'))
    #     # except Semester.DoesNotExist:
    #     try:
    #         rotation = Rotation.objects.get(id=self.data.get('rotation_pk'))
    #         #semester = rotation.semester
    #         return rotation.semester
    #     except Rotation.DoesNotExist:
    #         return self.cleaned_data['semester']   
    #         #raise forms.ValidationError("Error. Could not edit rotation.")

        

    def clean_start_week(self):
        rotation = None
        # try:        
        #     semester = Semester.objects.get(id=self.data.get('semester'))
        # except Semester.DoesNotExist:
        #     semester = None
        try:        
            semester = Semester.objects.get(id=self.data.get('semester'))
        except Semester.DoesNotExist:
            semester = None
        #classroom = self.cleaned_data['classroom']
       # semester = self.cleaned_data['semester']
        try:
            classroom = Classroom.objects.get(id=self.data.get('classroom'))  
        except Classroom.DoesNotExist:
            classroom = None

        if semester == None:
            rotation = Rotation.objects.get(id=self.data.get('rotation_pk'))
            semester = rotation.semester
            classroom = rotation.classroom            

        # try:
        #     classroom = Classroom.objects.get(id=self.data.get('classroom'))  
        # except Classroom.DoesNotExist:
        #     classroom = None

       # if semester == None: #or clasroom, really


        rotations = Rotation.objects.filter(semester=semester,classroom=classroom)
        if rotation:
            rotations = rotations.exclude(id=rotation.id)
      #  raise Exception("what")
        if rotations.filter(semester=semester,classroom=classroom,start_week=self.cleaned_data['start_week']):
            raise forms.ValidationError("Rotation already exists at this start week.")
        for rotation in rotations:
            if int(self.cleaned_data['start_week']) < rotation.start_week+rotation.length and int(self.cleaned_data['start_week']) >= rotation.start_week:
                raise forms.ValidationError("Rotation cannot exist within another rotation.")
        if int(self.data.get('end_week')) > (semester.get_number_weeks()+1):
            raise forms.ValidationError("Rotation cannot be longer than the semester length.")
        return self.cleaned_data['start_week']

    def clean_end_week(self):
        rotation = None
        try:        
            semester = Semester.objects.get(id=self.data.get('semester'))
        except Semester.DoesNotExist:
            semester = None
        #classroom = self.cleaned_data['classroom']
       # semester = self.cleaned_data['semester']
        try:
            classroom = Classroom.objects.get(id=self.data.get('classroom'))  
        except Classroom.DoesNotExist:
            classroom = None

        if semester == None: #or clasroom, really
            rotation = Rotation.objects.get(id=self.data.get('rotation_pk'))
            semester = rotation.semester
            classroom = rotation.classroom

        rotations = Rotation.objects.filter(semester=semester,classroom=classroom)
        if rotation:
            rotations = rotations.exclude(id=rotation.id)

        if int(self.data.get('start_week')) >= int(self.cleaned_data['end_week']):
            raise forms.ValidationError("End week cannot be equal to or less than start week.")
        for rotation in rotations:
            if int(self.data.get('end_week')) > rotation.start_week and int(self.data.get('start_week')) < rotation.start_week:
                raise forms.ValidationError("End week cannot be greater than other rotations start week.")            
        return self.cleaned_data['end_week']

class EditClassroomForm(forms.Form):
    course_code = forms.CharField(required=True)
    course_number = forms.CharField(required=True)
    description = forms.CharField(required=False)
   # num_weeks = forms.IntegerField(required=True)
    current_week = forms.IntegerField(required=True)
    current_classroom = forms.BooleanField(required=False)
    current_semester = forms.ModelChoiceField(queryset=Semester.objects.all(),required=True)

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
    email = forms.EmailField(required=False)
   # student_id = forms.CharField()
    #group_number = forms.IntegerField(required=False)
    classroom = forms.ModelChoiceField(queryset=Classroom.objects.all(),required=False)
    semester = forms.ModelChoiceField(queryset=Semester.objects.all(),required=False)

    class Meta:
        model = Student
        fields = ['first_name','last_name','email','notes','semester','classroom']

    def clean_first_name(self):
        if len(self.cleaned_data['first_name']) > 30:
            raise forms.ValidationError("First name must not be longer than %d characters." % 30)          
        return self.cleaned_data['first_name']

    def clean_last_name(self):
        if len(self.cleaned_data['last_name']) > 30:
            raise forms.ValidationError("Last name must not be longer than %d characters." % 30)          
        return self.cleaned_data['last_name']

class AddGroupForm(forms.Form):

    group_number = forms.IntegerField(required=False)
    number_of_groups = forms.IntegerField(required=True)
    rotation = forms.ModelChoiceField(queryset=Rotation.objects.all())

    def clean_number_of_groups(self):
        if self.cleaned_data['number_of_groups'] < 0:
            raise forms.ValidationError("Number of groups must be greater than or equal to zero.")          
        return self.cleaned_data['number_of_groups']       

class AddClassroomForm(forms.ModelForm):

    description = forms.CharField(required=False)
    course_code = forms.CharField()
    course_number = forms.CharField()
    current_semester = forms.ModelChoiceField(queryset=Semester.objects.all())
    #num_weeks = forms.IntegerField()

    class Meta:
        model = Classroom
        fields = ['course_code','course_number','description','current_semester']

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
	#CHOICES = tuple(RotationGroup.objects.all().values_list('id','group_number').order_by('group_number'))
	rotation_pk = forms.ModelChoiceField(queryset=Rotation.objects.all(),widget=forms.HiddenInput())
	# group_numbers = forms.MultipleChoiceField(
	#     required=True,
	#     widget=forms.CheckboxSelectMultiple,
	#     choices = CHOICES,
	# )  
	group_numbers = forms.MultipleChoiceField(
		required=False,
		widget=forms.CheckboxSelectMultiple,
		choices = [],
	) 
	def __init__(self, *args, **kwargs):
		super(AssignMultipleGroupsForm, self).__init__(*args, **kwargs)   
		#self.fields['group_numbers'].choices = choices
		self.fields['group_numbers'].choices = tuple(RotationGroup.objects.all().values_list('id','group_number').order_by('group_number'))    
	# def __init__(self, *args, **kwargs):
	# 	global CHOICES_GLOBAL
	# 	self.user = kwargs.pop('user', None)
	# 	# if self.user == None:
	# 	# 	CHOICES_GLOBAL = tuple()
	# 	# else:
	# 	CHOICES_GLOBAL = tuple(Group.objects.filter(classroom=self.user.current_classroom).values_list('id','group_number').order_by('group_number'))

	# 	super(AssignMultipleGroupsForm, self).__init__(*args, **kwargs)


class AssignMultipleStudentsForm(forms.Form):
	# all_students = Student.objects.all().values_list('id','first_name','last_name').order_by('last_name')

	# students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

	# CHOICES_students = tuple(students_full_name)    
	#raise Exception("wutt")
	students = forms.MultipleChoiceField(
	    required=False,
	    widget=forms.CheckboxSelectMultiple,
	    choices=[],
	)
	def __init__(self, *args, **kwargs):
	    super(AssignMultipleStudentsForm, self).__init__(*args, **kwargs)
	    all_students = Student.objects.all().values_list('id','first_name','last_name').order_by('last_name')

	    students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

	    CHOICES_students = tuple(students_full_name)       
	    self.fields['students'].choices = CHOICES_students     

	def clean_students(self):
	    value = self.cleaned_data['students']
	    if len(value) > 5:
	        raise forms.ValidationError("You can't select more than 5 students.")
	    return value    