# File: /srv/jaroslav.tech/app/project/urls.py
# FINAL VERSION WITH A HOMEPAGE

from django.contrib import admin
from django.urls import path
from django.http import HttpResponse

# This is a simple view function that returns a welcome message.
def home_view(request):
    html = """
    <html>
        <head><title>Welcome!</title></head>
        <body style='font-family: sans-serif; text-align: center; margin-top: 5em;'>
            <h1>It Just Works!</h1>
            <p>My Django application is running successfully behind the Nginx proxy.</p>
            <p>This is my new, scalable architecture.</p>
        </body>
    </html>
    """
    return HttpResponse(html)

urlpatterns = [
    path('admin/', admin.site.urls),
    # This line tells Django to use our home_view for the root URL ('')
    path('', home_view, name='home'),
]
