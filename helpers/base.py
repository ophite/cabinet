# coding=utf-8 
from datetime import datetime
from django.forms.fields import *
from django.forms import fields

safeDict = lambda d: [d.update({k: str(v)}) for k, v in d.items() if v.__class__ == buffer] and d
dateFormat = '%d.%m.%Y'
IIF = lambda condition, res1, res2: res1 if condition else res2
convert = lambda f: lambda x: IIF(x, f(x), None)

def safeConvert(t, x):
    try:
        return t(x)
    except:
        return None

class dictObject(object):
    """
        Словарь через точку
    """
    def __init__(self):
        self.dict = {}
        
    def __getattr__(self, name):
        if name == 'dict':
            return object.__getattribute__(self, name)
        else:
            return self.dict.get(name)
        
    def __setattr__(self, name, value):
        if name != 'dict':
            self.dict[name] = value
        else:
            return object.__setattr__(self, name, value)

def DictByForm(request, formClass):
    """
        словарь параметров по форме
    """
    toDjDict = {
        DateField: lambda x: datetime.strptime(x, '%d.%m.%Y'),
        fields.CharField: lambda x: x,
        str: lambda x: x,
        'default': lambda x: convert(int)(x),
    }
    toDj = lambda t: toDjDict.get(t.__class__, toDjDict['default'])
    
    d = formClass.FieldTypeDict if hasattr(formClass, 'FieldTypeDict') else {}
    #d =  if 'FieldTypeDict' in dir(formClass) else {}
    d = reduce(lambda res, (k, v): res + [(x, v) for x in k], d.items(), [])
    
    return dict([
        (name, toDj(t)(request.GET.get('id_' + name))) 
        for name, t in formClass.base_fields.items() + d
    ])
    
        
def createFilter(FilterString):
    return '*" and '.join(['"' + x for x in FilterString.split()]) + '*"' if len(FilterString) > 1 else '*'

def toAutocomplete(dict):
    return [{'id':x.get('OID',''),'value':x.get('FullName',''), 'label':x.get('FullName','')} for x in dict] 