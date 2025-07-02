from django.db import models


class Category(models.Model):
    title = models.CharField(max_length=200)
    user = models.ForeignKey('api.User', on_delete=models.CASCADE, related_name='categories')
    
    class Meta:
        verbose_name_plural = 'Categories'
        unique_together = ['title', 'user']
        ordering = ['title']
    
    def __str__(self):
        return f"{self.title} ({self.user.name})" 