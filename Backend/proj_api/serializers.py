from rest_framework import serializers

class SensorDataSerializer(serializers.Serializer):
    AccX = serializers.FloatField()
    AccY = serializers.FloatField()
    AccZ = serializers.FloatField()
    GyroX = serializers.FloatField()
    GyroY = serializers.FloatField()
    GyroZ = serializers.FloatField()