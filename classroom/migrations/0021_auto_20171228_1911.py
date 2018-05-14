# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('classroom', '0020_student_semester'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='rotationgroup',
            unique_together=set([('rotation', 'group')]),
        ),
    ]
