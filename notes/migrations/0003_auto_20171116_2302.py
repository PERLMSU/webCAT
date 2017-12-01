# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0016_auto_20171116_2302'),
        ('classroom', '0009_auto_20171109_1824'),
        ('notes', '0002_feedback_week_num'),
    ]

    operations = [
        migrations.CreateModel(
            name='Note',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('note', models.CharField(max_length=200)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('week_num', models.IntegerField()),
                ('student', models.ForeignKey(to='classroom.Student')),
                ('sub_category', models.ForeignKey(to='feedback.SubCategory')),
            ],
        ),
        migrations.RemoveField(
            model_name='feedback',
            name='student',
        ),
        migrations.RemoveField(
            model_name='feedback',
            name='sub_category',
        ),
        migrations.DeleteModel(
            name='Feedback',
        ),
    ]
