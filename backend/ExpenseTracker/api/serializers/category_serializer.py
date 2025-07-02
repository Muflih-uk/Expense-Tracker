from rest_framework import serializers
from api.models import Category


class CategorySerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    
    class Meta:
        model = Category
        fields = ['id', 'title', 'user']
        read_only_fields = ['id']
    
    def validate_title(self, value):
        user = self.context['request'].user
        if Category.objects.filter(user=user, title=value).exists():
            raise serializers.ValidationError("A category with this title already exists.")
        return value


class CategoryListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'title']
        read_only_fields = ['id'] 