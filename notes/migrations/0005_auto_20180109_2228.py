# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notes', '0004_note_observation'),
    ]

    operations = [
        migrations.AlterField(
            model_name='note',
            name='note',
            field=models.CharField(max_length=200, null=True, blank=True),
        ),
    ]
