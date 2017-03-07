from django.conf.urls import url
from classroom import views

urlpatterns = [
    url(r'^$', views.ClassroomView.as_view(), name='classroom-home'),
    url(r'^upload/student/$', views.UploadStudentsView.as_view(), name='classroom-upload-students'),
    url(r'^upload/group/$', views.UploadGroupsView.as_view(), name='classroom-upload-groups'),
    url(r'^download/(.*)', views.download, name="download"),
    url(r'^download_attachment/(.*)/(.*)', views.download_as_attachment,
        name="download_attachment"),
    url(r'^exchange/(.*)', views.exchange, name="exchange"),
    url(r'^parse/(.*)', views.parse, name="parse"),
    url(r'^import/', views.import_data, name="import"),
    url(r'^import_sheet/', views.import_sheet, name="import_sheet"),
    url(r'^export/(.*)', views.export_data, name="export")
]