from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse, HttpResponseBadRequest, JsonResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.template.defaulttags import register
from django import forms
import django_excel as excel

from classroom.models import *

from userprofile.models import Profile

from .forms import *
MAX_STUDENTS = 5


## LEGACY CODE ################################
@register.filter
def get_groups_by_instructor(groups, instructor_pk):
    return groups.filter(current_instructor = instructor_pk)

@register.filter
def get_rotation_groups_by_rotation(rotation_groups,rotation_pk):
    return rotation_groups.filter(rotation = rotation_pk).order_by('group_number')


@register.filter
def get_number_groups(rotation):
    return RotationGroup.objects.filter(rotation=rotation.id).count()

@register.filter
def make_list(number):
    return range(number)

@register.filter
def get_students_list(students):
    g_students = list(students)
    group_size = 4
    for i in (range(group_size-len(g_students))): #Fill with nuns!
        g_students.append(None)
    return g_students


@register.filter
def get_rotation_groups(rotation_pk):
    return RotationGroup.objects.filter(rotation=rotation_pk).order_by('group_number')


@register.filter
def get_rotation_groups_by_instructor(rotation_groups,instructor_pk):
    return rotation_groups.filter(instructor = instructor_pk).order_by('group_number')

@register.filter
def get_rotation_groups_by_instructor_home(instructor, classroom):
    week = classroom.current_week
    return RotationGroup.objects.filter(rotation__start_week__lte=week,rotation__end_week__gte=week, instructor = instructor,rotation__semester=classroom.current_semester,rotation__classroom=classroom).order_by('group_number')

def register_class(request):
    form = AddClassroomForm(request.POST or None)
    if form.is_valid():
        classroom = form.save(commit=False)
        classroom.instructor = request.user
        try:
            classroom.save()
            messages.add_message(request, messages.SUCCESS, 'Classroom successfully registered!')
        except Exception as e:
            messages.add_message(request, messages.ERROR, "An error occurred when attempting to register the class: "+str(e))
        return HttpResponseRedirect('/dashboard/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/dashboard/')     


class AddEditRotation(SuperuserRequiredMixin,TemplateView):

    def post(self, *args, **kwargs):
        form = AddEditRotationForm(self.request.POST or None)
        if form.is_valid():
            rotation = form.cleaned_data['rotation_pk'] 
            try:
                if rotation:
                    rotation.start_week = form.cleaned_data['start_week']
                    rotation.end_week = form.cleaned_data['end_week']
                    rotation.length = rotation.end_week - rotation.start_week
                    rotation.save()
                    messages.add_message(self.request, messages.SUCCESS, 'Successfully edited rotation.')
                else:
                    new_rotation = form.save(commit=False)
                    new_rotation.classroom = form.cleaned_data['classroom']
                    new_rotation.semester = form.cleaned_data['semester'] 
                    new_rotation.length = new_rotation.end_week - new_rotation.start_week
                    new_rotation.save()                    
                    messages.add_message(self.request, messages.SUCCESS, 'Successfully created rotation.')
            except Exception as e:
                messages.add_message(self.request, messages.ERROR, 'Unable to edit/add rotation.%s' % e)
        else:
            messages.error(self.request, form.errors)

        return HttpResponseRedirect('/dashboard/')


def edit_classroom(request, pk):
    form = EditClassroomForm(request.POST or None)
    if form.is_valid():

        try:
            classroom = Classroom.objects.get(id = pk)
        except Exception as e:
            messages.add_message(request, messages.ERROR, "Could not edit classroom: "+e)  
            return HttpResponseRedirect(reverse('dash-manage-users'))

        classroom.course_number = form.cleaned_data['course_number']
        classroom.course_code = form.cleaned_data['course_code']
        classroom.description = form.cleaned_data['description']
        classroom.current_week = form.cleaned_data['current_week']
        current_classroom_flag = form.cleaned_data['current_classroom']
        classroom.current_semester = form.cleaned_data['current_semester']

        if current_classroom_flag:
            request.user.current_classroom = classroom
            request.user.save()
            messages.add_message(request, messages.SUCCESS, "Set classroom as current. ")          

        classroom.save()
        messages.add_message(request, messages.SUCCESS, "Classroom successfully edited! ")  
        return HttpResponseRedirect(reverse('dash-home'))
    else:
        messages.error(request, form.errors)   
        return HttpResponseRedirect(reverse('dash-home'))


