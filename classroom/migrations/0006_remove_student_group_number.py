# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0005_auto_20170307_0328'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='student',
            name='group_number',
        ),
    ]
