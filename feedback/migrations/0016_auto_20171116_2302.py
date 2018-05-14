# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0015_auto_20171116_2228'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='explanation',
            name='observation',
        ),
        migrations.AddField(
            model_name='explanation',
            name='feedback',
            field=models.ForeignKey(default=1, to='feedback.Feedback'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='feedbackpiece',
            name='feedback',
            field=models.ForeignKey(default=1, to='feedback.Feedback'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='feedbackpiece',
            name='feedback_explanation',
            field=models.ForeignKey(default=1, to='feedback.Explanation'),
            preserve_default=False,
        ),
    ]
