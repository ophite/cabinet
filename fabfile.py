# from __future__ import absolute_import
# system
import sys
import os 
# custom
from fabric.api import local, settings, cd, lcd, run, env, prefix
from fabric.colors import green
from fabric.context_managers import shell_env

project_path = '~/svn/cabinet'
project_path_virtualenv = 'env'


def isLocalClient():
    '''
    check current application state (DEBUG)
    '''
    project_settings_path_full = os.getcwd() + '/Client/client_app'
    if not sys.path.__contains__(project_settings_path_full):
        sys.path.append(project_settings_path_full)
        from settings import DEBUG
    return DEBUG

def djangoOn():
    '''
    run django app
    '''
    print (green('LOCAL django start'))
    local(' && '.join(['cd ' + project_path + '/' + project_path_virtualenv, 
                       '. bin/activate', 
                       'cd ' + project_path,
                       'reset', 
                       'python manage.py runserver']))

def django2On():
    '''
    run django app
    '''
    print (green('LOCAL django start'))
    local(' && '.join(['cd ' + project_path + '/' + project_path_virtualenv, 
                       '. bin/activate', 
                       'cd ' + project_path,
                       'reset', 
                       'python manage.py runserver 10.8.168.50:8000']))

def djangoOff():
    '''
    When killing supervisord not killing pos_client (flask app)
    '''
    local('ps -ef | grep python')

def pip():
    '''
    install requiments Client with pip
    '''
    print (green('install requiments with pip'))
    if isLocalServer():
        local(' && '.join(['cd ' + project_path + '/' + project_path_virtualenv, 
                           '. bin/activate', 
                           'cd ' + project_path, 
                           'pwd && pip install -r requirements.txt']))
