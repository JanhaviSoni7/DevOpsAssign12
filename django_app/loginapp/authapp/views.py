# Create your views here.
from django.shortcuts import render, redirect
from .models import Login

def register(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        if not Login.objects.filter(username=username).exists():
            Login.objects.create(username=username, password=password)
            return redirect('login')
        else:
            return render(request, 'register.html', {'error': 'User already exists!'})
    return render(request, 'register.html')

def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        try:
            user = Login.objects.get(username=username, password=password)
            request.session['username'] = user.username
            return redirect('home')
        except Login.DoesNotExist:
            return render(request, 'login.html', {'error': 'Invalid credentials'})
    return render(request, 'login.html')

def home(request):
    username = request.session.get('username')
    if not username:
        return redirect('login')
    return render(request, 'home.html', {'username': username})

def logout_view(request):
    request.session.flush()
    return redirect('login')

