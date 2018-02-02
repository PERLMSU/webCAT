from django.conf import settings
from django.contrib.contenttypes.models import ContentType
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.core.mail import send_mail, EmailMessage, EmailMultiAlternatives
from django.contrib.auth.models import Permission
from django.core.urlresolvers import reverse
from django.db import models
from django.utils import timezone
from django.utils.translation import ugettext_lazy as _
from django.template.loader import render_to_string

from uuid import uuid4

from classroom.models import Classroom

class ProfileManager(BaseUserManager):
    """ Manager that contains methods used
        by the profile
    """
    def create_user(self, first_name, last_name, email, permission = 0, password=None, **kwargs):
        if not email:
            raise ValueError("Email address is required.")

        ct = ContentType.objects.get_for_model(Profile)
        profile = self.model(email=self.normalize_email(email), username=email)
        profile.set_password(password)
        profile.permission_level = permission
        profile.first_name = first_name
        profile.last_name = last_name
        profile.save()

        return profile

    def create_superuser(self, first_name, last_name, email, password, **kwargs):
        profile = self.create_user(first_name, last_name, email, 1,password, **kwargs)
        profile.is_admin = True
        profile.is_staff = True
        profile.is_superuser = True
        profile.save()

        return profile


class Profile(AbstractBaseUser, PermissionsMixin):
    """ User's model
    """
    class Meta:
       ordering = ['permission_level', 'last_name', 'first_name']

    email = models.EmailField(max_length=150, unique=True)
    username = models.CharField(max_length=150, unique=True)
    first_name = models.CharField(max_length=80, null=True, blank=True)
    last_name = models.CharField(max_length=80, null=True, blank=True)

    nick_name = models.CharField(max_length=15, null=True, blank=True)
  #  image = models.ImageField(upload_to='images/')
    bio = models.TextField(null=True, blank=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    city = models.CharField(max_length=100, null=True, blank=True)
    country = models.CharField(max_length=100, null=True, blank=True)
    state = models.CharField(max_length=100, null=True, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    is_verified = models.BooleanField(default=False)
    is_activated = models.BooleanField(default=False)

    permission_level = models.IntegerField(default=0)
    is_admin = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False, help_text=_('Designates whether the user can log into this admin '
                    'dashboard.'))
    is_active = models.BooleanField(_('active'), default=True)

    current_classroom = models.ForeignKey(Classroom, blank=True, null=True)

    objects = ProfileManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS  = ['first_name', 'last_name']

    def __str__(self):
        return self.email

    def get_current_classroom_instructor(self):
        if not self.current_classroom:
            return None
        else:
            return self.current_classroom.instructor


    def get_full_name(self):
        return "{} {}".format(self.first_name, self.last_name).strip()

    def get_short_name(self):
        return self.first_name

    def generate_confirm_key(self):
        """ Generate a confirm key for this user.
        """
        from userprofile.models import ConfirmationKey
        return ConfirmationKey.objects.create(user=self)

    def send_confirmation_email(self, request):
        """ Send confirmation key to user.
        """
        confirm_key = self.generate_confirm_key()
        url_path = request.build_absolute_uri(reverse('activation', args=(confirm_key.key,)))
        host_email = settings.EMAIL_HOST_USER
        subject =   "Confirmation Key"
        email_to = confirm_key.user.email
        html_content = render_to_string('email/activate.html',{
                                                        'subject': subject,
                                                        'url': url_path,
                                                    })
        subject, from_email, title='User Account', host_email, email_to
        msg = EmailMultiAlternatives(subject, html_content, from_email, [title])
        msg.content_subtype = "html"
        msg.send()


class ConfirmationKey(models.Model):
    """email confirmation key
    """
    user = models.ForeignKey(Profile)
    key = models.CharField(max_length=32, null=True, blank=True)
    is_used = models.BooleanField(default=False)

    def __str__(self):
        return "{user}:{key}".format(user=self.user, key=self.key)

    def save(self, *args, **kwargs):
        if not self.id:
            self.key = self._generate_key()
        return super(ConfirmationKey, self).save(*args, **kwargs)

    def _generate_key(self):
        return uuid4().hex


class ResetPasswordKey(models.Model):
    """reset password key
    """
    user = models.ForeignKey(Profile)
    key = models.CharField(max_length=32, null=True, blank=True)
    is_used = models.BooleanField(default=False)

    def __str__(self):
        return "{user}:{key}".format(user=self.user, key=self.key)

    def save(self, *args, **kwargs):
        if not self.id:
            self.key = self._generate_key()
        return super(ResetPasswordKey, self).save(*args, **kwargs)

    def _generate_key(self):
        return uuid4().hex

