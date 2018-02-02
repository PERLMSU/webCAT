from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.conf import settings
from django.core.mail import send_mail, EmailMessage, EmailMultiAlternatives
from django.template.loader import render_to_string
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.files.base import ContentFile

from django.template.defaulttags import register

import django_excel as excel
from django.db import IntegrityError

from .forms import *

from userprofile.models import (
								Profile, 
								ConfirmationKey,
								ResetPasswordKey
							)

from classroom.models import *
from classroom.forms import *

@register.filter
def get_num_students(classroom_pk):
	return Student.objects.filter(classroom=classroom_pk).count()


@register.filter
def get_rotations(classroom_pk,semester_pk):
	return Rotation.objects.filter(classroom=classroom_pk,semester=semester_pk)

@register.filter
def get_num_instructors(classroom_pk):
	return Profile.objects.filter(current_classroom=classroom_pk).count()	



class ForgotPasswordView(TemplateView):
    """ forgot password
    """
    template_name = 'registration/forgot_password.html'
    context = {}

    def get(self, *agrs, **kwargs):
        self.context['form'] = ForgotPasswordForm()
        return render(self.request, self.template_name, self.context)

    def post(self, *agrs, **kwargs):
        form = ForgotPasswordForm(self.request.POST)
        self.context['form'] = form

        if form.is_valid():
            user = Profile.objects.get(email=form.cleaned_data['email'])
            email = user.email
            key = ResetPasswordKey.objects.create(user=user)
            url_path = self.request.build_absolute_uri(reverse('reset-password', args=(key.key,)))
            html_content = render_to_string('email/forgot_password.html',{
                                                            'subject': 'Resetting Your Password',
                                                            'email': email,
                                                            'url': url_path
                                                        })
            subject, from_email, to = 'Password Reset', settings.EMAIL_HOST_USER, email
            msg = EmailMultiAlternatives(subject, html_content, from_email, [to])
            msg.content_subtype = "html"
            msg.send()
            self.add_message("Email has been sent")
            return render(self.request, self.template_name, self.context)
        return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)


class ResetPasswordView(TemplateView):
    """ reset password
    """
    template_name = 'registration/reset_password.html'
    context = {}

    def get(self, *args, **kwargs):
        self.context['form'] = ResetPasswordForm()

        try:
            key = ResetPasswordKey.objects.get(key=kwargs['key'])
        except ResetPasswordKey.DoesNotExist:
            key=None
        self.context['email'] = key.user.email     
        return render(self.request,  self.template_name, self.context)

    def post(self, *args, **kwargs):
        form = ResetPasswordForm(self.request.POST)

        try:
            key = ResetPasswordKey.objects.get(key=kwargs['key'])
        except ResetPasswordKey.DoesNotExist:
            key=None
        
        if key is not None:
            if form.is_valid():
                password = form.cleaned_data['password']
                user = Profile.objects.get(email=key.user.email)
                user.set_password(password)
                user.save()
                key.is_used = True
                key.save()
                ResetPasswordKey.objects.filter(user=user, is_used=False).delete()
                self.add_message("Password has been updated.")
                return HttpResponseRedirect(reverse('login'))
            self.context['form'] = form
          #  self.context['email'] = key.user.email
            return render(self.request, self.template_name, self.context)
        self.add_message("Reset password link is no longer valid.")
        return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)



class EmailConfirmationView(LoginRequiredMixin, TemplateView):
	template_name = 'account_email.html'
	context = {}

	def get(self, *args, **kwargs):
		form = AccountSettingsForm(instance=self.request.user)
		self.context['form'] = form
		return render(self.request, self.template_name, self.context)

	def post(self, request, *args, **kwargs):
		form = AccountSettingsForm(self.request.POST, instance=self.request.user)
		self.context['form'] = form
		if form.is_valid():
			host_email = settings.EMAIL_HOST_USER
			confirm_key = ConfirmationKey.objects.create(user=self.request.user)
			url_path = request.build_absolute_uri('/').strip("/")
			url =   url_path + "/profile/activate/" + confirm_key.key
			token = ConfirmationKey.objects.create(user=self.request.user)
			subject =   "Confirm New Email"
			email_to = form.data['email']
			html_content = render_to_string('email/new_email.html',{
															'subject': subject,
															'email': email_to,
															'url': url
														})
			subject, from_email, to = 'User Account', host_email, email_to
			msg = EmailMultiAlternatives(subject, html_content, from_email, [to])
			msg.content_subtype = "html"
			msg.send()
			self.add_message("Confirmation email has been sent.")

		self.add_message(form.errors, 40)
		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)

