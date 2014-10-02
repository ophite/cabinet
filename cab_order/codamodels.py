# coding=utf-8
from django.db import models
from helpers.sql import CustomManager, exec_sql, get_value
# from django.utils import simplejson as json
import simplejson as json
from helpers.base import createFilter, toAutocomplete
import ipdb

#def hideColumns(request, columns):
#    colByName = lambda cols, colName: [x for x in cols if x['name'] == colName][0]
#    
#    if (request.session.get('layoutgridcolumns')):
#        l = request.session.get('layoutgridcolumns')
#        for x in columns:
#            x['hidden'] =  str(colByName(l, x['name']).get('hidden', 'false'))
#            x['width'] = int(colByName(l, x['name']).get('width', ''))
#    
#    return columns
    
class Filter(models.Model):
    FilterID = models.IntegerField()
    ClassName = models.CharField(max_length=128)
    Name = models.CharField(max_length=128)
    ItemCount = models.IntegerField()

    objects = CustomManager()
    columns = [
        {'name': 'FilterID',    'local':'FilterID'},    
        {'name': 'ClassName',   'local':'ClassName'},    
        {'name': 'FullName',    'local':'Наименование'},
        {'name': 'ItemCount',   'local':'Кол-во'},
    ]     
    
    @classmethod
    def itemRubrikator(cls, FilterString, TopRecords):
        return Filter.objects.exec_objects().cabinet_ItemRubrikator(createFilter(FilterString), TopRecords)

class CodaUser(models.Model):
    FullName = models.CharField(max_length=128)
    OID = models.IntegerField()

    objects = CustomManager()
    columns = [
        {'name': 'OID',             'local':'OID'},    
        {'name': 'UserName',        'local':'Логин'},
    ]     
 
    @classmethod
    def GetByName(cls, UserName):
        return CodaUser.objects.exec_objects().cabinet_CodaUserByName(UserName)

class Department(models.Model):
    FullName = models.CharField(max_length=128)
    OID = models.IntegerField()

    objects = CustomManager()
    columns = [
        {'name': 'OID',                 'local':'OID'},    
        {'name': 'DepartmentName',      'local':'Наименование'},
    ]     
 
    @classmethod
    def subjectDepartments(cls, SubjectID):
        return Department.objects.exec_objects().cabinet_SubjectDepartments(SubjectID)

class Subject(models.Model):
    FullName = models.CharField(max_length=128)
    OID = models.IntegerField()

    objects = CustomManager()
    columns = [
        {'name': 'OID',         'local':'OID'},    
        {'name': 'FullName',    'local':'Наименование'},
    ]     
 
    @classmethod
    def filter(cls, FilterString, TopRecords):
        return toAutocomplete(Subject.objects.exec_dictlist().cabinet_SubjectFilter(createFilter(FilterString), TopRecords))
    
    @classmethod
    def get(cls, OID):
        return Subject.objects.exec_objects().cabinet_SubjectGet(OID)

