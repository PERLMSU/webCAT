# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0007_group_current_instructor'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom',
            name='current_week',
            field=models.IntegerField(null=True),
        ),
    ]
