from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, render_to_response, get_object_or_404
from django.views.generic import TemplateView, View, FormView
from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.files.base import ContentFile
from django.template.defaulttags import register
from .forms import AddCategoryForm, AddSubCategoryForm, EditCategoryForm, AddCommonFeedbackForm, EditDraftForm, AddRevisionNotesForm
# Create your views here.
from django.db import IntegrityError
from classroom.models import Classroom

from feedback.models import Category, SubCategory, CommonFeedback, Draft, Notification
from classroom.models import Student, Group
from notes.models import Feedback
from django.views.decorators.csrf import csrf_exempt
import datetime
from datetime import date, timedelta

@register.filter
def get_revision_notifications(draft):
    revision_notifications = Notification.objects.filter(draft_to_approve=draft)
    return revision_notifications


@register.filter
def get_student_feedback(student_pk,week):
    feedback_notes = Feedback.objects.filter(student=student_pk,week_num=week)
    return feedback_notes

@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories

@register.filter
def get_common_feedbacks(subcategory_pk):
	feedback_collection = CommonFeedback.objects.filter(sub_category=subcategory_pk)
	return feedback_collection

@register.filter
def get_student_draft(student_pk, week):
	draft = Draft.objects.filter(student = student_pk, week_num = week).first()
	return draft

class FeedbackView(LoginRequiredMixin, FormView):
    template_name = "feedback.html"
    form_class = EditDraftForm

    context = {}


    def get(self, request, *args, **kwargs):

		if 'weekDropDown' in self.request.GET:
		    week = int(self.request.GET['weekDropDown'].encode('ascii','ignore'))
		else:
		    week = 1

	#	raise Exception("what")
		groups = Group.objects.filter(current_instructor = self.request.user)
		groups_to_students = {}
		student_to_feedback_draft = {}
		for group in groups:
			groups_to_students[group] = Student.objects.filter(group=group)


		self.context['week'] = week
		self.context['loop_times'] = range(1, 13)
		self.context['groups_to_students'] = groups_to_students
		
		self.context['notifications'] = Notification.objects.filter(user=self.request.user)

		return render(self.request, self.template_name, self.context)

    def post(self,*args, **kwargs):
    	form = EditDraftForm(self.request.POST or None)
    #	raise Exception("test")
    	if form.is_valid():
    		draft_text = form.cleaned_data['draft_text']
    		student_pk = form.cleaned_data['student_pk']
    		week_num = form.cleaned_data['week_num']
    		try:
    			student = Student.objects.get(id=student_pk)
    		except Student.DoesNotExist:
    			messages.add_message(self.request, messages.ERROR, 'Draft could not be saved for this student.')
    			return HttpResponseRedirect('/feedback/')

    		try:
    			draft = Draft.objects.get(owner=self.request.user, student = student)
    		except Draft.DoesNotExist:
    			draft = Draft.objects.create(owner = self.request.user, student = student, status=0, week_num=week_num)

    		if self.request.POST.get("save"):
    			messages.add_message(self.request, messages.SUCCESS, 'Draft saved.')
    		elif self.request.POST.get("send"):
    			draft.status = 1
    			draft.send_to_instructor()
    			messages.add_message(self.request, messages.WARNING, 'Draft has been saved and sent to instructor for approval.')
    		#raise Exception("gefegeg")
    		draft.text = draft_text
    		draft.updated_ts = datetime.datetime.now()
    		draft.save()
    		return HttpResponseRedirect('/feedback/')
    	messages.add_message(self.request, messages.ERROR, 'Draft could not be saved.')
    	return HttpResponseRedirect('/feedback/')

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)


class InboxView(LoginRequiredMixin,TemplateView):
	template_name = "inbox.html"
	context = {}

	def get(self, request, *args, **kwargs):

		if 'weekDropDown' in self.request.GET:
		    week = int(self.request.GET['weekDropDown'].encode('ascii','ignore'))
		else:
		    week = 1

		# today_date = date.today()
		# current_day_of_week = today_date.weekday()
		# week_start = today_date - timedelta(days = current_day_of_week)
		# week_finish = today_date + timedelta(days = (6 - current_day_of_week))	


		self.context['draft_notifications_need_approval'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 1, draft_to_approve__week_num=week)
		self.context['draft_notifications_need_revision'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 2,draft_to_approve__week_num=week)
		self.context['draft_notifications_approved'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 3,draft_to_approve__week_num=week)

		self.context['week'] = week
		self.context['loop_times'] = range(1, 13)
		#	raise Exception("what")
		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)	


class CategoryView(LoginRequiredMixin, TemplateView):
	template_name = "categories.html"
	context = {}

	def get(self, *args, **kwargs):
		try:
			classroom = Classroom.objects.get(instructor = self.request.user)
		except Classroom.DoesNotExist:
			classroom = None
		self.context['create_main_category_form'] = AddCategoryForm()
		self.context['create_sub_category_form'] = AddSubCategoryForm()
		self.context['create_feedback_form'] = AddCommonFeedbackForm()
		self.context['main_categories'] = Category.objects.filter(classroom=classroom)

		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)	

