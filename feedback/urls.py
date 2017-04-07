from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *

urlpatterns = [
  url(r'^$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^categories/$', CategoryView.as_view(), name="feedback-categories"),
  url(r'^categories/create/$', create_category, name="category-create-main"),
  url(r'^categories/addsubcategory/(?P<pk>\d+)/$', create_subcategory, name="category-create-subcategory"),
  url(r'^categories/create_common_feedback/(?P<pk>\d+)/$', create_common_feedback, name="category-create-feedback"),
  url(r'^categories/editcategory/(?P<pk>\d+)/$', edit_category, name="edit-category"),
  url(r'^categories/editsubcategory/(?P<pk>\d+)/$', edit_subcategory, name="edit-subcategory"),
  url(r'^categories/delete_sub/(?P<pk>\d+)/$', DeleteSubCategoryView.as_view(), name="delete-subcategory"),
  url(r'^categories/delete_main/(?P<pk>\d+)/$', DeleteCategoryView.as_view(), name="delete-category"),
]

