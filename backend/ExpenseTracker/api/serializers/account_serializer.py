from rest_framework import serializers
from api.models import Account


class AccountSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True, default=serializers.CurrentUserDefault())
    current_balance = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    
    class Meta:
        model = Account
        fields = ['id', 'title', 'initial', 'user', 'current_balance']
        read_only_fields = ['id', 'current_balance']
    
    def validate_title(self, value):
        user = self.context['request'].user
        if Account.objects.filter(user=user, title=value).exists():
            raise serializers.ValidationError("An account with this title already exists.")
        return value


class AccountListSerializer(serializers.ModelSerializer):
    current_balance = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    
    class Meta:
        model = Account
        fields = ['id', 'title', 'initial', 'current_balance', 'user']
        read_only_fields = ['id', 'current_balance'] 