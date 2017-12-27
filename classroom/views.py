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
MAX_STUDENTS = 4


## LEGACY CODE ################################
@register.filter
def get_groups_by_instructor(groups, instructor_pk):
    return groups.filter(current_instructor = instructor_pk)

@register.filter
def get_rotation_groups_by_rotation(rotation_groups,rotation_pk):
    return rotation_groups.filter(rotation = rotation_pk)


@register.filter
def get_students_by_group(students, group_pk):
    group = Group.objects.get(id=group_pk)
    try:
        g_students = list(students.filter(group=group))
        group_size = 4
        for i in (range(group_size-len(g_students))): #Fill with nuns!
            g_students.append(None)
        return g_students
    except Student.DoesNotExist:
        return None
## ######################################## ##
@register.filter
def get_rotation_groups(rotation_pk):
    return RotationGroup.objects.filter(rotation=rotation_pk)


@register.filter
def get_rotation_groups_by_instructor(rotation_groups,instructor_pk):
    return rotation_groups.filter(instructor = instructor_pk)

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

def edit_rotation(request):
    form = AddEditRotationForm(request.POST or None)
    if form.is_valid():
        rotation = form.save(commit=False)
        # try:
            # rotation.classroom = Classroom.objects.getc(id=form.cleaned_data['classroom'])
            # rotation.semester = Semester.objects.get(id=form.cleaned_data['semester'])
        rotation.save()
        

        messages.add_message(request, messages.SUCCESS, 'Rotation successfully created!')
            # try:
            #     groups = Group.objects.filter(classroom=rotation.classroom)
            #     for group in groups:
            #         new_rotation_group = RotationGroup(rotation=rotation,group=group)
            # except Exception as e:
            #     messages.add_message(request, messages.ERROR, "An error occurred when attempting to create the rotation GROUPS: "+str(e))  

        # except Exception as e:
        #     messages.add_message(request, messages.ERROR, "An error occurred when attempting to create the rotation: "+str(e))          
    else:
        messages.error(request, form.errors)
    return HttpResponseRedirect('/dashboard/') 

def edit_classroom(request, pk):
    form = EditClassroomForm(request.POST or None)
    #raise Exception("hello")
    if form.is_valid():

        try:
            classroom = Classroom.objects.get(id = pk)
        except Exception as e:
            messages.add_message(request, messages.ERROR, "Could not edit classroom: "+e)  
            return HttpResponseRedirect(reverse('dash-manage-users'))

        classroom.course = form.cleaned_data['course']
        classroom.description = form.cleaned_data['description']
        classroom.current_week = form.cleaned_data['current_week']
        current_classroom_flag = form.cleaned_data['current_classroom']
        classroom.current_semester = form.cleaned_data['current_semester']
#        classroom.num_weeks = form.cleaned_data['num_weeks']


        if current_classroom_flag:
            request.user.current_classroom_id = pk
            request.user.save()
            messages.add_message(request, messages.SUCCESS, "Set classroom as current. ")          

        classroom.save()
        messages.add_message(request, messages.SUCCESS, "Classroom successfully edited! ")  
        return HttpResponseRedirect(reverse('dash-home'))
    else:
        messages.error(request, form.errors)   
        return HttpResponseRedirect(reverse('dash-home'))


def add_group(request):
    form = AddGroupForm(request.POST or None)
    userid = request.user.id
    user = request.user
    if form.is_valid():
        group_num = form.cleaned_data['group_number'] 
        classroom = request.user.current_classroom
        rotation = form.cleaned_data['rotation']
        group = Group.objects.create(group_number=group_num)
        try:
            group = Group.objects.get(group_number=group_num,classroom=classroom)
            try:
                rotation_group = RotationGroup.objects.get(rotation=rotation,group=group)            
                messages.add_message(request, messages.ERROR, 'Group already exists. ')
            except RotationGroup.DoesNotExist:
                group.create_rotation_group(rotation)
                messages.add_message(request, messages.SUCCESS, 'Group successfully added!')
        except Group.DoesNotExist:
            group.classroom = classroom
            group.save()
            group.create_rotation_group(rotation)            
            messages.add_message(request, messages.SUCCESS, 'Group successfully added!')
        return HttpResponseRedirect('/classroom/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/') 