# Sets the number of rotation groups in a particular rotation.
def add_group(request):
	form = AddGroupForm(request.POST or None)
	userid = request.user.id
	user = request.user
	if form.is_valid():
		group_number = form.cleaned_data['group_number'] 
		number_of_groups = form.cleaned_data['number_of_groups']
		#classroom = request.user.current_classroom
		rotation = form.cleaned_data['rotation']
		list_group_num = []
 
		original_rotation_groups = rotation.get_rotation_groups()
		original_rotation_groups_count = original_rotation_groups.count()

		difference = original_rotation_groups_count - number_of_groups


		if number_of_groups != 0:
			list_group_num = [x for x in range(1,number_of_groups+1)]  
		else:
			list_group_num = []
		added_count = 0
		removed_count = 0

		to_remove = []
		if difference > 0:
			for group_index in range(len(list_group_num),(len(list_group_num)+difference)):
				group = original_rotation_groups[group_index]
				to_remove.append(group)
				removed_count += 1
		else:
			for group_num in list_group_num:
			
				try:
					group = original_rotation_groups.get(group_number=group_num)			   			
				except RotationGroup.DoesNotExist:
					group = RotationGroup.objects.create(group_number=group_num,rotation=rotation)
					added_count += 1
					group.save()

			

		if added_count: 				
			messages.add_message(request, messages.SUCCESS, 'Groups (%s) successfully added!' % str(added_count))
		elif removed_count:
			for group in to_remove:
				group.delete()
			messages.add_message(request, messages.SUCCESS, 'Groups (%s) successfully removed.' % str(removed_count))
		else:
			messages.add_message(request, messages.WARNING, 'No groups were added.')  
          				
	else: 
		messages.error(request, form.errors)
	return HttpResponseRedirect('/classroom/') 

def add_student(request):
    form = AddStudentForm(request.POST or None)

    userid = request.user.id
    user = request.user
    if form.is_valid(): 
        student = form.save(commit=False)                    
        student.save()
        messages.add_message(request, messages.SUCCESS, 'Student successfully added!')
        return HttpResponseRedirect('/classroom/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/') 


class DeleteAllStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, View):
	""" delete goal view
	"""
	def post(self, *args, **kwargs):
		try: 
			classroom = Classroom.objects.get(id=kwargs['pk'])
		except Exception as e:
			messages.add_message(self.request, messages.ERROR, 'Unable to delete students from this classroom %s' % classroom)
		finally:
			students_to_delete = Student.objects.filter(classroom=classroom,semester=classroom.current_semester)
			students_to_delete.delete()

			messages.add_message(self.request, messages.SUCCESS, 'Students successfully deleted!')
		return HttpResponseRedirect(reverse('classroom-home'))

def edit_student(request, pk):
    

    try:
        student = Student.objects.get(id=pk)
    except Exception as e:
        messages.add_message(request, messages.ERROR, 'something bad happened: '+ e)
        return HttpResponseRedirect('/classroom/')

    form = AddStudentForm(request.POST or None, instance=student)

    if form.is_valid():
        form.save()
        messages.add_message(request, messages.SUCCESS, 'Student successfully saved!')
        return HttpResponseRedirect('/classroom/')        
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/')         

class UploadFileForm(forms.Form):
    file = forms.FileField()
    classroom = forms.ModelChoiceField(queryset=Classroom.objects.all(),widget=forms.HiddenInput())


