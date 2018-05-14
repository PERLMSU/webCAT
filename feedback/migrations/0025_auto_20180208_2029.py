# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0031_auto_20180202_2104'),
        ('feedback', '0024_auto_20180208_0039'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='feedbackpiece',
            name='feedback',
        ),
        migrations.RemoveField(
            model_name='feedbackpiece',
            name='feedback_explanation',
        ),
        migrations.RemoveField(
            model_name='feedbackpiece',
            name='observation',
        ),
        migrations.RemoveField(
            model_name='feedbackpiece',
            name='sub_category',
        ),
        migrations.AddField(
            model_name='notification',
            name='classroom',
            field=models.ForeignKey(default=1, to='classroom.Classroom'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='notification',
            name='semester',
            field=models.ForeignKey(default=1, to='classroom.Semester'),
            preserve_default=False,
        ),
        migrations.DeleteModel(
            name='FeedbackPiece',
        ),
    ]
