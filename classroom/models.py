import datetime
import calendar

from django.conf import settings
from django.db import models


class Classroom(models.Model):
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL)
    course = models.CharField(max_length=20)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    current_week = models.IntegerField(default=1)
    num_weeks = models.IntegerField(default=12)
    def __str__(self):
        return self.course

class Group(models.Model):
    classroom = models.ForeignKey(Classroom,null=True, default=None)
    group_number = models.IntegerField(null=True)
    current_instructor = models.ForeignKey(settings.AUTH_USER_MODEL, null=True)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('classroom', 'group_number',)    

    def __str__(self):
        return self.description

class Student(models.Model):
    group = models.ForeignKey(Group, null=True, default=None)
    classroom = models.ForeignKey(Classroom, null=True, default=None)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    notes = models.CharField(max_length=200)
    student_id = models.IntegerField(unique=True, null=True)

    def get_full_name(self):
        return "{} {}".format(self.first_name, self.last_name).strip()

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)
