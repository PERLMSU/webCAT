# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('classroom', '0016_rotation'),
    ]

    operations = [
        migrations.CreateModel(
            name='RotationGroup',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('description', models.CharField(max_length=200)),
                ('date_created', models.DateTimeField(auto_now_add=True)),
                ('date_updated', models.DateTimeField(auto_now=True)),
                ('current_instructor', models.ForeignKey(to=settings.AUTH_USER_MODEL, null=True)),
            ],
        ),
        migrations.RemoveField(
            model_name='group',
            name='current_instructor',
        ),
        migrations.RemoveField(
            model_name='group',
            name='date_created',
        ),
        migrations.RemoveField(
            model_name='group',
            name='date_updated',
        ),
        migrations.RemoveField(
            model_name='group',
            name='description',
        ),
        migrations.AddField(
            model_name='rotationgroup',
            name='group',
            field=models.ForeignKey(to='classroom.Group'),
        ),
        migrations.AddField(
            model_name='rotationgroup',
            name='rotation',
            field=models.ForeignKey(to='classroom.Rotation'),
        ),
    ]
