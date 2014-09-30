# coding=utf-8 
from codamodels import *
from datetime import datetime, date

from django.contrib import auth
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.core import serializers
from django.http import HttpResponseRedirect, Http404, HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.utils import simplejson as json

from functools import wraps
from helpers.base import dictObject, dateFormat, safeDict, safeConvert
from helpers.sql import toSql, CodaDBError

from models import *
import forms
import pyodbc
import xlrd



perPage = 20
#===================================================================================================
def login(request):
    if request.method == 'POST':
        form = forms.LoginForm(request.POST)
        user = auth.authenticate(username=form['username'].data, password=form['password'].data)
        
        if user and user.is_active:
            auth.login(request, user)
            
            #TODO: взглянуть трезвым взглядом
            d = UserProfile.objects.filter(user=request.user)
            if d: request.session['CustomerID'] = d[0].SubjectOID
            
            return HttpResponseRedirect(request.GET.get('next', '/'))
        else:
            msg = u'wrong password or username'
    else:
        form = forms.LoginForm()        
    return render_to_response('login.html', locals(), context_instance=RequestContext(request))

def logout(request):
    auth.logout(request)
    return HttpResponseRedirect('/accounts/login/')

def changePassword(request):
    if request.method == 'POST':
        form = forms.ChangePasswordForm(request.POST)
        if form.is_valid():
            request.user.set_password(form.cleaned_data['newPassword'])
            request.user.save()
            return HttpResponseRedirect('/')
    else:
        form = forms.ChangePasswordForm(initial={'username': request.user.username})
    return render_to_response('changePassword.html', {'form': form}, context_instance=RequestContext(request))


@login_required
def importExcel(request):
    if request.method == 'POST' and request.FILES.get('File', '') != '':
        sheet = xlrd.open_workbook(file_contents=request.FILES['File'].read()).sheets()[0]
        rows = [ sheet.row_values(i) for i in range(sheet.nrows) ]

        metadata = {
            'columns':sheet.ncols,
            'rows':sheet.nrows,
            'title':'My first excel sheet'
        }
    
        data = {}
        rowIndex = 0
        cellIndex = 0
        
        for row in rows:
            rowDict = {}
            for cell in row:
                rowDict['c'+str(cellIndex)] = {
                    'value':cell, 
                    'colspan': 'null',
                    'cl':''
                }
                cellIndex +=1
            
            data['r'+str(rowIndex)] = rowDict
            rowIndex +=1        
         
#        form = forms.ExcelImportForm(request.POST, request.FILES)
       # print json.dumps({'metadata':metadata, 'data':data})
        return excellsheet(request, data, metadata);
#        return HttpResponseRedirect('showExcelSheet/')
    
    return render_to_response('importExcel.html', {'form': forms.ExcelImportForm()}, context_instance=RequestContext(request))
#    return render_to_response('importExcel.html', {'form': forms.ExcelImportForm()}, context_instance=RequestContext(request))
#    return render_to_response('importExcel.html', {'sheet': json.dumps({'metadata':metadata, 'data':data}), 'form': forms.ExcelImportForm()}, context_instance=RequestContext(request))

@login_required
def excellsheet(request, data, metadata):
#    print request.FILES.get('File', '')
#    sheet = xlrd.open_workbook(file_contents=request.FILES['File'].read()).sheets()[0]
#    rows = [ sheet.row_values(i) for i in range(sheet.nrows) ]
#    print rows
#    metadata = {
#        'columns':sheet.ncols,
#        'rows':sheet.nrows,
#        'title':'My first excel sheet'
#    }
#
#    data = {}
#    rowIndex = 0
#    cellIndex = 0
#    for row in rows:
#        rowDict = {}
#        for cell in row:
#            rowDict['c'+str(cellIndex)] = {
#                'value':cell, 
#                'colspan': 'null',
#                'cl':''
#            }
#            cellIndex +=1
#        
#        data['r'+str(rowIndex)] = rowDict
#        rowIndex +=1  
#    return HttpResponseRedirect('/importExcel/excellsheet')


    return render_to_response('excellsheet.html',  {'sheet':json.dumps(dic)})
#    return render_to_response('excellsheet.html',  {'sheet':json.dumps({'metadata':metadata, 'data':data})})

def fill_session(func):
    def decorated(request, *args, **kwargs):
        order = request.session.get('Order')
        if not order: 
            return HttpResponseRedirect('/orderList/')
        
        request.session['data'] = safeDict(DocTradeLine.orderHeader(order))
        
        return func(request, *args, **kwargs)
    return wraps(func)(decorated)
