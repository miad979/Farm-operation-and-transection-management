from rest_framework import serializers

from .models import Animal, MilkProduction


class AnimalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Animal
        exclude = ("user",)


class MilkProductionSerializer(serializers.ModelSerializer):
    animal_name = serializers.CharField(source="animal.name", read_only=True)

    class Meta:
        model = MilkProduction
        exclude = ("user",)
        validators = []

    def validate_animal(self, value):
        request = self.context.get("request")
        if request and value.user_id != request.user.id:
            raise serializers.ValidationError("You can only record milk for your own animals.")
        return value
