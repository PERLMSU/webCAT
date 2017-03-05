from django import template
from django.conf import settings

register = template.Library()


@register.filter
def get_image(image):
    return image.url if image else settings.STATIC_URL  + 'img/avatar.jpg'

