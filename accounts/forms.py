from django.contrib.auth.forms import AuthenticationForm
from django.forms.fields import EmailField
from django import forms
from django.utils.translation import gettext, gettext_lazy as _


class CustomAuthenticationForm(AuthenticationForm):
    # Note: to extend AuthenticationForm, this has to be named username :(
    username = EmailField(widget=forms.TextInput(attrs={'autofocus': True, 'placeholder': _("Email")}))
    password = forms.CharField(
        label=_("Password"),
        strip=False,
        widget=forms.PasswordInput(attrs={'autocomplete': 'current-password', 'placeholder': _("Password")}),
    )
