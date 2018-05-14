from braces.views import LoginRequiredMixin
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.template.defaulttags import register
from django.views.generic import TemplateView, View

from classroom.models import *
# Create your views here.
from feedback.models import *
from notes.forms import AddFeedbackForm
from notes.models import Note


@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)


@register.filter
def get_subcategories(category_pk):
    sub_categories = SubCategory.objects.filter(main_category=category_pk)
    return sub_categories


@register.filter
def get_feedback_notes(student_pk, week):
    feedback_notes = Note.objects.filter(student=student_pk, week_num=week)
    return feedback_notes


@register.filter
def get_observations(subcategory):
    return Observation.objects.filter(sub_category=subcategory.id).order_by('observation_type')


class DeleteNote(LoginRequiredMixin, View):
    """ delete feedback view
    """

    def get(self, *args, **kwargs):
        note_id = kwargs['pk']
        try:
            note = Note.objects.get(id=kwargs['pk'])
        except Exception as e:
            messages.add_message(self.request, messages.ERROR, 'Unable to delete this note %s' % e)
        finally:
            note.delete()
            messages.add_message(self.request, messages.SUCCESS, 'Note successfully removed!')
        #  return JsonResponse({'note_pk':note_id})
        return HttpResponseRedirect('/notes/')


class AddFeedback(LoginRequiredMixin, TemplateView):
    """ create a feedback note for student(s)
    """
    context = {}

    def post(self, *args, **kwargs):
        form = AddFeedbackForm(self.request.POST or None)

        if form.is_valid():

            selected_students = [value for name, value in self.request.POST.items()
                                 if name.startswith('student_name')]

            subcategory = form.cleaned_data['subcategory']
            observation = form.cleaned_data['observation']
            feedback_note = form.cleaned_data['note']
            week = form.cleaned_data['week_num']

            if not range(len(selected_students)):
                messages.add_message(self.request, messages.WARNING,
                                     'No notes were added because no students were selected.')

            for i in range(len(selected_students)):
                student_pk = int(selected_students[i].encode('ascii'))
                try:
                    student = Student.objects.get(id=student_pk)
                    new_feedback = Note.objects.create(note=feedback_note, student=student, sub_category=subcategory,
                                                       observation=observation, week_num=week)
                    new_feedback.save()
                    messages.add_message(self.request, messages.SUCCESS, 'Note(s) successfully added.')
                except Exception as e:
                    messages.add_message(self.request, messages.ERROR, 'Unable to create this feedback note. %s' % e)

            return HttpResponseRedirect('/notes/')
        else:
            messages.error(self.request, form.errors)
            return HttpResponseRedirect('/notes/')


class NotesView(LoginRequiredMixin, TemplateView):
    template_name = "notes.html"
    context = {}

    def get(self, request, *args, **kwargs):

        classroom = self.request.user.current_classroom
        if classroom != None:
            if 'week' in self.kwargs:
                week = int(self.kwargs['week'])
            else:
                if request.user.current_classroom.current_week:
                    week = request.user.current_classroom.current_week
                else:
                    week = 1
            groups_assigned = RotationGroup.objects.filter(rotation__classroom=classroom,
                                                           rotation__semester=classroom.current_semester,
                                                           instructor=self.request.user,
                                                           rotation__start_week__lte=week, rotation__end_week__gte=week)

            main_categories = Category.objects.all()
            sub_categories = {}
            for category in main_categories:
                sub_categories[category.id] = SubCategory.objects.filter(main_category=category)

            self.context['loop_times'] = range(1, classroom.get_num_weeks())
            self.context['week'] = week
            self.context['week_begin'] = classroom.current_semester.get_week_start(week)
            self.context['week_end'] = classroom.current_semester.get_week_end(week)
            self.context['title'] = "Note Taker"
            self.context['rotation_groups'] = groups_assigned
            self.context['main_categories'] = main_categories
            self.context['sub_categories'] = sub_categories
            return render(self.request, self.template_name, self.context)
        else:
            messages.add_message(self.request, messages.WARNING,
                                 'You are not currently assigned to any classroom. Please contact your administrator to be assigned to a classroom.')
            return HttpResponseRedirect(reverse('dash-home'))

    def add_message(self, text, mtype=25):
        messages.add_message(self.request, mtype, text)


def change_week_notes(request):
    form = request.POST or None
    if 'weekDropDown' in request.POST:
        week = int(request.POST['weekDropDown'].encode('ascii', 'ignore'))
        return HttpResponseRedirect('/notes/week/' + str(week))
