from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.files.base import ContentFile
from django.template.defaulttags import register
from .forms import AddCategoryForm, AddSubCategoryForm, EditCategoryForm, AddCommonFeedbackForm
# Create your views here.
from django.db import IntegrityError
from classroom.models import Classroom

from models import Category, SubCategory, CommonFeedback
from classroom.models import Student, Group

@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories

@register.filter
def get_common_feedbacks(subcategory_pk):
	feedback_collection = CommonFeedback.objects.filter(sub_category=subcategory_pk)
	return feedback_collection

class FeedbackView(LoginRequiredMixin, TemplateView):
    template_name = "feedback.html"
    context = {}

    def get(self, *args, **kwargs):
        #form = AccountSettingsForm(instance=self.request.user)
        #self.context['form'] = form
        groups = Group.objects.filter(current_instructor = self.request.user)
        groups_to_students = {}
        for group in groups:
        	groups_to_students[group] = Student.objects.filter(group=group)
        self.context['groups_to_students'] = groups_to_students
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