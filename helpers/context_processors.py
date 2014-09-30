# coding=utf-8
import settings
from django.core.urlresolvers import resolve
from menu import menuHeader
from cab_order.models import UserProfile
from cab_order.codamodels import DocTradeLine, Subject

#===================================================================================================
get_menu_by_name = lambda name: ([x for x in menuHeader if x['Name'] == name] + [{}])[0]

params = {
    'newOrder': {'menu': 'New', 'header_text': u'Новый заказ', 'filter': 'FilterOrder', 'search_help_text': u'', 'search_text': u'Найти товар'},  
    'currentOrder': {'menu': 'Edit', 'header_text': u'Текущий заказ', 'filter': 'FilterOrder', 'search_help_text': u'Строка поиска товара', 'search_text': u'Фильтровать заказ'},
    'editOrder': {'menu': 'Edit', 'header_text': 'Текущий заказ', 'filter': 'FilterOrder', 'search_help_text': u'Строка поиска товара', 'search_text': u'Фильтровать заказ'},
    'orderList': {'menu': 'List', 'header_text': 'Список заказов', 'filter': 'FilterList', 'search_help_text': u'Строка поиска заказов', 'search_text': u'Найти заказ'},
    'addOrderItems': {'menu': 'Add', 'header_text': 'Добавить товар', 'filter': 'FilterOrder', 'search_help_text': u'Строка поиска товара', 'search_text': u'Найти товар'},
}

def get_info(_view, data, subject):
    if _view == 'newOrder' and subject:
        return [subject.SubjectFullName]
    
    elif _view in ['currentOrder', 'addOrderItems']:
        return [u'%s, Заказ №%s от %s' % (data.get('SubjectFullName') or '', data.get('DocCode') or '', data.get('DocDate') or '')]
    
    elif _view == 'orderList' and subject:
        return [u'Текущие заказы: %s' % subject.SubjectFullName]
     
def custom_processor(request):
    c = {}
    _view = resolve(request.META['PATH_INFO']).func.__name__
    order = request.session.get('Order', None) 
    
    subject = {}
    if request.user.is_active:
        d = UserProfile.objects.filter(user=request.user)
        if d: subject = d[0]
    
    if _view in params:
        d = params[_view]
        
        menuItems = [
            dict(get_menu_by_name(x['Name']).items() + x.items()) 
            for x in get_menu_by_name(d['menu']).get('AvaliableItems', [])
        ]
        
        c.update({
            'header_text': d['header_text'],
            'search_help_text': d['search_help_text'],
            'search_text': d['search_text'],
            'filter': request.session.get(d['filter'], ''),
            'info': get_info(_view, request.session.get('data'), subject),
            'menuItems': menuItems,
        })
    
    c.update({
        'debug': settings.DEBUG,
        'subject': subject and subject.SubjectOID,
        'order': order,
    })
    return c