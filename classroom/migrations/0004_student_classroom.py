# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0003_auto_20170307_0149'),
    ]

    operations = [
        migrations.AddField(
            model_name='student',
            name='classroom',
            field=models.ForeignKey(default=None, to='classroom.Classroom', null=True),
        ),
    ]