# Assign / Unassign mulitple rotation groups from an instructor in a particular rotation
class AssignMultipleGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    context = {} 

    def post(self, *args, **kwargs):
        form = AssignMultipleGroupsForm(self.request.POST or None)
        if form.is_valid():
            checked_groups = form.cleaned_data['group_numbers']
            rotation = form.cleaned_data['rotation_pk']
            try:
                instructor = Profile.objects.get(id=kwargs['pk'])
            except Exception as e:
                messages.add_message(self.request, messages.ERROR, 'Unable to assign to this instructor %s' % e)  
                return HttpResponseRedirect('/classroom/')

            # First, unassign all currently assigned groups from instructor
            assigned_groups = RotationGroup.objects.filter(rotation=rotation,instructor=instructor)
            for group in assigned_groups:
                group.instructor = None
                group.save()

            if not checked_groups:
                messages.add_message(self.request, messages.SUCCESS, 'Successfully unassigned all groups from this instructor.')

            # Second, assign all checked groups to instructor
            for group_pk in checked_groups:
                #
                try:
                    group = RotationGroup.objects.get(id = group_pk)
                    group.instructor = instructor
                    group.save()
                    messages.add_message(self.request, messages.SUCCESS, 'Successfully assigned group '+str(group.group_number)+' to %s' % instructor.get_full_name())
                except Exception as e:
                    messages.add_message(self.request, messages.ERROR, 'Unable to assign group numbers to this instructor %s' % e) 
            return HttpResponseRedirect('/classroom/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/classroom/')                 

# Assign / Unassign mulitple students from a group in a particular rotation
class AssignMultipleStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    context = {} 

    def post(self, *args, **kwargs):
        form = AssignMultipleStudentsForm(self.request.POST or None)
        if form.is_valid():
            checked_students = form.cleaned_data['students']

            try:
                group = RotationGroup.objects.get(id=kwargs['pk'])
            except Exception as e:
                messages.add_message(self.request, messages.ERROR, 'Unable to assign to this group %s' % e)  
                return HttpResponseRedirect('/classroom/')

            # First, clear all current students from the rotation group 
            group.students.clear()

            count = group.students.count()
            successfully_added = []

            # Second, add all checked students to the rotation group
            for student_pk in checked_students:
                
                    try:
                        student = Student.objects.get(id = student_pk)
                        if count != MAX_STUDENTS:
                            exists =  RotationGroup.objects.filter(rotation=group.rotation,students__id=student.id)
                            # Remove existing students from other groups
                            for exist in exists:
                                exist.students.remove(student)

                            group.students.add(student)
                            successfully_added.append(student.first_name + ' ' + student.last_name)
                        else:
                            messages.add_message(self.request, messages.WARNING, 'Could not add '+ student.first_name + ' ' + student.last_name + ' to group - already 4 members') 
                    except Exception as e:
                        messages.add_message(self.request, messages.ERROR, 'Unable to assign student ' + student.first_name + ' ' + student.last_name + ' %s' % e) 

                    count = group.students.count()

            if successfully_added:
                messages.add_message(self.request, messages.SUCCESS, 'Successfully added '+ ", ".join(successfully_added) + ' to group.')
            if not checked_students:
                messages.add_message(self.request, messages.SUCCESS, 'Successfully unassigned all students from group.')

            return HttpResponseRedirect('/classroom/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/classroom/')     


# Assign one particular rotation group to an instructor 
class AssignGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    context = {}    

    def post(self, *args, **kwargs):
        form = AssignInstructorForm(self.request.POST or None)

        if form.is_valid():
            instructor = form.cleaned_data['instructor_id']
            rotation_group =  form.cleaned_data['rotation_group_id']
            group_num = form.cleaned_data['group_num']
            group_description = form.cleaned_data['group_description']
            classroom = self.request.user.current_classroom

            try:
                rotation_group.instructor = instructor
                rotation_group.description = group_description
                rotation_group.save()
                messages.add_message(self.request, messages.SUCCESS, 'Successfully edited group!')                
            except Exception as e:
                messages.add_message(self.request, messages.ERROR, 'Unable to assign this group to this instructor %s' % e)      
            return HttpResponseRedirect('/classroom/')                
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/classroom/')              

