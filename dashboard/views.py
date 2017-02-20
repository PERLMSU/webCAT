from django.shortcuts import render

# Create your views here.


def view_dashboard(request):
	return render(request, "index.html")