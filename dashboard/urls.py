from django.conf.urls import url
from django.template.response import TemplateResponse
from . import views


urlpatterns = [
  	  url(r'^', views.view_dashboard, name='admin-dashboard'),
  	  url(r'^charts/', views.view_charts, name='admin-charts'),
  	  url(r'^tables/', views.view_tables, name='admin-tables'),
  	  url(r'^forms/', views.view_forms, name='admin-forms'),
  	  url(r'^bootstrap/', views.view_bootstrap, name='admin-bootstrap'),
  	  url(r'^blank/', views.view_blank, name='admin-blank'),
]