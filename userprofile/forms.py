from django import forms
from django.utils.translation import ugettext_lazy as _

from collections import OrderedDict
from django.conf import settings

import string

from django.contrib.auth import authenticate
from django.contrib.auth.forms import AuthenticationForm

from django.core.files.base import ContentFile

import base64



from .models import Profile
from localflavor.us.us_states import STATE_CHOICES
from localflavor.us.forms import USStateField

class AddImageForm(forms.Form):
    image = forms.ImageField()

    # def clean_image(self):
    #   image = self.cleaned_data.get('image')
    #   if image:
    #       if image._size > 2*1024*1024:
    #           raise ValidationError("Image file is too large. (>2MB")

    #       return image
    #   else:
    #       raise ValidationError("Couldn't read uploaded image")

class UpdateProfileForm(forms.Form):
    nick_name = forms.CharField(max_length=15)
    city = forms.CharField(max_length=15)
    state = forms.CharField(max_length=15)
    country = forms.CharField(max_length=15)


class ProfileForm(forms.ModelForm):
    birth_date = forms.DateField(
                    widget=forms.DateInput({'type': 'date'}), 
                    input_formats=settings.DATE_INPUT_FORMATS, 
                    required=False)
    email = forms.CharField(widget=forms.TextInput(attrs={'readonly':'readonly'}))

    class Meta:
        model = Profile
        fields = (
            'email',
            'first_name',
            'last_name',
            'nick_name',
            'bio',
            'phone',
            'city',
            'state',
            'country',
            'birth_date',
        )

    YOUR_STATE_CHOICES = list(STATE_CHOICES)
    YOUR_STATE_CHOICES.insert(0, ('', '---------'))
    state = USStateField(
                widget=forms.Select(choices=YOUR_STATE_CHOICES), 
                required=False)


class ProfileImageForm(forms.ModelForm):

    image = forms.ImageField(required=False)

    class Meta:
        model = Profile
        fields = ('image',)

    def save(self, commit=True):
        instance = super(ProfileImageForm, self).save(commit=False)
        data = self.data['image']
        image = base64.b64decode(data.split(',')[1])
        filename = self.data['filename']
        instance.image = ContentFile(image, filename)
        if commit:
            instance.save()
        return instance


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

