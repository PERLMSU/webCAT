from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import (
    FeedbackView,
	)

urlpatterns = [
  url(r'^$', FeedbackView.as_view(), name="feedback-home"),
]