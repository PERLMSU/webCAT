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
    def __str__(self):
        return self.course

class Group(models.Model):
    classroom = models.ForeignKey(Classroom)
    group_number = models.IntegerField(default=0)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.description

class Student(models.Model):
    group = models.ForeignKey(Group)
    classroom = models.ForeignKey(Classroom)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    notes = models.CharField(max_length=200)

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)
