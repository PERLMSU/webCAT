# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('feedback', '0014_auto_20171109_1613'),
    ]

    operations = [
        migrations.CreateModel(
            name='Explanation',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('feedback_explanation', models.CharField(max_length=2000, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='Feedback',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('feedback', models.CharField(max_length=2000, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='FeedbackPiece',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
            ],
        ),
        migrations.CreateModel(
            name='Observation',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('observation', models.CharField(max_length=2000, null=True)),
                ('observation_type', models.NullBooleanField()),
                ('sub_category', models.ForeignKey(to='feedback.SubCategory')),
            ],
        ),
        migrations.RemoveField(
            model_name='commonfeedback',
            name='sub_category',
        ),
        migrations.DeleteModel(
            name='CommonFeedback',
        ),
        migrations.AddField(
            model_name='feedbackpiece',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation'),
        ),
        migrations.AddField(
            model_name='feedbackpiece',
            name='sub_category',
            field=models.ForeignKey(to='feedback.SubCategory'),
        ),
        migrations.AddField(
            model_name='feedback',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation'),
        ),
        migrations.AddField(
            model_name='explanation',
            name='observation',
            field=models.ForeignKey(to='feedback.Observation'),
        ),
    ]
