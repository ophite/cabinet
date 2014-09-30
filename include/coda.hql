--=============================================================================================================
--  CODA specific macroses
--=============================================================================================================

#ifndef __CODA_HQL__
#define __CODA_HQL__

#ifndef __MACROSES_HQL__
#include "macroses.hql"
#endif

#ifndef __MESSAGES_HQL__
#include "messages.hql"
#endif

#ifndef __CONSTANTS_HQL__
#include "constants.hql"
#endif

if db_name() = 'coda' and @@servername = 'kia06' and system_user not in ('TRITON\victor', 'TRITON\pastushenko.m', 'TRITON\sasha', 'TRITON\perevertaylo.y', 'TRITON\obolonsky.m', 'TRITON\pavuk.v')
    raiserror('YOU DONT HAVE PERMNISSIONS TO COMPILE ON WORKING CODA SYSTEM', 16, 1);

--=============================================================================================================

#define CONTAINER_LOCK(container, id)           if (@@trancount > 0) begin                                                                                                                                         \
                                                    declare VARIABLE(@Lock_) int, VARIABLE(@RootID_) bigint;                                                                                                       \
                                                    if (id is null) begin                                                                                                                                          \
                                                        set VARIABLE(@Lock_) = (select count(*) from container with (rowlock xlock) where OID in (select OID from container with (nolock) where OwnerID is null)); \
                                                    end else begin                                                                                                                                                 \
                                                        exec Directory_CalcRootID id, VARIABLE(@RootID_) output;                                                                                                   \
                                                        set VARIABLE(@Lock_) = (select count(*) from container with (rowlock xlock) where OID in (VARIABLE(@RootID_)));                                            \
                                                    end;                                                                                                                                                           \
                                                end

#define DOCUMENT_LOCK(id)                       if (@@trancount > 0) begin                                                                                                                                         \
                                                    declare VARIABLE(@Lock_) int;                                                                                                                                  \
                                                    set VARIABLE(@Lock_) = (select count(*) from Document with (rowlock xlock) where OID = id);                                                                    \
                                                end

#define DOCUMENTS_LOCK(ids)                     if (@@trancount > 0) begin                                                                                                                                         \
                                                    declare VARIABLE(@Lock_) int;                                                                                                                                  \
                                                    set VARIABLE(@Lock_) = (select count(*) from Document with (rowlock xlock) where OID in (select Object from ids));                                                                    \
                                                end

#define DIRECTORY_LOCK(ids)                     if (@@trancount > 0) begin                                                                                                                                         \
                                                    declare VARIABLE(@Lock_) int;                                                                                                                                  \
                                                    set VARIABLE(@Lock_) = (select count(*) from Directory with (rowlock xlock) where OID in ids);                                                                 \
                                                end

// o - object
#define CODA_FIELDS(o)                          o.OID, o.CID, o.Comments, o.DelDate, o.FullName, o.IconIndex, o.IsDeleted, o.Name, o.OwnerID, o.ParentID, o.SID, o.GUID, o.TST

// for many-to-many link
#define TO_CODA_FIELDS(l, o, p)                 l.*, Comments = cast(null as varchar(128)), o.DelDate, FullName = cast(null as varchar(128)), o.GUID, IconIndex = isnull(o.IconIndex, -1), IsDeleted = isnull(o.IsDeleted, 0), Name = cast('' as varchar(128)), OwnerID = p.OID, ParentID = p.OID, p.SID, o.TST
#define TO_CODA_DOCLINE_FIELDS(l, o)            l.*, Comments = cast(null as varchar(128)), o.DelDate, FullName = cast(null as varchar(128)), o.GUID, o.IsDeleted, Name = cast('' as varchar(128)), OwnerID = l.DocID, ParentID = l.DocID, o.SID
#define TO_CODA_DOCGROUPLINE_FIELDS(l, o)       l.*, o.DelDate, FullName = cast(null as varchar(128)), o.GUID, o.IsDeleted, Name = cast('' as varchar(128)), OwnerID = l.DocID, ParentID = l.DocID, o.SID
#define TO_CODA_DOCBANKEXTRACTLINE_FIELDS(l, o) l.*, o.DelDate, FullName = cast(null as varchar(128)), o.GUID, o.IsDeleted, Name = cast('' as varchar(128)), OwnerID = l.DocID, ParentID = l.DocID, o.SID

