# coding=utf-8 
from django.db import models
from functional import curry
from django.utils import simplejson as json
from datetime import date, datetime
from helpers.base import dictObject
import settings
import pyodbc

#===================================================================================================
#Преобразователи типов: с sql в python и обратно

toSqlDict = {
    str: lambda x: "'" + x + "'" if x != 'null' else x,
    None.__class__: lambda x: 'null',
    list: lambda x: ', '.join(x),
    unicode: lambda x: "'" + x + "'" if x != 'null' else x,
    datetime: lambda x: "'" + x.date().isoformat().replace('-','') + "'",
    date: lambda x: "'" + x.isoformat().replace('-','') + "'",
    'default': lambda x: str(x),
}
toSql = lambda x: toSqlDict.get(x.__class__, toSqlDict['default'])(x)

fromSqlDict = {
    float: lambda x: int(x) if x.is_integer() else x, #выкосить
    str: lambda x: x.decode('cp1251'),
    datetime: lambda x: x.strftime('%d.%m.%Y'),
    pyodbc.Row: lambda x: map(lambda item: fromSql(item), x),  
    'default': lambda x: x,
}
fromSql = lambda x: fromSqlDict.get(x.__class__, fromSqlDict['default'])(x)

columnNames = lambda model: [col.get('name') for col in model.columns] if hasattr(model, 'columns') else []

#===================================================================================================
def get_objects(cursor, model):
    fields = [(i, x[0]) for i, x in enumerate(cursor.description) if x[0] in columnNames(model)]
    items = []
    while 1:
        for x in cursor.fetchall():
            values = {}
            for i, column in fields:
                values[column] = fromSql(x[i])
                
                
            if hasattr(model, 'calcFields'):
                values.update(dict([
                    (k, f(values)) for k, f in model.calcFields.items() 
                ]))
                
            items.append(values)
        if not cursor.nextset():
            break;
    return items

def get_json(cursor, model):
    " по курсору запроса возвращает данные в формате json "
    return json.dumps(get_objects(cursor, model))

def get_dictlist(cursor):
    return [
        dict(zip(
            [item[0] for item in cursor.description], fromSql(x)
        ))
        for x in cursor.fetchall()
    ]

def get_value(cursor):
    return fromSql(cursor.fetchall()[0][0])

def exec_procedure(proc_name, functor, *args):
    """ выполнение хранимой процедуры(proc_name)
        c параметрами(args), формат данных на выходе
        определяет функция functor
     """
    connection = ';'.join([k + '=' + v for k,v in settings.SQL_DATABASES.items()])
    con = pyodbc.connect(connection)
    cur = con.cursor()
    
    cmd = 'exec' + ' ' + proc_name + ' ' + ', '.join([toSql(x) for x in args])
    cmd = """ SET ANSI_NULLS, \
            QUOTED_IDENTIFIER, \
            CONCAT_NULL_YIELDS_NULL, \
            ANSI_WARNINGS, \
            ANSI_PADDING, \
            ARITHABORT ON; """  + cmd
    cmd = cmd.encode('cp1251')
    
    print '-' * 150 + '\n' + cmd.split('; ')[-1] + '\n' + '-' * 150
    cur.execute(cmd)    
                
    items = functor(cur)
    con.commit()
    con.close()
    return items

def exec_sql(cmd):
    connection = ';'.join([k + '=' + v for k,v in settings.SQL_DATABASES.items()])
    con = pyodbc.connect(connection)
    cur = con.cursor()
    
    cmd = """ SET ANSI_NULLS, \
            QUOTED_IDENTIFIER, \
            CONCAT_NULL_YIELDS_NULL, \
            ANSI_WARNINGS, \
            ANSI_PADDING, \
            ARITHABORT ON; """  + cmd
    cmd = cmd.encode('cp1251')
    cur.execute(cmd)
    con.commit()
    con.close()

#===================================================================================================
class CustomManager(models.Manager):
    "менеджер по работе с моделями"
    
    class _sqlmanager(object):
        def __init__(self, functor):
            self.functor = functor
        def __getattribute__(self, name):
            if name == 'functor':
                return object.__getattribute__(self, name)
            else:
                return curry(exec_procedure, name, self.functor)
            
    def exec_json(self):
        "возвращает объект класса _sqlmanager, выдающий json данные"
        new_get_json = curry(get_json, self.model, pos=1)
        return CustomManager._sqlmanager(new_get_json)
    
    def exec_objects(self):
        "возвращает объекты класса _sqlmanager"
        new_get_objects = curry(get_objects, self.model, pos=1)
        return CustomManager._sqlmanager(new_get_objects)
    
    def exec_value(self):
        return CustomManager._sqlmanager(get_value)
    
    def exec_dictlist(self):
        return CustomManager._sqlmanager(get_dictlist)

class CodaDBError(pyodbc.DatabaseError):
    def __init__(self, message):
        pyodbc.DatabaseError.__init__(self)
        self.error_text = message[1][29:-25]
