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
from classroom.models import Classroom
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
def get_note_feedback_pieces(note):
	if note.observation != None:
		return FeedbackPiece.objects.filter(observation=note.observation)
	else:
		return FeedbackPiece.objects.filter(sub_category=note.sub_category)  

#def get_observations_by_notes(notes):

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
def get_feedback_pieces(subcategory_pk):
	feedback_collection = FeedbackPiece.objects.filter(sub_category=subcategory_pk)
	return feedback_collection


@register.filter
def get_student_draft(student_pk, week):
	draft = Draft.objects.filter(student = student_pk, week_num = week).first()
	return draft

# class EditObservation(SuperuserRequiredMixin,TemplateView):

#     def post(self, *args, **kwargs):
#         form = EditObservationForm(self.request.POST or None)
#         #raise Exception("what")
#         if form.is_valid():
#             observation_text = form.cleaned_data['observation']
#             observation = form.cleaned_data['observation_pk']
#             observation_type = int(form.cleaned_data['observation_type'])
#             if observation_type == -1:
#             	observation_type = None
#             try:
#                 observation.observation = observation_text
#                 observation.observation_type = observation_type
#                 observation.save()
#                 messages.add_message(self.request, messages.SUCCESS, 'Successfully edited observation.')
#             except Exception as e:
#                 messages.add_message(self.request, messages.ERROR, 'Unable to edit observation.%s' % e)
#             return HttpResponseRedirect('/feedback/manager/')
#         else:
#             messages.error(self.request, form.errors)
#             return HttpResponseRedirect('/feedback/manager/')     

class AddEditObservation(SuperuserRequiredMixin,TemplateView):

	def post(self, *args, **kwargs):
		form = EditObservationForm(self.request.POST or None)
		#raise Exception("what")
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
            # observation_text = form.cleaned_data['observation']
            # observation = form.cleaned_data['observation_pk']            

            # observation_type = int(form.cleaned_data['observation_type'])
            # if observation_type == -1:
            # 	observation_type = None         	
            # try:
            #     observation.observation = observation_text
            #     observation.observation_type = observation_type
            #     observation.save()
            #     messages.add_message(self.request, messages.SUCCESS, 'Successfully edited observation.')
            # except Exception as e:
            #     messages.add_message(self.request, messages.ERROR, 'Unable to edit observation.')
			return HttpResponseRedirect('/feedback/manager/')
		else:
			messages.error(self.request, form.errors)
			return HttpResponseRedirect('/feedback/manager/') 

class AddEditCommonFeedback(SuperuserRequiredMixin,TemplateView):

	def post(self, *args, **kwargs):
		form = EditCommonFeedbackForm(self.request.POST or None)
		#raise Exception("what")
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
		#raise Exception("what")
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
			#groups_to_students = {}
			student_to_feedback_draft = {}
			# for group in groups:
			# 	groups_to_students[group] = Student.objects.filter(group__students=group)

		#	raise Exception("test!")
			main_categories = Category.objects.filter(classroom=classroom)

			self.context['title'] = "Feedback Writer"
			self.context['week'] = int(week)
			self.context['rotation_groups'] = groups
			# self.context['loop_times'] = range(1, 13)
			self.context['loop_times'] = range(1,classroom.get_num_weeks())
			self.context['grade_scale'] = [x*.25 for x in range(17)]
			#self.context['groups_to_students'] = groups_to_students
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
		#raise Exception("test")
		if form.is_valid():
			draft_text = form.cleaned_data['draft_text']
			draft = form.cleaned_data['draft']
			student = form.cleaned_data['student']
			week_num = form.cleaned_data['week_num']

			# try:
			# 	draft = Draft.objects.get(owner=self.request.user, student = student, week_num = week_num)
			# except Draft.DoesNotExist:
			# 	draft = Draft.objects.create(owner = self.request.user, student = student, status=0, week_num=week_num)
			if not draft:
				try:
					draft = Draft.objects.get(owner=self.request.user, student = student, week_num = week_num)
				except Draft.DoesNotExist:
					draft = Draft.objects.create(owner = self.request.user, student = student, status=0, week_num=week_num)				

			# grades_values = dict([(name.encode('ascii','ignore')[6:],value.encode('ascii','ignore')) for name, value in self.request.POST.items()
			# 	if name.startswith('grade_')])
			grades_values = dict([(name[6:],value) for name, value in self.request.POST.items() if name.startswith('grade_')])

			#raise Exception("wht")

		#	print(grades_values)
			for category_pk,grade_val in grades_values.items():
				category = Category.objects.get(id=category_pk)
				try:
					grade = Grade.objects.get(draft=draft, category=category)
					grade.grade = grade_val
					grade.save()
				except Grade.DoesNotExist:
					grade = Grade.objects.create(draft=draft,category=category,grade=grade_val)
				#print(category.name+ ": "+str(grade))

			draft.text = draft_text
			draft.updated_ts = datetime.datetime.now()
			
			saved_draft = True
			if self.request.POST.get("save"):
				saved_draft = True
				#messages.add_message(self.request, messages.SUCCESS, 'Draft saved.')
			elif self.request.POST.get("send"):
				saved_draft=False
				draft.status = 1
				draft.send_to_instructor()
				# messages.add_message(self.request, messages.WARNING, 'Draft has been saved and sent to instructor for approval.')   
			draft.save()
			return JsonResponse({'success':True,'saved_draft':saved_draft,'student_id':student.id,'last_updated':datetime.datetime.now().strftime("%b. %d, %Y, %I:%M %p")})
			#return HttpResponseRedirect('/feedback/week/'+str(week_num))
		#messages.error(self.request, form.errors)
		#form.errors['student_id']=student.id
		return JsonResponse({'success':False,'form_errors':form.errors,'student_id':student_.id})
		#return HttpResponseRedirect('/feedback/')

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)


