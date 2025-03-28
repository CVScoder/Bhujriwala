import firebase_admin
from firebase_admin import credentials, auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

cred = credentials.Certificate("C:/Users/leela/Documents/Bhujriwala/bhujhriwala_backend/bujriwala/firebase.json") # Download from Firebase Console
firebase_admin.initialize_app(cred)

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None
        
        token = auth_header.split('Bearer ')[1]
        try:
            decoded_token = auth.verify_id_token(token)
            uid = decoded_token['uid']
            return (uid, None)  # UID as authenticated user
        except Exception as e:
            raise AuthenticationFailed(f'Invalid Firebase token: {str(e)}')