from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse, JsonResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, render_to_response, get_object_or_404
from django.views.generic import TemplateView, View, FormView
from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.files.base import ContentFile
from django.template.defaulttags import register

import json
from .forms import *
# Create your views here.
from django.db import IntegrityError
from userprofile.models import Profile
from feedback.models import *
from classroom.models import *

from notes.models import Note
from django.views.decorators.csrf import csrf_exempt
import datetime
from datetime import date, timedelta
from decimal import *

@register.filter
def compare_grade(grade,val):
	if grade != None:
		return Decimal(grade) == Decimal(val)
	else:
		return False


@register.filter
def get_draft_grades(draft):
	return Grade.objects.filter(draft=draft)


@register.filter
def filter_drafts_by_instructor(drafts,instructor):
	return drafts.filter(owner=instructor)

@register.filter
def filter_draft_count_by_instructor(drafts,instructor):
	return drafts.filter(owner=instructor).count()

@register.filter
def get_subcategory_observations(subcategory):
	return Observation.objects.filter(sub_category=subcategory)


@register.filter
def get_subcategory_feedbacks(subcategory):
	return Feedback.objects.filter(sub_category=subcategory)	

@register.filter
def get_subcategory_feedback_explanations(subcategory):
	return Explanation.objects.filter(sub_category=subcategory)	


@register.filter
def get_observation_feedbacks(observation):
	return Feedback.objects.filter(observation=observation)

@register.filter
def get_feedback_explanations(feedback):
	return Explanation.objects.filter(feedback=feedback)

@register.filter
def get_grade_for_category(draft,category):
	try:
		grade = Grade.objects.get(draft=draft,category=category)
		return grade
	except Grade.DoesNotExist:
		return None

@register.filter
def get_revision_notifications(draft):
    revision_notifications = Notification.objects.filter(draft_to_approve=draft)
    return revision_notifications


@register.filter
def get_student_feedback(student_pk,week):
    feedback_notes = Note.objects.filter(student=student_pk,week_num=week)
    return feedback_notes

@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories

@register.filter
def get_student_draft(student_pk, week):
	draft = Draft.objects.filter(student = student_pk, week_num = week).first()
	return draft



class AddEditObservation(SuperuserRequiredMixin,TemplateView):

	def post(self, *args, **kwargs):
		form = EditObservationForm(self.request.POST or None)
		if form.is_valid():
			observation = form.cleaned_data['observation_pk'] 
			try:
				if observation:
					f = EditObservationForm(self.request.POST, instance=observation)
					f.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully edited observation.')
				else:
					new_observation = form.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully added observation.')
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, 'Unable to edit/add observation.%s' % e)
			return HttpResponseRedirect('/feedback/manager/')
		else:
			messages.error(self.request, form.errors)
			return HttpResponseRedirect('/feedback/manager/') 

class AddEditCommonFeedback(SuperuserRequiredMixin,TemplateView):

	def post(self, *args, **kwargs):
		form = EditCommonFeedbackForm(self.request.POST or None)
		
		if form.is_valid():

			feedback = form.cleaned_data['feedback_pk'] 
			try:
				if feedback:
					f = EditCommonFeedbackForm(self.request.POST, instance=feedback)
					f.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully edited feedback.')
				else:
					new_common_feedback = form.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully created feedback.')
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, 'Unable to edit/add feedback.%s' % e)        	

			return HttpResponseRedirect('/feedback/manager/')
		else:
			messages.error(self.request, form.errors)
			return HttpResponseRedirect('/feedback/manager/') 


class AddEditFeedbackExplanation(SuperuserRequiredMixin,TemplateView):

	def post(self, *args, **kwargs):
		form = EditExplanationForm(self.request.POST or None)
		if form.is_valid():

			feedback_explanation = form.cleaned_data['explanation_pk'] 
			try:
				if feedback_explanation:
					f = EditExplanationForm(self.request.POST, instance=feedback_explanation)
					f.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully edited feedback explanation.')
				else:
					feedback_explanation = form.save()
					messages.add_message(self.request, messages.SUCCESS, 'Successfully created explanation for feedback.')
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, 'Unable to edit/add explanation.%s' % e)        	
				
			return HttpResponseRedirect('/feedback/manager/')
		else:
			messages.error(self.request, form.errors)
			return HttpResponseRedirect('/feedback/manager/') 


class FeedbackManager(SuperuserRequiredMixin, TemplateView):
	template_name = "feedbackmanager.html"
	context = {}

	def get(self, *args, **kwargs):

		classroom = self.request.user.current_classroom
		if classroom != None:
			self.context['main_categories'] = Category.objects.all()
			self.context['manager_view'] = True
			self.context['title'] = "Manage Feedback"
			return render(self.request, self.template_name, self.context)
		else:
			messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
			return HttpResponseRedirect(reverse('dash-home'))  				