// l - link, o - object, p - parent
#define TO_CODA_FIELDS_LINK(l, o, p)            l.*, Comments = cast(null as varchar(128)), o.DelDate, FullName = cast(null as varchar(128)), o.IsDeleted, Name = cast('' as varchar(128)), p.SID
#define TO_CODA_FIELDS_RECODE(l, o, p)          l.*, Comments = cast(null as varchar(128)), o.DelDate, FullName = cast(null as varchar(128)), Name = cast('' as varchar(128)), p.SID
#define TO_CODA_FIELDS_PACKING(p, i)            p.*, FullName = cast(null as varchar(128)), OwnerID = p.ItemID, ParentID = p.ItemID, i.SID, i.TST

#define TO_CODA_FIELDS_ENUM(o)                  o.*, Comments = cast(null as varchar(128)), DelDate = cast(null as datetime), IconIndex = cast(-1 as int), IsDeleted = cast(0 as bit), ParentID = cast(null as bigint), OwnerID = cast(null as bigint), SID = cast(31415926 as bigint)
#define TO_CODA_FIELDS_ADDRESS(o, p)            o.*, OwnerID = o.ParentID, SID = p.SID
#define TO_CODA_FIELDS_STATUSUSAGE(o, p)        o.*, Comments = cast(null as varchar(128)), p.DelDate, FullName = cast(null as varchar(128)), p.IconIndex, p.IsDeleted, Name = cast('' as varchar(128)), OwnerID = p.OID, ParentID = p.OID, p.SID, p.GUID, p.TST
#define TO_CODA_FIELDS_EMPLOYEESHEET(o, p)      o.*, p.DelDate, p.FullName, p.IconIndex, p.IsDeleted, p.Name, OwnerID = p.OID, ParentID = p.OID, p.SID, p.GUID

#define TO_CODA_FIELDS_FULL                     CID = cast(-1 as int), Comments = cast(null as varchar(128)), DelDate = cast(null as datetime), FullName = cast(null as varchar(128)), GUID = cast(null as uniqueidentifier), IconIndex = cast(-1 as int), IsDeleted = cast(0 as bit), Name = cast('' as varchar(128)), OwnerID = cast(null as bigint), ParentID = cast(null as bigint), SID = cast(null as bigint), TST = cast(null as binary(8))
#define CODA_FIELDS_ISIS(l, o, p)               l.OID, l.CID, o.Comments, o.DelDate, o.FullName, l.IconIndex, o.IsDeleted, o.Name, l.OwnerID, l.ParentID, p.SID, o.GUID, l.TST

#define JOURNAL_DOC_FIELDS(d)                   d.OID, d.CID, d.Amount, d.BranchID, d.ChangeDate, d.Comments, d.CreateDate, d.DelDate, d.DocCode, d.DocDate, d.EmployeeID, d.DeliverID, d.ReceiverID, d.FirmID, d.FullName, d.GUID, d.IconIndex, d.IsDeleted, d.Name, d.NodeID, d.RGB, d.SourceDocID, d.DocGroupID, d.DocGroupPosition, d.TST
#define JOURNAL_DOCTRANSIT_FIELDS(d)            d.OID, d.CID, d.Amount, d.BranchID, d.ChangeDate, d.Comments, d.CreateDate, d.DelDate, d.DocCode, isnull(d.ArrivalPlanDate, d.ArrivalRatedDate) as DocDate, d.EmployeeID, d.DeliverID, d.ReceiverID, d.FirmID, d.FullName, d.GUID, d.IconIndex, d.IsDeleted, d.Name, d.NodeID, d.RGB, d.SourceDocID, d.DocGroupID, d.DocGroupPosition, d.TST
#define TO_JOURNAL_DOC_FIELDS                   CID = cast(-1 as int), Amount = 0, BranchID = null, ChangeDate = cast(null as datetime), Comments = cast(null as varchar(128)), CreateDate = cast(null as datetime), DelDate = cast(null as datetime), DocCode = cast(null as varchar(32)), DocDate = MIN_DATE, EmployeeID = cast(null as bigint), DeliverID = cast(null as bigint), ReceiverID = cast(null as bigint), FirmID = cast(-1 as bigint), FullName = cast(null as varchar(128)), GUID = cast(null as uniqueidentifier), IconIndex = cast(-1 as int), IsDeleted = cast(0 as bit), Name = cast('' as varchar(128)), NodeID = cast(null as bigint), RGB = 'G', SourceDocID = cast(null as bigint), DocGroupID = cast(null as bigint), DocGroupPosition = cast(null as bigint), TST = cast(null as binary(8))
#define DOCUMENT_FIELDS(d)                      d.*, OwnerID = d.FirmID, ParentID = d.FirmID, SID = (select SID from o_Directory where OID = d.FirmID)
#define TO_DOCTRADE_FIELDS(d)                   d.CID, d.Amount, d.BranchID, d.ChangeDate, d.Comments, d.CostSum, d.CreateDate, d.DelDate, d.DeliverID, d.DocCode, d.DocDate, d.DocGroupID, d.DocGroupPosition, d.EmployeeID, d.FilialID, d.FirmID, d.FullName, d.GUID, d.IconIndex, d.IsDeleted, d.Name, d.NodeID, d.PriceSum, d.PrintComments, d.ReceiverID, d.RevenueID, d.RGB, d.SourceDocID, d.TaxCode, d.TaxDate, d.TST, d.VatPercent, d.VatSum, OwnerID = d.FirmID, ParentID = d.FirmID, SID = (select SID from o_Directory where OID = d.FirmID)


