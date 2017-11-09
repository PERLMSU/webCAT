from __future__ import unicode_literals

import datetime
import calendar

from django.conf import settings
from django.db import models

from classroom.models import Classroom, Student

NOT_SUBMITTED = 0
SUBMITTED_AWAITING_APPROVAL = 1
NEEDS_REVISION =  2
APPROVED = 3

DRAFT_STATUS = (
    (NOT_SUBMITTED, 'Not Submitted'),
    (SUBMITTED_AWAITING_APPROVAL, 'Submitted, Awaiting Approval'),
    (NEEDS_REVISION, 'Needs Revision'),
    (APPROVED, 'Approved')
)



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
    name = models.CharField(max_length=100)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    def __str__(self):
        return self.name

class CommonFeedback(models.Model):
    sub_category = models.ForeignKey(SubCategory)

    feedback = models.CharField(max_length=200, null=True)
    observation = models.CharField(max_length=200, null=True)
    problem = models.CharField(max_length=2000, null=True)
    solution = models.CharField(max_length=2000, null=True)
    solution_explanation = models.CharField(max_length=2000, null=True)
    
    def __str__(self):
        return "Problem: {} \nSolution: {}".format(self.problem, self.solution)  


# class ObservationFeedback(models.Model):
#     sub_category = models.ForeignKey(SubCategory)
#     problem = models.CharField(max_length=300)




class Draft(models.Model):
    text = models.CharField(max_length=4096)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    week_num = models.IntegerField()
    student = models.ForeignKey(Student)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL)
    status = models.PositiveSmallIntegerField(choices=DRAFT_STATUS)

    def send_to_instructor(self):
        instructor = self.owner.get_current_classroom_instructor()
        try:
            notification = Notification.objects.get(draft_to_approve = self)
            notification.updated_ts = datetime.datetime.now()
            notification.save()
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = instructor,
                notification="This draft has been submitted for approval. Please review."
            )

    def add_revision_notes(self, notes):
        try:
            notification = Notification.objects.get(draft_to_approve = self)
            notification.notification = "This draft has revision notes: " + notes 
            notification.updated_ts = datetime.datetime.now()
            notification.save()
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = self.owner,
                notification="This draft has revision notes: " + notes 
            )

    def send_approval_notification(self):
        try: 
            notification = Notification.objects.get(draft_to_approve = self)
            notification.notification = "This draft has been approved"
            notification.updated_ts = datetime.datetime.now()
            notification.save()            
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = self.owner,
                notification="This draft has been approved"
            )            

class Grade(models.Model):
    grade = models.DecimalField(max_digits=3, decimal_places=2)
    draft = models.ForeignKey(Draft)
    category = models.ForeignKey(Category)

class Notification(models.Model):
    notification = models.CharField(max_length=500)
    draft_to_approve = models.ForeignKey(Draft, blank=True, null=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    created_ts = models.DateTimeField(auto_now_add=True)
    updated_ts = models.DateTimeField(auto_now=True)
