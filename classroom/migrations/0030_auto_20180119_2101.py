# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0029_remove_classroom_course'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='classroom',
            options={'ordering': ['course_code', 'course_number']},
        ),
        migrations.AlterModelOptions(
            name='rotation',
            options={'ordering': ['start_week']},
        ),
        migrations.AlterModelOptions(
            name='semester',
            options={'ordering': ['date_begin']},
        ),
    ]
