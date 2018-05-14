# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('auth', '0006_require_contenttypes_0002'),
    ]

    operations = [
        migrations.CreateModel(
            name='Profile',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(null=True, verbose_name='last login', blank=True)),
                ('is_superuser', models.BooleanField(default=False,
                                                     help_text='Designates that this user has all permissions without explicitly assigning them.',
                                                     verbose_name='superuser status')),
                ('email', models.EmailField(unique=True, max_length=150)),
                ('username', models.CharField(unique=True, max_length=150)),
                ('first_name', models.CharField(max_length=80, null=True, blank=True)),
                ('last_name', models.CharField(max_length=80, null=True, blank=True)),
                ('nick_name', models.CharField(max_length=15, null=True, blank=True)),
                ('bio', models.TextField(null=True, blank=True)),
                ('phone', models.CharField(max_length=20, null=True, blank=True)),
                ('city', models.CharField(max_length=100, null=True, blank=True)),
                ('country', models.CharField(max_length=100, null=True, blank=True)),
                ('state', models.CharField(max_length=100, null=True, blank=True)),
                ('birth_date', models.DateField(null=True, blank=True)),
                ('date_joined', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('is_verified', models.BooleanField(default=False)),
                ('is_activated', models.BooleanField(default=False)),
                ('is_admin', models.BooleanField(default=False)),
                ('is_staff', models.BooleanField(default=False)),
                ('is_active', models.BooleanField(default=True, verbose_name='active')),
                ('groups',
                 models.ManyToManyField(related_query_name='user', related_name='user_set', to='auth.Group', blank=True,
                                        help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.',
                                        verbose_name='groups')),
                ('user_permissions',
                 models.ManyToManyField(related_query_name='user', related_name='user_set', to='auth.Permission',
                                        blank=True, help_text='Specific permissions for this user.',
                                        verbose_name='user permissions')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='ConfirmationKey',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('key', models.CharField(max_length=32, null=True, blank=True)),
                ('is_used', models.BooleanField(default=False)),
                ('user', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