class FeedbackView(LoginRequiredMixin, View):
	template_name = "feedback.html"
	form_class = EditDraftForm

	context = {}


	def get(self, request, *args, **kwargs):

		classroom = request.user.current_classroom
		if classroom != None:

			if 'week' in self.kwargs:
				week = int(self.kwargs['week'])
			else:
				if request.user.current_classroom.current_week:
					week = request.user.current_classroom.current_week
				else:
					week = 1

			groups = RotationGroup.objects.filter(rotation__classroom = classroom, rotation__semester=classroom.current_semester.id,instructor= self.request.user,
				rotation__start_week__lte=week,rotation__end_week__gte=week)
			
			student_to_feedback_draft = {}

			main_categories = Category.objects.filter(classroom=classroom)

			self.context['title'] = "Feedback Writer"
			self.context['week'] = int(week)
			self.context['week_begin'] = classroom.current_semester.get_week_start(week)
			self.context['week_end'] = classroom.current_semester.get_week_end(week)  			

			self.context['rotation_groups'] = groups
			self.context['loop_times'] = range(1,classroom.get_num_weeks())
			self.context['grade_scale'] = [x*.25 for x in range(17)]
			self.context['main_categories'] = main_categories
			self.context['notifications'] = Notification.objects.filter(user=self.request.user)
			self.context['manager_view'] = False

			return render(self.request, self.template_name, self.context)
		else:
			messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
			return HttpResponseRedirect(reverse('dash-home'))  		

	def post(self,*args, **kwargs):
		form = EditDraftForm(self.request.POST or None)
		student_ = Student.objects.get(id=kwargs['pk'])		
		if form.is_valid():
			draft_text = form.cleaned_data['draft_text']
			draft = form.cleaned_data['draft']
			student = form.cleaned_data['student']
			week_num = form.cleaned_data['week_num']

			if not draft:
				try:
					draft = Draft.objects.get(owner=self.request.user, student = student, week_num = week_num)
				except Draft.DoesNotExist:
					draft = Draft.objects.create(owner = self.request.user, student = student, status=0, week_num=week_num)				

			grades_values = dict([(name[6:],value) for name, value in self.request.POST.items() if name.startswith('grade_')])


			for category_pk,grade_val in grades_values.items():
				category = Category.objects.get(id=category_pk)
				try:
					grade = Grade.objects.get(draft=draft, category=category)
					grade.grade = grade_val
					grade.save()
				except Grade.DoesNotExist:
					grade = Grade.objects.create(draft=draft,category=category,grade=grade_val)

			draft.text = draft_text
			draft.updated_ts = datetime.datetime.now()
			
			saved_draft = True
			if self.request.POST.get("save"):
				saved_draft = True
			elif self.request.POST.get("send"):
				saved_draft=False
				draft.status = 1
				draft.send_to_instructor() 
			draft.save()
			return JsonResponse({'success':True,'saved_draft':saved_draft,'student_id':student.id,'last_updated':datetime.datetime.now().strftime("%b. %d, %Y, %I:%M %p")})

		return JsonResponse({'success':False,'form_errors':form.errors,'student_id':student_.id})


	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)



def change_week_feedback(request):
	form = request.POST or None
	if 'weekDropDown' in request.POST:
		week = int(request.POST['weekDropDown'].encode('ascii','ignore'))	
		return HttpResponseRedirect('/feedback/week/'+str(week)) 

class CategoryView(LoginRequiredMixin, TemplateView):
	template_name = "categories.html"
	context = {}

	def get(self, *args, **kwargs):
		classroom = self.request.user.current_classroom
		if classroom != None:
			self.context['create_main_category_form'] = AddCategoryForm()
			self.context['create_sub_category_form'] = AddSubCategoryForm()
			self.context['main_categories'] = Category.objects.all()
			self.context['title'] = "Manage Categories"

			return render(self.request, self.template_name, self.context)
		else:
			messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
			return HttpResponseRedirect(reverse('dash-home'))

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


def create_category(request):
	form = AddCategoryForm(request.POST or None)
	if form.is_valid():
		name = form.cleaned_data['name']
		description = form.cleaned_data['description']
		category = form.save(commit=False)

		classroom = request.user.current_classroom

		try:
			category.classroom = classroom
			category.save()
			messages.add_message(request, messages.SUCCESS, 'Category sucessfully created.')
		except IntegrityError as e:
			messages.add_message(request, messages.ERROR, 'Category with that name already exists.')
		return HttpResponseRedirect('/feedback/categories/')
	else: 
		messages.error(request, form.errors)
		return HttpResponseRedirect('/feedback/categories/') 


class DeleteFeedbackPieceView(LoginRequiredMixin, View):
    """ delete category view
    """
    def get(self, *args, **kwargs):
        try:
            feedbackpiece = FeedbackPiece.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this feedback piece %s' % e)
        finally:
            feedbackpiece.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Feedback Piece successfully deleted!')
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
        try:
            subcategory = SubCategory.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this subcategory %s' % e)
        finally:
            subcategory.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Subcategory successfully deleted!')
        return HttpResponseRedirect('/feedback/categories/') 



class DeleteObservationView(LoginRequiredMixin, View):
    """ delete observation view
    """
    def get(self, *args, **kwargs):
        try:
            observation = Observation.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this observation %s' % e)
        finally:
            observation.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Observation successfully deleted!')
        return HttpResponseRedirect('/feedback/manager/') 



class DeleteCommonFeedbackView(LoginRequiredMixin, View):
    """ delete feedback view
    """
    def get(self, *args, **kwargs):
        try:
            common_feedback = Feedback.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this common feedback %s' % e)
        finally:
            common_feedback.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Common Feedback successfully deleted!')
        return HttpResponseRedirect('/feedback/manager/') 

class DeleteFeedbackExplanationView(LoginRequiredMixin, View):
    """ delete feedback view
    """
    def get(self, *args, **kwargs):
        try:
            feedback_explanation = Explanation.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this explanation %s' % e)
        finally:
            feedback_explanation.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Explanation successfully deleted!')
        return HttpResponseRedirect('/feedback/manager/') 


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

			