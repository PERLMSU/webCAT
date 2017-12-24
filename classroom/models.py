import datetime
import calendar

from django.conf import settings
from django.db import models

from datetime import datetime, date, time, timedelta


class Semester(models.Model):
    date_begin = models.DateField()
    date_end = models.DateField()
    title = models.CharField(max_length=200)

    def get_number_weeks(self):
        monday1 = (self.date_begin - timedelta(days=self.date_end.weekday()))
        monday2 = (self.date_end - timedelta(days=self.date_end.weekday()))        
        return (monday2 - monday1).days / 7

    def __str__(self):
        return self.title

class Classroom(models.Model):
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL)
    current_semester = models.ForeignKey(Semester)
    course = models.CharField(max_length=20)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    current_week = models.IntegerField(default=1)
   # num_weeks = models.IntegerField(default=12)
    def __str__(self):
        return self.course

    def get_num_weeks(self):
        return self.current_semester.get_number_weeks()

class Rotation(models.Model):
    semester = models.ForeignKey(Semester)
    classroom = models.ForeignKey(Classroom)
    start_week = models.IntegerField()
    length = models.IntegerField()
    #start_date= models.DateField(required=False)
    #end_date = models.DateField(required=False)

    def __str__(self):
        return "{} {} \nStart Week: {} Length: {} \nDate: {} - {}".format(self.classroom, self.semester, self.start_week,self.length,str(self.get_start_date()),str(self.get_end_date()))
    #instructor = models.ForeignKey(settings.AUTH_USER_MODEL)
    def get_start_date(self):
        time_diff = timedelta(weeks=self.start_week)
        return (self.semester.date_begin+time_diff)

    def get_end_date(self):
        time_diff = timedelta(weeks=self.length)
        return (self.get_start_date() + time_diff)

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
        return self.group_number

# class Rotation(models.Model):
#     week_start =  


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
