# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0028_auto_20180104_1909'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='classroom',
            name='course',
        ),
    ]
