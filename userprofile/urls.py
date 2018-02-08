from django.conf.urls import url
#from . import views
from userprofile.views import *

urlpatterns = [
    url(r'^$', ProfileView.as_view(), name="user-profile"),
    url(r'^upload/$', ProfileImageView.as_view(), name="user-profile-upload"),
    url(r'^settings/$', EmailConfirmationView.as_view(), name="user-account-settings"),
    # url(r'^settings/email/$', UpdateEmailView.as_view(), name="user-email-settings"),
    url(r'^activate/(?P<key>[0-9A-Za-z]+)/$', ConfirmationView.as_view(), name="account-activate"),
    url(r'^resend/activation/key/$', ResendActivationView.as_view(), name="resend-activation-key"), 
    url(r'^settings/password/$', ChangePasswordView.as_view(), name="user-change-password"),
    url(r'^users/$', UsersView.as_view(), name="user-list"),
    url(r'^users/(?P<pk>[0-9]+)/$', UserProfilesView.as_view(), name="user-details")
]