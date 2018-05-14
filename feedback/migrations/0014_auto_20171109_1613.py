# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0013_auto_20171109_1543'),
    ]

    operations = [
        migrations.AlterField(
            model_name='commonfeedback',
            name='problem',
            field=models.CharField(max_length=2000, null=True),
        ),
        migrations.AlterField(
            model_name='commonfeedback',
            name='solution',
            field=models.CharField(max_length=2000, null=True),
        ),
        migrations.AlterField(
            model_name='commonfeedback',
            name='solution_explanation',
            field=models.CharField(max_length=2000, null=True),
        ),
    ]