class Order(models.Model):
    OID = models.BigIntegerField()
    Comments = models.TextField()
    DelayLimit = models.IntegerField()
    DepartmentID = models.BigIntegerField()
    CustomerID = models.BigIntegerField()
    DocCode = models.CharField(max_length=32)
    DocDate = models.DateField()
    #FullName = models.CharField(max_length=128)
    SubjectFullName = models.CharField(max_length=128)
    DepartmentFullName = models.CharField(max_length=128)
    Amount = models.FloatField()    
    IsFinished = models.BooleanField()
    
    objects = CustomManager()
    
    columns = [
        {'name': 'OID',                 'local':u'OID',            'hidden': True},        
        {'name': 'DepartmentID',        'local':u'DepartmentID',   'hidden': True},
        {'name': 'CustomerID',          'local':u'CustomerID',     'hidden': True},
        {'name': 'OrderID',             'local':u'OrderID',        'hidden': True},
        
        {'name': 'DocCode',             'local':u'Заказ', 'width': 100},
        {'name': 'DocDate',             'local':u'Дата'},
        {'name': 'Amount',              'local':u'Сумма', 'width': 120,  'sorttype':'int',   'type': 'currency'},
        {'name': 'SubjectFullName',     'local':u'Контрагент', 'width': 350},
        {'name': 'DepartmentFullName',  'local':u'Адрес', 'width': 350},
        {'name': 'DelayLimit',          'local':u'Отсрочка', 'sorttype':'int',   'type': 'int', 'width': 35},
        {'name': 'IsFinished',          'local':u'Зав', 'width': 25},
        {'name': 'Comments',            'local':u'Комментарий', 'width': 300},
    ]
    
    calcFields = {
        'IsFinished':  lambda d: u'  +' if d.get('IsFinished') else '',
    }
    
    @classmethod
    def orderList(cls, DateBeg, DateEnd, FilterString, CustomerID, WithFinished, PageSize, PageNumber):
        return Order.objects.exec_objects().cabinet_OrderList(DateBeg, DateEnd, createFilter(FilterString), CustomerID, WithFinished, PageSize, PageNumber)
    
    @classmethod
    def orderListPagesCount(cls, DateBeg, DateEnd, FilterString, CustomerID, WithFinished, PageSize):
        return Order.objects.exec_value().cabinet_OrderListPagesCount(DateBeg, DateEnd, createFilter(FilterString), CustomerID, WithFinished, PageSize)
    
    @classmethod
    def createOrder(cls, DocDate, DelayLimit, CustomerID, DepartmentID, Comments, **kwargs):
        return Order.objects.exec_value().cabinet_OrderNew(DocDate, DelayLimit, CustomerID, DepartmentID, Comments)
    
    @classmethod
    def updateOrder(cls, OrderID, DocDate, DelayLimit, CustomerID, DepartmentID, Comments, **kwargs):
        return Order.objects.exec_value().cabinet_OrderUpdate(OrderID, DocDate, DelayLimit, CustomerID, DepartmentID, Comments)
    
    @classmethod
    def finishOrder(cls, OrderID):
        return Order.objects.exec_value().cabinet_OrderFinished(OrderID)
    
    @classmethod
    def deleteOrder(cls, OrderID):
        return Order.objects.exec_value().cabinet_OrderDelete(OrderID)
 
