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

import django_excel as excel

from .forms import(
               # ProfileForm,
                #ProfileImageForm, 
                AccountSettingsForm, 
                AccountEmailForm, 
                ChangePasswordForm,
                LoginForm,
                AddInstructorForm,
            ) 

from userprofile.models import (
                                Profile, 
                                ConfirmationKey
                            )

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
        users = Profile.objects.all()
        self.context['users'] = users
        #raise Exception("test")
        return render(self.request, self.template_name, self.context)

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

class DashboardView(LoginRequiredMixin, TemplateView):
	""" dashboard page, manage users
	"""
	template_name = 'index.html'
	context = {}

	def get(self, *args, **kwargs):

		if self.request.user.is_authenticated():
			self.context['form'] = AddInstructorForm()
			users = Profile.objects.all()
			self.context['users'] = users
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