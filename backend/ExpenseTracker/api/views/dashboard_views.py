from rest_framework import permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.db.models import Sum, Count
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

from api.models import Transaction, Category, Account


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def dashboard(request):
    """Get comprehensive dashboard data"""
    user = request.user
    today = datetime.now().date()
    
    # Get period from query params
    period = request.query_params.get('period', 'month')
    
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
        start_date = today.replace(day=1)
        end_date = (start_date + relativedelta(months=1)) - timedelta(days=1)
    
    # Get transactions for the period
    transactions = Transaction.objects.filter(
        user=user,
        date__range=[start_date, end_date]
    )
    
    # Calculate totals
    total_income = transactions.filter(transaction_type='income').aggregate(
        total=Sum('amount'))['total'] or 0
    total_expenses = transactions.filter(transaction_type='expense').aggregate(
        total=Sum('amount'))['total'] or 0
    net_amount = total_income - total_expenses
    
    # Category breakdown for expenses
    category_breakdown = transactions.filter(transaction_type='expense').values(
        'category__title').annotate(
        total=Sum('amount'),
        count=Count('id')
    ).order_by('-total')
    
    # Account summary
    accounts = Account.objects.filter(user=user)
    account_summary = []
    total_account_balance = 0
    
    for account in accounts:
        account_balance = account.current_balance
        total_account_balance += account_balance
        account_summary.append({
            'id': account.id,
            'title': account.title,
            'initial_balance': account.initial,
            'current_balance': account_balance,
            'change': account_balance - account.initial
        })
    
    # Recent transactions
    recent_transactions = Transaction.objects.filter(
        user=user
    ).order_by('-date')[:10]
    
    # Monthly trend (last 6 months)
    monthly_trend = []
    for i in range(6):
        month_start = today.replace(day=1) - relativedelta(months=i)
        month_end = (month_start + relativedelta(months=1)) - timedelta(days=1)
        
        month_transactions = Transaction.objects.filter(
            user=user,
            date__range=[month_start, month_end]
        )
        
        month_income = month_transactions.filter(transaction_type='income').aggregate(
            total=Sum('amount'))['total'] or 0
        month_expenses = month_transactions.filter(transaction_type='expense').aggregate(
            total=Sum('amount'))['total'] or 0
        
        monthly_trend.append({
            'month': month_start.strftime('%Y-%m'),
            'income': month_income,
            'expenses': month_expenses,
            'net': month_income - month_expenses
        })
    
    monthly_trend.reverse()  # Show oldest first
    
    # Top spending categories
    top_categories = transactions.filter(transaction_type='expense').values(
        'category__title').annotate(
        total=Sum('amount')
    ).order_by('-total')[:5]
    
    return Response({
        'period': {
            'type': period,
            'start_date': start_date,
            'end_date': end_date
        },
        'summary': {
            'total_income': total_income,
            'total_expenses': total_expenses,
            'net_amount': net_amount,
            'transaction_count': transactions.count(),
            'total_account_balance': total_account_balance
        },
        'category_breakdown': category_breakdown,
        'account_summary': account_summary,
        'recent_transactions': [
            {
                'id': t.id,
                'title': t.title,
                'amount': t.amount,
                'transaction_type': t.transaction_type,
                'category': t.category.title,
                'account': t.account.title,
                'date': t.date
            } for t in recent_transactions
        ],
        'monthly_trend': monthly_trend,
        'top_categories': top_categories
    })


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def quick_stats(request):
    """Get quick statistics for today, week, month"""
    user = request.user
    today = datetime.now().date()
    
    stats = {}
    
    # Today's stats
    today_transactions = Transaction.objects.filter(
        user=user,
        date=today
    )
    today_income = today_transactions.filter(transaction_type='income').aggregate(
        total=Sum('amount'))['total'] or 0
    today_expenses = today_transactions.filter(transaction_type='expense').aggregate(
        total=Sum('amount'))['total'] or 0
    
    stats['today'] = {
        'income': today_income,
        'expenses': today_expenses,
        'net': today_income - today_expenses,
        'count': today_transactions.count()
    }
    
    # This week's stats
    week_start = today - timedelta(days=today.weekday())
    week_end = week_start + timedelta(days=6)
    week_transactions = Transaction.objects.filter(
        user=user,
        date__range=[week_start, week_end]
    )
    week_income = week_transactions.filter(transaction_type='income').aggregate(
        total=Sum('amount'))['total'] or 0
    week_expenses = week_transactions.filter(transaction_type='expense').aggregate(
        total=Sum('amount'))['total'] or 0
    
    stats['week'] = {
        'income': week_income,
        'expenses': week_expenses,
        'net': week_income - week_expenses,
        'count': week_transactions.count()
    }
    
    # This month's stats
    month_start = today.replace(day=1)
    month_end = (month_start + relativedelta(months=1)) - timedelta(days=1)
    month_transactions = Transaction.objects.filter(
        user=user,
        date__range=[month_start, month_end]
    )
    month_income = month_transactions.filter(transaction_type='income').aggregate(
        total=Sum('amount'))['total'] or 0
    month_expenses = month_transactions.filter(transaction_type='expense').aggregate(
        total=Sum('amount'))['total'] or 0
    
    stats['month'] = {
        'income': month_income,
        'expenses': month_expenses,
        'net': month_income - month_expenses,
        'count': month_transactions.count()
    }
    
    return Response(stats) 