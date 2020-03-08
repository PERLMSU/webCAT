from import_export import resources
from import_export.admin import ImportExportModelAdmin
from django.contrib import admin
from webcat.models import Draft, Comment, Grade


class DraftResource(resources.ModelResource):
    class Meta:
        model = Draft


class CommentResource(resources.ModelResource):
    class Meta:
        model = Comment


class GradeResource(resources.ModelResource):
    class Meta:
        model = Grade


@admin.register(Draft)
class DraftAdmin(ImportExportModelAdmin):
    search_fields = ('content',)
    list_display = (
    'content', 'status', 'student', 'rotation_group', 'parent_draft', 'notes', 'created_at', 'updated_at')
    list_filter = ('status',)
    list_display_links = ('student', 'rotation_group', 'parent_draft')
    readonly_fields = ('created_at', 'updated_at')
    resource_class = DraftResource


@admin.register(Comment)
class CommentAdmin(ImportExportModelAdmin):
    search_fields = ('content',)
    list_display = ('content', 'draft', 'user', 'created_at', 'updated_at')
    list_display_links = ('draft', 'user')
    readonly_fields = ('created_at', 'updated_at')
    resource_class = CommentResource


@admin.register(Grade)
class GradeAdmin(ImportExportModelAdmin):
    search_fields = ('note',)
    list_display = ('score', 'note', 'category', 'draft', 'created_at', 'updated_at')
    list_display_links = ('category', 'draft')
    readonly_fields = ('created_at', 'updated_at')
    resource_class = GradeResource
