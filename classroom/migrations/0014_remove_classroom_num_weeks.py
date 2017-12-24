# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0013_classroom_current_semester'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='classroom',
            name='num_weeks',
        ),
    ]
