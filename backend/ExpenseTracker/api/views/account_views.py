from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter
from django.db.models import Sum, Count
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

from api.models import Account, Transaction
from api.serializers import AccountSerializer, AccountListSerializer


class AccountViewSet(viewsets.ModelViewSet):
    serializer_class = AccountSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    ordering_fields = ['title', 'initial']
    search_fields = ['title']
    
    def get_serializer_class(self):
        if self.action == 'list':
            return AccountListSerializer
        return AccountSerializer
    
    def get_queryset(self):
        # Users can only see their own accounts
        return Account.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def perform_update(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def with_balance(self, request):
        """Get accounts with current balance"""
        accounts = self.get_queryset()
        serializer = AccountListSerializer(accounts, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """Get account summary with total balances"""
        accounts = self.get_queryset()
        
        total_initial = sum(account.initial for account in accounts)
        total_current = sum(account.current_balance for account in accounts)
        total_change = total_current - total_initial
        
        return Response({
            'total_accounts': accounts.count(),
            'total_initial_balance': total_initial,
            'total_current_balance': total_current,
            'total_change': total_change,
            'accounts': AccountListSerializer(accounts, many=True).data
        })
    
    @action(detail=True, methods=['get'])
    def transactions(self, request, pk=None):
        """Get all transactions for a specific account"""
        try:
            account = self.get_queryset().get(pk=pk)
            transactions = Transaction.objects.filter(
                account=account,
                user=request.user
            ).order_by('-date')
            
            from api.serializers import TransactionListSerializer
            serializer = TransactionListSerializer(transactions, many=True)
            return Response(serializer.data)
        except Account.DoesNotExist:
            return Response({'error': 'Account not found'}, status=404)
    
    @action(detail=True, methods=['get'])
    def balance_history(self, request, pk=None):
        """Get balance history for an account over time"""
        try:
            account = self.get_queryset().get(pk=pk)
            
            # Get period from query params
            period = request.query_params.get('period', 'month')
            today = datetime.now().date()
            
            if period == 'week':
                start_date = today - timedelta(days=7)
            elif period == 'month':
                start_date = today - timedelta(days=30)
            elif period == 'year':
                start_date = today - timedelta(days=365)
            else:
                start_date = today - timedelta(days=30)
            
            transactions = Transaction.objects.filter(
                account=account,
                user=request.user,
                date__gte=start_date
            ).order_by('date')
            
            # Calculate running balance
            balance_history = []
            running_balance = account.initial
            
            for transaction in transactions:
                if transaction.transaction_type == 'income':
                    running_balance += transaction.amount
                else:
                    running_balance -= transaction.amount
                
                balance_history.append({
                    'date': transaction.date,
                    'balance': running_balance,
                    'transaction': {
                        'id': transaction.id,
                        'title': transaction.title,
                        'amount': transaction.amount,
                        'type': transaction.transaction_type
                    }
                })
            
            return Response({
                'account': AccountListSerializer(account).data,
                'initial_balance': account.initial,
                'current_balance': account.current_balance,
                'balance_history': balance_history
            })
        except Account.DoesNotExist:
            return Response({'error': 'Account not found'}, status=404) 