#===================================================================================================
@login_required
@fill_session
def addOrderItems(request, OID=None):
    if request.session['data']['IsFinished']:        
        return HttpResponseRedirect('/editOrder/current')
    
    order = request.session['Order']
    c = {
        'columns': DocTradeLine.getColumns(request.user),
        'form': forms.SummaryOrderForm(),
        'rules': DocTradeLine.conditionRulesGet(),
        'headerForm': forms.HeaderOrderForm(initial=request.session['data']),
        'gridType': 'new',
        'quantities': DocTradeLine.orderGetQuantityPrice(order),
    }

    return render_to_response('editOrder.html', c, context_instance=RequestContext(request))

@login_required
@fill_session    
def currentOrder(request):
    order = request.session['Order']
    
    c = {
        'columns': DocTradeLine.getColumns(request.user),
        'form': forms.SummaryOrderForm(),
        'rules': DocTradeLine.conditionRulesGet(),
        'data': json.dumps(DocTradeLine.itemFilter(order, '', order, perPage, 1, request.user)),
        'total': DocTradeLine.itemFilterPagesCount('', order, perPage),
        'gridType': 'current',
        'headerForm': forms.HeaderOrderForm(initial=request.session['data']),
        'quantities': DocTradeLine.orderGetQuantityPrice(order),
        'delayLimits': [0, 7, 14, 21],
        'gridType': 'current',
        'readonly': request.session['data']['IsFinished'],            
    }
       
    return render_to_response('editOrder.html', c, context_instance=RequestContext(request))

@login_required
def newOrder(request):
    request.session.pop('Order', None)
    CustomerID = request.session.get('CustomerID')

    c = {
        'headerForm': forms.HeaderOrderForm(initial={'DocDate': date.today().strftime(dateFormat), 'DelayLimit': 0, 'CustomerID' : CustomerID, 'SubjectFullName' : Subject.get(CustomerID)[0]['FullName'] if CustomerID else ''}),
        'delayLimits': [0, 7, 14, 21],
        'gridType': 'current',
        'columns': DocTradeLine.getColumns(request.user),
        'IsNew': True,
    }
    
    return render_to_response('editOrder.html', c, context_instance=RequestContext(request))

@login_required    
def orderList(request):
    CustomerID = request.session.get('CustomerID')
    SubjectFullName = Subject.get(CustomerID)[0]['FullName'] if CustomerID else ''
    FilterString = request.GET.get('FilterString', '')
    BegDate = datetime.strptime(request.session.get('BegDate'), dateFormat) if request.session.get('BegDate') else 'null'
    EndDate = datetime.strptime(request.session.get('EndDate'), dateFormat) if request.session.get('EndDate') else 'null'
    WithFinished = request.session.get('WithFinished')
    total = Order.orderListPagesCount(BegDate, EndDate, FilterString, CustomerID or 'null', WithFinished, perPage)
        
    page = safeConvert(int, request.GET.get('page')) or 1
    page = 1 if page > total else page
    
    f = forms.HeaderOrderListForm(initial={
        'BegDate': request.session.get('BegDate'),
        'EndDate': request.session.get('EndDate'),
        'CustomerID': CustomerID,
        'SubjectFullName': SubjectFullName,
        'WithFinished' : WithFinished,
    })
    c = {
         'form': f, 
         'columns': Order.columns, 
         'data': json.dumps(Order.orderList(BegDate, EndDate, FilterString, CustomerID or 'null', WithFinished, perPage, page)),
         'total': total,
         'page': page
    }
    return render_to_response('orderList.html', c, context_instance=RequestContext(request))

@login_required
def editOrder(request, OID):
    request.session['Order'] = OID
    return currentOrder(request)
#===================================================================================================
@login_required
def itemFilter(request):
    if not request.session.get('Order'): 
        return HttpResponse(json.dumps({'data': {}, 'total': 1, 'rubrikator': 0 }))
    
    FilterString = request.session['FilterOrder'] = request.GET.get('FilterString', '')
    FillRubrikator = 'FilterID' in request.GET
    FilterID = request.GET.get('FilterID', 'null') if FillRubrikator else request.session['Order']
    
    return HttpResponse(json.dumps({
        'data': DocTradeLine.itemFilter(request.session['Order'], FilterString, FilterID, perPage, request.GET.get('page', 1), request.user),
        'total': DocTradeLine.itemFilterPagesCount(FilterString, FilterID, perPage) if not request.GET.get('page') else 0,
        'rubrikator': Filter.itemRubrikator(FilterString, 10) if not request.GET.get('page') and FillRubrikator else 0,
        'setPage': request.GET.get('page', 1),
    }))
    
