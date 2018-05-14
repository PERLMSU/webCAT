# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0012_semester'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom',
            name='current_semester',
            field=models.ForeignKey(default=1, to='classroom.Semester'),
            preserve_default=False,
        ),
    ]
