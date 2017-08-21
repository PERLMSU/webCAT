# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0007_group_current_instructor'),
        ('userprofile', '0006_auto_20170403_0220'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='current_classroom',
            field=models.ForeignKey(blank=True, to='classroom.Classroom', null=True),
        ),
        migrations.AddField(
            model_name='profile',
            name='professor_instructor',
            field=models.ForeignKey(blank=True, to=settings.AUTH_USER_MODEL, null=True),
        ),
    ]
