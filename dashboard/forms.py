from django import forms
from django.forms import ModelForm
from django.contrib.auth import authenticate
from django.utils.translation import ugettext_lazy as _

from collections import OrderedDict
from django.conf import settings

import string

from django.contrib.auth import authenticate
from django.contrib.auth.forms import AuthenticationForm

from django.core.files.base import ContentFile

import base64

from userprofile.models import Profile
from classroom.models import Classroom


# class ClassroomRegistrationForm(forms.ModelForm):
#     course = forms.CharField()
#     description = forms.CharField(required=False)
    

#     class Meta:
#         model = Classroom
#         fields = ['course','description']



class LoginForm(forms.Form):
    """ login form
    """
    user_cache = None

    email = forms.EmailField()
    password = forms.CharField(widget=forms.PasswordInput)

    def clean(self):
        email = self.cleaned_data.get('email')
        password = self.cleaned_data.get('password')

        user = authenticate(email=email, password=password)
        if not user:
            raise forms.ValidationError("Invalid Email or Password")
        else:
            self.user_cache = user

        return self.cleaned_data



class EditInstructorForm(forms.Form):
    CHOICES=[(0,'Learning Assistant'),
         (1, 'Admin')]    
    first_name = forms.CharField()
    last_name = forms.CharField()
    current_classroom = forms.ModelChoiceField(queryset=Classroom.objects.all().order_by('course_code','course_number'), empty_label=True)    
    permission_level = forms.ChoiceField(choices = CHOICES,
                            widget=forms.RadioSelect(attrs=dict(required=True,
                            render_value=False)),
                            label=_("Permission Level: "))
    email = forms.EmailField(
                            widget=forms.TextInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("Email"))
    
class AddInstructorForm(forms.Form):
    """ add instructor form
    """
    #first_name = forms.CharField()
    #last_name = forms.CharField()

    CHOICES=[(0,'Learning Assistant'),
         (1, 'Admin')]

    first_name = forms.CharField(
                            widget=forms.TextInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("First Name"))
    last_name = forms.CharField(
                            widget=forms.TextInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("Last Name"))

    email = forms.EmailField(
                            widget=forms.TextInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("Email"))
                        
    password = forms.CharField(
                            widget=forms.PasswordInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("Password"))

    confirm_password = forms.CharField(
                            widget=forms.PasswordInput(attrs=dict(required=True,
                            max_length=30, render_value=False)),
                            label=_("Password (again)"))

    permission_level = forms.ChoiceField(choices = CHOICES,
                            widget=forms.RadioSelect(attrs=dict(required=True,
                            render_value=False)),
                            label=_("Permission Level: "))

    def clean_email(self):
        email = self.cleaned_data.get('email')
        if not email:
            raise forms.ValidationError("Email is required")

        if Profile.objects.filter(email=email).exists():
            raise forms.ValidationError("Email is already registered")

        return email

    def clean(self):
        if 'password' in self.cleaned_data and 'confirm_password' in self.cleaned_data:
            # At least MIN_LENGTH long
            if len(self.cleaned_data['password']) < 6:
                raise forms.ValidationError("Password must be at least %d characters long." % 6)
            
            if all(c.isupper() == self.cleaned_data['password'].isupper() for c in self.cleaned_data['password']):
                raise forms.ValidationError("Password must contain at least one uppercase letter")

            if all(c.isdigit() == self.cleaned_data['password'].isdigit() for c in self.cleaned_data['password']):
                raise forms.ValidationError("Password must contain at least one digit")

            if self.cleaned_data['password'] != self.cleaned_data['confirm_password']:
                raise forms.ValidationError(_("The two password fields did not match."))
            return self.cleaned_data


class AccountSettingsForm(forms.ModelForm):
    
    class Meta:
        model = Profile
        fields = ('email',)

    def clean(self):
        cleaned_data = super(AccountSettingsForm, self).clean()
        email = self.data['email']
        if Profile.objects.filter(email=email).exists():
            raise forms.ValidationError("Email is already registered")
        return cleaned_data


class AccountEmailForm(forms.ModelForm):
    email = forms.CharField(
                            widget=forms.TextInput(attrs={'readonly':'readonly'}),
                            label=_("Current Address"))
    new_email = forms.EmailField(
                            widget=forms.TextInput(attrs=dict(required=False,
                            max_length=30, render_value=False)),
                            label=_("New Email Address"))

    class Meta:
        model = Profile
        fields = ('email', 'new_email')

    def clean(self):
        cleaned_data = super(AccountEmailForm, self).clean()
        new_email = self.data['new_email']
        if Profile.objects.filter(email=new_email).exists():
            raise forms.ValidationError("Email is already registered")
        return cleaned_data

    def save(self, commit=True):
        instance = super(AccountEmailForm, self).save(commit=False)
        instance.email = self.data['new_email']
        if commit:
            instance.save()
        return instance


class ChangePasswordForm(forms.ModelForm):
    """ form for changing password
    """
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop('user',None)
        return super(ChangePasswordForm, self).__init__(*args,**kwargs)

    password = forms.CharField(widget=forms.PasswordInput({
        'class':'input form-control',
        'placeholder': 'Enter current password'
        }))
    new_password = forms.CharField(widget=forms.PasswordInput({
        'class':'input form-control',
        'placeholder': 'Enter new password'
        }))
    confirm_password = forms.CharField(widget=forms.PasswordInput({
        'class':'input form-control',
        'placeholder': 'Enter corfirm password'
        }))
    
    class Meta:
        model = Profile
        fields = (
            'password', 
            'new_password', 
            'confirm_password'
            )

    def clean_password(self):
        password = self.cleaned_data.get('password')
        email = self.request
        user = authenticate(email=email, password=password)
        if not user:
            raise forms.ValidationError("Incorrect Password!")
        return password

    def clean(self):
        if 'new_password' in self.cleaned_data and 'confirm_password' in self.cleaned_data:
            # At least MIN_LENGTH long
            if len(self.cleaned_data['new_password']) < 6:
                raise forms.ValidationError("Password must be at least %d characters long." % 6)
            
            if all(c.isupper() == self.cleaned_data['new_password'].isupper() for c in self.cleaned_data['new_password']):
                raise forms.ValidationError("Password must contain at least one uppercase letter")

            if all(c.isdigit() == self.cleaned_data['new_password'].isdigit() for c in self.cleaned_data['new_password']):
                raise forms.ValidationError("Password must contain at least one digit")

            if self.cleaned_data['new_password'] != self.cleaned_data['confirm_password']:
                raise forms.ValidationError(_("The two password fields did not match."))
            return self.cleaned_data

    def save(self, commit=True):
        instance = super(ChangePasswordForm, self).save(commit=False)
        if commit:
            instance.set_password(self.data['new_password'])
            user = instance.save()
        return instance
