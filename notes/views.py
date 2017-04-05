from django.shortcuts import render
from django.contrib.auth import login, logout
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from braces.views import LoginRequiredMixin, SuperuserRequiredMixin
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView, View
from django.conf import settings
from django.template.defaulttags import register
# Create your views here.

from feedback.models import Category, SubCategory
from classroom.models import Classroom

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)

@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories


class NotesView(LoginRequiredMixin, TemplateView):
    template_name = "notes.html"
    context = {}

    def get(self, *args, **kwargs):
        #form = AccountSettingsForm(instance=self.request.user)
        #self.context['form'] = form
        main_categories = Category.objects.all()
        sub_categories = {}
        for category in main_categories:
        	sub_categories[category.id] = SubCategory.objects.filter(main_category = category)

        #raise Exception("whassup")
        self.context['main_categories'] = Category.objects.all()
        self.context['sub_categories'] = sub_categories
        return render(self.request, self.template_name, self.context)

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)