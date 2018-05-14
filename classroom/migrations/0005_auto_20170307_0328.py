# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0004_student_classroom'),
    ]

    operations = [
        migrations.AlterField(
            model_name='group',
            name='group_number',
            field=models.IntegerField(unique=True, null=True),
        ),
    ]
