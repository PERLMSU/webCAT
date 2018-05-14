# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0002_auto_20170307_0055'),
    ]

    operations = [
        migrations.AlterField(
            model_name='group',
            name='classroom',
            field=models.ForeignKey(default=None, to='classroom.Classroom', null=True),
        ),
    ]
