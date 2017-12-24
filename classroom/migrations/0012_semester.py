# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0011_auto_20171214_2150'),
    ]

    operations = [
        migrations.CreateModel(
            name='Semester',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('date_begin', models.DateTimeField()),
                ('date_end', models.DateTimeField()),
                ('title', models.CharField(max_length=200)),
            ],
        ),
    ]
