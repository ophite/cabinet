# from django.conf.urls.defaults import *
from django.conf.urls import patterns, include, url
from django.contrib import admin
from cab_order import views
import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    (r'^$', views.manageEntrance),
    
    (r'^editOrder/(?P<action>\w+)/(?P<OID>\d+)', views.selectOrder),
    (r'^editOrder/add', views.addOrderItems),
    (r'^editOrder/new', views.newOrder),
    (r'^editOrder/current', views.currentOrder),
    
    (r'^finish/(?P<OID>\d+)/(?P<page>\d+)', views.finishOrder),
    (r'^finish/(?P<OID>\d+)', views.finishOrder),
    (r'^finish/', views.finishOrder),
    (r'^delete/(?P<OID>\d+)/(?P<page>\d+)', views.deleteOrder),
    (r'^delete/(?P<OID>\d+)', views.deleteOrder),
    (r'^delete/', views.deleteOrder),
    
    (r'^orderList/$', views.orderList),
    (r'^importExcel/$', views.importExcel),
    (r'^importExcel/excellsheet/$', views.excellsheet),
    
    (r'^orderListData/$', views.orderListData),
    (r'^saveOrderHeader/$', views.saveOrderHeader),

    (r'^itemFilter', views.itemFilter),
    (r'^subjectFilter', views.subjectFilter),
    (r'^subjectDepartments', views.subjectDepartments),
    
    #save orders
    (r'^saveOrder/true', views.saveOrder, {'force_override': True}),
    (r'^saveOrder/false', views.saveOrder, {'force_override': False}),
    
    #login
    (r'^	', views.logout),    
    (r'^accounts/login/$', views.login),
    (r'^logout$', views.logout),
    (r'^changePassword/$', views.changePassword),
    
    #admin
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),
    
    #serve static files
    (r'^content/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.MEDIA_CONTENT}),
    (r'^images/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.MEDIA_IMAGES}),    
)
