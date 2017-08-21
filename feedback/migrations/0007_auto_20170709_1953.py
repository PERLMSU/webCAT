# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
import datetime
from django.utils.timezone import utc


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0006_notification_user'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='created_ts',
            field=models.DateTimeField(default=datetime.datetime(2017, 7, 9, 19, 53, 38, 574038, tzinfo=utc), auto_now_add=True),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='notification',
            name='updated_ts',
            field=models.DateTimeField(default=datetime.datetime(2017, 7, 9, 19, 53, 48, 93352, tzinfo=utc), auto_now=True),
            preserve_default=False,
        ),
    ]
