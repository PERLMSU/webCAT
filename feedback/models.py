from __future__ import unicode_literals

import datetime
import calendar

from django.conf import settings
from django.db import models

from classroom.models import Classroom


class Category(models.Model):
    classroom = models.ForeignKey(Classroom,null=True, default=None)
    name = models.CharField(max_length=30, unique=True)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    def __str__(self):
        return self.name

class SubCategory(models.Model):
    main_category = models.ForeignKey(Category)
    name = models.CharField(max_length=30)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    def __str__(self):
        return self.name

class CommonFeedback(models.Model):
    sub_category = models.ForeignKey(SubCategory)
    feedback = models.CharField(max_length=200)
    
    def __str__(self):
        return self.feedback    