from django.urls import path
from .views import IndexView, SensorDataView

urlpatterns = [
    path('',IndexView),
    # path('predict', views.predict_driver_status),
    path('predict/', SensorDataView.as_view()),
]