class UpdateEmailView(LoginRequiredMixin, TemplateView):
	template_name = 'update_email.html'
	context = {}

	def get(self, *args, **kwargs):
		form = AccountEmailForm(instance=self.request.user)
		self.context['form'] = form
		return render(self.request, self.template_name, self.context)

	def post(self, request, *args, **kwargs):
		form = AccountEmailForm(self.request.POST, instance=self.request.user)
		self.context['form'] = form
		if form.is_valid():
			form.save()
			self.add_message("Your email has been updated.")

		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)


class ChangePasswordView(LoginRequiredMixin, View):

	def post(self, *args, **kwargs):
		account = Profile.objects.get(email=self.request.user)
		form = ChangePasswordForm(self.request.POST, instance=account, user=self.request.user)
		if form.is_valid():
			form.save()
			instance = form.save()
			instance.backend = settings.AUTHENTICATION_BACKENDS[0]
			login(self.request,instance)
			self.add_message("Password has been updated")
	   
		self.add_message(form.errors, 40)
		return HttpResponseRedirect(reverse('dash-settings'))

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)


class UserProfilesView(LoginRequiredMixin, TemplateView):
	""" user profile page
	"""
	template_name = 'user_details.html'
	context = {}

	def get(self, *args, **kwargs):
		user_id = kwargs.get('pk')
		user = get_object_or_404(Profile, id=user_id)
		self.context['user'] = user
		return render(self.request, self.template_name, self.context)

class SettingsView(TemplateView):
	template_name = 'settings.html'

class LoginView(TemplateView):
	""" login page
	"""
	template_name = 'registration/login.html'

	def get(self, *args, **kwargs):
		form = LoginForm()
		return render(self.request, self.template_name, {'form': form})

	def post(self, *args, **kwargs):
		form = LoginForm(self.request.POST)
		if form.is_valid():
			# user credentials are valid.
			# add user to the session
			login(self.request, form.user_cache)

			return HttpResponseRedirect(reverse('dash-home'))
		return render(self.request, self.template_name, {'form': form})


class LogoutView(View):
	""" logout event
	"""

	def get(self, *args, **kwargs):
		logout(self.request)
		return HttpResponseRedirect(reverse('login'))


class ActivationView(View):
	""" User Activation
	"""
	def get(self, *args, **kwargs):
		activate = get_object_or_404(ConfirmationKey, key=kwargs['key'])
		user = Profile.objects.get(email=activate.user)
		
		if user.is_active == True:
			user.is_verified = True 
			user.save()
			activate.is_used = True
			activate.save()
			ConfirmationKey.objects.filter(user=activate.user, is_used=False).delete()
			self.add_message("Congratulations! Your account is now activated")
			return HttpResponseRedirect(reverse('dash-home'))

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)

class ResendActivationView(View):
	""" Resend activation key
	"""
	def get(self, *args, **kwargs):
		user = Profile.objects.get(email=self.request.user)
		user.send_confirmation_email(self.request)
		self.add_message("Email has been sent")
		return HttpResponseRedirect(reverse('dash-home'))

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)

class ManageUsersView(LoginRequiredMixin, SuperuserRequiredMixin, TemplateView):
	""" dashboard page, manage users
	"""
	template_name = 'manage.html'
	context = {}

	def get(self, *args, **kwargs):
		self.context['form'] = AddInstructorForm()
		users = Profile.objects.filter()
		self.context['users'] = users
		self.context['classrooms'] = Classroom.objects.all().order_by('course_code')
		self.context['edit_instructor_form'] = EditInstructorForm()
		#raise Exception("test")
		return render(self.request, self.template_name, self.context)

	def post(self, *args, **kwargs):
		form = AddInstructorForm(self.request.POST)
		if form.is_valid():
			try:
				user = Profile.objects.create_user(
							first_name=form.cleaned_data['first_name'],
							last_name=form.cleaned_data['last_name'],
						   password=form.cleaned_data['password'],
						   email=form.cleaned_data['email'],
						   permission = form.cleaned_data['permission_level']
						   )
				self.add_message("User successfully created!")   
				# return HttpResponseRedirect(reverse('dash-manage-users'))				
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, "Could not create user: "+str(e))
			try:

				user.send_confirmation_email(self.request)  
				self.add_message("Confirmation email sent.")   
			except Exception as e:
				messages.add_message(self.request, messages.ERROR, "Could not send confirmation email: "+str(e))				
		self.context['form'] = form
		users = Profile.objects.all()
		self.context['users'] = users
		messages.add_message(self.request, messages.ERROR, form.errors)          
		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text) 

