# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0007_auto_20170709_1953'),
    ]

    operations = [
        migrations.AddField(
            model_name='draft',
            name='week_num',
            field=models.IntegerField(default=1),
            preserve_default=False,
        ),
    ]
