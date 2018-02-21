from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *

urlpatterns = [
  url(r'^$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^(?P<pk>\d+)/$', FeedbackView.as_view(), name="feedback-home-save"),
  url(r'^student/(?P<pk>\d+)/$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^week/(?P<week>\d+)/$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^week/change/$', change_week_feedback, name="feedback-change-week"),
  url(r'^manager/$', FeedbackManager.as_view(), name="feedback-manager"),
  url(r'^manager/observation/$', AddEditObservation.as_view(), name="edit-observation"),
  url(r'^manager/observation/delete/(?P<pk>\d+)/$', DeleteObservationView.as_view(), name="delete-observation"),
  url(r'^manager/feedback/$', AddEditCommonFeedback.as_view(), name="edit-common-feedback"),
  url(r'^manager/feedback/delete/(?P<pk>\d+)/$', DeleteCommonFeedbackView.as_view(), name="delete-common-feedback"),
  url(r'^manager/explanation/$', AddEditFeedbackExplanation.as_view(), name="edit-feedback-explanation"),
  url(r'^manager/explanation/delete/(?P<pk>\d+)/$', DeleteFeedbackExplanationView.as_view(), name="delete-explanation"),
  url(r'^categories/$', CategoryView.as_view(), name="feedback-categories"),
  url(r'^categories/create/$', create_category, name="category-create-main"),
  url(r'^categories/addsubcategory/(?P<pk>\d+)/$', create_subcategory, name="category-create-subcategory"),
  url(r'^categories/editcategory/(?P<pk>\d+)/$', edit_category, name="edit-category"),
  url(r'^categories/editsubcategory/(?P<pk>\d+)/$', edit_subcategory, name="edit-subcategory"),
  url(r'^categories/delete_sub/(?P<pk>\d+)/$', DeleteSubCategoryView.as_view(), name="delete-subcategory"),
  url(r'^categories/delete_main/(?P<pk>\d+)/$', DeleteCategoryView.as_view(), name="delete-category"),
  url(r'^categories/delete_feedback/(?P<pk>\d+)/$', DeleteFeedbackPieceView.as_view(), name="delete-feedback-piece"),
]

