from django.conf.urls import url
from .views import *
from django.template.response import TemplateResponse

urlpatterns = [
	url(r'^$', NotesView.as_view(), name="notes-home"),
	  url(r'^week/(?P<week>\d+)/$', NotesView.as_view(), name="notes-home"),
	  url(r'^week/change/$', change_week_notes, name="notes-change-week"),	
	 url(r'^add/$', AddFeedback.as_view(), name='notes-add-feedback'),
]