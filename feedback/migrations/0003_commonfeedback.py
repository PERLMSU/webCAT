# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0002_auto_20170403_0220'),
    ]

    operations = [
        migrations.CreateModel(
            name='CommonFeedback',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('feedback', models.CharField(max_length=200)),
                ('sub_category', models.ForeignKey(to='feedback.SubCategory')),
            ],
        ),
    ]
