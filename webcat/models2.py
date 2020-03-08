from django.db import models
from django.contrib.auth.models import User


class TimeStampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class ContentModel(models.Model):
    content = models.TextField(null=False)

    class Meta:
        abstract = True


class Classroom(TimeStampedModel):
    course_code = models.TextField(null=False)
    name = models.TextField(null=False)
    description = models.TextField()

    categories = models.ManyToManyField("Category")
    users = models.ManyToManyField(User)


class Semester(TimeStampedModel):
    name = models.TextField(null=False)
    description = models.TextField()
    start_date = models.DateField(null=False)
    end_date = models.DateField(null=False)

    users = models.ManyToManyField(User)


class Section(TimeStampedModel):
    number = models.TextField(null=False)
    description = models.TextField()

    classroom = models.ForeignKey(Classroom, on_delete=models.CASCADE, null=False)
    semester = models.ForeignKey(Semester, on_delete=models.CASCADE, null=False)
    users = models.ManyToManyField(User)


class Rotation(TimeStampedModel):
    number = models.IntegerField(null=False)
    description = models.TextField()

    section = models.ForeignKey(Section, on_delete=models.CASCADE, null=False)
    users = models.ManyToManyField(User)


class RotationGroup(TimeStampedModel):
    number = models.IntegerField(null=False)
    description = models.TextField()

    rotation = models.ForeignKey(Rotation, on_delete=models.CASCADE, null=False)
    users = models.ManyToManyField(User)


class Category(TimeStampedModel):
    name = models.TextField(null=False)
    description = models.TextField()

    parent_category = models.ForeignKey("Category", on_delete=models.SET_NULL, null=True)

    class Meta:
        verbose_name_plural = "categories"


class Observation(TimeStampedModel):
    content = models.TextField(null=False)

    category = models.ForeignKey(Category, on_delete=models.CASCADE, null=False)


class Feedback(TimeStampedModel):
    content = models.TextField(null=False)

    observation = models.ForeignKey(Observation, on_delete=models.CASCADE, null=False)

    class Meta:
        verbose_name_plural = "feedback"


class Explanation(TimeStampedModel):
    content = models.TextField(null=False)

    feedback = models.ForeignKey(Feedback, on_delete=models.CASCADE, null=False)


