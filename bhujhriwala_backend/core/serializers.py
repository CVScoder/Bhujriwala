from rest_framework import serializers
from .models import ScrapRequest

class ScrapRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScrapRequest
        fields = ['id', 'image', 'status', 'timestamp']