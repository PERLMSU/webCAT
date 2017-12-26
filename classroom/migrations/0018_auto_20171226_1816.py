# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0017_auto_20171226_1812'),
    ]

    operations = [
        migrations.RenameField(
            model_name='rotationgroup',
            old_name='current_instructor',
            new_name='instructor',
        ),
        migrations.RemoveField(
            model_name='student',
            name='group',
        ),
        migrations.AddField(
            model_name='rotationgroup',
            name='students',
            field=models.ManyToManyField(to='classroom.Student'),
        ),
    ]
