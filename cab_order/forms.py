# coding=utf-8 
from django import forms
from django.utils.html import conditional_escape
from django.utils.safestring import mark_safe
from django.forms.widgets import Widget, Textarea
from django.utils.encoding import force_unicode#, StrAndUnicode
from django.contrib.auth.models import User
from django.core import validators
from datetime import datetime
from helpers.sql import toSqlDict
from helpers.base import dateFormat
    
class CodaForm(forms.Form):
    def __init__(self, *args, **kwargs):
        super(CodaForm, self).__init__(*args, **kwargs)
        if hasattr(self, 'read_only_fields'):
            for field in self.read_only_fields:
                self.fields[field].widget.attrs['readonly'] = True

def flatatt(attrs):
    return u''.join([u' %s="%s"' % (k, conditional_escape(v)) for k, v in attrs.items()])

class Label(Widget):    
    def render(self, name, value, attrs=None):
        if value is None: value = ''
        final_attrs = self.build_attrs(attrs, name=name)
        return mark_safe(u'<label%s>%s</label>' % (flatatt(final_attrs),
                conditional_escape(force_unicode(value))))
        
#===================================================================================================
class LoginForm(CodaForm):
    username = forms.CharField(max_length=150, label=u'Логин')
    password = forms.CharField(widget=forms.PasswordInput(), max_length=500, label=u'Пароль')

class ChangePasswordForm(CodaForm):
    username = forms.CharField(max_length=150, label=u'Логин')
    oldPassword = forms.CharField(widget=forms.PasswordInput(), max_length=500, label=u'Пароль')
    newPassword = forms.CharField(widget=forms.PasswordInput(), max_length=500, label=u'Новый пароль')
    confirmPassword = forms.CharField(widget=forms.PasswordInput(), max_length=500, label=u'Подтвердите пароль')
    
    def clean_username(self):
        data = self.cleaned_data['username']
        if not User.objects.filter(username=data):
            raise forms.ValidationError(u"Такого пользователя нет")
        return data
    
    def clean_oldPassword(self):
        data = self.cleaned_data['oldPassword']
        if 'username' in self.cleaned_data:
            u = User.objects.filter(username=self.cleaned_data['username'])[0]
            if not u.check_password(data):
                raise forms.ValidationError(u"Введите правильный старый пароль")
        return data
    
    def clean_confirmPassword(self):
        if 'newPassword' in self.cleaned_data and self.cleaned_data['newPassword'] != self.cleaned_data['confirmPassword']:
            raise forms.ValidationError("Password should sovpadat")
        
class SummaryOrderForm(CodaForm):
    discount = forms.DecimalField(label=u'Скидка', decimal_places=2, widget=Label, initial=0)
    basePriceSum = forms.DecimalField(label=u'Сумма по прайсу', decimal_places=2, widget=Label)
    discountSum = forms.DecimalField(label=u'Сумма скидки', decimal_places=2, widget=Label)
    priceSum = forms.DecimalField(label=u'Сумма без НДС', decimal_places=2, widget=Label)
    vatSum = forms.DecimalField(label=u'Сумма НДС', decimal_places=2, widget=Label)
    amount = forms.DecimalField(label=u'Сумма c НДС', decimal_places=2, widget=Label)
                                
class HeaderOrderListForm(CodaForm):
    BegDate = forms.DateField(label=u'Период с')
    EndDate = forms.DateField(label=u'Период по')
    # CustomerID = forms.IntegerField(label=u'Контрагент')
    CustomerID = forms.CharField(label=u'Контрагент')
    WithFinished = forms.BooleanField(label=u'Показывать завершенные')

class HeaderOrderForm(CodaForm):
    DocCode = forms.IntegerField(label=u'Заказ', required=False)
    DocDate = forms.DateField(label=u'Дата', input_formats=['%d.%m.%Y'])
    CustomerID = forms.CharField(label=u'Наименование контрагента')
    DepartmentID = forms.IntegerField(label=u'Адрес', required=False)
    DelayLimit = forms.IntegerField(label=u'Отсрочка')
    Comments = forms.CharField(max_length=128, label=u'Коментарий', widget=Textarea, required=False)

    read_only_fields = ['DocCode']
    
class ExcelImportForm(CodaForm):
    DocType = forms.ChoiceField(label=u'Тип кода документа')
    File = forms.FileField(label=u'Файл')