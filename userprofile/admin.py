from django.contrib import admin

from .models import (
                    Profile,
                    ConfirmationKey
                )

admin.site.register(Profile)
admin.site.register(ConfirmationKey)

