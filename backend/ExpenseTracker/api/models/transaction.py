from django.db import models


class Transaction(models.Model):
    TRANSACTION_TYPE_CHOICES = [
        ('income', 'Income'),
        ('expense', 'Expense'),
    ]
    
    title = models.CharField(max_length=200)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    transaction_type = models.CharField(
        max_length=10, 
        choices=TRANSACTION_TYPE_CHOICES,
        default='expense'
    )
    category = models.ForeignKey(
        'api.Category', 
        on_delete=models.CASCADE, 
        related_name='transactions'
    )
    account = models.ForeignKey(
        'api.Account', 
        on_delete=models.CASCADE, 
        related_name='transactions'
    )
    date = models.DateField()
    notes = models.TextField(blank=True, null=True)
    receipt = models.ImageField(
        upload_to='receipts/', 
        blank=True, 
        null=True
    )
    tags = models.CharField(max_length=500, blank=True, null=True)
    user = models.ForeignKey(
        'api.User', 
        on_delete=models.CASCADE, 
        related_name='transactions'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'created_at']),
            models.Index(fields=['user', 'date']),
            models.Index(fields=['user', 'transaction_type']),
            models.Index(fields=['user', 'category']),
            models.Index(fields=['user', 'account']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.amount} ({self.transaction_type})"
    
    def save(self, *args, **kwargs):
        # Ensure the user matches the category and account user
        if self.category and self.category.user != self.user:
            raise ValueError("Category must belong to the same user")
        if self.account and self.account.user != self.user:
            raise ValueError("Account must belong to the same user")
        super().save(*args, **kwargs) 