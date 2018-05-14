# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0011_auto_20171109_1538'),
    ]

    operations = [
        migrations.AddField(
            model_name='commonfeedback',
            name='observation',
            field=models.CharField(max_length=200, null=True),
        ),
        migrations.AddField(
            model_name='commonfeedback',
            name='problem',
            field=models.CharField(max_length=500, null=True),
        ),
        migrations.AddField(
            model_name='commonfeedback',
            name='solution',
            field=models.CharField(max_length=500, null=True),
        ),
        migrations.AddField(
            model_name='commonfeedback',
            name='solution_explanation',
            field=models.CharField(max_length=500, null=True),
        ),
    ]