class InboxView(SuperuserRequiredMixin,TemplateView):
	template_name = "inbox.html"
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
			self.context['draft_notifications_need_approval'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 1, draft_to_approve__week_num=week)
			self.context['draft_notifications_need_revision'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 2,draft_to_approve__week_num=week)
			self.context['draft_notifications_approved'] = Notification.objects.filter(user=self.request.user,draft_to_approve__status = 3,draft_to_approve__week_num=week)

			self.context['drafts_need_approval'] = Draft.objects.filter(week_num=week,student__classroom = classroom,student__semester=classroom.current_semester,status=1)
			self.context['drafts_need_revision'] = Draft.objects.filter(week_num=week,student__classroom = classroom,student__semester=classroom.current_semester,status=2)
			self.context['drafts_approved'] = Draft.objects.filter(week_num=week,student__classroom = classroom,student__semester=classroom.current_semester,status=3,email_sent=False)
			self.context['drafts_emailed'] = Draft.objects.filter(week_num=week,student__classroom = classroom,student__semester=classroom.current_semester,status=3,email_sent=True)			

			self.context['title'] = "Inbox"
			self.context['week'] = week
			self.context['loop_times'] = range(1,request.user.current_classroom.get_num_weeks())
			return render(self.request, self.template_name, self.context)
		else:
			messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
			return HttpResponseRedirect(reverse('dash-home')) 			

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)	




def change_week(request):
	form = request.POST or None
	if 'weekDropDown' in request.POST:
		week = int(request.POST['weekDropDown'].encode('ascii','ignore'))	
		return HttpResponseRedirect('/feedback/inbox/week/'+str(week)) 

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
			#self.context['create_feedback_form'] = AddFeedbackPieceForm()
			# self.context['main_categories'] = Category.objects.filter(classroom=classroom)
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

# def create_common_feedback(request, pk):

# 	form = AddFeedbackPieceForm(request.POST or None)
# 	#raise Exception("yay")
# 	if form.is_valid():
# 		feedback = form.cleaned_data['feedback']
# 		observation = form.cleaned_data['observation']
# 		explanation = form.cleaned_data['feedback_explanation']

# 		if form.cleaned_data['observation_type']:
# 			observation_type = int(form.cleaned_data['observation_type'])
# 		else:
# 			observation_type = None

# 		if observation_type == -1:
# 			observation_type = None
		

# 		#If selected from prepopulated / preexisting
# 		feedback_object = form.cleaned_data['feedback_pk']
# 		observation_object = form.cleaned_data['observation_pk']
# 		explanation_object = form.cleaned_data['feedback_explanation_pk']

# 		subcategory = form.cleaned_data['subcategory_pk']

# 		# observation_object = None
# 		# feedback_object = None
# 		# explanation_object = None

# 		# #raise Exception("wtf")
# 		# try:
# 		# 	subcategory = SubCategory.objects.get(id=subcategory_pk)
# 		# except SubCategory.DoesNotExist:
# 		# 	subcategory = None


# 		if observation_object == None and observation:
# 			#Create observation
# 			try:
# 				new_observation = Observation(sub_category=subcategory, observation = observation, observation_type = observation_type )
# 				new_observation.save()	
# 				observation_object = new_observation					
# 				messages.add_message(request, messages.SUCCESS, 'Successfully added new observation')
# 			except Exception as e:
# 				messages.add_message(request, messages.ERROR, 'Unable to create this observation %s' % e)				
# 		# else:
# 		# 	try:
# 		# 		observation_object = Observation.objects.get(id=observation_pk)
# 		# 	except Observation.DoesNotExist:
# 		# 		observation_object = None			

