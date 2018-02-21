# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0027_auto_20180221_1723'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('classroom', '0031_auto_20180202_2104'),
    ]

    operations = [
        migrations.CreateModel(
            name='Notification',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('notification', models.CharField(max_length=500)),
                ('created_ts', models.DateTimeField(auto_now_add=True)),
                ('updated_ts', models.DateTimeField(auto_now=True)),
                ('classroom', models.ForeignKey(to='classroom.Classroom')),
                ('draft_to_approve', models.ForeignKey(blank=True, to='feedback.Draft', null=True)),
                ('semester', models.ForeignKey(to='classroom.Semester')),
                ('user', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
