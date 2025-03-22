# Bhujriwala - Django Backend

## 📌 Overview
Bhujriwala is a Django-based backend application that provides authentication and user management features. It includes API endpoints for user registration, login, and profile management.

## 🚀 Features
- User Registration with Token Authentication
- Secure Login System
- Profile Management
- PostgreSQL Database Support
- Django REST Framework (DRF) API Endpoints

---

## 🔧 Installation & Setup

### **1️⃣ Clone the Repository**
```sh
git clone https://github.com/yourusername/bhujriwala.git
cd bhujriwala
```

### **2️⃣ Create a Virtual Environment**
```sh
python -m venv venv
source venv/bin/activate   # macOS/Linux
venv\Scripts\activate      # Windows
```

### **3️⃣ Install Dependencies**
```sh
pip install -r requirements.txt
```

### **4️⃣ Configure PostgreSQL Database**
1. Install PostgreSQL and create a new database.
2. Update `settings.py` with your database credentials:
   ```python
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.postgresql',
           'NAME': 'bhujriwala_db',
           'USER': 'your_db_user',
           'PASSWORD': 'your_db_password',
           'HOST': 'localhost',
           'PORT': '5432',
       }
   }
   ```

### **5️⃣ Apply Migrations**
```sh
python manage.py makemigrations
python manage.py migrate
```

### **6️⃣ Create a Superuser (Optional)**
```sh
python manage.py createsuperuser
```

### **7️⃣ Run the Server**
```sh
python manage.py runserver
```
Server will start at: `http://127.0.0.1:8000/`

---

## 🚀 API Testing

### **1️⃣ Register a User**
```sh
curl -X POST http://127.0.0.1:8000/api/users/register/ \
     -H "Content-Type: application/json" \
     -d '{
           "username": "testuser",
           "email": "test@example.com",
           "password": "strongpassword",
           "user_type": "household",
           "phone_number": "1234567890"
         }'
```

### **2️⃣ Login a User**
```sh
curl -X POST http://127.0.0.1:8000/api/users/login/ \
     -H "Content-Type: application/json" \
     -d '{
           "username": "testuser",
           "password": "strongpassword"
         }'
```

### **3️⃣ Access User Profile (Authenticated Request)**
```sh
curl -X GET http://127.0.0.1:8000/api/users/profile/ \
     -H "Authorization: Token your_generated_token" \
     -H "Content-Type: application/json"
```

---

## ❓ Troubleshooting

### **Database Connection Issues**
- Ensure PostgreSQL is installed and running.
- Verify database credentials in `settings.py`.
- Run `python manage.py migrate` again if needed.

### **Server Not Starting?**
- Check for syntax errors in `settings.py` or `urls.py`.
- Ensure `include` is imported in `urls.py`:
  ```python
  from django.urls import path, include
  ```

### **Authentication Issues?**
- Run `python manage.py createsuperuser` to create an admin user.
- Make sure `rest_framework.authtoken` is in `INSTALLED_APPS`.
- Restart the server after making changes.

---

## 📜 License
This project is licensed under the MIT License.

