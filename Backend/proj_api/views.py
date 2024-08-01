#Import necessary libraries
import joblib
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.generics import CreateAPIView
from .serializers import SensorDataSerializer
from django.conf import settings
import numpy as np
import os

# Load the model from the static folder
path_to_model = os.path.join(settings.BASE_DIR, 'static/model/')
loaded_model = joblib.load(open(path_to_model+'rf_model.joblib', 'rb'))



# Create your views here.
@api_view(['GET'])
def IndexView(request):
    return_data = {
        'message' : 'Welcome to the Driver Status Prediction API',
        'routes' : '/api/predict/',
        "error_code" : "0",
        "info" : "success",
    }
    return Response(return_data)



# SensroData
class SensorDataView(CreateAPIView):
    """
    Get the sensor data from the mobile and make a prediction
    """
    serializer_class = SensorDataSerializer

    def post(self, request):
        try:
            # Get the JSON data from the request
            driver_json_data = request.data

            # Serialize the JSON data using the SensorDataSerializer
            serializer = SensorDataSerializer(data=driver_json_data)
            serializer.is_valid(raise_exception=True)

            # Extract the values from the serialized data
            data_values = list(serializer.validated_data.values())
            driver_info = np.array(data_values)

            # Make the prediction using the loaded model 
            driver_status = loaded_model.predict([driver_info])

            # Check the Model confidence score
            confidence_score =  np.max(loaded_model.predict_proba([driver_info]))

            response_data = {
            'Status': 'Success',
            'Driving Style': 'Aggressive' if driver_status[0] == 0 
                                    else ('Normal' if driver_status[0] == 1 
                                        else('Slow' if driver_status[0] == 2 
                                             else 'UNKNOWN')),
            'Model Confidence Score': round(confidence_score*100, 2)
            }

        except ValueError as Error:
            # Handle any errors that may occur during the prediction
            response_data = {
            'Status' : 'Failed',
            "Error": str(Error)
            }

        return Response(response_data)