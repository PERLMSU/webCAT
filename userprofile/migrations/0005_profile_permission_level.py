# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('userprofile', '0004_remove_profile_permission_level'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='permission_level',
            field=models.IntegerField(default=0),
        ),
    ]
