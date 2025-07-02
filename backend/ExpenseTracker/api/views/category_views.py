from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter
from django.db.models import Sum, Count
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

from api.models import Category, Transaction
from api.serializers import CategorySerializer, CategoryListSerializer


class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    ordering_fields = ['title']
    search_fields = ['title']
    
    def get_serializer_class(self):
        if self.action == 'list':
            return CategoryListSerializer
        return CategorySerializer
    
    def get_queryset(self):
        # Users can only see their own categories
        return Category.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def perform_update(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def with_stats(self, request):
        """Get categories with transaction statistics"""
        categories = self.get_queryset()
        
        # Get period from query params
        period = request.query_params.get('period', 'month')
        today = datetime.now().date()
        
        if period == 'today':
            start_date = today
            end_date = today
        elif period == 'week':
            start_date = today - timedelta(days=today.weekday())
            end_date = start_date + timedelta(days=6)
        elif period == 'month':
            start_date = today.replace(day=1)
            end_date = (start_date + relativedelta(months=1)) - timedelta(days=1)
        elif period == 'year':
            start_date = today.replace(month=1, day=1)
            end_date = today.replace(month=12, day=31)
        else:
            start_date = None
            end_date = None
        
        # Get transaction stats for each category
        categories_with_stats = []
        for category in categories:
            transactions = Transaction.objects.filter(
                category=category,
                user=request.user
            )
            
            if start_date and end_date:
                transactions = transactions.filter(date__range=[start_date, end_date])
            
            total_amount = transactions.aggregate(total=Sum('amount'))['total'] or 0
            transaction_count = transactions.count()
            
            categories_with_stats.append({
                'id': category.id,
                'title': category.title,
                'total_amount': total_amount,
                'transaction_count': transaction_count
            })
        
        # Sort by total amount descending
        categories_with_stats.sort(key=lambda x: x['total_amount'], reverse=True)
        
        return Response(categories_with_stats)
    
    @action(detail=True, methods=['get'])
    def transactions(self, request, pk=None):
        """Get all transactions for a specific category"""
        try:
            category = self.get_queryset().get(pk=pk)
            transactions = Transaction.objects.filter(
                category=category,
                user=request.user
            ).order_by('-date')
            
            from api.serializers import TransactionListSerializer
            serializer = TransactionListSerializer(transactions, many=True)
            return Response(serializer.data)
        except Category.DoesNotExist:
            return Response({'error': 'Category not found'}, status=404) 