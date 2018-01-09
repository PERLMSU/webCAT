import datetime
import calendar

from django.conf import settings
from django.db import models
from django.db import IntegrityError

from datetime import datetime, date, time, timedelta


class Semester(models.Model):
    date_begin = models.DateField()
    date_end = models.DateField()
    title = models.CharField(max_length=200)


    def get_number_weeks(self):
        monday1 = (self.date_begin - timedelta(days=self.date_end.weekday()))
        monday2 = (self.date_end - timedelta(days=self.date_end.weekday()))        
        return int((monday2 - monday1).days / 7)

    def get_year(self):
        pass

    def __str__(self):
        return "{} {} to {}".format(self.title, self.date_begin, self.date_end)

class Classroom(models.Model):
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL)
    current_semester = models.ForeignKey(Semester)
    #course = models.CharField(max_length=20)
    course_code = models.CharField(max_length=5, null=True)
    course_number = models.CharField(max_length=5,null=True)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    current_week = models.IntegerField(default=1)
   # num_weeks = models.IntegerField(default=12)
    def __str__(self):
        return '{} {}'.format(self.course_code, self.course_number)

    def get_num_weeks(self):
        return self.current_semester.get_number_weeks()

    def get_current_rotation(self):
        return Rotation.objects.get(classroom=self,semester=self.current_semester, start_week__lte=self.current_week,end_week__gte=self.current_week)      

class Rotation(models.Model):
    semester = models.ForeignKey(Semester)
    classroom = models.ForeignKey(Classroom)
    start_week = models.IntegerField()
    end_week = models.IntegerField()
    length = models.IntegerField()
    #start_date= models.DateField(required=False)
    #end_date = models.DateField(required=False)

    def save(self, *args, **kwargs):
    

        super(Rotation, self).save(*args, **kwargs)

        # groups = Group.objects.filter(classroom=self.classroom)
        # for group in groups:
        #     new_rotation_group = RotationGroup.objects.create(rotation=self,group=group)
        #     new_rotation_group.save() 

    # def __init__(self):

        # groups = Group.objects.filter(classroom=self.classroom)
        # for group in groups:
        #     new_rotation_group = RotationGroup(rotation=rotation,group=group)        

    def __str__(self):
        return "Duration: {}-{} Dates: {} - {}".format(self.start_week,self.end_week,str(self.get_start_date()),str(self.get_end_date()))
    #instructor = models.ForeignKey(settings.AUTH_USER_MODEL)
    def get_start_date(self):
        time_diff = timedelta(weeks=self.start_week)
        return (self.semester.date_begin+time_diff)

    def get_end_date(self):
        time_diff = timedelta(weeks=self.length)
        return (self.get_start_date() + time_diff)

    def get_end_week(self):
        return self.start_week + self.length



# class Group(models.Model):
#     classroom = models.ForeignKey(Classroom,null=True, default=None)
#     group_number = models.IntegerField(null=True)

#     class Meta:
#         unique_together = ('classroom', 'group_number',)    

#     def __str__(self):
#         return self.group_number

#     def create_rotation_group(self,rotation):
#         try:
#             new_rotation_group = RotationGroup.objects.create(rotation=rotation,group=self)
#             new_rotation_group.save()
#         except IntegrityError:
#             pass
            #messages.add_message(request, messages.ERROR, 'Could not create rotation group: '+ str(e))               

class Student(models.Model):
    #group = models.ForeignKey(Group, null=True, default=None)
    classroom = models.ForeignKey(Classroom, null=True, default=None)
    semester = models.ForeignKey(Semester)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    notes = models.CharField(max_length=2000)
    email = models.EmailField(null=True,blank=True,unique=True)
    #student_id = models.IntegerField(unique=True, null=True)

    def get_email(self):
        if self.email:
            return self.email
        else:
            return ''


    def get_full_name(self):
        return "{} {}".format(self.first_name, self.last_name).strip()

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)


class RotationGroup(models.Model):
    rotation = models.ForeignKey(Rotation)
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL, null=True)
    description = models.CharField(max_length=200)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    students = models.ManyToManyField(Student)
    group_number = models.IntegerField()

    class Meta:
        unique_together = ('rotation', 'group_number',)   

    def __str__(self):
        return "# {} Tutor: {} Rotation: {}".format(self.group, self.current_instructor, self.rotation)  




