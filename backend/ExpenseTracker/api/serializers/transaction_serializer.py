from rest_framework import serializers
from api.models import Transaction, Category, Account


class CategoryNestedSerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'title']


class AccountNestedSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'title']


class TransactionSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    category_detail = CategoryNestedSerializer(source='category', read_only=True)
    account_detail = AccountNestedSerializer(source='account', read_only=True)
    
    class Meta:
        model = Transaction
        fields = [
            'id', 'title', 'amount', 'transaction_type', 'category', 'category_detail',
            'account', 'account_detail', 'date', 'notes', 'receipt', 'tags', 'user', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']
    
    def validate(self, data):
        user = self.context['request'].user
        
        # Validate category belongs to user
        if 'category' in data and data['category'].user != user:
            raise serializers.ValidationError("Category must belong to the current user.")
        
        # Validate account belongs to user
        if 'account' in data and data['account'].user != user:
            raise serializers.ValidationError("Account must belong to the current user.")
        
        return data


class TransactionListSerializer(serializers.ModelSerializer):
    category = CategoryNestedSerializer(read_only=True)
    account = AccountNestedSerializer(read_only=True)
    
    class Meta:
        model = Transaction
        fields = [
            'id', 'title', 'amount', 'transaction_type', 'category', 'account',
            'date', 'notes', 'receipt', 'tags', 'created_at'
        ]
        read_only_fields = ['id', 'created_at'] 