def add_student(request):
    form = AddStudentForm(request.POST or None)

    userid = request.user.id
    user = request.user
    if form.is_valid():
        group_num = form.cleaned_data['group_number'] 
        class_pk = form.cleaned_data['classroom_pk']  

        student = form.save(commit=False)     
        if group_num:
            try:
                group = Group.objects.get(group_number=group_num)
                student.group = group
            except Group.DoesNotExist:
                messages.add_message(request, messages.WARNING, 'Group number ' + str(group_num) + ' was not found. Please create group before assigning to students.')                
                student.group = None

        if class_pk:
            try:
                classroom = Classroom.objects.get(id=class_pk)
                student.classroom = classroom
            except Classroom.DoesNotExist:
                messages.add_message(request, messages.WARNING, 'Classroom id: ' + str(class_pk) + ' was not found.')                
                student.classroom = None                 
        student.save()
        messages.add_message(request, messages.SUCCESS, 'Student successfully added!')
        return HttpResponseRedirect('/classroom/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/') 


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
    classroom = forms.CharField(widget=forms.HiddenInput())





# class AssignMultipleStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
#     """ assign students to groups
#     """
#     context = {} 

#     def post(self, *args, **kwargs):
#         form = AssignMultipleStudentsForm(self.request.POST or None)
#         if form.is_valid():
#             checked_groups = form.cleaned_data['group_numbers']
#             try:
#                 instructor = Profile.objects.get(id=kwargs['pk'])
#             except Exception as e:
#                 messages.add_message(self.request, messages.ERROR, 'Unable to assign to this instructor %s' % e)  
#                 return HttpResponseRedirect('/classroom/')

#             for group_pk in checked_groups:
#                 try:
#                     group = Group.objects.get(id = group_pk)
#                     group.current_instructor = instructor
#                     group.save()
#                 except Exception as e:
#                     messages.add_message(self.request, messages.ERROR, 'Unable to assign group numbers to this instructor %s' % e) 
#             return HttpResponseRedirect('/classroom/')
#         else:
#             messages.error(self.request, form.errors)
#             return HttpResponseRedirect('/classroom/')  



class AssignMultipleGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    context = {} 

    def post(self, *args, **kwargs):
        form = AssignMultipleGroupsForm(self.request.POST or None)
        if form.is_valid():
            checked_groups = form.cleaned_data['group_numbers']
            try:
                instructor = Profile.objects.get(id=kwargs['pk'])
            except Exception as e:
                messages.add_message(self.request, messages.ERROR, 'Unable to assign to this instructor %s' % e)  
                return HttpResponseRedirect('/classroom/')

            for group_pk in checked_groups:
                try:
                    group = RotationGroup.objects.get(id = group_pk)
                    group.instructor = instructor
                    group.save()
                    messages.add_message(self.request, messages.SUCCESS, 'Successfully assigned group to %s' % instructor.get_full_name())
                except Exception as e:
                    messages.add_message(self.request, messages.ERROR, 'Unable to assign group numbers to this instructor %s' % e) 
            return HttpResponseRedirect('/classroom/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/classroom/')                 


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

            count = group.students.count()
            for student_pk in checked_students:
                
                    try:
                        student = Student.objects.get(id = student_pk)
                        if count != MAX_STUDENTS:
                            exists =  RotationGroup.objects.filter(rotation=group.rotation,students__id=student.id)
                            #remove existing students from other groups
                                #messages.add_message(self.request, messages.ERROR, ' '+ student.first_name + ' ' + student.last_name + ' exists ') 
                            for exist in exists:
                                exist.students.remove(student)

                            group.students.add(student)
                            messages.add_message(self.request, messages.SUCCESS, 'Successfully added '+ student.first_name + ' ' + student.last_name + ' to group!') 
                        else:
                            messages.add_message(self.request, messages.WARNING, 'Could not add '+ student.first_name + ' ' + student.last_name + ' to group - already 4 members') 
                    except Exception as e:
                        messages.add_message(self.request, messages.ERROR, 'Unable to assign student ' + student.first_name + ' ' + student.last_name + ' %s' % e) 

                    count = group.students.count()

            return HttpResponseRedirect('/classroom/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/classroom/')     



class AssignGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    #template_name = 'assign_groups.html'
    context = {}    

    def post(self, *args, **kwargs):
        #raise Exception("what")
        form = AssignInstructorForm(self.request.POST or None)

        if form.is_valid():
            instructor = form.cleaned_data['instructor_id']
            rotation_group =  form.cleaned_data['rotation_group_id']
            group_num = form.cleaned_data['group_num']
            group_description = form.cleaned_data['group_description']
            classroom = self.request.user.current_classroom

            # try:
            #     group = RotationGroup.objects.get(
            # except Exception as e:
            #     messages.add_message(self.request, messages.ERROR, 'Unable to access this group %s' % e)
            #     return HttpResponseRedirect('/classroom/')   

            try:
               # instructor = Profile.objects.get(id=instructor_pk)
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


class UploadStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ upload students
    """
    template_name = 'upload_students.html'
    context = {}    

    def get(self, request, *args, **kwargs):
        form = UploadFileForm()


        current_classroom_pk = self.request.user.current_classroom_id
        if current_classroom_pk:
            try:
                classroom = Classroom.objects.get(id=current_classroom_pk)
            except Classroom.DoesNotExist:
                classroom = None
                self.add_message("Error when trying to load current classroom.")
        else:
            self.add_message("No current classroom is set. Please visit the dashboard to set a current classroom.") 

        students = Student.objects.filter(classroom=classroom).order_by('last_name')
        groups = Group.objects.filter(classroom=classroom).order_by('group_number')                   
       # classroom = Classroom.objects.get(instructor = self.request.user)
        add_student_form = AddStudentForm()
        return render(self.request, self.template_name,
        {
            'form': form,
            'title': 'Excel file upload and download example',
            'header': ('Please choose any excel file ' +
                       'from your cloned repository:'),
            'students': students,
            'classroom': classroom,
            'add_student_form': add_student_form,
            'upload_view': True,
        }) 

    def post(self, *args, **kwargs):
        form = UploadFileForm(self.request.POST, self.request.FILES)
        def group_class_func(row):
            try:
                classroom = Classroom.objects.get(id=classroom_pk)

            except Classroom.DoesNotExist:
                classroom = None     
            try:
                group = Group.objects.get(group_number=row[2])
            except Group.DoesNotExist:
                group = None 
            row[2] = group   
            row.pop()
            row.append(classroom)  
           # print(row)               
            return row
        if form.is_valid():
            classroom_pk = form.cleaned_data['classroom']   

            self.request.FILES['file'].save_to_database(
                model = Student,
                mapdict= {"First_Name": "first_name",
                          "Last_Name": "last_name",
                          "Group_Number": "group",
                          "Student_ID": "student_id",
                          "Classroom_ID": "classroom"}, 
                initializer = group_class_func)
            self.add_message("Students successfully added!") 
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



class UploadGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ upload groups
    """
    template_name = 'upload_groups.html'
    context = {}    

    def get(self, request, *args, **kwargs):
        form = UploadFileForm()


        current_classroom_pk = self.request.user.current_classroom_id
        if current_classroom_pk:
            try:
                classroom = Classroom.objects.get(id=current_classroom_pk)
            except Classroom.DoesNotExist:
                classroom = None
                self.add_message("Error when trying to load current classroom.")
        else:
            self.add_message("No current classroom is set. Please visit the dashboard to set a current classroom.")  

        students = Student.objects.filter(classroom=classroom).order_by('last_name')
        groups = Group.objects.filter(classroom=classroom).order_by('group_number')
       # classroom = Classroom.objects.get(instructor = self.request.user)
        return render(self.request, self.template_name,
        {
            'form': form,
            'add_group_form': AddGroupForm(),
            'title': 'Excel file upload and download example',
            'header': ('Please choose any excel file ' +
                       'from your cloned repository:'),
            'groups': groups,
            'classroom': classroom,
            'students': students,
            'upload_view': True,
        }) 

    def post(self, *args, **kwargs):
        form = UploadFileForm(self.request.POST, self.request.FILES)
        def classroom_func(row):
            try:
                classroom = Classroom.objects.get(id=classroom_pk)
                row.pop()
                row.append(classroom)
            except Classroom.DoesNotExist:
                classroom = None     
            #print(row)
            return row
        if form.is_valid():
            classroom_pk = form.cleaned_data['classroom']  
            self.request.FILES['file'].save_book_to_databasee(
                model = Group,
                mapdict= {"Group_Number": "group_number",
                          "Description": "description",
                          "Classroom_ID": "classroom"}, 
                initializer = classroom_func)
            self.add_message("Groups successfully added!")
            return HttpResponseRedirect(reverse('classroom-upload-groups'))
        else:
            self.add_message("Form not valid, failed to add groups.")          
            return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text) 


