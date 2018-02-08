from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from django.contrib.auth import login
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from braces.views import LoginRequiredMixin
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.template.defaulttags import register
from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.files.base import ContentFile

import base64


from .models import Profile, ConfirmationKey

from .forms import (
                ProfileForm,
                ProfileImageForm, 
                AccountSettingsForm, 
                AccountEmailForm, 
                ChangePasswordForm,
            )

from feedback.models import Notification



@register.filter
def get_user_notifications(user_pk):
    return Notification.objects.filter(user = user_pk, draft_to_approve__status__in =[1,2])

class ProfileView(LoginRequiredMixin, TemplateView):
    """ profile page
    """
    template_name = 'profile.html'
    context = {}

    def get(self, *args, **kwargs):
        form = ProfileForm(instance=self.request.user)
        self.context['form'] = form
        return render(self.request, self.template_name, self.context)

    def post(self, *args, **kwargs):
        form = ProfileForm(self.request.POST, instance=self.request.user)
        self.context['form'] = form
        if form.is_valid():
            form.save()

            self.add_message("Profile has been updated.")

            return HttpResponseRedirect(reverse('user-profile'))
        return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)


class ProfileImageView(LoginRequiredMixin, View):


    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super(ProfileImageView, self).dispatch(self.request, *args, **kwargs)

    def post(self, *args, **kwargs):
        form = ProfileImageForm(self.request.POST, instance=self.request.user)
        if form.is_valid():
            form.save()   

            self.add_message("Profile image has been updated")
            return HttpResponseRedirect(reverse('user-profile'))

        self.add_message(form.errors, 40)
        return HttpResponseRedirect(reverse('user-profile'))

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


class ConfirmationView(View):
    """ User Activation
    """
    def get(self, *args, **kwargs):
        activate = get_object_or_404(ConfirmationKey, key=kwargs['key'])
        user = Profile.objects.get(email=activate.user)
        
        if user.is_active == True:
            user.is_activated = True 
            user.save()
            activate.is_used = True
            activate.save()
            ConfirmationKey.objects.filter(user=activate.user, is_used=False).delete()
            return HttpResponseRedirect(reverse('user-email-settings'))


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
        return HttpResponseRedirect(reverse('user-account-settings'))

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
        self.context['profile_user'] = user
        return render(self.request, self.template_name, self.context)


class UsersView(LoginRequiredMixin, TemplateView):
    """ users page
    """
    template_name = 'users.html'
    context = {}

    def get(self, *args, **kwargs):
        users = Profile.objects.all()
        page = self.request.GET.get('page', 1)

        paginator = Paginator(users, 10)
        try: 
            users = paginator.page(page)
        except PageNotAnInteger:
            users = paginator.page(1)
        except EmptyPage:
            users = paginator.page(paginator.num_pages)
        self.context['users'] = users
        return render(self.request, self.template_name, self.context)