#define SUMMARY_TABLE                           OID bigint, CID int, Comments varchar(128), DelDate datetime, FullName varchar(128), GUID uniqueidentifier, IconIndex int, IsDeleted bit, Name varchar(128), OwnerID bigint, ParentID bigint, SID bigint, TST binary(8), ItemID bigint, Ordered money, Quantity money, Weight money, WeightNetto money, Volume money, Pallet money, SalepointCount bigint, VehicleWeight money, VehicleVolume money, VehiclePallet money, Cases money, RestCases money, Pack money, RestPack money, Layer money, MSU money, PurePall money, PureCase money, PurePack money, RetPureCase money

#define DECLARE_INTERFACE_CLASS_PROPERTIES(c)   begin                                                                                     \
                                                    exec Sys_AddClassProperty   c,    'Service',          'varchar(128) null';            \
                                                                                                                                          \
                                                    exec Sys_AddClassProperty   c,    'DefaultCastClass', 'varchar(128) null';            \
                                                    exec Sys_AddClassProperty   c,    'ParentClasses',    'varchar(512) null';            \
                                                    exec Sys_AddClassProperty   c,    'OwnerClasses',     'varchar(512) null';            \
                                                                                                                                          \
                                                    exec Sys_AddClassProperty   c,    'IsAbstract',       'bit not null default(0)';      \
                                                    exec Sys_AddClassProperty   c,    'IsReplicated',     'bit not null default(0)';      \
                                                    exec Sys_AddClassProperty   c,    'HasMapping',       'bit not null default(0)';      \
                                                                                                                                          \
                                                    exec Sys_AddClassProperty   c,    'IconIndex',        'int not null default(-1)';     \
                                                                                                                                          \
                                                    exec Sys_AddClassProperty   c,    'EditForm',         'varchar(128) null';            \
                                                    exec Sys_AddClassProperty   c,    'ListForm',         'varchar(128) null';            \
                                                    exec Sys_AddClassProperty   c,    'TreeForm',         'varchar(128) null';            \
                                                    exec Sys_AddClassProperty   c,    'MainForm',         'varchar(128) null';            \
                                                    exec Sys_AddClassProperty   c,    'ListControl',      'varchar(128) null';            \
                                                end

#define INTERFACE_CLASS_PROPERTIES(c)           c.CID, c.ParentCID, c.ClassName, c.FriendlyName, c.Service, c.DefaultCastClass, c.ParentClasses, c.OwnerClasses, c.IsAbstract, c.IsReplicated, c.HasMapping, c.IconIndex, c.EditForm, c.ListForm, c.TreeForm, c.MainForm, c.ListControl

#define DOC_GUID_BY_OID(_OID)                   (select GUID from o_Document where OID = _OID)
#define DOC_OID_BY_GUID(_GUID)                  (select OID  from o_Document where GUID = _GUID)

#define OID_BY_GUID(_GUID)                      (select OID  from o_Directory where GUID = _GUID)
#define GUID_BY_OID(_OID)                       (select GUID from o_Directory where OID = _OID)

#define OID_BY_GUID_FROMCLASS(_GUID, _CLASS)    (select OID  from _CLASS where GUID = _GUID)

#define ENUM_OID_BY_GUID(_GUID)                 (select OID  from o_Enum where GUID = _GUID)
#define ENUM_GUID_BY_OID(_OID)                  (select GUID from o_Enum where OID = _OID)
#define ENUM_NAME(_OID)                         (select Name from o_Enum where OID = _OID)

