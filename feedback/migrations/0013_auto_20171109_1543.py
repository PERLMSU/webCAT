# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0012_auto_20171109_1543'),
    ]

    operations = [
        migrations.AlterField(
            model_name='commonfeedback',
            name='feedback',
            field=models.CharField(max_length=200, null=True),
        ),
    ]
