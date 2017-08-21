from __future__ import unicode_literals

import datetime
import calendar

from django.conf import settings
from django.db import models

from classroom.models import Classroom, Student
from feedback.models import SubCategory

# Create your models here.

class Feedback(models.Model):
    sub_category = models.ForeignKey(SubCategory)
    note = models.CharField(max_length=200)
    student = models.ForeignKey(Student)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    week_num = models.IntegerField()
    
    def __str__(self):
        return self.note    