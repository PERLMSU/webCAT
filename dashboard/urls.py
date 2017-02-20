from django.conf.urls import url
from django.template.response import TemplateResponse
from . import views


urlpatterns = [
  	  url(r'^', views.view_dashboard, name='admin-dashboard'),
]