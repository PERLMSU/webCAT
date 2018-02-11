from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *

urlpatterns = [
  url(r'^$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^(?P<pk>\d+)/$', FeedbackView.as_view(), name="feedback-home-save"),
  url(r'^student/(?P<pk>\d+)/$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^week/(?P<week>\d+)/$', FeedbackView.as_view(), name="feedback-home"),
  url(r'^week/change/$', change_week_feedback, name="feedback-change-week"),
  url(r'^inbox/$', InboxView.as_view(), name="feedback-inbox"),
  url(r'^inbox/change/$', change_week, name="inbox-change-week"),
  url(r'^inbox/week/(?P<week>\d+)/$', InboxView.as_view(), name="feedback-inbox"),
  url(r'^inbox/approve/(?P<pk>\d+)/$', approve_draft, name="inbox-approve-draft"),
  url(r'^inbox/approve-selected/(?P<status>\d+)/$', ApproveSelectedDrafts.as_view(), name="inbox-approve-selected"),
  url(r'^inbox/approve-all/(?P<week>\d+)/$', ApproveAllDrafts.as_view(), name="inbox-approve-all-drafts"),
  url(r'^inbox/approve-edits/$', ApproveDraft.as_view(), name="inbox-approve-draft-edits"),
  url(r'^inbox/send/(?P<week>\d+)/$', SendDrafts.as_view(), name="inbox-send-all-drafts"),
  url(r'^inbox/send-selected/(?P<status>\d+)/$', SendSelectedDrafts.as_view(), name="inbox-send-selected"),
  url(r'^inbox/send/(?P<week>\d+)/(?P<resend>\d+)/$', SendDrafts.as_view(), name="inbox-resend-all-drafts"),
  url(r'^inbox/revision/$', send_draft_revision, name="send-revision-notes"),
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
 # url(r'^categories/create_common_feedback/(?P<pk>\d+)/$', create_common_feedback, name="category-create-feedback"),
  url(r'^categories/editcategory/(?P<pk>\d+)/$', edit_category, name="edit-category"),
  url(r'^categories/editsubcategory/(?P<pk>\d+)/$', edit_subcategory, name="edit-subcategory"),
  url(r'^categories/delete_sub/(?P<pk>\d+)/$', DeleteSubCategoryView.as_view(), name="delete-subcategory"),
  url(r'^categories/delete_main/(?P<pk>\d+)/$', DeleteCategoryView.as_view(), name="delete-category"),
  url(r'^categories/delete_feedback/(?P<pk>\d+)/$', DeleteFeedbackPieceView.as_view(), name="delete-feedback-piece"),
  
  # url(r'^common/$', CommonView.as_view(), name="feedback-common"),

 # url(r'^edit-draft/$', EditDraftView.as_view(), name="edit-draft"),
]

