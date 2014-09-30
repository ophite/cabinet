
-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go

-- =============================================================================================================
/*
exec sp_configure 'show advanced options', 1
go

exec sp_configure 'clr enabled', 1
reconfigure with override
go

-- for CLR
alter database coda set trustworthy on
go

-- for CLR
alter authorization on database::coda to sa
go

-- DocImportPDA

exec Util_CreateIndex 'in_DocImportPDA_Customer', 'o_DocImportPDA', 'CustomerID'
exec Util_CreateIndex 'in_DocImportPDA_Finished', 'o_DocImportPDA', 'IsFinished'
go

-- Item

exec Sys_AddProperty        'Item',         'FullTextSearch',       'varchar(max) null'                         -- строка для поиска
exec Sys_AddProperty        'Item',         'PurposeID',            'ref Purpose null'                          -- назначение
exec Sys_AddProperty        'Item',         'RestItemID',           'ref Item null'                             -- позиция для остатка

exec Util_CreateIndex 'in_Item_Purpose',    'o_Item', 'PurposeID'
exec Util_CreateIndex 'in_Item_Rest',       'o_Item', 'RestItemID'
go

create fulltext index on o_Item (FullTextSearch LANGUAGE 'Russian')
    key index pk_o_000069
go

alter fulltext index on o_Item set stoplist off
go

-- Subject

exec Sys_AddProperty        'Subject',      'FullTextSearch',       'varchar(max) null'                         -- строка для поиска
go

create fulltext index on o_Subject (FullTextSearch LANGUAGE 'Russian')
    key index pk_o_000042
go

alter fulltext index on o_Subject set stoplist off
go

-- Department

exec Sys_AddProperty        'Department',   'FullTextSearch',       'varchar(max) null'                         -- строка для поиска
go

create fulltext index on o_Department (FullTextSearch LANGUAGE 'Russian')
    key index pk_o_000049
go

alter fulltext index on o_Department set stoplist off
go

*/

-- =============================================================================================================
/*
declare @ConditionID bigint = 8000001692604;
delete from ConditionRule where OwnerID = @ConditionID;

declare @DelayTypeID bigint = 7000000001216;
exec ConditionRule_Create @ConditionID, 'delay', 'delay', null, @DelayTypeID,     0,     1, 2.25, null;
exec ConditionRule_Create @ConditionID, 'delay', 'delay', null, @DelayTypeID,     1,     8, 1.50, null;
exec ConditionRule_Create @ConditionID, 'delay', 'delay', null, @DelayTypeID,     8,    15, 0.75, null;
exec ConditionRule_Create @ConditionID, 'delay', 'delay', null, @DelayTypeID,    15,     0,    0, null;

declare @ValueTypeID bigint = 7000000001215;
exec ConditionRule_Create @ConditionID, 'value', 'value', null, @ValueTypeID,     0,  3500,    0, null;
exec ConditionRule_Create @ConditionID, 'value', 'value', null, @ValueTypeID,  3500,  8000,    1, null;
exec ConditionRule_Create @ConditionID, 'value', 'value', null, @ValueTypeID,  8000, 25000,    2, null;
exec ConditionRule_Create @ConditionID, 'value', 'value', null, @ValueTypeID, 25000,     0,    5, null;

select * from ConditionRule where OwnerID = @ConditionID;
go

create table cabinet_ItemSDO
(
    BranchID        bigint not null,
    ItemID          bigint not null,
    SDO             money not null,

    constraint pk_ItemBranchSDO primary key clustered (ItemID, BranchID)
)
go

create table cabinet_SubjectSBB
(
    SubjectID       bigint not null,
    DepartmentID    bigint null,
    SubBrandID      bigint not null,
    StoreID         bigint not null,
    BranchID        bigint not null,

    constraint pk_SubjectSBB unique clustered (SubjectID, SubBrandID, DepartmentID)
)
go
*/

