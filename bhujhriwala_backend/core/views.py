from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import ScrapRequest
from .serializers import ScrapRequestSerializer
from rest_framework.parsers import MultiPartParser, FormParser
from .authentication import FirebaseAuthentication

from django.http import HttpResponse

def home():
    return HttpResponse("Welcome to my site!")

class ScrapRequestViewSet(viewsets.ModelViewSet):
    queryset = ScrapRequest.objects.all()
    serializer_class = ScrapRequestSerializer
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = (MultiPartParser, FormParser)

    def get_queryset(self):
        return ScrapRequest.objects.filter(firebase_uid=self.request.user)

    def perform_create(self, serializer):
        serializer.save(firebase_uid=self.request.user)