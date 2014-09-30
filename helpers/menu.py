# coding=utf-8
menuHeader = [
    # Новый заказ
    {
     'Name':'New', 
     'Locale':'Новый заказ', 
     'Location':'/editOrder/new/',     
     'AvaliableItems': [
        {'Name': 'List'},
        {'Name': 'Save', 'Action': 'SaveHeaderFromNew', 'Right': True},
        ],
    },
    # Добавить товар
    {
     'Name':'Add', 
     'Locale':'Добавить товар', 
     'Location':'/editOrder/add/',
     'AvaliableItems': [
        {'Name': 'List', 'Action': 'SaveCurrentOrder'},
        {'Name': 'Edit', 'Action': 'SaveCurrentOrder'},
        {'Name': 'Add', 'IsActive': True, 'Action': 'CallSearch'},
        {'Name': 'Save', 'Predicat': 'isDirty', 'Action': 'SaveCurrentOrder', 'Right': True},
        ]
    },
    # Редактировать 
    {
     'Name': 'Edit',
     'Locale':'Редактировать',
     'Location':'/editOrder/current/',
     'AvaliableItems': [
        {'Name': 'List', 'Action': 'SaveCurrentOrder'},
        {'Name': 'Edit', 'IsActive': True, 'Action': 'CallSearch'},
        {'Name': 'Add', 'Action': 'SaveCurrentOrder', 'Predicat': 'IsReadOnly'},
        
        {'Name': 'Delete', 'Action': 'DeleteCurrentOrder', 'Predicat': 'IsReadOnly', 'Right': True},
        {'Name': 'Finish', 'Action': 'FinishCurrentOrder', 'Predicat': 'IsReadOnly', 'Right': True},
        {'Name': 'Save', 'Predicat': 'isDirty', 'Action': 'SaveCurrentOrder', 'Right': True},
        ]
    },
    # Завершить 
    {
     'Name': 'Finish',
     'Locale':'Завершить',
     'Location':'/finish/',
    },
    # Удалить 
    {
     'Name': 'Delete',
     'Locale':'Удалить',
     'Location':'/delete/',
    },
    # Список заказов
    {
     'Name':'List',
     'Locale':'Список заказов',
     'Location':'/orderList/',
     'AvaliableItems': [
        {'Name': 'List', 'IsActive': True, 'Action': 'CallSearch'},
        {'Name': 'Edit', 'Predicat': 'IsOrderSelected', 'Action': 'SetCurrentOrder'},
        {'Name': 'Add',  'Predicat': 'IsOrderNotFinished', 'Action': 'SetCurrentOrder'},
        
        {'Name': 'Delete', 'Predicat': 'IsOrderNotFinished', 'Action': 'DeleteCurrentOrder', 'Right': True},
        {'Name': 'Finish', 'Predicat': 'IsOrderNotFinished', 'Action': 'DisposeCurrentOrder', 'Right': True},
        {'Name': 'New', 'Right': True},
        ]
    },
    # Сохранить
    {
     'Name':'Save',
     'Locale':'Сохранить',
    },
]