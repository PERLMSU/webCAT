from django.shortcuts import render

from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.conf import settings
from django.template.defaulttags import register
# Create your views here.
from ast import literal_eval
from feedback.models import Category, SubCategory
from classroom.models import Classroom, Group, Student
from notes.forms import AddFeedbackForm
from notes.models import Note

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)

@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories

@register.filter
def get_feedback_notes(student_pk,week):
    feedback_notes = Note.objects.filter(student=student_pk,week_num=week)
    return feedback_notes


class AddFeedback(LoginRequiredMixin, TemplateView):
    """ create a feedback note for student(s)
    """
    context = {} 

    def post(self, *args, **kwargs):
        form = AddFeedbackForm(self.request.POST or None)
        
        if form.is_valid():

            selected_students = [value for name, value in self.request.POST.iteritems()
                if name.startswith('student_name')]

           # selected_students_pk = [item for value in selected_students for item in literal_eval(value)]

            category_to_add_feedback = SubCategory.objects.get(id=kwargs['pk'])
            feedback_note = form.cleaned_data['note']
            week = form.cleaned_data['week_num']

            if not range(len(selected_students)):
                messages.add_message(self.request, messages.WARNING, 'No notes were added because no students were selected.')

            for i in range(len(selected_students)):
                #
                #student_pk = student_pk.encode('ascii')
                student_pk = int(selected_students[i].encode('ascii'))
                #student = Student.objects.get(student_pk)
               # raise Exception("test")
                try:
                    student = Student.objects.get(id=student_pk)
                    new_feedback = Note.objects.create(note=feedback_note,student=student,sub_category=category_to_add_feedback,week_num=week)
                    new_feedback.save()
                    messages.add_message(self.request, messages.SUCCESS, 'Note(s) successfully added.')
                except Exception as e:
                    messages.add_message(self.request, messages.ERROR, 'Unable to create this feedback note. %s' % e) 

     #       raise Exception("testy")
            # checked_groups = form.cleaned_data['group_numbers']
            # try:
            #     instructor = Profile.objects.get(id=kwargs['pk'])
            # except Exception as e:
            #     messages.add_message(self.request, messages.ERROR, 'Unable to assign to this instructor %s' % e)  
            #     return HttpResponseRedirect('/classroom/')

            # for group_pk in checked_groups:
            #     try:
            #         group = Group.objects.get(id = group_pk)
            #         group.current_instructor = instructor
            #         group.save()
            #     except Exception as e:
            #         messages.add_message(self.request, messages.ERROR, 'Unable to assign group numbers to this instructor %s' % e) 
            return HttpResponseRedirect('/notes/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/notes/')  

class NotesView(LoginRequiredMixin, TemplateView):
    template_name = "notes.html"
    context = {}

    def get(self, request, *args, **kwargs):

		if 'week' in self.kwargs:
		    week = int(self.kwargs['week'])
		else:
		    week = 1

		current_classroom_pk = self.request.user.current_classroom_id
		if current_classroom_pk:
		    try:
		        classroom = Classroom.objects.get(id=current_classroom_pk)
		    except Classroom.DoesNotExist:
		        classroom = None
		        self.add_message("Error when trying to load current classroom.")
		else:
		    self.add_message("No current classroom is set. Please	 visit the dashboard to set a current classroom.") 

		group_to_student_dict = {}
		groups_assigned = Group.objects.filter(classroom=classroom,current_instructor = self.request.user)
		for group in groups_assigned:
		    students = Student.objects.filter(group=group)
		    group_to_student_dict[group] = students

		main_categories = Category.objects.filter(classroom=classroom)
		sub_categories = {}
		for category in main_categories:
			sub_categories[category.id] = SubCategory.objects.filter(main_category = category)
		self.context['loop_times'] = range(1, 13)
		self.context['week'] = week
		self.context['student_groups'] = group_to_student_dict
		self.context['main_categories'] = main_categories
		self.context['sub_categories'] = sub_categories
		return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)


def change_week_notes(request):
    form = request.POST or None
    if 'weekDropDown' in request.POST:
        week = int(request.POST['weekDropDown'].encode('ascii','ignore'))   
        return HttpResponseRedirect('/notes/week/'+str(week))         