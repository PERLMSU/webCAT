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

			self.context['grade_scale'] = [x*.25 for x in range(17)]
			self.context['title'] = "Inbox"
			self.context['instructors'] = Profile.objects.filter(current_classroom=classroom)
			self.context['week'] = week
			self.context['week_begin'] = classroom.current_semester.get_week_start(week)
			self.context['week_end'] = classroom.current_semester.get_week_end(week)
			self.context['loop_times'] = range(1,request.user.current_classroom.get_num_weeks())
			return render(self.request, self.template_name, self.context)
		else:
			messages.add_message(self.request, messages.WARNING, 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')            
			return HttpResponseRedirect(reverse('dash-home')) 			

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)	



class ApproveAllDrafts(SuperuserRequiredMixin,LoginRequiredMixin, TemplateView):

	def get(self, *args, **kwargs):
		week = int(self.kwargs['week'])
		classroom = self.request.user.current_classroom	
		drafts = Draft.objects.filter(student__classroom=classroom,student__semester=classroom.current_semester,week_num=week,status=1)
		for draft in drafts:
			draft.status = 3
			draft.save()
		messages.add_message(self.request, messages.SUCCESS, 'Successfully approved all drafts.')
		return HttpResponseRedirect('/inbox/')		


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


			grades_values = dict([(name[6:],value) for name, value in self.request.POST.items() if name.startswith('grade_')])

			for category_pk,grade_val in grades_values.items():
				category = Category.objects.get(id=category_pk)
				try:
					grade = Grade.objects.get(draft=draft, category=category)
					grade.grade = grade_val
					grade.save()
				except Grade.DoesNotExist:
					grade = Grade.objects.create(draft=draft,category=category,grade=grade_val)

			#raise Exception("wht")
			draft.save()
			messages.add_message(self.request, messages.SUCCESS, 'Successfully approved with edits.')
			return HttpResponseRedirect('/inbox/')
		else:
			messages.add_message(self.request, messages.ERROR, form.errors)
			return JsonResponse(form.errors)


class ApproveSelectedDrafts(SuperuserRequiredMixin,LoginRequiredMixin, TemplateView):

	def post(self, *args, **kwargs):

		status = int(kwargs['status'])

		selected_drafts = [value for name, value in self.request.POST.items() if name.startswith('draft_to_approve_')]

		count = 0			
		for i in range(len(selected_drafts)):
			draft_pk = int(selected_drafts[i].encode('ascii'))
			try:
				draft = Draft.objects.get(id=draft_pk)
				draft.status = 3
				draft.send_approval_notification()
				draft.save()
				count += 1
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, "Something went wrong. A draft could not be approved.")	

		messages.add_message(self.request, messages.SUCCESS, "Drafts have been approved ("+str(count)+")")	
		return HttpResponseRedirect('/inbox/') 


class SendSelectedDrafts(SuperuserRequiredMixin,LoginRequiredMixin, TemplateView):

	def post(self, *args, **kwargs):

		status = int(kwargs['status'])
		if status == 3:
			selected_drafts = [value for name, value in self.request.POST.items() if name.startswith('draft_to_send_')]
		elif status == 4:
			selected_drafts = [value for name, value in self.request.POST.items() if name.startswith('draft_to_resend_')]

		sent_count = 0	
		successfully_sent = []
		no_email_found = []
		no_email_count = 0		
		for i in range(len(selected_drafts)):
			draft_pk = int(selected_drafts[i].encode('ascii'))
			draft = Draft.objects.get(id=draft_pk)
			try:
				if draft.send_email_to_student():
					sent_count += 1
					successfully_sent.append(draft.student.get_full_name())
				else:
					no_email_count += 1
					no_email_found.append(draft.student.get_full_name())
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, 'Unable to send this feedback to student: %s' % e) 

		if successfully_sent:
			messages.add_message(self.request, messages.SUCCESS, str(len(successfully_sent)) + ' Feedback Emails have been sent to: ' +', '.join(successfully_sent))             
		if no_email_count:
			messages.add_message(self.request, messages.ERROR, str(len(no_email_found)) + ' Emails could not be sent, no email addresses found for: ' +', '.join(no_email_found))  

		return HttpResponseRedirect('/inbox/') 



class SendDrafts(SuperuserRequiredMixin, View):

	def get(self, *args, **kwargs):
		week = int(self.kwargs['week'])
		resend = False
		if 'resend' in self.kwargs:
			resend = True
		#resend = self.kwargs['resend']
		sent_count = 0
		drafts = Draft.objects.filter(student__classroom=self.request.user.current_classroom,student__semester=self.request.user.current_classroom.current_semester,
			week_num=week,status=3,email_sent=resend)
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
		return HttpResponseRedirect('/inbox/') 	


def approve_draft(request, pk):
	try:
		draft = Draft.objects.get(id=pk)
		draft.status = 3
		draft.send_approval_notification()
		draft.save()
		messages.add_message(request, messages.SUCCESS, 'Draft sucessfully approved.')		
	except Draft.DoesNotExist:
		messages.add_message(request, messages.ERROR, 'Error when approving feedback draft.')
	return HttpResponseRedirect('/inbox/') 	

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
		return HttpResponseRedirect('/inbox/') 
	else:
		messages.add_message(request, messages.ERROR, 'Form not valid. Please check your inputs.')
		return HttpResponseRedirect('/inbox/') 

def change_week(request):
	form = request.POST or None
	if 'weekDropDown' in request.POST:
		week = int(request.POST['weekDropDown'].encode('ascii','ignore'))	
		return HttpResponseRedirect('/inbox/week/'+str(week)) 

