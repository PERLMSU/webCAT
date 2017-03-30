from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import (
	FeedbackView,
	CategoryView,
	create_category,
	)

urlpatterns = [
  url(r'^$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^categories/$', CategoryView.as_view(), name="feedback-categories"),
  url(r'^categories/create', create_category, name="category-create-main"),
]