# 		#raise Exception("wat")
# 		if feedback_object == None and (feedback and observation_object != None):
# 			#Create observation
# 			try:
# 				new_feedback = Feedback(observation=observation_object, feedback = feedback,sub_category=subcategory)
# 				new_feedback.save()	
# 				feedback_object = new_feedback					
# 				messages.add_message(request, messages.SUCCESS, 'Successfully added new feedback')
# 			except Exception as e:
# 				messages.add_message(request, messages.ERROR, 'Unable to create this feedback %s' % e)		
# 		# else:
# 		# 	try:
# 		# 		feedback_object = Feedback.objects.get(id=feedback_pk)
# 		# 	except Feedback.DoesNotExist:
# 		# 		feedback_object = None					

# 		if explanation_object == None and (explanation and feedback_object != None):
# 			#Create observation
# 			try:
# 				new_explanation = Explanation(feedback=feedback_object, feedback_explanation = explanation,sub_category=subcategory)
# 				new_explanation.save()	
# 				explanation_object = new_explanation					
# 				messages.add_message(request, messages.SUCCESS, 'Successfully added new explanation')
# 			except Exception as e:
# 				messages.add_message(request, messages.ERROR, 'Unable to create this explanation %s' % e)		
# 		# else:
# 		# 	try:
# 		# 		explanation_object = Explanation.objects.get(id=explanation_pk)
# 		# 	except Explanation.DoesNotExist:
# 		# 		explanation_object = None	


# 		try:
# 			new_fb_piece = FeedbackPiece(sub_category=subcategory, observation = observation_object, feedback = feedback_object, feedback_explanation = explanation_object)
# 			new_fb_piece.save()
# 			messages.add_message(request, messages.SUCCESS, 'Successfully added new feedback piece!')
# 		except Exception as e:
# 			messages.add_message(request, messages.ERROR, 'Unable to create this feedback piece %s' % e)				
# 		return HttpResponseRedirect('/feedback/categories/')

# 	messages.add_message(request, messages.ERROR, form.errors)
# 	return HttpResponseRedirect('/feedback/categories/')			
# 			#new_feedback_piece = FeedbackPiece.create()



class ApproveDraft(SuperuserRequiredMixin,LoginRequiredMixin, TemplateView):

	def post(self, *args, **kwargs):
		form = ApproveEditDraftForm(self.request.POST or None)
		if form.is_valid():
			draft = form.cleaned_data['draft_pk']
			draft_text = form.cleaned_data['draft_text']
			if draft.status != 3:
				draft.status = 3
				draft.send_approval_notification()
			draft.text = draft_text				
			draft.save()
			messages.add_message(self.request, messages.SUCCESS, 'Successfully approved with edits.')
			return HttpResponseRedirect('/feedback/inbox/')
			#return JsonResponse({'draft_id':draft.id,'draft_text':draft_text})
		else:
			messages.add_message(self.request, messages.ERROR, form.errors)
			return JsonResponse(form.errors)


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
		draft = form.cleaned_data['draft_pk']
		revision_notes = form.cleaned_data['revision_notes']		
		try:
			#draft = Draft.objects.get(id=draft_pk)
			draft.status = 2
			draft.save()
			draft.add_revision_notes(revision_notes)
			messages.add_message(request, messages.INFO, 'Draft revision notes sent.')		
		except Exception as e:
			messages.add_message(request, messages.ERROR, 'Error when sending feedback draft revision notes.'+str(e))
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



class SendDrafts(SuperuserRequiredMixin, View):

	def get(self, *args, **kwargs):
		week = int(self.kwargs['week'])
		sent_count = 0
		drafts = Draft.objects.filter(student__classroom=self.request.user.current_classroom,student__semester=self.request.user.current_classroom.current_semester,
			week_num=week,status=3,email_sent=False)
		successfully_sent = []
		no_email_found = []
		no_email_count = 0
		for draft in drafts:
		# for i in range(10):
			try:
				if draft.send_email_to_student():
					sent_count += 1
					successfully_sent.append(draft.student.get_full_name())
				else:
					no_email_count += 1
					no_email_found.append(draft.student.get_full_name())
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, 'Unable to send this feedback to student: %s' % e) 

		messages.add_message(self.request, messages.SUCCESS, str(len(successfully_sent)) + ' Feedback Emails have been sent to: ' +', '.join(successfully_sent))             
		if no_email_count:
			messages.add_message(self.request, messages.ERROR, str(len(no_email_found)) + ' Emails could not be sent, no email addresses found for: ' +', '.join(no_email_found))             
		return HttpResponseRedirect('/feedback/inbox/') 	


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