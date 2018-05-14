# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0026_rotation_end_week'),
    ]

    operations = [
        migrations.AlterField(
            model_name='rotation',
            name='end_week',
            field=models.IntegerField(),
        ),
    ]