#define NAME(_OID)                              (select Name from o_Directory where OID = _OID)
#define FULL_NAME(_OID)                         (select FullName from o_Directory where OID = _OID)
#define EAN_BY_ITEM(_OID)                       (select top 1 ScanCode from Packing where PackTypeID = ENUM_OID_BY_GUID(GUID_PACKTYPE_ITEM) and ItemID = _OID)

#define PARENT_GUID(_OID)                       (select p.GUID from o_Directory o, o_Directory p where o.OID = _OID and p.OID = o.ParentID and p.CID = o.CID)

#define CHECK_TABLE_NAME(_code)                 case when charIndex('.', _code) > 0 then ('ZC_' + replace(_code, '.', '_')) else REGISTER_CHECK_TABLE_NAME(_code) end
#define MOVE_TABLE_NAME(_code)                  case when charIndex('.', _code) > 0 then ('CheckMove') else REGISTER_MOVE_TABLE_NAME(_code) end
#define REST_TABLE_NAME(_code)                  case when charIndex('.', _code) > 0 then ('CheckRest') else REGISTER_REST_TABLE_NAME(_code) end
#define POST_TABLE_NAME(_code)                  case when charIndex('.', _code) > 0 then ('Posting') else REGISTER_POST_TABLE_NAME(_code) end

#define REGISTER_CHECK_TABLE_NAME(_code)        ('RC_' + replace(rtrim(ltrim(_code)), ' ', '_'))
#define REGISTER_MOVE_TABLE_NAME(_code)         ('RM_' + replace(rtrim(ltrim(_code)), ' ', '_'))
#define REGISTER_REST_TABLE_NAME(_code)         ('RR_' + replace(rtrim(ltrim(_code)), ' ', '_'))
#define REGISTER_POST_TABLE_NAME(_code)         ('RP_' + replace(rtrim(ltrim(_code)), ' ', '_'))

// get root XML element name
#define XML_ELEMENT(x)                          dbo.System_GetXmlElement(x)

#define MAPPING_TST(_NodeID, _GUID, _TST)       dbo.Mapping_TST(_NodeID, _GUID, _TST)

#define SORTNO(x)                               isnull(right('000000000' + x, 9), '999999999')

// valid GCAS code
#define VALID_GCAS_CODE(_code)                  IIF(isnumeric(_code) = 1 and len(_code) <= 8, cast(1 as bit), cast(0 as bit))
--=============================================================================================================
/*
#define WRITE_LOG(_objectID)                    begin                                                                                                                       \
                                                    declare VARIABLE(@ProcName_) varchar(128) = object_name(@@PROCID);                                                      \
                                                    exec Log_Create VARIABLE(@ProcName_), _objectID, 1;                                                                     \
                                                end

#define WRITE_ENUMERATE_LOG(_count, _class)     begin                                                                                                                       \
                                                    declare VARIABLE(@RowCount_) int = _count;                                                                              \
                                                    declare VARIABLE(@ProcName_) varchar(128) = object_name(@@PROCID) + ' : ' + _class;                                     \
                                                    exec Log_Create VARIABLE(@ProcName_), null, VARIABLE(@RowCount_);                                                       \
                                                end

#define WRITE_TRIGGER_LOG                       begin                                                                                                                       \
                                                    declare VARIABLE(@ProcName_) varchar(128) = object_name(@@PROCID);                                                      \
                                                    declare VARIABLE(@RowCount_) int = (select count(*) from inserted);                                                     \
                                                    if VARIABLE(@RowCount_) = 0 set VARIABLE(@RowCount_) = (select count(*) from deleted);                                  \
                                                    declare VARIABLE(@ObjectID_) bigint;                                                                                    \
                                                    if VARIABLE(@RowCount_) = 1 set VARIABLE(@ObjectID_) = (select OID from inserted union select OID from deleted);        \
                                                    exec Log_Create VARIABLE(@ProcName_), VARIABLE(@ObjectID_), VARIABLE(@RowCount_);                                       \
                                                end
*/

