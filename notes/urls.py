from django.conf.urls import url
from .views import *
from django.template.response import TemplateResponse

urlpatterns = [
	url(r'^$', NotesView.as_view(), name="notes-home"),
	 url(r'^add/(?P<pk>\d+)/$', AddFeedback.as_view(), name='notes-add-feedback'),
]