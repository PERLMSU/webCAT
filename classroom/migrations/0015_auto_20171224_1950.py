# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0014_remove_classroom_num_weeks'),
    ]

    operations = [
        migrations.AlterField(
            model_name='semester',
            name='date_begin',
            field=models.DateField(),
        ),
        migrations.AlterField(
            model_name='semester',
            name='date_end',
            field=models.DateField(),
        ),
    ]
