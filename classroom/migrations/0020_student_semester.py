# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0019_auto_20171227_1937'),
    ]

    operations = [
        migrations.AddField(
            model_name='student',
            name='semester',
            field=models.ForeignKey(default=1, to='classroom.Semester'),
            preserve_default=False,
        ),
    ]
