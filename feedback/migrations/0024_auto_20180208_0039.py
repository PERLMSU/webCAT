# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0023_auto_20180206_1847'),
    ]

    operations = [
        migrations.AlterField(
            model_name='draft',
            name='text',
            field=models.CharField(max_length=4096, null=True, blank=True),
        ),
    ]
