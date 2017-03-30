from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse, HttpResponseBadRequest, JsonResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.template.defaulttags import register
from django import forms
import django_excel as excel

from models import Student, Group, Classroom

from userprofile.models import Profile

from .forms import AddStudentForm, AddGroupForm, AddClassroomForm

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

def register_class(request):
    form = AddClassroomForm(request.POST or None)
    if form.is_valid():
        classroom = form.save(commit=False)
        classroom.instructor = request.user
        try:
            classroom.save()
            messages.add_message(request, messages.SUCCESS, 'Classroom successfully registered!')
        except Exception as e:
            messages.add_message(request, messages.ERROR, "An error occurred when attempting to register the class: "+e)
        return HttpResponseRedirect('/classroom/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/')     

def add_group(request):
    form = AddGroupForm(request.POST or None)
    userid = request.user.id
    user = request.user
    if form.is_valid():
        group_num = form.cleaned_data['group_number'] 
        description = form.cleaned_data['description']
        group = form.save(commit=False)
        try:
            group = Group.objects.get(group_number=group_num)
            messages.add_message(request, messages.ERROR, 'Group already exists. ')
        except Group.DoesNotExist:
            group.save()
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
        student = form.save(commit=False)
        if group_num:
            try:
                group = Group.objects.get(group_number=group_num)
                student.group = group
            except Group.DoesNotExist:
                messages.add_message(request, messages.WARNING, 'Group number ' + group_num + ' was not found. Please create group before assigning to students.')                
                student.group = None
        student.save()
        messages.add_message(request, messages.SUCCESS, 'Student successfully added!')
        return HttpResponseRedirect('/classroom/')
    else: 
        messages.error(request, form.errors)
        return HttpResponseRedirect('/classroom/') 

class UploadFileForm(forms.Form):
    file = forms.FileField()
    classroom = forms.CharField(widget=forms.HiddenInput())


class AssignGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ assign groups to LA's
    """
    template_name = 'assign_groups.html'
    context = {}    

    def get(self, *args, **kwargs):
        # form = UploadFileForm()
        students = Student.objects.all()
        groups = Group.objects.all()
        classroom = Classroom.objects.get(instructor = self.request.user)
        learning_assistants = Profile.objects.all().filter(permission_level=0)
        instructors = Profile.objects.all().filter(permission_level=1)
        return render(self.request, self.template_name,
        {
            'students': students,
            'learning_assistants':learning_assistants,
            'instructors':instructors,
            'groups': groups,
            'classroom': classroom,
        })

class UploadStudentsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ upload students
    """
    template_name = 'upload_students.html'
    context = {}    

    def get(self, *args, **kwargs):
        form = UploadFileForm()
        students = Student.objects.all()
        groups = Group.objects.all()
        classroom = Classroom.objects.get(instructor = self.request.user)
        return render(self.request, self.template_name,
        {
            'form': form,
            'title': 'Excel file upload and download example',
            'header': ('Please choose any excel file ' +
                       'from your cloned repository:'),
            'students': students,
            'classroom': classroom,
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

class UploadGroupsView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
    """ upload groups
    """
    template_name = 'upload_groups.html'
    context = {}    

    def get(self, *args, **kwargs):
        form = UploadFileForm()
        groups = Group.objects.all()
        students = Student.objects.all()
        classroom = Classroom.objects.get(instructor = self.request.user)
        return render(self.request, self.template_name,
        {
            'form': form,
            'title': 'Excel file upload and download example',
            'header': ('Please choose any excel file ' +
                       'from your cloned repository:'),
            'groups': groups,
            'classroom': classroom,
            'students': students,
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
            self.request.FILES['file'].save_to_database(
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
        # form = UploadFileForm()
        add_student_form = AddStudentForm()
        add_group_form = AddGroupForm()
        add_classroom_form = AddClassroomForm()
        groupform = AddGroupForm()
        students = Student.objects.all()
        groups = Group.objects.all()
        try:
            classroom = Classroom.objects.get(instructor = self.request.user)
        except Classroom.DoesNotExist:
            classroom = None
        learning_assistants = Profile.objects.all().filter(permission_level=0)
        instructors = Profile.objects.all().filter(permission_level=1)
        return render(self.request, self.template_name,
        {
            'students': students,
            'learning_assistants':learning_assistants,
            'instructors':instructors,
            'groups': groups,
            'classroom': classroom,
            'add_student_form': add_student_form,
            'add_group_form': add_group_form,
            'add_classroom_form': add_classroom_form,
        })

    # def post(self, *args, **kwargs):
    #     form = UploadFileForm(self.request.POST, self.request.FILES)

    #     if form.is_valid():
    #         raise Exception("test")
    #         self.request.FILES['file'].save_to_database(
    #             model=Student,
    #             mapdict=['first_name', 'last_name', 'group_number', 'student_id'])
    #         self.add_message("Students successfully added!") 

    #         return HttpResponseRedirect(reverse('classroom-home'))
    #     else:
    #         self.add_message("Form not valid, failed to add students.")          
    #         return render(self.request, self.template_name, self.context)

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