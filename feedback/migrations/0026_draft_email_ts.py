# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0025_auto_20180208_2029'),
    ]

    operations = [
        migrations.AddField(
            model_name='draft',
            name='email_ts',
            field=models.DateTimeField(null=True),
        ),
    ]
