from django.db import models

# Create your models here.
from django.db import models

class ScrapRequest(models.Model):
    firebase_uid = models.CharField(max_length=128)  # Links to Firebase user
    image = models.ImageField(upload_to='scrap_images/%Y/%m/%d/')
    status = models.CharField(max_length=20, default='pending')
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Scrap Request by {self.firebase_uid} - {self.timestamp}"
