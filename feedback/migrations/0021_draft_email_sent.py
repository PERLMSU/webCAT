# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0020_auto_20180109_2038'),
    ]

    operations = [
        migrations.AddField(
            model_name='draft',
            name='email_sent',
            field=models.BooleanField(default=False),
        ),
    ]
