# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('userprofile', '0003_auto_20170305_2257'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='profile',
            name='permission_level',
        ),
    ]
