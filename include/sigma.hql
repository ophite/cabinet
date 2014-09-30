//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#ifndef _SIGMA_HQL_
#define _SIGMA_HQL_

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define INFO(_c, _s1, _s2) print '--  ' + _c +  space(1 - len(_c)) + '  ' + _s1 + space(15 - len(_s1)) + ': ' + _s2

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define SYSTEM_NAME             (UPPER(cast(SERVERPROPERTY('ServerName') as varchar(128)) + '.' + DB_NAME()))

#define SYSTEM_CLASSES          ('Sys', 'Util')

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define CID_SHIFT               cast(1000000000000 as bigint)
#define CLASS_TABLE(_x)         ('c_' + _x)
#define CLASS_VIEW(_x)          ('z_' + _x)

#define OID_2_ID(_x)            cast(((_x) - cast(((_x) / CID_SHIFT) as bigint) * CID_SHIFT) as int)
#define ID_2_DIRECTORY(_x)      cast((8 * CID_SHIFT + (_x)) as bigint)
#define ID_2_DOCUMENT(_x)       cast((198 * CID_SHIFT + (_x)) as bigint)

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define OBJECT_TABLE(_x)        ('o_' + _x)
#define OBJECT_VIEW(_x)         (_x)
#define ROOT_OBJECT_TABLE(_x)   (select object_table from classes where cid = (select root_cid from classes where class_name = _x))

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define CLASS_NAME(_cid)        (select class_name from classes where cid = (_cid))
#define CLASS_ID(_class_name)   (select cid from classes where class_name = (_class_name))

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define METHOD(_name)           ('m_' + _name)
#define CLASS_METHOD(_name)     ('cm_' + _name)

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define METHOD_SUBSTRING(_x)           substring(_x, 3, 64)
#define CLASS_METHOD_SUBSTRING(_x)     substring(_x, 4, 64)

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define FOREIGN_PATTERN         'fk[_][co][_][0-9][0-9][0-9][0-9][0-9][0-9][_][co][_][0-9][0-9][0-9][0-9][0-9][0-9][_]%'
#define METHOD_PATTERN          'm[_]%'
#define CLASS_METHOD_PATTERN    'cm[_]%'

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define SID(_n) (replicate('0', 6 - len(cast(_n as varchar(16)))) + cast(_n as varchar(16)))

#define IS_VIRTUAL(_method_name) (_method_name like 'zp[_]%')

// change oid/cid to OID/CID
//#define FMT(_name)              IIF(_name in ('oid', 'cid'), upper(_name), _name)

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define CIRCULAR_REFERENCE(_class_name, _parent_name) \
    (exists(select * from sys_BaseClasses where class_name = _parent_name and base_class_name = _class_name))

#define CLASS_EXISTS(_class_name) (exists(select * from classes where class_name = _class_name))

// exists in class tree from root to leaf
#define PROPERTY_DEFINED_IN_CLASS_TREE(_class_name, _property_name) \
    (exists(select * from sys_Properties where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name) and name = _property_name))

#define CLASS_PROPERTY_DEFINED_IN_CLASS_TREE(_class_name, _property_name) \
    (exists(select * from sys_ClassProperties where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name) and name = _property_name))

#define METHOD_DEFINED_IN_CLASS_TREE(_class_name, _method_name) \
    (exists(select * from sys_Methods where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name) and name = _method_name))

#define CLASS_METHOD_DEFINED_IN_CLASS_TREE(_class_name, _method_name) \
    (exists(select * from sys_ClassMethods where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name) and name = _method_name))

// exists in this or base classes
#define PROPERTY_EXISTS(_class_name, _property_name) \
    (exists(select * from sys_Properties where class_name =_class_name and name = _property_name))

#define CLASS_PROPERTY_EXISTS(_class_name, _property_name) \
    (exists(select * from sys_ClassProperties where class_name =_class_name and name = _property_name))

#define METHOD_EXISTS(_class_name, _method_name) \
    (exists(select * from sys_Methods where class_name =_class_name and name = _method_name))

#define CLASS_METHOD_EXISTS(_class_name, _method_name) \
    (exists(select * from sys_ClassMethods where class_name =_class_name and name = _method_name))

#define METHOD_DEFINED_IN_CHILDREN(_class_name, _method_name) \
    ( \
    (not METHOD_EXISTS(_class_name, _method_name)) and \
    (exists(select * from sys_Methods where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name and base_class_name <> class_name) and name = _method_name)) \
    )

#define CLASS_METHOD_DEFINED_IN_CHILDREN(_class_name, _method_name) \
    ( \
    (not CLASS_METHOD_EXISTS(_class_name, _method_name)) and \
    (exists(select * from sys_ClassMethods where class_name in (select class_name from sys_BaseClasses where base_class_name = _class_name and base_class_name <> class_name) and name = _method_name)) \
    )

// exists in own class/object table
#define PROPERTY_DEFINED_IN_OWN_TABLE(_class_name, _property_name) \
    (exists(select * from sys_Properties where class_name =_class_name and name = _property_name and base_cid = cid))

#define CLASS_PROPERTY_DEFINED_IN_OWN_TABLE(_class_name, _property_name) \
    (exists(select * from sys_ClassProperties where class_name =_class_name and name = _property_name and base_cid = cid))

#define METHOD_DEFINED_IN_OWN_TABLE(_class_name, _method_name) \
    (exists(select * from sys_Methods where class_name =_class_name and name = _method_name and base_cid = cid))

#define CLASS_METHOD_DEFINED_IN_OWN_TABLE(_class_name, _method_name) \
    (exists(select * from sys_ClassMethods where class_name =_class_name and name = _method_name and base_cid = cid))

#define FOREIGN_EXISTS(_foreign_name) \
    (exists(select * from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = _foreign_name))

#define IS_REFERENCE(_class_name, _property_name) \
    (exists(select * from Sys_References where class_name = _class_name and property = _property_name and type = 'oo'))

#define IS_CLASS_REFERENCE(_class_name, _property_name) \
    (exists(select * from Sys_References where class_name = _class_name and property = _property_name and type = 'oc'))

#define IS_STATIC_REFERENCE(_class_name, _property_name) \
    (exists(select * from Sys_References where class_name = _class_name and property = _property_name and type = 'co'))

#define IS_STATIC_CLASS_REFERENCE(_class_name, _property_name) \
    (exists(select * from Sys_References where class_name = _class_name and property = _property_name and type = 'cc'))

#define IS_A(_class_name, _base_class_name) \
    (exists(select * from Sys_BaseClasses where class_name = _class_name and base_class_name = _base_class_name))

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
// (cid << 48) | oid
#define LONG_ID(_cid, _oid) cast(cast(_cid  as binary(2)) + cast(_oid as binary(6)) as bigint)

#define CID_FROM_ID(_x)  cast(substring(_x, 1, 2) as int)
*/

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#endif
