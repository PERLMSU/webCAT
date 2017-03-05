from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import (
	DashboardView,
    #ManageUsersView,
    # LoginView,
    # LogoutView,
    # SignupView,
    ActivationView,
    ResendActivationView,
)


urlpatterns = [
	url(r'^$', DashboardView.as_view(), name='admin-dashboard'),
#  url(r'^manage/$', ManageUsersView.as_view(), name='admin-manage-users'),
	url(r'^activate/(?P<key>[0-9A-Za-z]+)/$', ActivationView.as_view(), name="activation"),
    url(r'^resend/activation/key/$', ResendActivationView.as_view(), name="resend-activation-key"),  	  
  	  # url(r'^charts/', views.view_charts, name='admin-charts'),
  	  # url(r'^tables/', views.view_tables, name='admin-tables'),
  	  # url(r'^forms/', views.view_forms, name='admin-forms'),
  	  # url(r'^bootstrap/', views.view_bootstrap, name='admin-bootstrap'),
  	  # url(r'^blank/', views.view_blank, name='admin-blank'),
]