from django.test import TestCase
from webcat.models import Classroom
from django_fakery import factory
import pytest

class ClassroomTestCase(TestCase):
    def setUp(self):
        factory.m(Classroom)(course_code="test_class")

    def test_works(self):
        test_class = Classroom.objects.get(course_code="test_class")
        self.assertEqual(test_class.course_code, "test_class")