# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0008_classroom_current_week'),
    ]

    operations = [
        migrations.AlterField(
            model_name='classroom',
            name='current_week',
            field=models.IntegerField(default=1),
        ),
    ]
