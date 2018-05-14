# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0020_auto_20180109_2038'),
        ('notes', '0003_auto_20171116_2302'),
    ]

    operations = [
        migrations.AddField(
            model_name='note',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation', null=True),
        ),
    ]
