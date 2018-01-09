# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0018_auto_20171224_1900'),
    ]

    operations = [
        migrations.AlterField(
            model_name='explanation',
            name='feedback_explanation',
            field=models.CharField(max_length=2000),
        ),
        migrations.AlterField(
            model_name='feedback',
            name='feedback',
            field=models.CharField(default='No text!', max_length=2000),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='feedbackpiece',
            name='feedback',
            field=models.ForeignKey(to='feedback.Feedback', null=True),
        ),
        migrations.AlterField(
            model_name='feedbackpiece',
            name='feedback_explanation',
            field=models.ForeignKey(to='feedback.Explanation', null=True),
        ),
        migrations.AlterField(
            model_name='feedbackpiece',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation', null=True),
        ),
        migrations.AlterField(
            model_name='observation',
            name='observation',
            field=models.CharField(default=123, max_length=2000),
            preserve_default=False,
        ),
    ]
