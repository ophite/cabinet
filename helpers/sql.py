# coding=utf-8 
from django.db import models
# from django.utils import simplejson as json
import json
from datetime import date, datetime
from helpers.base import dictObject
import settings
import pyodbc
import ipdb
from decimal import Decimal


#Преобразователи типов: с sql в python и обратно
toSqlDict = {
    str:            lambda x: "'" + x + "'" if x != 'null' else x,
    None.__class__: lambda x: 'null',
    list:           lambda x: ', '.join(x),
    unicode:        lambda x: "'" + x + "'" if x != 'null' else x,
    datetime:       lambda x: "'" + x.date().isoformat().replace('-','') + "'",
    date:           lambda x: "'" + x.isoformat().replace('-','') + "'",
    'default':      lambda x: str(x),
}
toSql = lambda x: toSqlDict.get(x.__class__, toSqlDict['default'])(x)


fromSqlDict = {
    float:      lambda x: int(x) if x.is_integer() else x, #выкосить
    str:        lambda x: x.decode('cp1251'),
    datetime:   lambda x: x.strftime('%d.%m.%Y'),
    pyodbc.Row: lambda x: map(lambda item: fromSql(item), x),  
    Decimal:    lambda x: int(x),
    bytearray:  lambda x: x.decode('cp1251'),
    'default':  lambda x: x,
}
fromSql = lambda x: fromSqlDict.get(x.__class__, fromSqlDict['default'])(x)


columnNames = lambda model: [col.get('name') for col in model.columns] if hasattr(model, 'columns') else []


def get_objects(cursor, model):
    # ipdb.set_trace()
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
    # ipdb.set_trace()
    return json.dumps(get_objects(cursor, model))


def get_dictlist(cursor):
    # ipdb.set_trace()
    return [
        dict(zip([item[0] for item in cursor.description], fromSql(x))) for x in cursor.fetchall()
    ]


def get_value(cursor):
    # ipdb.set_trace()
    return fromSql(cursor.fetchall()[0][0])


def exec_procedure(proc_name, functor, *args):
    """ выполнение хранимой процедуры(proc_name)
        c параметрами(args), формат данных на выходе
        определяет функция functor
     """
    connection = ';'.join([k + '=' + v for k,v in settings.SQL_DATABASES.items()])
    con = pyodbc.connect(connection)
    # con.driver_needs_utf8 = False
    cur = con.cursor()
    
    # ipdb.set_trace()
    cmd = 'exec' + ' ' + proc_name + ' ' + ', '.join([toSql(x) for x in args])
    cmd = """ SET ANSI_NULLS, \
            QUOTED_IDENTIFIER, \
            CONCAT_NULL_YIELDS_NULL, \
            ANSI_WARNINGS, \
            ANSI_PADDING, \
            ARITHABORT ON; """  + cmd
    cmd = cmd.encode('cp1251')
    # ipdb.set_trace()
   
    print '-' * 150 + '\n' + cmd.split('; ')[-1] + '\n' + '-' * 150
    cur.execute(cmd)    
    ipdb.set_trace()
    items = functor(cur)
    con.commit()
    con.close()

    return items


def exec_sql(cmd):
    # ipdb.set_trace()
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


class curry:
    def __init__(self, func, *args, **kwargs):
        # self._func = func
        # self._params = args, 
        # self._pos = kwargs.get('pos', 0)
        self._func, self._params, self._pos = func, args, kwargs.get('pos', 0)
        # ipdb.set_trace()

    def __call__(self, *args):
        return self._func(*(args[:self._pos] + self._params + args[self._pos:]))
# def get_objects(cursor, model):
# def get_json(cursor, model):
# def get_dictlist(cursor):
# def get_value(cursor):


class CustomManager(models.Manager):
    "менеджер по работе с моделями"
    
    class _sqlmanager(object):
        def __init__(self, functor):
            # ipdb.set_trace()
            self.functor = functor
        def __getattribute__(self, name):
            # ipdb.set_trace()
            if name == 'functor':
                # ipdb.set_trace()
                return object.__getattribute__(self, name)
            else:
                return curry(exec_procedure, name, self.functor)
            
    def exec_json(self):
        # ipdb.set_trace()
        "возвращает объект класса _sqlmanager, выдающий json данные"
        new_get_json = curry(get_json, self.model, pos=1)
        return CustomManager._sqlmanager(new_get_json)
    
    def exec_objects(self):
        # ipdb.set_trace()
        "возвращает объекты класса _sqlmanager"
        new_get_objects = curry(get_objects, self.model, pos=1)
        return CustomManager._sqlmanager(new_get_objects)
    
    def exec_value(self):
        # ipdb.set_trace()
        return CustomManager._sqlmanager(get_value)
    
    def exec_dictlist(self):
        # ipdb.set_trace()
        return CustomManager._sqlmanager(get_dictlist)


class CodaDBError(pyodbc.DatabaseError):
    def __init__(self, message):
        pyodbc.DatabaseError.__init__(self)
        self.error_text = message[1][29:-25]