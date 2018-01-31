# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feedback', '0021_draft_email_sent'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='observation',
            options={'ordering': ['observation_type', 'observation']},
        ),
        migrations.AlterModelOptions(
            name='subcategory',
            options={'ordering': ['name']},
        ),
    ]
