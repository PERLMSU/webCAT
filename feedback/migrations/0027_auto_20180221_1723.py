# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0026_draft_email_ts'),
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
        migrations.AlterModelOptions(
            name='draft',
            options={'ordering': ['student']},
        ),
        migrations.DeleteModel(
            name='Notification',
        ),
    ]
