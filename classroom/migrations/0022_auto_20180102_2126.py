# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0021_auto_20171228_1911'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='group',
            unique_together=set([]),
        ),
        migrations.RemoveField(
            model_name='group',
            name='classroom',
        ),
        migrations.AddField(
            model_name='rotationgroup',
            name='group_number',
            field=models.IntegerField(default=1),
            preserve_default=False,
        ),
        migrations.AlterUniqueTogether(
            name='rotationgroup',
            unique_together=set([('rotation', 'group_number')]),
        ),
        migrations.RemoveField(
            model_name='rotationgroup',
            name='group',
        ),
        migrations.DeleteModel(
            name='Group',
        ),
    ]
