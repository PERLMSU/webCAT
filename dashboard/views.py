from braces.views import LoginRequiredMixin
from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse

from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View

from .forms import LoginForm, AddInstructorForm

from userprofile.models import (
                                Profile, 
                                ConfirmationKey
                            )
# Create your views here.


def view_dashboard(request):
	return render(request, "index.html")


def view_charts(request):
	return render(request, "charts.html")	

def view_tables(request):
	return render(request, "tables.html")


def view_forms(request):
	return render(request, "forms.html")

def view_bootstrap(request):
	return render(request, "bootstrap-elements.html")


def view_blank(request):
	return render(request, "blank-page.html")	

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
            return HttpResponseRedirect(reverse('admin-dashboard'))

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)

class ResendActivationView(View):
    """ Resend activation key
    """
    def get(self, *args, **kwargs):
        user = Profile.objects.get(email=self.request.user)
        user.send_confirmation_email(self.request)
        self.add_message("Email has been sent")
        return HttpResponseRedirect(reverse('admin-dashboard'))

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)

class DashboardView(TemplateView):
	""" dashboard page, manage users
	"""
	template_name = 'index.html'
	context = {}

	def get(self, *args, **kwargs):
		self.context['form'] = AddInstructorForm()
		users = Profile.objects.all()
		self.context['users'] = users
		raise Exception("test")
		return render(self.request, self.template_name, self.context)

	def post(self, *args, **kwargs):
		form = AddInstructorForm(self.request.POST)
		if form.is_valid():
		    # register user
		    permission = form.cleaned_data['permission_level']
		  #  raise Exception("test")
		    user = Profile.objects.create_user(
		               password=form.cleaned_data['password'],
		               email=form.cleaned_data['email'],
		               permission_level= form.cleaned_data['permission_level']
		               )
		    user.send_confirmation_email(self.request)
		    return HttpResponseRedirect(reverse('admin-dashboard'))
		self.context['form'] = form
		users = Profile.objects.all()
		self.context['users'] = users		
		return render(self.request, self.template_name, self.context)