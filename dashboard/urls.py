from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *


urlpatterns = [
	url(r'^$', DashboardView.as_view(), name='dash-home'),
  url(r'^manage/$', ManageUsersView.as_view(), name="dash-manage-users"),
  url(r'^semester/add/$', add_semester, name="dash-add-semester"),
  url(r'^manage/edit/(?P<pk>\d+)/$', edit_instructor, name="dash-edit-user"),
  url(r'^manage/delete/(?P<pk>\d+)/$', DeleteInstructorView.as_view(), name="dash-remove-user"),
    url(r'^accounts/login/$', LoginView.as_view(), name="login"),
    url(r'^accounts/logout/$', LogoutView.as_view(), name="logout"),    
    url(r'^forgot-password/$', ForgotPasswordView.as_view(), name="forgot-password"),
    url(r'^reset-password/(?P<key>[0-9A-Za-z]+)/$', ResetPasswordView.as_view(), name="reset-password"), 
]