# Excel upload of students - must use the correct excel template to be successful
class UploadStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ upload students
    """
    template_name = 'upload_students.html'
    context = {}
    count = 0
    email_already_exist = 0    

    def get(self, request, *args, **kwargs):
        form = UploadFileForm()

        classroom = self.request.user.current_classroom
        if classroom != None:

            students = Student.objects.filter(classroom=classroom,semester=classroom.current_semester).order_by('last_name')                 
            return render(self.request, self.template_name,
            {
                'title': 'Upload Students',
                'header': ('Please choose an excel file to upload'),
                'students': students,
                'classroom': classroom,
                'upload_view': True,
            }) 
        else:
            messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
            return HttpResponseRedirect(reverse('dash-home'))                 

    def post(self, *args, **kwargs):
        form = UploadFileForm(self.request.POST, self.request.FILES)
        self.count = 0
        self.email_already_exist = 0
        
        # Row function to configure each row in excel sheet
        # Automatically configures classroom and semester based on context
        # Leave classroom and semester blank in excel sheet (Headers still needed)
        def class_semester_func(row):

            row[4] = classroom
            row[5] = classroom.current_semester

            if not Student.objects.filter(email=row[2]).count():
                self.count += 1  
            else:
                self.email_already_exist += 1            
            return row
        if form.is_valid():
            classroom  = form.cleaned_data['classroom']

            self.request.FILES['file'].save_to_database(
                model = Student,
                mapdict= {"First_Name": "first_name",
                          "Last_Name": "last_name",
                          "Email": "email",
                          'Notes':'notes',
                          "Classroom":"classroom",
                          "Semester":"semester"
                          },
                initializer = class_semester_func)

            self.add_message( str(self.count) + " Students successfully added!")
            self.add_message(str(self.email_already_exist) + " Students were not added because their email address already exists.")

            return HttpResponseRedirect(reverse('classroom-upload-students'))
        else:
            self.add_message("Form not valid, failed to add students.")          
            return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text) 


class DeleteRotation(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ delete student view
    """
    def get(self, *args, **kwargs):
        try:
            rotation = Rotation.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this rotation %s' % e)
        finally:
            rotation.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Rotation successfully deleted!')
        return HttpResponseRedirect('/dashboard/') 


