from django.contrib.auth.models import User
from django.conf import settings
from random import random
from cab_order.codamodels import CodaUser
import ldap
import ipdb

#===================================================================================================
class ActiveDirectoryBackend:
    def authenticate(self, username=None, password=None):
        l = ldap.initialize(settings.AD_LDAP_URL)
        try:
            l.simple_bind_s(username, password)
        except:
            return None
        l.unbind_s()
        
        users = User.objects.filter(username=username)
        user = users[0] if users else None
        
        if not CodaUser.GetByName(username):
            if user: 
                user.delete()            
            return None
        
        if not user:
            user = User(username=username, is_staff=True, is_superuser=False)
            user.set_password(random())
            user.save()
        return user

    def get_user(self,user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None