#define WRITE_TRIGGER_LOG_TEMP                  begin                                                                                                                       \
                                                    declare VARIABLE(@ProcName_) varchar(128) = object_name(@@PROCID);                                                      \
                                                    declare VARIABLE(@RowCount_) int = (select count(*) from inserted);                                                     \
                                                    if VARIABLE(@RowCount_) = 0 set VARIABLE(@RowCount_) = (select count(*) from deleted);                                  \
                                                    declare VARIABLE(@ObjectID_) bigint;                                                                                    \
                                                    if VARIABLE(@RowCount_) = 1 set VARIABLE(@ObjectID_) = (select OID from inserted union select OID from deleted);        \
                                                    exec Log_Create VARIABLE(@ProcName_), VARIABLE(@ObjectID_), VARIABLE(@RowCount_);                                       \
                                                end

#define WRITE_LOG(_objectID)                begin declare VARIABLE(@LogDisabled_) int; end

#define WRITE_ENUMERATE_LOG(_count, _class) begin declare VARIABLE(@LogDisabled_) int; end

#define WRITE_TRIGGER_LOG                   begin declare VARIABLE(@LogDisabled_) int; end

#define TRANSLATE(f, l, o, a)               isnull(dbo.Vocabulary_SelectValue(l, a.o, MAC_STRING(f)), a.f) as f

#define ROUND2(x)                           floor(x * 100.0 + 0.55) / 100.0

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

#define RESULT_COLLECTOR \
    create table #validation_result \
    ( \
        ID              bigint identity (1, 1), \
        OID             bigint, \
        ObjectID        bigint, \
        ValidatorID     bigint, \
        Error           varchar(max), \
        Message         varchar(max), \
        Value           money, \
        SecurableMethod varchar(max), \
        IgnoreMessage   bit default 0, \
        AllowIgnore     bit default 0 \
    )

#define RESULT_DECLARE \
    declare @result table \
    ( \
        OID             bigint, \
        ObjectID        bigint, \
        ValidatorID     bigint, \
        Error           varchar(max),  \
        Message         varchar(max),  \
        Value           money,         \
        SecurableMethod varchar(max),  \
        IgnoreMessage   bit default 0, \
        AllowIgnore     bit default 0  \
    )

#define RESULT_COMMIT \
    if object_id('tempdb..#validation_result') is not null \
        insert into #validation_result (OID, ObjectID, ValidatorID, Error, Message, Value, SecurableMethod, IgnoreMessage, AllowIgnore) \
            select OID, ObjectID, ValidatorID, Error, Message, Value, SecurableMethod, IgnoreMessage, AllowIgnore from @result; \
    return

#define RESULT_ROLLBACK \
    if object_id('tempdb..#validation_result') is not null \
        insert into #validation_result (OID, ObjectID, ValidatorID, Error, Message, Value, SecurableMethod, IgnoreMessage, AllowIgnore) \
            select OID, ObjectID, ValidatorID, Error, Message, Value, SecurableMethod, IgnoreMessage, AllowIgnore from @result; \
    declare VARIABLE(@_ErrorMessage) varchar(max), VARIABLE(@_ErrorNumber) int, VARIABLE(@_ErrorLine) int, VARIABLE(@_ErrorProcedure) nvarchar(255);  \
    select VARIABLE(@_ErrorNumber) = ERROR_NUMBER(), VARIABLE(@_ErrorLine) = ERROR_LINE(), VARIABLE(@_ErrorProcedure) = ISNULL(ERROR_PROCEDURE(), '-');  \
    select VARIABLE(@_ErrorMessage) = 'ERROR: %d, PROC: %s, LINE: %d' + char(13) + char(10) + ERROR_MESSAGE();  \
    raiserror (VARIABLE(@_ErrorMessage), 16, 1, VARIABLE(@_ErrorNumber), VARIABLE(@_ErrorProcedure), VARIABLE(@_ErrorLine));  \
    return  \

--=============================================================================================================

#define POSTING_COLLECTOR \
    create table #posting_collector \
    ( \
        PostID          bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        DebID           bigint,     \
        CreID           bigint,     \
        Amount          money,      \
        Quantity        money       \
    )

