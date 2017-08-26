from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import (
	DashboardView,
  SettingsView,
    ManageUsersView,
     LoginView,
     LogoutView,
    # SignupView,
    ActivationView,
    ResendActivationView,
    EmailConfirmationView,
    UpdateEmailView,
    ChangePasswordView,
    edit_instructor,
)


urlpatterns = [
	url(r'^$', DashboardView.as_view(), name='dash-home'),
  url(r'^manage/$', ManageUsersView.as_view(), name="dash-manage-users"),
  url(r'^manage/edit/(?P<pk>\d+)/$', edit_instructor, name="dash-edit-user"),
    url(r'^settings/$', EmailConfirmationView.as_view(), name="dash-settings"),
    url(r'^settings/email/$', UpdateEmailView.as_view(), name="dash-email-settings"),
    #url(r'^activate/(?P<key>[0-9A-Za-z]+)/$', ConfirmationView.as_view(), name="account-activate"),
    url(r'^settings/password/$', ChangePasswordView.as_view(), name="dash-change-password"),  
	  url(r'^activate/(?P<key>[0-9A-Za-z]+)/$', ActivationView.as_view(), name="activation"),
    url(r'^resend/activation/key/$', ResendActivationView.as_view(), name="resend-activation-key"), 
    url(r'^accounts/login/$', LoginView.as_view(), name="login"),
    url(r'^accounts/logout/$', LogoutView.as_view(), name="logout"),     	  
  	  # url(r'^charts/', views.view_charts, name='admin-charts'),
  	  # url(r'^tables/', views.view_tables, name='admin-tables'),
  	  # url(r'^forms/', views.view_forms, name='admin-forms'),
  	  # url(r'^bootstrap/', views.view_bootstrap, name='admin-bootstrap'),
  	  # url(r'^blank/', views.view_blank, name='admin-blank'),
]