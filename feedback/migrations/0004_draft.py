# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('classroom', '0007_group_current_instructor'),
        ('feedback', '0003_commonfeedback'),
    ]

    operations = [
        migrations.CreateModel(
            name='Draft',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('text', models.CharField(max_length=4096)),
                ('date_created', models.DateTimeField(auto_now_add=True)),
                ('date_updated', models.DateTimeField(auto_now=True)),
                ('status', models.PositiveSmallIntegerField(
                    choices=[(0, 'Not Submitted'), (1, 'Submitted, Awaiting Approval'), (2, 'Needs Revision'),
                             (3, 'Approved')])),
                ('owner', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
                ('student', models.ForeignKey(to='classroom.Student')),
            ],
        ),
    ]
