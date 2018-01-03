# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0025_auto_20180102_2303'),
    ]

    operations = [
        migrations.AddField(
            model_name='rotation',
            name='end_week',
            field=models.IntegerField(null=True),
        ),
    ]
