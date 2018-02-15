from __future__ import unicode_literals

import datetime
import calendar

from django.conf import settings
from django.db import models

from django.core.mail import send_mail, EmailMessage, EmailMultiAlternatives
from django.template.loader import render_to_string


from classroom.models import *

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
    class Meta:
        ordering = ["name"]

    # feedback = models.CharField(max_length=200, null=True)
    # observation = models.CharField(max_length=200, null=True)
    # problem = models.CharField(max_length=2000, null=True)

    # solution_explanation = models.CharField(max_length=2000, null=True)
    
    # def __str__(self):
    #     return "Problem / Observaton: {} \nSolution: {}".format(self.problem, self.solution)  

class Observation(models.Model):
    sub_category = models.ForeignKey(SubCategory)
    observation = models.CharField(max_length=2000)
    # 1 for positive, 0 for negative
    observation_type = models.NullBooleanField()

    def get_observation_type(self):
        if self.observation_type:
            return "Positive"
        elif self.observation_type == None:
            return "Neutral"
        elif self.observation_type == False:
            return "Negative"

    def __str__(self):
        return "{}".format(self.observation)


    class Meta:
        ordering = ["observation_type",'observation']

class Feedback(models.Model):
    sub_category = models.ForeignKey(SubCategory)
    observation = models.ForeignKey(Observation)
    feedback = models.CharField(max_length=2000)

    def __str__(self):
        return "{}".format(self.feedback)

class Explanation(models.Model):
    sub_category = models.ForeignKey(SubCategory)
    feedback = models.ForeignKey(Feedback)
    feedback_explanation = models.CharField(max_length=2000)

    def __str__(self):
        return "{}".format(self.feedback_explanation)

# class FeedbackPiece(models.Model):
#     sub_category = models.ForeignKey(SubCategory)
#     observation = models.ForeignKey(Observation)
#     feedback = models.ForeignKey(Feedback)
#     feedback_explanation = models.ForeignKey(Explanation)

class Draft(models.Model):
    text = models.CharField(max_length=4096, null=True, blank=True)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    week_num = models.IntegerField()
    student = models.ForeignKey(Student)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,null=True)
    status = models.PositiveSmallIntegerField(choices=DRAFT_STATUS)
    email_sent = models.BooleanField(default=False)
    email_ts = models.DateTimeField(null=True)

    def __str__(self): 
        return "Instructor: {} Student: {} Feedback: {}".format(self.owner,self.student,self.text)

    def send_to_instructor(self):
        instructor = self.owner.get_current_classroom_instructor()
        try:
            notification = Notification.objects.get(draft_to_approve = self)
            notification.updated_ts = datetime.now()
            notification.user = instructor
            notification.notification = "This draft has been submitted for approval. Please review."
            notification.save()
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = instructor,
                notification="This draft has been submitted for approval. Please review.",
                classroom = self.owner.current_classroom,
                semester = self.owner.current_classroom.current_semester                
            )

    def add_revision_notes(self, notes):
        try:
            notification = Notification.objects.get(draft_to_approve = self)
            notification.user = self.owner
            notification.notification = "This draft has revision notes: " + notes 
            notification.updated_ts = datetime.now()
            notification.save()
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = self.owner,
                notification="This draft has revision notes: " + notes,
                classroom = self.owner.current_classroom,
                semester = self.owner.current_classroom.current_semester
            )

    def send_approval_notification(self):
        try: 
            notification = Notification.objects.get(draft_to_approve = self)
            notification.notification = "This draft has been approved"
            notification.user = self.owner
            notification.updated_ts = datetime.now()
            notification.save()            
        except (Notification.DoesNotExist):
            notification = Notification.objects.create(
                draft_to_approve = self,
                user = self.owner,
                notification="This draft has been approved",
                classroom = self.owner.current_classroom,
                semester = self.owner.current_classroom.current_semester
            )            

    def send_email_to_student(self):
        if self.student.email:
            host_email = settings.EMAIL_HOST_USER
            subject =   "PCubed Feedback - Week "+str(self.week_num)
            email_to = self.student.email
            html_content = render_to_string('email/grades.html',{
                                                            'subject': subject,
                                                            'feedback': self.text,
                                                            'student': self.student,
                                                            'grades': self.get_grades()
                                                        })
            subject, from_email, title=subject, host_email, email_to
            msg = EmailMultiAlternatives(subject, html_content, from_email, [title])
            msg.content_subtype = "html"
            msg.send()
            self.email_sent = True
            self.email_ts = datetime.now()
            self.save()   
            return True         
        else:
            return False

    def get_grades(self):
        grades = Grade.objects.filter(draft=self)
        return grades

    class Meta:    
        unique_together = ('owner', 'student','week_num')   
        ordering = ["student"]

    def get_notifications(self):
        return Notification.objects.get(draft_to_approve=self)

class Grade(models.Model):
    grade = models.DecimalField(max_digits=3, decimal_places=2)
    draft = models.ForeignKey(Draft)
    category = models.ForeignKey(Category)

class Notification(models.Model):
    #classroom = models.ForeignKey(Classroom)
    #semester = models.ForeignKey(Semester)
    notification = models.CharField(max_length=500)
    classroom = models.ForeignKey(Classroom)
    semester = models.ForeignKey(Semester)
    draft_to_approve = models.ForeignKey(Draft, blank=True, null=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    created_ts = models.DateTimeField(auto_now_add=True)
    updated_ts = models.DateTimeField(auto_now=True)

    def __str__(self): 
        return "{} {}".format(self.draft_to_approve,self.notification)