#define POSTING_COMMIT \
    delete from Posting where PostID in (select PostID from #posting_collector where PostID > 0); \
    insert into Posting (DocID, PostDay, DebID, CreID, Amount, Quantity) \
        select  DocID, PostDay, DebID, CreID, Amount, Quantity \
        from    #posting_collector \
        where   PostID < 0 and (Amount != 0 or Quantity != 0); \
    drop table #posting_collector

#define RP_BUY_COLLECTOR \
    create table #rp_buy_collector  \
    ( \
        ID              bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        CheckID         bigint,     \
        _Item           bigint,     \
        _Our            bit,        \
        _Ret            bit,        \
        Quantity        money,      \
        Amount          money,      \
        Vat             money,      \
        Cost            money       \
    )

#define RP_BUY_COMMIT \
    delete from RP_Buy where ID in (select ID from #rp_buy_collector where ID > 0); \
    insert into RP_Buy (DocID, PostDay, CheckID, _Item, _Our, _Ret, Quantity, Amount, Vat, Cost) \
        select  DocID, PostDay, CheckID, _Item, _Our, _Ret, Quantity, Amount, Vat, Cost \
        from    #rp_buy_collector \
        where   ID < 0 and (Amount != 0 or Quantity != 0); \
    drop table #rp_buy_collector

#define RP_CUSTOMER_COLLECTOR \
    create table #rp_customer_collector  \
    ( \
        ID              bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        CheckID         bigint,     \
        _DelayLimit     bigint,     \
        _Commodity      bit,        \
        _Our            bit,        \
        _RGB            char(1),    \
        _Document       bigint,     \
        Amount          money       \
    )

#define RP_CUSTOMER_COMMIT \
    delete from RP_Customer where ID in (select ID from #rp_customer_collector where ID > 0); \
    insert into RP_Customer (DocID, PostDay, CheckID, _DelayLimit, _Commodity, _Our, _RGB, _Document, Amount) \
        select  DocID, PostDay, CheckID, _DelayLimit, _Commodity, _Our, _RGB, _Document, Amount \
        from    #rp_customer_collector \
        where   ID < 0 and Amount != 0; \
    drop table #rp_customer_collector

#define RP_REMAINS_COLLECTOR \
    create table #rp_remains_collector  \
    ( \
        ID              bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        CheckID         bigint,     \
        _Item           bigint,     \
        _OperType       bigint,     \
        Quantity        money,      \
        Amount          money,      \
        _Document       bigint,     \
        _DocDate        datetime,   \
        _Cost           money       \
    )

#define RP_REMAINS_COMMIT \
    delete from RP_Remains where ID in (select ID from #rp_remains_collector where ID > 0); \
    insert into RP_Remains (DocID, PostDay, CheckID, _Item, _OperType, Quantity, Amount, _Document, _DocDate, _Cost) \
        select  DocID, PostDay, CheckID, _Item, _OperType, Quantity, Amount, _Document, _DocDate, _Cost \
        from    #rp_remains_collector \
        where   ID < 0 and (Amount != 0 or Quantity != 0); \
    drop table #rp_remains_collector

#define RP_SALE_COLLECTOR \
    create table #rp_sale_collector  \
    ( \
        ID              bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        CheckID         bigint,     \
        _Item           bigint,     \
        _Our            bit,        \
        _Ret            bit,        \
        _RGB            char(1),    \
        Quantity        money,      \
        Amount          money,      \
        Vat             money,      \
        Cost            money       \
    )

#define RP_SALE_COMMIT \
    delete from RP_Sale where ID in (select ID from #rp_sale_collector where ID > 0); \
    insert into RP_Sale (DocID, PostDay, CheckID, _Item, _Our, _Ret, _RGB, Quantity, Amount, Vat, Cost) \
        select  DocID, PostDay, CheckID, _Item, _Our, _Ret, _RGB, Quantity, Amount, Vat, Cost \
        from    #rp_sale_collector \
        where   ID < 0 and (Amount != 0 or Quantity != 0); \
    drop table #rp_sale_collector

#define RP_SUPPLIER_COLLECTOR \
    create table #rp_supplier_collector  \
    ( \
        ID              bigint,     \
        DocID           bigint,     \
        PostDay         datetime,   \
        CheckID         bigint,     \
        _DelayLimit     bigint,     \
        _Commodity      bit,        \
        _Our            bit,        \
        _Document       bigint,     \
        Amount          money       \
    )

#define RP_SUPPLIER_COMMIT \
    delete from RP_Supplier where ID in (select ID from #rp_supplier_collector where ID > 0); \
    insert into RP_Supplier (DocID, PostDay, CheckID, _DelayLimit, _Commodity, _Our, _Document, Amount) \
        select  DocID, PostDay, CheckID, _DelayLimit, _Commodity, _Our, _Document, Amount \
        from    #rp_supplier_collector \
        where   ID < 0 and Amount != 0; \
    drop table #rp_supplier_collector

--=============================================================================================================
#endif // __CODA_HQL__
