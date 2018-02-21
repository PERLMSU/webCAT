from django.conf.urls import url
from django.template.response import TemplateResponse
from .views import *

urlpatterns = [
  url(r'^$', InboxView.as_view(), name="feedback-inbox"),
  url(r'^change/$', change_week, name="inbox-change-week"),
  url(r'^week/(?P<week>\d+)/$', InboxView.as_view(), name="feedback-inbox"),
  url(r'^approve/(?P<pk>\d+)/$', approve_draft, name="inbox-approve-draft"),
  url(r'^approve-selected/(?P<status>\d+)/$', ApproveSelectedDrafts.as_view(), name="inbox-approve-selected"),
  url(r'^approve-all/(?P<week>\d+)/$', ApproveAllDrafts.as_view(), name="inbox-approve-all-drafts"),
  url(r'^approve-edits/$', ApproveDraft.as_view(), name="inbox-approve-draft-edits"),
  url(r'^send/(?P<week>\d+)/$', SendDrafts.as_view(), name="inbox-send-all-drafts"),
  url(r'^send-selected/(?P<status>\d+)/$', SendSelectedDrafts.as_view(), name="inbox-send-selected"),
  url(r'^send/(?P<week>\d+)/(?P<resend>\d+)/$', SendDrafts.as_view(), name="inbox-resend-all-drafts"),
  url(r'^revision/$', send_draft_revision, name="send-revision-notes"),
]

