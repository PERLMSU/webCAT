# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0019_auto_20180109_2013'),
    ]

    operations = [
        migrations.AlterField(
            model_name='feedbackpiece',
            name='feedback',
            field=models.ForeignKey(default=4, to='feedback.Feedback'),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='feedbackpiece',
            name='feedback_explanation',
            field=models.ForeignKey(to='feedback.Explanation'),
        ),
        migrations.AlterField(
            model_name='feedbackpiece',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation'),
        ),
    ]
