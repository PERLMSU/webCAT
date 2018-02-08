from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *


urlpatterns = [
	url(r'^$', DashboardView.as_view(), name='dash-home'),
  url(r'^manage/$', ManageUsersView.as_view(), name="dash-manage-users"),
  url(r'^semester/add/$', add_semester, name="dash-add-semester"),
  url(r'^manage/edit/(?P<pk>\d+)/$', edit_instructor, name="dash-edit-user"),
  url(r'^manage/delete/(?P<pk>\d+)/$', DeleteInstructorView.as_view(), name="dash-remove-user"),
    # url(r'^settings/$', EmailConfirmationView.as_view(), name="dash-settings"),
    # url(r'^settings/email/$', UpdateEmailView.as_view(), name="dash-email-settings"),
  #  url(r'^settings/password/$', ChangePasswordView.as_view(), name="dash-change-password"),  
#	  url(r'^activate/(?P<key>[0-9A-Za-z]+)/$', ActivationView.as_view(), name="activation"),
#    url(r'^resend/activation/key/$', ResendActivationView.as_view(), name="resend-activation-key"), 
    url(r'^accounts/login/$', LoginView.as_view(), name="login"),
    url(r'^accounts/logout/$', LogoutView.as_view(), name="logout"),    
    url(r'^forgot-password/$', ForgotPasswordView.as_view(), name="forgot-password"),
    url(r'^reset-password/(?P<key>[0-9A-Za-z]+)/$', ResetPasswordView.as_view(), name="reset-password"), 
]