def create_subcategory(request, pk):
	form = AddSubCategoryForm(request.POST or None)
	if form.is_valid():
		name = form.cleaned_data['name']
		description = form.cleaned_data['description']
		sub_category = form.save(commit=False)
		try:
			sub_category.main_category = Category.objects.get(id = pk)
			sub_category.save()
			messages.add_message(request, messages.SUCCESS, 'Subcategory sucessfully created.')
		except Exception as e:
			messages.add_message(request, messages.ERROR, 'Error when adding subcategory: '+e)
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 

def create_common_feedback(request, pk):

	form = AddCommonFeedbackForm(request.POST or None)
	if form.is_valid():
		feedback = form.cleaned_data['feedback']
		common_feedback = form.save(commit=False)
		try:
			common_feedback.sub_category = SubCategory.objects.get(id = pk)
			common_feedback.save()
			messages.add_message(request, messages.SUCCESS, 'Feedback sucessfully created.')
		except Exception as e:
			messages.add_message(request, messages.ERROR, 'Error when adding feedback: '+e)
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 


def approve_draft(request, pk):
	try:
		draft = Draft.objects.get(id=pk)
		draft.status = 3
		draft.send_approval_notification()
		draft.save()
		messages.add_message(request, messages.SUCCESS, 'Draft sucessfully approved.')		
	except Draft.DoesNotExist:
		messages.add_message(request, messages.ERROR, 'Error when approving feedback draft.')
	return HttpResponseRedirect('/feedback/inbox/') 	

def send_draft_revision(request):
	form = AddRevisionNotesForm(request.POST or None)
	#raise Exception("wuht")
	if form.is_valid():	
		draft_pk = form.cleaned_data['draft_pk']
		revision_notes = form.cleaned_data['revision_notes']		
		try:
			draft = Draft.objects.get(id=draft_pk)
			draft.status = 2
			draft.save()
			draft.add_revision_notes(revision_notes)
			messages.add_message(request, messages.INFO, 'Draft revision notes sent.')		
		except Draft.DoesNotExist:
			messages.add_message(request, messages.ERROR, 'Error when sending feedback draft revision notes.')
		return HttpResponseRedirect('/feedback/inbox/') 
	else:
		messages.add_message(request, messages.ERROR, 'Form not valid. Please check your inputs.')
		return HttpResponseRedirect('/feedback/inbox/') 

def create_category(request):
	form = AddCategoryForm(request.POST or None)
	if form.is_valid():
		name = form.cleaned_data['name']
		description = form.cleaned_data['description']
		category = form.save(commit=False)
		try:
			category.classroom = Classroom.objects.get(instructor = request.user)
			category.save()
			messages.add_message(request, messages.SUCCESS, 'Category sucessfully created.')
		except IntegrityError as e:
			messages.add_message(request, messages.ERROR, 'Category with that name already exists.')
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 


class DeleteCategoryView(LoginRequiredMixin, View):
    """ delete category view
    """
    def get(self, *args, **kwargs):
        try:
            category = Category.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this category %s' % e)
        finally:
            category.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Category successfully deleted!')
        return HttpResponseRedirect('/feedback/categories/') 

class DeleteSubCategoryView(LoginRequiredMixin, View):
    """ delete category view
    """
    def get(self, *args, **kwargs):
    	#raise Exception("got here?")
        try:
            subcategory = SubCategory.objects.get(id=kwargs['pk'])
            #raise Exception("whaatt")
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this subcategory %s' % e)
        finally:
            subcategory.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Subcategory successfully deleted!')
        return HttpResponseRedirect('/feedback/categories/') 


#class EditDraftView(LoginRequiredMixin, FormView):

	#@csrf_exempt
	#def post(self, request, *args, **kwargs):
		#raise Exception("got here?")
		#form = EditDraftForm(request.POST)
		#raise Exception("got here! ")
		#if form.is_valid():
	#		text = form.cleaned_data['text']
#		context = {}
	#	return self.render_to_response(context)

def edit_subcategory(request, pk):
	form = EditCategoryForm(request.POST or None)
	if form.is_valid():
		name = form.cleaned_data['name']
		description = form.cleaned_data['description']			
		try:
			subcategory = SubCategory.objects.get(id=pk)
			subcategory.name = name
			subcategory.description = description
			subcategory.save()
			messages.add_message(request, messages.SUCCESS, 'Category saved.')				
		except SubCategory.DoesNotExist:
			messages.add_message(request, messages.ERROR, 'Error - failed to save.')				
			return HttpResponseRedirect('/feedback/categories/')
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 

def edit_category(request, pk):
	form = EditCategoryForm(request.POST or None)
	if form.is_valid():
		name = form.cleaned_data['name']
		description = form.cleaned_data['description']			
		try:
			category = Category.objects.get(id=pk)
			category.name = name
			category.description = description
			category.save()
			messages.add_message(request, messages.SUCCESS, 'Category saved.')				
		except Category.DoesNotExist:
			messages.add_message(request, messages.ERROR, 'Error - failed to save.')							
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 	