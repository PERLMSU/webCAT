# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('classroom', '0015_auto_20171224_1950'),
    ]

    operations = [
        migrations.CreateModel(
            name='Rotation',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('start_week', models.IntegerField()),
                ('length', models.IntegerField()),
                ('classroom', models.ForeignKey(to='classroom.Classroom')),
                ('semester', models.ForeignKey(to='classroom.Semester')),
            ],
        ),
    ]
