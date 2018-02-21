# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('inbox', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='notification',
            name='classroom',
        ),
        migrations.RemoveField(
            model_name='notification',
            name='draft_to_approve',
        ),
        migrations.RemoveField(
            model_name='notification',
            name='semester',
        ),
        migrations.RemoveField(
            model_name='notification',
            name='user',
        ),
        migrations.DeleteModel(
            name='Notification',
        ),
    ]
