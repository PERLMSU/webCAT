# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0030_auto_20180119_2101'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='rotationgroup',
            options={'ordering': ['group_number']},
        ),
    ]
