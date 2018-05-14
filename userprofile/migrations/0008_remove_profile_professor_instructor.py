# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('userprofile', '0007_auto_20170709_1926'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='profile',
            name='professor_instructor',
        ),
    ]
