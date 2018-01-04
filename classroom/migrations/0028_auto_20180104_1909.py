# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0027_auto_20180103_2131'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom',
            name='course_code',
            field=models.CharField(max_length=5, null=True),
        ),
        migrations.AddField(
            model_name='classroom',
            name='course_number',
            field=models.CharField(max_length=5, null=True),
        ),
    ]
