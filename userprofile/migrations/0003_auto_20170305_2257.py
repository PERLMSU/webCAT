# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('userprofile', '0002_auto_20170305_2250'),
    ]

    operations = [
        migrations.AlterField(
            model_name='profile',
            name='permission_level',
            field=models.IntegerField(default=False, blank=True),
        ),
    ]
