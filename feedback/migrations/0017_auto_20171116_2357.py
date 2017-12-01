# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0016_auto_20171116_2302'),
    ]

    operations = [
        migrations.AddField(
            model_name='explanation',
            name='sub_category',
            field=models.ForeignKey(default=5, to='feedback.SubCategory'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='feedback',
            name='sub_category',
            field=models.ForeignKey(default=5, to='feedback.SubCategory'),
            preserve_default=False,
        ),
    ]
