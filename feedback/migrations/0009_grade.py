# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0008_draft_week_num'),
    ]

    operations = [
        migrations.CreateModel(
            name='Grade',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('grade', models.DecimalField(max_digits=2, decimal_places=1)),
                ('category', models.ForeignKey(to='feedback.Category')),
                ('draft', models.ForeignKey(to='feedback.Draft')),
            ],
        ),
    ]
