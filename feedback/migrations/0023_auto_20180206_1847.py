# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0022_auto_20180128_2100'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='draft',
            unique_together=set([('owner', 'student', 'week_num')]),
        ),
    ]
