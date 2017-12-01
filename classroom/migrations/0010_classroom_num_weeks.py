# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0009_auto_20171109_1824'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom',
            name='num_weeks',
            field=models.IntegerField(default=12),
        ),
    ]