PROCEDURE(cabinet_RebuildFullText)
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    -- =============================================================================================================
    -- set null's to all fields

    update  o_Item
    set     FullTextSearch = null, PurposeID = null, RestItemID = null
    where   FullTextSearch is not null or PurposeID is not null

    -- =============================================================================================================
    -- update RestItemID by DefaultItemID

    update  x
    set     x.RestItemID = i.OID
    from    Product p
            join Item i on i.OID = p.DefaultItemID
            join Item xx on xx.ParentID = p.OID
            join o_Item x on x.OID = xx.OID
    where   x.ItemTypeID is null or x.ItemTypeID not in (7000000001302, 7000000001303)

    -- =============================================================================================================
    -- setting RestItemID for other Items

    update  x
    set     x.RestItemID = x.OID
    from    Item i
            join o_Item x on x.OID = i.OID
    where   i.RestItemID is null or i.IsDeleted = 1 or i.WMS = 1

    -- =============================================================================================================
    -- update main PurposeID on Items
/*
    ;
    with Tree(ProductID, PurposeID, ParentID) as
        (
        select  l.ObjectID, p.OID, p.ParentID
        from    ProductLink l join Purpose p on p.OID = l.ParentID
        where   l.IsRemoved = 0

        union all
        select  t.ProductID, p.OID, p.ParentID
        from    Tree t join Purpose p on p.OID = t.ParentID
        )
    update  x
    set     x.PurposeID = r.OID
    from    o_Item x
            join Item i on i.OID = x.OID
            join Product p on p.OID = i.ParentID
            join Tree t on t.ProductID = p.OID
            join Purpose r on r.OID = t.PurposeID and r.ParentID in (8000005701862, 8000001364197, 8000001364198);
*/

    -- =============================================================================================================
    -- update V-B-SB name on Items

    update  x
    set     x.FullTextSearch = i.FullName + ';' + sb.FullName + ';' + b.FullName + ';' + isnull(pa.ScanCode + ';', '')
    from    Brand b
            join SubBrand sb on sb.ParentID = b.OID and sb.IsDeleted = 0
            join Product p on p.ParentID = sb.OID and p.IsDeleted = 0
            join Item i on i.ParentID = p.OID and i.IsDeleted = 0 and i.WMS = 0
            join Packing pa on pa.OID = i.DefaultPackingID
            join o_Item x on x.OID = i.OID and x.RestItemID = x.OID
    where   b.ParentID in (8000003361019, 8000003362180, 8000006262806)

    -- =============================================================================================================
    -- update Purposes Tree on Items