class ClassroomView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ dashboard page, manage users
    """
    template_name = 'classroom.html'
    context = {}

    def get(self, *args, **kwargs):

        current_classroom_pk = self.request.user.current_classroom_id
        if current_classroom_pk:
            try:
                classroom = Classroom.objects.get(id=current_classroom_pk)
            except Classroom.DoesNotExist:
                classroom = None
                self.add_message("Error when trying to load current classroom.")


        else:
            self.add_message("No current classroom is set. Please visit the dashboard to set a current classroom.")

        students = Student.objects.filter(classroom=classroom).order_by('last_name')
        groups = Group.objects.filter(classroom=classroom).order_by('group_number')
        rotation_groups = RotationGroup.objects.filter(rotation__semester=classroom.current_semester,rotation__classroom=classroom)
        semesters = Semester.objects.all().order_by('date_begin')

        # try:
        #     classroom = Classroom.objects.get(instructor = self.request.user)
        # except Classroom.DoesNotExist:
        #     classroom = None
        learning_assistants = Profile.objects.filter(current_classroom = classroom).order_by('last_name')
        assign_instructor_form = AssignInstructorForm()
        assign_instructor_form.fields['instructor_id'].choices = [(la[0],la[1]+' '+la[2]) for la in learning_assistants.values_list('id','first_name','last_name').order_by('last_name')]
      

        add_student_form1 = AddStudentForm()
        add_student_form1.fields["classroom_pk"].initial = current_classroom_pk

        assign_groups_form = AssignMultipleGroupsForm()
        assign_groups_form.fields['group_numbers'].choices = tuple(RotationGroup.objects.filter(rotation__classroom=classroom).values_list('id','group__group_number').order_by('group__group_number'))
        #choices = tuple(Group.objects.filter(classroom=classroom).values_list('id','group_number').order_by('group_number'))
        #ssign_groups_form.set_group_numbers(choices)

        #CHOICES_groups = tuple(RotationGroup.objects.filter(classroom=classroom).values_list('id','group__group_number').order_by('group__group_number'))
        

        assign_students_form = AssignMultipleStudentsForm()
        all_students = Student.objects.filter(classroom=classroom).values_list('id','first_name','last_name').order_by('last_name')

        students_full_name = [(student[0],student[1]+' '+student[2]) for student in all_students]

        CHOICES_students = tuple(students_full_name)        
        assign_students_form.fields['students'].choices = CHOICES_students

       # raise Exception("tat")
        
        # learning_assistants = Profile.objects.all().filter(permission_level=0)
     #  instructors = Profile.objects.all()
        return render(self.request, self.template_name,
        {
            'students': students,
            'learning_assistants':learning_assistants,
          #  'instructors':instructors,
            'groups': groups,
            'rotation_groups': rotation_groups,
            'classroom': classroom,
            'semesters' : semesters,
            'add_student_form': add_student_form1,
            'add_group_form': AddGroupForm(),
            'add_classroom_form': AddClassroomForm(),
            'assign_multiple_groups_form': assign_groups_form,
            'assign_multiple_students_form': assign_students_form,
            'assign_instructor_form': assign_instructor_form,
            'upload_view': False,
        })

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text) 

def upload(request):
    
    if request.method == "POST":
        #raise Exception("somehow got here")

        form = UploadFileForm(request.POST, request.FILES)
        if form.is_valid():
            request.FILES['file'].save_to_database(
                name_columns_by_row=2,
                model=Student,
                mapdict=['first_name', 'last_name', 'group_number', 'student_id'])
            return HttpResponse("OK")
        else:
            return HttpResponseBadRequest()  
        # def group_func(row):
        #     print row[0]
        #     try:
        #         group = Group.objects.filter(group_number=row[0])[0]
        #     row[0] = q
        #     return row
        # if form.is_valid():
        #     request.FILES['file'].save_book_to_database(
        #         models=[
        #             (Student, ['first_name', 'last_name', 'group_number', 'student_id']),
        #          ]
        #         )

        # if form.is_valid():
        #     filehandle = request.FILES['file']
        #     return excel.make_response(filehandle.get_sheet(), "csv",
        #                                file_name="download")
    else:
        form = UploadFileForm()
    return render(
        request,
        'upload_form.html',
        {
            'form': form,
            'title': 'Excel file upload and download example',
            'header': ('Please choose any excel file ' +
                       'from your cloned repository:')
        })


def download(request, file_type):
    sheet = excel.pe.Sheet(data)
    return excel.make_response(sheet, file_type)


def download_as_attachment(request, file_type, file_name):
    return excel.make_response_from_array(
        data, file_type, file_name=file_name)


def export_data(request, atype):
    if atype == "sheet":
        return excel.make_response_from_a_table(
            Question, 'xls', file_name="sheet")
    elif atype == "book":
        return excel.make_response_from_tables(
            [Question, Choice], 'xls', file_name="book")
    elif atype == "custom":
        question = Question.objects.get(slug='ide')
        query_sets = Choice.objects.filter(question=question)
        column_names = ['choice_text', 'id', 'votes']
        return excel.make_response_from_query_sets(
            query_sets,
            column_names,
            'xls',
            file_name="custom"
        )
    else:
        return HttpResponseBadRequest(
            "Bad request. please put one of these " +
            "in your url suffix: sheet, book or custom")


def import_data(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST,
                              request.FILES)

        def choice_func(row):
            q = Question.objects.filter(slug=row[0])[0]
            row[0] = q
            return row
        if form.is_valid():
            request.FILES['file'].save_book_to_database(
                models=[Question, Choice],
                initializers=[None, choice_func],
                mapdicts=[
                    ['question_text', 'pub_date', 'slug'],
                    ['question', 'choice_text', 'votes']]
            )
            return HttpResponse("OK", status=200)
        else:
            return HttpResponseBadRequest()
    else:
        form = UploadFileForm()
    return render(
        request,
        'upload_form.html',
        {
            'form': form,
            'title': 'Import excel data into database example',
            'header': 'Please upload sample-data.xls:'
        })


def import_sheet(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST,
                              request.FILES)
        if form.is_valid():
            request.FILES['file'].save_to_database(
                name_columns_by_row=2,
                model=Student,
                mapdict=['question_text', 'pub_date', 'slug'])
            return HttpResponse("OK")
        else:
            return HttpResponseBadRequest()
    else:
        form = UploadFileForm()
    return render(
        request,
        'upload_form.html',
        {'form': form})


def exchange(request, file_type):
    form = UploadFileForm(request.POST, request.FILES)
    if form.is_valid():
        filehandle = request.FILES['file']
        return excel.make_response(filehandle.get_sheet(), file_type)
    else:
        return HttpResponseBadRequest()


def parse(request, data_struct_type):
    form = UploadFileForm(request.POST, request.FILES)
    if form.is_valid():
        filehandle = request.FILES['file']
        if data_struct_type == "array":
            return JsonResponse({"result": filehandle.get_array()})
        elif data_struct_type == "dict":
            return JsonResponse(filehandle.get_dict())
        elif data_struct_type == "records":
            return JsonResponse({"result": filehandle.get_records()})
        elif data_struct_type == "book":
            return JsonResponse(filehandle.get_book().to_dict())
        elif data_struct_type == "book_dict":
            return JsonResponse(filehandle.get_book_dict())
        else:
            return HttpResponseBadRequest()
    else:
        return HttpResponseBadRequest()