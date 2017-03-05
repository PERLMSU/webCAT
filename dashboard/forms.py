from django import forms
from django.contrib.auth import authenticate
from django.utils.translation import ugettext_lazy as _

import string

from userprofile.models import Profile



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


class AddInstructorForm(forms.Form):
    """ add instructor form
    """
    #first_name = forms.CharField()
    #last_name = forms.CharField()

    CHOICES=[(0,'Learning Assistant'),
         (1, 'Admin')]

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
