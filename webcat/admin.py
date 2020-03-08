from import_export import resources
from import_export.admin import ImportExportModelAdmin
from django.contrib import admin
from webcat.models import Classroom, Semester, Section, Rotation, RotationGroup, Category, Observation, Feedback, \
    Explanation
from django.utils.translation import gettext_lazy as _


class ClassroomResource(resources.ModelResource):
    class Meta:
        model = Classroom


class SemesterResource(resources.ModelResource):
    class Meta:
        model = Semester


class SectionResource(resources.ModelResource):
    class Meta:
        model = Section


class RotationResource(resources.ModelResource):
    class Meta:
        model = Rotation


class RotationGroupResource(resources.ModelResource):
    class Meta:
        model = RotationGroup


class CategoryResource(resources.ModelResource):
    class Meta:
        model = Category


class ObservationResource(resources.ModelResource):
    class Meta:
        model = Observation


class FeedbackResource(resources.ModelResource):
    class Meta:
        model = Feedback


class ExplanationResource(resources.ModelResource):
    class Meta:
        model = Explanation


@admin.register(Classroom)
class ClassroomAdmin(ImportExportModelAdmin):
    fieldsets = (
        (None, {'fields': ('course_code', 'name', 'description')}),
        (_('Membership'), {
            'fields': ('users',),
        }),
        (_('Important dates'), {'fields': ('created_at', 'updated_at')}),
    )
    search_fields = ('course_code', 'name')
    list_display = ('course_code', 'name', 'description', 'created_at', 'updated_at')
    resource_class = ClassroomResource


@admin.register(Semester)
class SemesterAdmin(ImportExportModelAdmin):
    search_fields = ('name',)
    list_display = ('name', 'start_date', 'end_date', 'description', 'created_at', 'updated_at')
    readonly_fields = ('created_at', 'updated_at')
    resource_class = SemesterResource


@admin.register(Section)
class SectionAdmin(ImportExportModelAdmin):
    search_fields = ('number', 'semester', 'classroom',)
    list_display = ('number', 'description', 'semester', 'classroom', 'created_at', 'updated_at')
    list_display_links = ('classroom', 'semester',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = SectionResource


@admin.register(Rotation)
class RotationAdmin(ImportExportModelAdmin):
    search_fields = ('number',)
    list_display = ('number', 'start_date', 'end_date', 'description', 'section', 'created_at', 'updated_at')
    list_display_links = ('section',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = RotationResource


@admin.register(RotationGroup)
class RotationGroupAdmin(ImportExportModelAdmin):
    search_fields = ('number',)
    list_display = ('number', 'description', 'rotation', 'created_at', 'updated_at')
    list_display_links = ('rotation',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = RotationGroupResource


@admin.register(Category)
class CategoryAdmin(ImportExportModelAdmin):
    search_fields = ('name',)
    list_display = ('name', 'description', 'parent_category', 'created_at', 'updated_at')
    list_display_links = ('parent_category',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = CategoryResource


@admin.register(Observation)
class ObservationAdmin(ImportExportModelAdmin):
    search_fields = ('content',)
    list_display = ('content', 'type', 'category', 'created_at', 'updated_at')
    list_filter = ('type',)
    list_display_links = ('category',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = ObservationResource


@admin.register(Feedback)
class FeedbackAdmin(ImportExportModelAdmin):
    search_fields = ('content',)
    list_display = ('content', 'observation', 'created_at', 'updated_at')
    list_display_links = ('observation',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = FeedbackResource


@admin.register(Explanation)
class ExplanationAdmin(ImportExportModelAdmin):
    search_fields = ('content',)
    list_display = ('content', 'feedback', 'created_at', 'updated_at')
    list_display_links = ('feedback',)
    readonly_fields = ('created_at', 'updated_at')
    resource_class = ExplanationResource