/*
    ;
    with Tree(OID, PurposeID, FullName) as
        (
        select  i.OID, i.PurposeID, p.FullName
        from    Item i join Purpose p on p.OID = i.PurposeID
        where   i.FullTextSearch is not null

        union all
        select  t.OID, p.OID, p.FullName
        from    Tree t join Purpose p on p.ParentID = t.PurposeID and p.IsDeleted = 0
        )
    update  x
    set     x.FullTextSearch = x.FullTextSearch + t.PurposeString
    from    (
            select  t.OID, PurposeString = dbo.AggString(distinct t.FullName)
            from    Tree t
            group by t.OID
            ) t
            join o_Item x on x.OID = t.OID;
*/
    -- =============================================================================================================
    -- update Subject's info

    update o_Subject set FullTextSearch = null
    ;
    with Tree (OID) as
        (
        select s.OID from Subjects s where s.OID = 8000000000213
        union all
        select s.OID from Tree t, Subjects s where s.ParentID = t.OID and s.IsDeleted = 0
        )
    update  o
    set     o.FullTextSearch =
                isnull(s.FullName + ';', '') +
                isnull(s.PaperRegistrationCode + ';', '') +
                isnull(s.PaperVATCode + ';', '') +
                isnull(s.PaperVATExtraNO + ';', '') +
                isnull(pa.FullName + ';', '') +
                isnull(la.FullName + ';', '') +
                isnull(i.FullName + ';', '') +
                isnull(i.PaperITNCode + ';', '') +
                isnull(i.PaperPassportNO + ';', '') +
                isnull(ia.FullName + ';', '')
    from    Tree t
            join Subject s on s.ParentID = t.OID
            join o_Subject o on o.OID = s.OID
            left join Address pa on pa.OID = s.AddressID
            left join Address la on la.OID = s.LawAddressID
            left join Individual i on i.OID = s.IndividualID
            left join Address ia on ia.OID = i.AddressID
    where   s.IsDeleted = 0;

    -- =============================================================================================================
    -- update Subject's info by Departments

    update  s
    set     s.FullTextSearch = s.FullTextSearch + isnull(DepInfo, '')
    from    o_Subject s
            join
                (
                select  s.OID, DepInfo = dbo.AggString(d.FullName)
                from    o_Subject s
                        join Department d on d.OwnerID = s.OID
                where   s.FullTextSearch is not null
                group by s.OID
                ) x on x.OID = s.OID
    where   s.FullTextSearch is not null;

    -- =============================================================================================================
    -- update Department's info by Departments

    update o_Department set FullTextSearch = null;

    update  d
    set     d.FullTextSearch = o.FullName
    from    o_Subject s
            join o_Directory o on o.OwnerID = s.OID
            join o_Department d on d.OID = o.OID
    where   s.FullTextSearch is not null;

    -- =============================================================================================================
    -- calc Subject Store Branch

    declare @SubBrand table (SubBrandID bigint, TradeMarkID bigint, Level int);
    with Tree (SubBrandID, TradeMarkID, Level) as
        (
        select  distinct SubBrandID = p.ParentID, TradeMarkID = p.ParentID, Level = 1
        from    Item i
                join Product p on p.OID = i.ParentID
        where   i.FullTextSearch is not null

        union all
        select  t.SubBrandID, TradeMarkID = m.ParentID, Level = t.Level + 1
        from    Tree t
                join TradeMark m on m.OID = t.TradeMarkID
        )
    insert into @SubBrand (SubBrandID, TradeMarkID, Level)
    select  SubBrandID, TradeMarkID, Level
    from    Tree;

    select  distinct sp.SubjectID, sp.SalepointID, sb.SubBrandID, sb.Level, tm.StoreID
    into #SubjectStoreItem
    from    Seller s
            join SellerPoint sp on sp.SellerID = s.OID
            join SellerTradeMark tm on tm.SellerID = s.OID
            join @SubBrand sb on sb.TradeMarkID = tm.TradeMarkID
            join o_Directory su on su.OID = sp.SubjectID and su.IsDeleted = 0
    where   s.IsDeleted = 0 and sp.SalepointID is null

    union all
    select  distinct sp.SubjectID, sp.SalepointID, sb.SubBrandID, sb.Level, tm.StoreID
    from    Seller s
            join SellerPoint sp on sp.SellerID = s.OID
            join SellerTradeMark tm on tm.SellerID = s.OID
            join @SubBrand sb on sb.TradeMarkID = tm.TradeMarkID
            join o_Directory su on su.OID = sp.SubjectID and su.IsDeleted = 0
    where   s.IsDeleted = 0 and sp.SalepointID is not null

    delete  m
    from    #SubjectStoreItem m
    where   exists
                (
                select  *
                from    #SubjectStoreItem l
                where   l.SubjectID = m.SubjectID and isnull(l.SalepointID, -1) = isnull(m.SalepointID, -1) and l.SubBrandID = m.SubBrandID
                        and ((l.Level < m.Level) or (l.Level = m.Level and l.StoreID < m.StoreID))
                );

    declare @BranchOwnerID bigint = 8000003129145;
    truncate table cabinet_SubjectSBB;

    insert into cabinet_SubjectSBB (SubjectID, DepartmentID, SubBrandID, StoreID, BranchID)
    select  s.SubjectID, s.SalepointID, s.SubBrandID, s.StoreID, b.OID
    from    #SubjectStoreItem s
            inner join RegionLink l on l.ObjectID = s.StoreID and l.IsRemoved = 0 and l.OwnerID = @BranchOwnerID
            inner join Branch b on b.OID = l.ParentID and b.IsDeleted = 0;

    -- =============================================================================================================
    -- calc SDO

    delete from cabinet_ItemSDO;

    declare @Date datetime = convert(varchar, getdate(), 112);
    declare @Days int = 56;
    declare @WorkingDays int = 48;
    declare @BegDate datetime = @Date - @Days - 1;
    declare @EndDate datetime = @Date - 1;

    insert into cabinet_ItemSDO (BranchID, ItemID, SDO)
        select  BranchID = c.Branch, ItemID = i.RestItemID, SDO = sum(m.Quantity) / @WorkingDays
        from    RC_Sale c
                join RM_Sale m on m.CheckID = c.CheckID
                join Item i on i.OID = m._Item
        where   m.MoveDay between @BegDate and @EndDate and m._Ret = 0 and m._Our = 0
                and c.Branch = 8000003129149
        group by c.Branch, i.RestItemID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

-- =============================================================================================================
-- END OF FILE
