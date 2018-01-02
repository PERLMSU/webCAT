# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0018_auto_20171226_1816'),
    ]

    operations = [
        migrations.AlterField(
            model_name='student',
            name='notes',
            field=models.CharField(max_length=2000),
        ),
    ]