class DeleteStudent(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ delete student view
    """
    def get(self, *args, **kwargs):
        try:
            student = Student.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this student %s' % e)
        finally:
            student.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Student successfully deleted!')
        return HttpResponseRedirect('/classroom/') 

class DeleteGroup(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ delete group view
    """
    def get(self, *args, **kwargs):
        try:
            rotation_group = RotationGroup.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this group %s' % e)
        finally:
            rotation_group.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Group successfully deleted!')
        return HttpResponseRedirect('/classroom/') 



class ClassroomView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ dashboard page, manage users
    """
    template_name = 'classroom.html'
    context = {}

    def get(self, *args, **kwargs):

        classroom = self.request.user.current_classroom
        if classroom != None:
            students = Student.objects.filter(classroom=classroom,semester=classroom.current_semester).order_by('last_name')

            rotation_groups = RotationGroup.objects.filter(rotation__semester=classroom.current_semester,rotation__classroom=classroom).order_by('group_number')

            learning_assistants = Profile.objects.filter(current_classroom = classroom).order_by('last_name')
            assign_instructor_form = AssignInstructorForm()
            assign_instructor_form.fields['instructor_id'].choices = [(la[0],la[1]+' '+la[2]) for la in learning_assistants.values_list('id','first_name','last_name').order_by('last_name')]
          

            add_student_form1 = AddStudentForm()

            assign_groups_form = AssignMultipleGroupsForm()
            assign_groups_form.fields['group_numbers'].choices = rotation_groups.values_list('id','group_number').order_by('group_number')


            assign_students_form = AssignMultipleStudentsForm()
            all_students = students.values_list('id','first_name','last_name').order_by('last_name')

            students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

            CHOICES_students = tuple(students_full_name)        
            assign_students_form.fields['students'].choices = CHOICES_students

            return render(self.request, self.template_name,
            {
                'students': students,
                'learning_assistants':learning_assistants,
                'title': "Classroom",
                'rotation_groups': rotation_groups,
                'classroom': classroom,
                'add_student_form': add_student_form1,
                'add_group_form': AddGroupForm(),
                'add_classroom_form': AddClassroomForm(),
                'assign_multiple_groups_form': assign_groups_form,
                'assign_multiple_students_form': assign_students_form,
                'assign_instructor_form': assign_instructor_form,
                'upload_view': False,
            })
        else:
            messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
            return HttpResponseRedirect(reverse('dash-home'))             


    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text) 


# def download(request, file_type):
#     sheet = excel.pe.Sheet(data)
#     return excel.make_response(sheet, file_type)


# def download_as_attachment(request, file_type, file_name):
#     return excel.make_response_from_array(
#         data, file_type, file_name=file_name)


# def export_data(request, atype):
#     if atype == "sheet":
#         return excel.make_response_from_a_table(
#             Question, 'xls', file_name="sheet")
#     elif atype == "book":
#         return excel.make_response_from_tables(
#             [Question, Choice], 'xls', file_name="book")
#     elif atype == "custom":
#         question = Question.objects.get(slug='ide')
#         query_sets = Choice.objects.filter(question=question)
#         column_names = ['choice_text', 'id', 'votes']
#         return excel.make_response_from_query_sets(
#             query_sets,
#             column_names,
#             'xls',
#             file_name="custom"
#         )
#     else:
#         return HttpResponseBadRequest(
#             "Bad request. please put one of these " +
#             "in your url suffix: sheet, book or custom")


# def import_data(request):
#     if request.method == "POST":
#         form = UploadFileForm(request.POST,
#                               request.FILES)

#         def choice_func(row):
#             q = Question.objects.filter(slug=row[0])[0]
#             row[0] = q
#             return row
#         if form.is_valid():
#             request.FILES['file'].save_book_to_database(
#                 models=[Question, Choice],
#                 initializers=[None, choice_func],
#                 mapdicts=[
#                     ['question_text', 'pub_date', 'slug'],
#                     ['question', 'choice_text', 'votes']]
#             )
#             return HttpResponse("OK", status=200)
#         else:
#             return HttpResponseBadRequest()
#     else:
#         form = UploadFileForm()
#     return render(
#         request,
#         'upload_form.html',
#         {
#             'form': form,
#             'title': 'Import excel data into database example',
#             'header': 'Please upload sample-data.xls:'
#         })


# def import_sheet(request):
#     if request.method == "POST":
#         form = UploadFileForm(request.POST,
#                               request.FILES)
#         if form.is_valid():
#             request.FILES['file'].save_to_database(
#                 name_columns_by_row=2,
#                 model=Student,
#                 mapdict=['question_text', 'pub_date', 'slug'])
#             return HttpResponse("OK")
#         else:
#             return HttpResponseBadRequest()
#     else:
#         form = UploadFileForm()
#     return render(
#         request,
#         'upload_form.html',
#         {'form': form})


# def exchange(request, file_type):
#     form = UploadFileForm(request.POST, request.FILES)
#     if form.is_valid():
#         filehandle = request.FILES['file']
#         return excel.make_response(filehandle.get_sheet(), file_type)
#     else:
#         return HttpResponseBadRequest()


# def parse(request, data_struct_type):
#     form = UploadFileForm(request.POST, request.FILES)
#     if form.is_valid():
#         filehandle = request.FILES['file']
#         if data_struct_type == "array":
#             return JsonResponse({"result": filehandle.get_array()})
#         elif data_struct_type == "dict":
#             return JsonResponse(filehandle.get_dict())
#         elif data_struct_type == "records":
#             return JsonResponse({"result": filehandle.get_records()})
#         elif data_struct_type == "book":
#             return JsonResponse(filehandle.get_book().to_dict())
#         elif data_struct_type == "book_dict":
#             return JsonResponse(filehandle.get_book_dict())
#         else:
#             return HttpResponseBadRequest()
#     else:
#         return HttpResponseBadRequest()