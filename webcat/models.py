# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.utils import timezone
from accounts.models import User
import reversion
from django.utils.translation import gettext_lazy as _


class AutoDateTimeField(models.DateTimeField):
    def pre_save(self, model_instance, add):
        return timezone.now()


class TimeStampedModel(models.Model):
    """Adds automatic timestamps to models"""
    id = models.BigAutoField(primary_key=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = AutoDateTimeField(default=timezone.now)

    class Meta:
        abstract = True


@reversion.register()
class Category(TimeStampedModel):
    name = models.TextField(unique=True)
    description = models.TextField(blank=True, null=True)
    parent_category = models.ForeignKey('self', models.CASCADE, blank=True, null=True)

    class Meta:
        verbose_name_plural = 'categories'

    def __str__(self) -> str:
        return self.name


@reversion.register(fields=["name", "description"])
class Classroom(TimeStampedModel):
    course_code = models.TextField(_("course code"), unique=True)
    name = models.TextField(_("name"), max_length=30)
    description = models.TextField(_("description"), blank=True, null=True)

    users = models.ManyToManyField(User)
    categories = models.ManyToManyField(Category)

    def __str__(self) -> str:
        return self.course_code


@reversion.register(fields=["content", "type", "category"])
class Observation(TimeStampedModel):
    content = models.TextField()

    class ObservationType(models.TextChoices):
        POSITIVE = "positive", _("Positive")
        NEUTRAL = "neutral", _("Neutral")
        NEGATIVE = "negative", _("Negative")

    type = models.TextField(choices=ObservationType.choices, default=ObservationType.NEUTRAL)
    category = models.ForeignKey(Category, models.CASCADE)

    def __str__(self) -> str:
        return f'{_("Observation")} {self.id}'


@reversion.register(fields=["content"])
class Feedback(TimeStampedModel):
    content = models.TextField()
    observation = models.ForeignKey(Observation, models.CASCADE)

    def __str__(self) -> str:
        return f'{_("Feedback")} {self.id}'

    class Meta:
        verbose_name_plural = 'feedback'


@reversion.register(fields=["content"])
class Explanation(TimeStampedModel):
    content = models.TextField()
    feedback = models.ForeignKey(Feedback, models.CASCADE)


class Semester(TimeStampedModel):
    name = models.TextField()
    description = models.TextField(blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField()
    users = models.ManyToManyField(User)

    def __str__(self) -> str:
        return self.name


class Section(TimeStampedModel):
    number = models.TextField()
    description = models.TextField(blank=True, null=True)
    semester = models.ForeignKey(Semester, models.CASCADE)
    classroom = models.ForeignKey(Classroom, models.CASCADE)

    users = models.ManyToManyField(User)

    def __str__(self) -> str:
        return f'{_("Section")} {self.number}'


class Rotation(TimeStampedModel):
    number = models.IntegerField()
    description = models.TextField(blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField()
    section = models.ForeignKey(Section, models.CASCADE)

    users = models.ManyToManyField(User)

    def __str__(self) -> str:
        return f'{_("Rotation")} {self.number}'


class RotationGroup(TimeStampedModel):
    number = models.IntegerField()
    description = models.TextField(blank=True, null=True)
    rotation = models.ForeignKey(Rotation, models.CASCADE)

    users = models.ManyToManyField(User)

    def __str__(self) -> str:
        return f'{_("Rotation Group")} {self.number}'


@reversion.register(fields=["content", "status", "notes"])
class Draft(TimeStampedModel):
    content = models.TextField()

    class Status(models.TextChoices):
        UNREVIEWED = "unreviewed", _("Unreviewed")
        NEEDS_REVISION = "needs_revision", _("Needs Revision")
        APPROVED = "approved", _("Approved")
        EMAILED = "emailed", _("Emailed")

    status = models.TextField(choices=Status.choices, default=Status.UNREVIEWED)
    student = models.ForeignKey(User, models.CASCADE, blank=True, null=True)
    rotation_group = models.ForeignKey(RotationGroup, models.CASCADE, blank=True, null=True)

    notes = models.TextField(blank=True, null=True)
    parent_draft = models.ForeignKey('self', models.CASCADE, blank=True, null=True)

    def __str__(self) -> str:
        if self.student_id:
            return f'{_("Draft")} {self.id} - {self.student}'
        elif self.rotation_group_id:
            return f'{_("Draft")} {self.id} - {self.rotation_group}'
        else:
            return f'{_("Draft")} {self.id}'


@reversion.register(fields=["note", "score"])
class Grade(TimeStampedModel):
    score = models.IntegerField()
    note = models.TextField(blank=True, null=True)
    category = models.ForeignKey(Category, models.CASCADE)
    draft = models.ForeignKey(Draft, models.CASCADE)


@reversion.register(fields=["content"])
class Comment(TimeStampedModel):
    content = models.TextField()
    draft = models.ForeignKey(Draft, models.CASCADE, blank=True, null=True)
    user = models.ForeignKey(User, models.CASCADE, blank=True, null=True)


class ReviewRequest(TimeStampedModel):
    draft = models.OneToOneField(Draft, models.CASCADE)
    user = models.ForeignKey(User, models.CASCADE)

    class Meta:
        unique_together = (('draft', 'user'),)


class StudentFeedback(TimeStampedModel):
    draft = models.OneToOneField(Draft, models.CASCADE)
    feedback = models.ForeignKey(Feedback, models.CASCADE)

    class Meta:
        unique_together = (('draft', 'feedback'),)


class StudentExplanation(TimeStampedModel):
    draft = models.OneToOneField(StudentFeedback, models.CASCADE)
    feedback_id = models.IntegerField()
    explanation = models.ForeignKey(Explanation, models.CASCADE)

    class Meta:
        unique_together = (('draft', 'feedback_id', 'explanation'),)
