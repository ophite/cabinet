# Django settings for cabinet project.
import os

DEBUG = True
TEMPLATE_DEBUG = DEBUG
PRODUCTION = False

ADMINS = (
    # ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3', # Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'db/local.db' if not PRODUCTION else '/home/projects/cabinet/db/django.db', # 'db/django.db',  # Or path to database file if using sqlite3.
        'USER': '',                      # Not used with sqlite3.
        'PASSWORD': '',                  # Not used with sqlite3.
        'HOST': '',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '',                      # Set to empty string for default. Not used with sqlite3.
    }
}
        # 'unicode_results': False,

# SQL_DATABASES = {
#     'PWD':'Qq123456',
#     'UID':'sa',
#     'DATABASE': 'coda',
#     'DRIVER': '{FreeTDS}',
#     'TDS_VERSION':'7',
#     'SERVER': 'kib17',
#     'CHARSET': 'utf-8',
# }

SQL_DATABASES = {
    'DSN':'sqlserverdatasource',
    'UID':'sa',
    'PWD': 'Qq123456',
    'DATABASE': 'coda',
}
 
# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'Europe/Kiev'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'ua-uk'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale
USE_L10N = True

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = '' # '/usr/local/lib/python2.6/dist-packages/django/contrib/admin/media/'

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com/media/", "http://example.com/media/"
MEDIA_URL = '' #'https://pydev.asnova.com/static/admin/'

# Absolute path to the directory that holds static files.
# Example: "/home/media/media.lawrence.com/static/"
#STATIC_ROOT = '/home/pydev/trunk/pydev/cabinet/content/'

# URL that handles the static files served from STATIC_ROOT.
# Example: "http://media.lawrence.com/static/"
#STATIC_URL = 'https://pydev.asnova.com/content/'
# STATIC_URL = 'C:\trunk\cabinet\content'

import os
path_server = os.path.dirname(os.path.realpath(__file__))
# path_root = path_server.split('/Server')[0]
STATIC_URL = path_server + '/content/'

# URL prefix for admin media -- CSS, JavaScript and images.
# Make sure to use a trailing slash.
# Examples: "http://foo.com/static/admin/", "/static/admin/".
#ADMIN_MEDIA_PREFIX = 'https://pydev.asnova.com/static/admin/' 
#ADMIN_MEDIA_PREFIX = '/usr/local/lib/python2.6/dist-packages/django/contrib/admin/media/' 

# A list of locations of additional static files
STATICFILES_DIRS = (
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = '!fd%q!b^o7h!xk+*6iawhh&j&1=c8)6#qg*v1$u&cq8f$sl30_'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
#     'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
)

ROOT_URLCONF = 'urls'

TEMPLATE_DIRS = (
    'templates',
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

INSTALLED_APPS = (
    'cab_order',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Uncomment the next line to enable the admin:
    'django.contrib.admin',
    # Uncomment the next line to enable admin documentation:
    # 'django.contrib.admindocs',
)

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request':{
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}
MEDIA_CONTENT = os.path.join(os.path.dirname(__file__), 'content')
MEDIA_IMAGES = os.path.join(os.path.dirname(__file__), 'content/css/ui-darkness/images')
TEMPLATE_CONTEXT_PROCESSORS = (
    "django.contrib.auth.context_processors.auth",
    "django.core.context_processors.debug",
    "django.core.context_processors.i18n",
    "django.core.context_processors.media",
    "django.contrib.messages.context_processors.messages",
    "helpers.context_processors.custom_processor",
)

AUTHENTICATION_BACKENDS = (
    'helpers.backends.ActiveDirectoryBackend',
    'django.contrib.auth.backends.ModelBackend',
)

AD_LDAP_URL = 'ldap://savserv.kiev.ua'
