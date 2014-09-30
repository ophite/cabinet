# coding=utf-8 
from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    user = models.ForeignKey(User, unique=True)
    SubjectRegistrationCode = models.IntegerField()
    SubjectOID = models.IntegerField()
    SubjectFullName = models.CharField(max_length=128)
    
    #магия показывает имя пользователя в админке(в профайлах)
    def __unicode__(self):
        return self.user.username    