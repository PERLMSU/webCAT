from django.shortcuts import render

# Create your views here.


def view_dashboard(request):
	return render(request, "index.html")


def view_charts(request):
	return render(request, "charts.html")	

def view_tables(request):
	return render(request, "tables.html")


def view_forms(request):
	return render(request, "forms.html")

def view_bootstrap(request):
	return render(request, "bootstrap-elements.html")


def view_blank(request):
	return render(request, "blank-page.html")				