class DocTradeLine(models.Model):
    ItemID = models.IntegerField()
    Quantity = models.IntegerField()
    Available = models.IntegerField()
    BasePrice = models.FloatField()
    VatPercent = models.FloatField()
    VatSum = models.FloatField()
    Amount = models.FloatField()

    Name = models.CharField(max_length=128)     
    ExtraName = models.CharField(max_length=128)
    ScanCode = models.CharField(max_length=32)
    DivLoadQnt = models.IntegerField()
    IsAvailable = models.BooleanField()

    objects = CustomManager()
    
    columns = [
        {'name': 'ItemID',      'local':u'ItemID',          'hidden': True},        
        {'name': 'DivLoadQnt',  'local':u'МинЗ',            'sorttype':'int',   'type': 'int', 'width': 21},
        {'name': 'Name',        'local':u'Наименование',    'width': 250},
        {'name': 'ExtraName',   'local':u'Емк.',            'width': 20},
        {'name': 'ScanCode',    'local':u'EAN',             'width': 60},
        {'name': 'Quantity',    'local':u'Кол-во',          'sorttype':'int',   'type': 'int', 'editable':'true', 'width':28},
        {'name': 'Available',   'local':u'Склад',           'sorttype':'int',   'type': 'int', 'Condition': lambda user: user.is_staff},
        {'name': 'IsAvailable', 'local':u'Склад',           'width': 21,        'Condition': lambda user: not user.is_staff},
        {'name': 'BasePrice',   'local':u'Прайс',           'sorttype':'int',   'type': 'currency'},
        {'name': 'Price',       'local':u'Цена',            'sorttype':'int',   'type': 'currency'},
        {'name': 'VatPercent',  'local':u'НДС %',           'sorttype':'int',   'type': 'int', 'formatter': 'vatSumFormatter', 'unformat': 'vatSumUnformatter', 'width':27},
        {'name': 'PriceSum',    'local':u'Сумма',           'sorttype':'int',   'type': 'currency'},
        {'name': 'VatSum',      'local':u'НДС',             'sorttype':'int',   'type': 'currency'},
        {'name': 'Amount',      'local':u'Всего',           'sorttype':'int',   'type': 'currency'},
        {'name': 'SortNO',      'local':u'Сорт',            'hidden': True},                                                           
    ]
    
    @classmethod
    def getColumns(cls, user):
        return [col for col in cls.columns if not col.get('Condition') or col['Condition'](user)] 
    
    calcFields = {
        'PriceSum':     lambda d: d.get('BasePrice', 0) * d.get('Quantity', 0),
        'VatSum':       lambda d: d.get('BasePrice', 0) * d.get('Quantity', 0) * d.get('VatPercent', 0),
        'Amount':       lambda d: d.get('BasePrice', 0) * d.get('Quantity', 0) + d.get('VatSum', 0),
        'Price':        lambda d: d.get('BasePrice', 0),
        'IsAvailable':  lambda d: u'Да' if d.get('IsAvailable') else '',
    }
    
    @classmethod
    def avaliableColumns(cls, user):
        return [col for col in cls.columns if not col.get('Condition') or col['Condition'](user)]
    
    @classmethod
    def itemFilter(cls, OrderID, FilterString, FilterID, PageSize, PageNumber, user):
        data = DocTradeLine.objects.exec_objects().cabinet_ItemFilter(OrderID, createFilter(FilterString), FilterID, PageSize, PageNumber)
        for d in data: [d.pop(col['name']) for col in cls.columns if col.get('Condition') and not col['Condition'](user)]
        return data
 
    @classmethod
    def itemFilterPagesCount(cls, FilterString, FilterID, PageSize):
        return DocTradeLine.objects.exec_value().cabinet_ItemFilterPagesCount(createFilter(FilterString), FilterID, PageSize) or 1
    
    @classmethod
    def orderHeader(cls, OID):
        ipdb.set_trace()
        result = (DocTradeLine.objects.exec_dictlist().cabinet_OrderGet(OID) + [{}])[0]
        return result
    
    @classmethod
    def conditionRulesGet(cls):
        return json.dumps(DocTradeLine.objects.exec_dictlist().cabinet_ConditionRulesGet())
    
    @classmethod
    def orderGetQuantityPrice(cls, OID):
        return json.dumps(dict([
          (d.pop('ItemID'), dict(d.items() + [('RowState', '')])) for d in DocTradeLine.objects.exec_dictlist().cabinet_OrderGetQuantityPrice(OID)   
        ]))

    @classmethod
    def saveOrder(cls, OID, items):
        " SAVE "
        cmd = ''
  
        #added/modified
        modified = [(ItemID, items[ItemID]['Quantity']) for ItemID in items if items[ItemID]['RowState'] in ('a', 'm')]
        if modified:
            cmd += "declare @tableM TableValueType; "
            cmd += '; '.join(map(lambda (x, y): "insert into @tableM(Object, Value) values (%d, %d) " %  (int(x), int(y, 0)), modified))
            cmd += "exec cabinet_OrderInsertUpdateLines %s, @tableM; " % int(OID)
        
        #deleted
        deleted = [ItemID for ItemID in items if items[ItemID]['RowState'] == 'd']
        if deleted:
            cmd += "declare @tableD TableValueType; "
            cmd += '; '.join(map(lambda x: "insert into @tableD(Object) values (%d) " %  int(x), deleted))
            cmd += "exec cabinet_OrderDeleteLines %s, @tableD; " % int(OID)
        
        if cmd:
            cmd = "begin tran; " + cmd + " commit;" 
            print cmd
            exec_sql(cmd)