@login_required
def subjectDepartments(request):
    return HttpResponse(json.dumps(Department.subjectDepartments(request.GET.get('SubjectID', 0))))

@login_required
def subjectFilter(request):
    return HttpResponse(json.dumps(Subject.filter(request.GET.get('FilterString', ''), 10)))

@login_required
def saveOrderHeader(request):
    f = forms.HeaderOrderForm(request.POST)
    if f.is_valid():
        d = dict(f.cleaned_data)
        if request.session.get('Order'):
            d.update({'OrderID': request.session['Order']})
            request.session['TST'] = str(Order.updateOrder(**d))
        else:
            request.session['Order'] = Order.createOrder(**d)
    
    return HttpResponse(json.dumps({'errors': f.errors}) if f.errors else '{}')     

#@login_required
#def saveGridLayout(request):
#    request.session.update({
#        'layoutgridcolumns' : json.loads(request.POST.get('layoutgridcolumns', '[]')),
#    })
#    
#    return HttpResponse('{}')

@login_required
def orderListData(request):
    request.session.update({
        'BegDate' : request.GET.get('BegDate'),
        'EndDate' : request.GET.get('EndDate'),
        'FilterList': request.GET.get('FilterString', ''),
        'CustomerID': request.GET.get('CustomerID'),
        'WithFinished': request.GET.get('WithFinished'),
    })
    
    BegDate = datetime.strptime(request.GET.get('BegDate'), dateFormat) if request.GET.get('BegDate') else 'null'
    EndDate = datetime.strptime(request.GET.get('EndDate'), dateFormat) if request.GET.get('EndDate') else 'null'
    FilterString = request.GET.get('FilterString', '')
    CustomerID = request.GET.get('CustomerID') or 'null'
    WithFinished = request.GET.get('WithFinished')
    
#    fl = open('log', 'w')
#    fl.write('FilterString')
#    fl.write(request.GET.get('FilterString', ''))
#    fl.write()
#    fl.write()
#    
    return HttpResponse(json.dumps({
        'data': Order.orderList(BegDate, EndDate, FilterString, CustomerID, WithFinished, perPage, request.GET.get('page', 1)),
        'total': Order.orderListPagesCount(BegDate, EndDate, FilterString, CustomerID, WithFinished, perPage) if not request.GET.get('page') else 0,
    }))

@login_required
def saveOrder(request, force_override=False):
    "сохраняет детали заказа"    
    
    order = request.session.get('Order')
    data = DocTradeLine.orderHeader(order)    
    
    tst, request.session['data']['TST'] = request.session['data']['TST'], str(data.get('TST'))   
    not_changed = request.session['data']['TST'] == tst
    
    if data.get('IsFinished'):
        return HttpResponse(json.dumps({'error': u'OrderFinished'}))
    
    if not_changed or force_override:
        DocTradeLine.saveOrder(order, json.loads(request.GET.get('items', '{}')))
        return HttpResponse('{}')
    else:
        return HttpResponse(json.dumps({'error': u'DataChanged'}))
    
@login_required
def selectOrder(request, action, OID):
    request.session['Order'] = OID
    return HttpResponseRedirect('/editOrder/' + action)

@login_required
def saveFilter(request, form, filter):
    request.session['FilterList' if form == 'list' else 'FilterOrder'] = filter
    return HttpResponse('')

@login_required
def finishOrder(request, OID=None, page=1):
    order = OID or request.session['Order']
    
    if not DocTradeLine.orderHeader(order)['IsFinished']:
        try: 
            if 'Order' in request.session: request.session.pop('Order')
            Order.finishOrder(order)
        except pyodbc.DatabaseError as inst:
            return HttpResponse(json.dumps({'error':CodaDBError(inst).error_text}))
    
    return HttpResponse('{}')

@login_required
def deleteOrder(request, OID=None, page=1):
    order = OID or request.session['Order']
    if not DocTradeLine.orderHeader(order)['IsFinished']:
        if 'Order' in request.session: request.session.pop('Order')
        Order.deleteOrder(order)
    
    return HttpResponseRedirect('/orderList/?page=%s' % page)

@login_required
def manageEntrance(request):
    return HttpResponseRedirect('/editOrder/add/' if request.session.get('Order') and request.session.get('Data') else '/orderList/')