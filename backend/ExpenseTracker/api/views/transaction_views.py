from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter
from django_filters import rest_framework as filters
from django.db.models import Sum, Q
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from calendar import monthrange

from api.models import Transaction
from api.serializers import TransactionSerializer, TransactionListSerializer


class TransactionFilter(filters.FilterSet):
    # Date filtering options (using created_at)
    created_from = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte', label='Created From')
    created_to = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte', label='Created To')
    created_exact = filters.DateTimeFilter(field_name='created_at', lookup_expr='exact', label='Created Exact')
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gt', label='Created After')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lt', label='Created Before')
    
    # Transaction date filtering (keeping original date field)
    date_from = filters.DateFilter(field_name='date', lookup_expr='gte', label='Transaction Date From')
    date_to = filters.DateFilter(field_name='date', lookup_expr='lte', label='Transaction Date To')
    date_exact = filters.DateFilter(field_name='date', lookup_expr='exact', label='Transaction Date Exact')
    date_after = filters.DateFilter(field_name='date', lookup_expr='gt', label='Transaction Date After')
    date_before = filters.DateFilter(field_name='date', lookup_expr='lt', label='Transaction Date Before')
    
    # Period filtering (using created_at)
    period = filters.CharFilter(method='filter_by_period', label='Period')
    day = filters.NumberFilter(method='filter_by_day', label='Day of Month')
    month = filters.NumberFilter(method='filter_by_month', label='Month')
    year = filters.NumberFilter(method='filter_by_year', label='Year')
    weekday = filters.NumberFilter(method='filter_by_weekday', label='Day of Week (0=Monday, 6=Sunday)')
    
    # Amount filtering
    amount_min = filters.NumberFilter(field_name='amount', lookup_expr='gte', label='Minimum Amount')
    amount_max = filters.NumberFilter(field_name='amount', lookup_expr='lte', label='Maximum Amount')
    amount_exact = filters.NumberFilter(field_name='amount', lookup_expr='exact', label='Exact Amount')
    
    # Other filters
    transaction_type = filters.ChoiceFilter(choices=Transaction.TRANSACTION_TYPE_CHOICES, label='Transaction Type')
    category = filters.NumberFilter(field_name='category', lookup_expr='exact', label='Category ID')
    account = filters.NumberFilter(field_name='account', lookup_expr='exact', label='Account ID')
    tags = filters.CharFilter(field_name='tags', lookup_expr='icontains', label='Tags')
    has_receipt = filters.BooleanFilter(method='filter_has_receipt', label='Has Receipt')
    has_notes = filters.BooleanFilter(method='filter_has_notes', label='Has Notes')
    
    class Meta:
        model = Transaction
        fields = {
            'title': ['exact', 'icontains', 'istartswith', 'iendswith'],
            'notes': ['exact', 'icontains', 'istartswith'],
            'amount': ['exact', 'gte', 'lte', 'gt', 'lt'],
            'date': ['exact', 'gte', 'lte', 'gt', 'lt'],
            'created_at': ['exact', 'gte', 'lte', 'gt', 'lt'],
            'transaction_type': ['exact'],
            'category': ['exact'],
            'account': ['exact'],
        }
    
    def filter_by_period(self, queryset, name, value):
        """Filter by predefined periods using created_at: today, yesterday, week, month, quarter, year, last_week, last_month, last_year"""
        today = datetime.now().date()
        
        if value == 'today':
            return queryset.filter(created_at__date=today)
        elif value == 'yesterday':
            yesterday = today - timedelta(days=1)
            return queryset.filter(created_at__date=yesterday)
        elif value == 'week':
            week_start = today - timedelta(days=today.weekday())
            week_end = week_start + timedelta(days=6)
            return queryset.filter(created_at__date__range=[week_start, week_end])
        elif value == 'last_week':
            last_week_start = today - timedelta(days=today.weekday() + 7)
            last_week_end = last_week_start + timedelta(days=6)
            return queryset.filter(created_at__date__range=[last_week_start, last_week_end])
        elif value == 'month':
            month_start = today.replace(day=1)
            month_end = (month_start + relativedelta(months=1)) - timedelta(days=1)
            return queryset.filter(created_at__date__range=[month_start, month_end])
        elif value == 'last_month':
            last_month = today - relativedelta(months=1)
            last_month_start = last_month.replace(day=1)
            last_month_end = (last_month_start + relativedelta(months=1)) - timedelta(days=1)
            return queryset.filter(created_at__date__range=[last_month_start, last_month_end])
        elif value == 'quarter':
            quarter_start = today.replace(month=((today.month - 1) // 3) * 3 + 1, day=1)
            quarter_end = (quarter_start + relativedelta(months=3)) - timedelta(days=1)
            return queryset.filter(created_at__date__range=[quarter_start, quarter_end])
        elif value == 'year':
            year_start = today.replace(month=1, day=1)
            year_end = today.replace(month=12, day=31)
            return queryset.filter(created_at__date__range=[year_start, year_end])
        elif value == 'last_year':
            last_year = today.year - 1
            last_year_start = today.replace(year=last_year, month=1, day=1)
            last_year_end = today.replace(year=last_year, month=12, day=31)
            return queryset.filter(created_at__date__range=[last_year_start, last_year_end])
        elif value == 'last_7_days':
            seven_days_ago = today - timedelta(days=7)
            return queryset.filter(created_at__date__range=[seven_days_ago, today])
        elif value == 'last_30_days':
            thirty_days_ago = today - timedelta(days=30)
            return queryset.filter(created_at__date__range=[thirty_days_ago, today])
        elif value == 'last_90_days':
            ninety_days_ago = today - timedelta(days=90)
            return queryset.filter(created_at__date__range=[ninety_days_ago, today])
        
        return queryset
    
    def filter_by_day(self, queryset, name, value):
        """Filter by day of month (1-31) using created_at"""
        if 1 <= value <= 31:
            return queryset.filter(created_at__day=value)
        return queryset
    
    def filter_by_month(self, queryset, name, value):
        """Filter by month (1-12) using created_at"""
        if 1 <= value <= 12:
            return queryset.filter(created_at__month=value)
        return queryset
    
    def filter_by_year(self, queryset, name, value):
        """Filter by year using created_at"""
        if value >= 1900:
            return queryset.filter(created_at__year=value)
        return queryset
    
    def filter_by_weekday(self, queryset, name, value):
        """Filter by day of week (0=Monday, 6=Sunday) using created_at"""
        if 0 <= value <= 6:
            return queryset.filter(created_at__week_day=value + 1)  # Django uses 1=Sunday, 2=Monday, etc.
        return queryset
    
    def filter_has_receipt(self, queryset, name, value):
        """Filter transactions that have or don't have receipts"""
        if value:
            return queryset.exclude(receipt='')
        else:
            return queryset.filter(receipt='')
    
    def filter_has_notes(self, queryset, name, value):
        """Filter transactions that have or don't have notes"""
        if value:
            return queryset.exclude(notes__isnull=True).exclude(notes='')
        else:
            return queryset.filter(Q(notes__isnull=True) | Q(notes=''))


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_class = TransactionFilter
    ordering_fields = ['title', 'amount', 'date', 'created_at', 'transaction_type', 'category', 'account']
    search_fields = ['title', 'notes', 'tags']
    
    def get_serializer_class(self):
        if self.action == 'list':
            return TransactionListSerializer
        return TransactionSerializer
    
    def get_queryset(self):
        # Users can only see their own transactions
        return Transaction.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def perform_update(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """Get expense summary for different periods using created_at"""
        user = request.user
        today = datetime.now().date()
        
        # Get date range from query params or default to current month
        period = request.query_params.get('period', 'month')
        
        if period == 'today':
            start_date = today
            end_date = today
        elif period == 'yesterday':
            start_date = today - timedelta(days=1)
            end_date = start_date
        elif period == 'week':
            start_date = today - timedelta(days=today.weekday())
            end_date = start_date + timedelta(days=6)
        elif period == 'last_week':
            start_date = today - timedelta(days=today.weekday() + 7)
            end_date = start_date + timedelta(days=6)
        elif period == 'month':
            start_date = today.replace(day=1)
            end_date = (start_date + relativedelta(months=1)) - timedelta(days=1)
        elif period == 'last_month':
            last_month = today - relativedelta(months=1)
            start_date = last_month.replace(day=1)
            end_date = (start_date + relativedelta(months=1)) - timedelta(days=1)
        elif period == 'quarter':
            start_date = today.replace(month=((today.month - 1) // 3) * 3 + 1, day=1)
            end_date = (start_date + relativedelta(months=3)) - timedelta(days=1)
        elif period == 'year':
            start_date = today.replace(month=1, day=1)
            end_date = today.replace(month=12, day=31)
        elif period == 'last_year':
            last_year = today.year - 1
            start_date = today.replace(year=last_year, month=1, day=1)
            end_date = today.replace(year=last_year, month=12, day=31)
        else:
            # Custom date range
            start_date = request.query_params.get('start_date')
            end_date = request.query_params.get('end_date')
            if not start_date or not end_date:
                start_date = today.replace(day=1)
                end_date = (start_date + relativedelta(months=1)) - timedelta(days=1)
        
        transactions = self.get_queryset().filter(
            created_at__date__range=[start_date, end_date]
        )
        
        # Calculate totals
        total_income = transactions.filter(transaction_type='income').aggregate(
            total=Sum('amount'))['total'] or 0
        total_expenses = transactions.filter(transaction_type='expense').aggregate(
            total=Sum('amount'))['total'] or 0
        net_amount = total_income - total_expenses
        
        # Category breakdown
        category_breakdown = transactions.filter(transaction_type='expense').values(
            'category__title').annotate(total=Sum('amount')).order_by('-total')
        
        # Account breakdown
        account_breakdown = transactions.values(
            'account__title').annotate(total=Sum('amount')).order_by('-total')
        
        # Recent transactions
        recent_transactions = transactions.order_by('-created_at')[:10]
        
        return Response({
            'period': period,
            'start_date': start_date,
            'end_date': end_date,
            'summary': {
                'total_income': total_income,
                'total_expenses': total_expenses,
                'net_amount': net_amount,
                'transaction_count': transactions.count(),
                'income_count': transactions.filter(transaction_type='income').count(),
                'expense_count': transactions.filter(transaction_type='expense').count()
            },
            'category_breakdown': category_breakdown,
            'account_breakdown': account_breakdown,
            'recent_transactions': TransactionListSerializer(recent_transactions, many=True).data
        })
    
    @action(detail=False, methods=['get'])
    def expenses(self, request):
        """Get only expense transactions"""
        queryset = self.get_queryset().filter(transaction_type='expense')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = TransactionListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = TransactionListSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def income(self, request):
        """Get only income transactions"""
        queryset = self.get_queryset().filter(transaction_type='income')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = TransactionListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = TransactionListSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_category(self, request):
        """Get transactions grouped by category"""
        category_id = request.query_params.get('category')
        if category_id:
            queryset = self.get_queryset().filter(category_id=category_id)
        else:
            queryset = self.get_queryset()
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = TransactionListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = TransactionListSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_account(self, request):
        """Get transactions grouped by account"""
        account_id = request.query_params.get('account')
        if account_id:
            queryset = self.get_queryset().filter(account_id=account_id)
        else:
            queryset = self.get_queryset()
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = TransactionListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = TransactionListSerializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def date_range(self, request):
        """Get transactions within a specific date range with enhanced filtering using created_at"""
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        
        if not start_date or not end_date:
            return Response({
                'error': 'Both start_date and end_date are required (YYYY-MM-DD format)'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
        except ValueError:
            return Response({
                'error': 'Invalid date format. Use YYYY-MM-DD'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        queryset = self.get_queryset().filter(created_at__date__range=[start_date, end_date])
        
        # Apply additional filters
        transaction_type = request.query_params.get('transaction_type')
        if transaction_type:
            queryset = queryset.filter(transaction_type=transaction_type)
        
        category_id = request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        account_id = request.query_params.get('account')
        if account_id:
            queryset = queryset.filter(account_id=account_id)
        
        # Ordering
        ordering = request.query_params.get('ordering', '-created_at')
        if ordering:
            queryset = queryset.order_by(ordering)
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = TransactionListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = TransactionListSerializer(queryset, many=True)
        return Response(serializer.data) 