def add_semester(request):
	form = AddSemesterForm(request.POST or None)
	if form.is_valid():
		semester = form.save(commit=False)
		semester.save()
		messages.add_message(request, messages.SUCCESS, "Semester successfully added!")  
		return HttpResponseRedirect(reverse('dash-home'))        
	else:
		messages.error(request, form.errors)
		return HttpResponseRedirect(reverse('dash-home'))    	
	#return HttpResponseRedirect('/dashboard/') 


def edit_instructor(request, pk):
	form = EditInstructorForm(request.POST or None)
	if form.is_valid():
		try:
			instructor = Profile.objects.get(id = pk)
		except Exception as e:
			messages.add_message(request, messages.ERROR, "Could not edit user: "+e)  
			return HttpResponseRedirect(reverse('dash-manage-users'))

		instructor.first_name = form.cleaned_data['first_name']
		instructor.last_name = form.cleaned_data['last_name']
		instructor.email = form.cleaned_data['email']
		instructor.current_classroom = form.cleaned_data['current_classroom']
		instructor.permission_level = form.cleaned_data['permission_level']
		instructor.save()
		messages.add_message(request, messages.SUCCESS, "User successfully edited!")   
		return HttpResponseRedirect(reverse('dash-manage-users'))
	else:
		messages.add_message(request, messages.ERROR, "User not edited, form inputs not valid.")   
		return HttpResponseRedirect(reverse('dash-manage-users'))  


class DeleteInstructorView(LoginRequiredMixin, View):
    """ delete instructor view
    """
    def get(self, *args, **kwargs):
        try:
            instructor = Profile.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this user %s' % e)
        finally:
            instructor.delete()
            messages.add_message(self.request, messages.SUCCESS, 'User successfully deleted!')
        return HttpResponseRedirect('/dashboard/manage/') 


class DashboardView(LoginRequiredMixin, TemplateView):
	""" dashboard page, manage users
	"""
	template_name = 'index.html'
	context = {}

	def get(self, request, *args, **kwargs):

		if self.request.user.is_authenticated():
			self.context['form'] = AddInstructorForm()
			self.context['add_semester_form'] = AddSemesterForm()
#			self.context['register_classroom_form'] = ClassroomRegistrationForm()
			users = Profile.objects.all()
			self.context['users'] = users
			#if request.user.current_classroom_id:
			self.context['current_classroom'] = request.user.current_classroom or None
			#else:
			#	self.context['c']
			self.context['rotation_form'] = AddEditRotationForm()
			self.context['semesters'] = Semester.objects.all().order_by('date_begin')
			self.context['register_classroom'] = AddClassroomForm()
			self.context['edit_classroom'] = EditClassroomForm()

			self.context['classrooms'] = Classroom.objects.filter(instructor = self.request.user)
			return render(self.request, self.template_name, self.context)

		form = LoginForm()
		return render(self.request, 'registration/login.html', {'form': form})        

	def post(self, *args, **kwargs):
		form = AddInstructorForm(self.request.POST)
		if form.is_valid():
			# register user
			#permission = form.cleaned_data['permission_level']
	   # raise Exception("test")
			user = Profile.objects.create_user(
					   password=form.cleaned_data['password'],
					   email=form.cleaned_data['email'],
					   permission = form.cleaned_data['permission_level']
					   )
			user.send_confirmation_email(self.request)   
			self.add_message("User successfully created")	
			return HttpResponseRedirect(reverse('dash-home'))
		self.context['form'] = form
		users = Profile.objects.all()
		self.context['users'] = users
		self.add_message("Form not valid, failed to create user.")			
		return render(self.request, self.template_name, self.context)

	def add_message(self, text, mtype=25):
		messages.add_message(self.request, mtype, text)		