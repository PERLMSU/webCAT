# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='student',
            name='classroom',
        ),
        migrations.AddField(
            model_name='student',
            name='group_number',
            field=models.IntegerField(default=0),
        ),
        migrations.AddField(
            model_name='student',
            name='student_id',
            field=models.IntegerField(unique=True, null=True),
        ),
        migrations.AlterField(
            model_name='student',
            name='group',
            field=models.ForeignKey(default=None, to='classroom.Group', null=True),
        ),
    ]
