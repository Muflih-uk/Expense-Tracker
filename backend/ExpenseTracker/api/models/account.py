from django.db import models


class Account(models.Model):
    title = models.CharField(max_length=200)
    initial = models.DecimalField(max_digits=15, decimal_places=2, default=0.00)
    user = models.ForeignKey('api.User', on_delete=models.CASCADE, related_name='accounts')
    
    class Meta:
        unique_together = ['title', 'user']
        ordering = ['title']
    
    def __str__(self):
        return f"{self.title} ({self.user.name})"
    
    @property
    def current_balance(self):
        """Calculate current balance based on initial amount and transactions"""
        from api.models.transaction import Transaction
        
        transactions = Transaction.objects.filter(account=self)
        income = transactions.filter(transaction_type='income').aggregate(
            total=models.Sum('amount'))['total'] or 0
        expenses = transactions.filter(transaction_type='expense').aggregate(
            total=models.Sum('amount'))['total'] or 0
        
        return self.initial + income - expenses 