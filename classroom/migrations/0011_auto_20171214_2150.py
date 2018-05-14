# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0010_classroom_num_weeks'),
    ]

    operations = [
        migrations.AlterField(
            model_name='group',
            name='group_number',
            field=models.IntegerField(null=True),
        ),
        migrations.AlterUniqueTogether(
            name='group',
            unique_together=set([('classroom', 'group_number')]),
        ),
    ]
