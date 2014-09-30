-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go

/* =============================================================================================================
    declare @FilterString varchar(128) = '"порош*"';
    declare @TopRecords int = 10;

    exec cabinet_ItemRubrikator @FilterString, @TopRecords;
   ============================================================================================================= */

PROCEDURE(cabinet_ItemRubrikator)
    @FilterString   varchar(128),
    @TopRecords     int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    if @FilterString is null or @FilterString = '' or @FilterString = '*' or @FilterString = '"*"' or @FilterString = '"**"'  begin
        select  top (@TopRecords) ClassName = 'SubBrand', FilterID = sb.OID, sb.FullName, ItemCount = count(*)
        from    Item i
                join o_Directory p on p.OID = i.ParentID    -- Product
                join o_Directory sb on sb.OID = p.ParentID  -- SubBrand
        where   i.FullTextSearch is not null
        group by sb.OID, sb.FullName
        order by count(*) desc;

        select  top (@TopRecords) ClassName = 'Purpose', FilterID = p.OID, p.FullName, ItemCount = count(*)
        from    o_Item i                                    -- Item
                join o_Directory p on p.OID = i.PurposeID   -- Purpose
        where   i.FullTextSearch is not null
        group by p.OID, p.FullName
        order by count(*) desc;

    end else begin
        select  top (@TopRecords) ClassName = 'SubBrand', FilterID = sb.OID, sb.FullName, ItemCount = count(*)
        from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f
                join o_Directory i on i.OID = f.[KEY]       -- Item
                join o_Directory p on p.OID = i.ParentID    -- Product
                join o_Directory sb on sb.OID = p.ParentID  -- SubBrand
        group by sb.OID, sb.FullName
        order by count(*) desc;

        select  top (@TopRecords) ClassName = 'Purpose', FilterID = p.OID, p.FullName, ItemCount = count(*)
        from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f
                join o_Item i on i.OID = f.[KEY]            -- Item
                join o_Directory p on p.OID = i.PurposeID   -- Purpose
        group by p.OID, p.FullName
        order by count(*) desc;

    end;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

/* =============================================================================================================
    declare @FilterString varchar(128) = '"ARI*"';
    declare @FilterID bigint = 8000001364267; -- 198000032684695 for Order
    declare @PageSize int = 10;
    declare @PageNumber int = 1;
    declare @BranchID bigint = null;

    exec cabinet_ItemFilter @FilterString, @FilterID, @PageSize, @PageNumber, @BranchID;
   ============================================================================================================= */

PROCEDURE(cabinet_ItemFilter)
    @OrderID        bigint,
    @FilterString   varchar(128),
    @FilterID       bigint,
    @PageSize       int,
    @PageNumber     int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    declare @ConditionID bigint = 8000001692604; --TODO - move to settings

    declare @Items table (OID bigint);

    if @FilterString is null or @FilterString = '' or @FilterString = '*' or @FilterString = '"*"' or @FilterString = '"**"'  begin
        if @FilterID is null -- filter by string
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    o_Item i
                    where   i.FullTextSearch is not null
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else if exists (select * from o_DocImportPDA where OID = @FilterID) -- filter by order
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    DocImportPDALine l join o_Item i on i.OID = l.ItemID
                    where   l.DocID = @FilterID
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else if exists (select * from o_Purpose where OID = @FilterID) -- filter by string and purpose
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    o_Item i
                    where i.PurposeID = @FilterID and i.FullTextSearch is not null
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else -- filter by string and subbrand
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    Item i join o_Directory p on p.OID = i.ParentID and p.ParentID = @FilterID
                    where   i.FullTextSearch is not null
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

    end else begin
        if @FilterID is null -- filter by string
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join o_Item i on i.OID = f.[KEY]
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else if exists (select * from o_DocImportPDA where OID = @FilterID)
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    DocImportPDALine l join o_Item i on i.OID = l.ItemID join CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f on f.[KEY] = i.OID
                    where   l.DocID = @FilterID
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else if exists (select * from o_Purpose where OID = @FilterID) -- filter by string and purpose
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join o_Item i on i.OID = f.[KEY]
                    where   i.PurposeID = @FilterID
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else -- filter by string and subbrand
            insert  @Items select i.OID
            from    (
                    select  i.OID, ROW = row_number() over (order by i.SortNO, i.OID)
                    from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join Item i on i.OID = f.[KEY] join o_Directory p on p.OID = i.ParentID and p.ParentID = @FilterID
                    ) i
            where   i.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;
    end;

    declare @CustomerID     bigint,
            @DepartmentID   bigint;

    select  @CustomerID     = CustomerID,
            @DepartmentID   = isnull(DepartmentID, -1)
    from    DocImportPDA
    where   OID = @OrderID;

    declare @RestItems table (OID bigint, ItemID bigint, StoreID bigint, BranchID bigint);
    insert  @RestItems select i.OID, i.RestItemID, bb.StoreID, bb.BranchID
    from    @Items x, Item i, o_Directory p, cabinet_SubjectSBB bb
    where   i.RestItemID = x.OID and p.OID = i.ParentID
            and bb.SubjectID = @CustomerID and @DepartmentID = isnull(bb.DepartmentID, @DepartmentID) and bb.SubBrandID = p.ParentID;

    declare @Date datetime = getdate();

    declare @Rests table (OID bigint, BranchID bigint, Rest money);
    insert @Rests select x.ItemID, x.BranchID, sum(Quantity)
    from    (
            select  x.OID, x.ItemID, x.BranchID, Quantity = sum(Quantity)
            from    (
                    select  i.OID, i.ItemID, i.BranchID, Quantity = sum(r.Quantity)
                    from    @RestItems i, RC_Rests c, RR_Rests r
                    where   c.Store = i.StoreID and r.CheckID = c.CheckID and r._Item = i.OID
                    group by i.OID, i.ItemID, i.BranchID
                    having sum(r.Quantity) != 0

                    union all
                    select  i.OID, i.ItemID, i.BranchID, Quantity = -sum(r.Quantity)
                    from    @RestItems i, RC_Reserve c, RR_Reserve r
                    where   c.Store = i.StoreID and r.CheckID = c.CheckID and r._Item = i.OID
                    group by i.OID, i.ItemID, i.BranchID
                    having sum(r.Quantity) != 0

                    union all
                    select  i.OID, i.ItemID, i.BranchID, Quantity = -sum(r.Quantity)
                    from    @RestItems i, RC_Quota c, RR_Quota r
                    where   r.CheckID = c.CheckID and r._Item = i.OID and c.Branch = i.BranchID and r._IssueDate <= @Date and @Date <= r._ExpireDate
                    group by i.OID, i.ItemID, i.BranchID
                    having sum(r.Quantity) != 0

                    union all
                    select  i.OID, i.ItemID, i.BranchID, Quantity = -sum(r.Quantity)
                    from    @RestItems i, RC_QuotaFilial c, RR_QuotaFilial r
                    where   r.CheckID = c.CheckID and r._Item = i.OID and c.FDIBranch = i.BranchID and @Date <= r._ExpireDate
                    group by i.OID, i.ItemID, i.BranchID
                    ) x
            group by x.OID, x.ItemID, x.BranchID
            having sum(x.Quantity) > 0
            ) x
    group by x.ItemID, x.BranchID;

    select  ItemID = x.OID, i.DivLoadQnt, Available = isnull(r.Rest, 0), BasePrice = isnull(pr.Price, 0), i.SortNO, i.Name, pa.ScanCode, VatPercent = p.Vat * 100, i.ExtraName,
            IsAvailable = IIF(isnull(r.Rest, 0) > isnull(s.SDO, 0), 1, 0)
    from    @Items x
            join Item i on i.OID = x.OID
            join Product p on p.OID = i.ParentID
            join Packing pa on pa.OID = i.DefaultPackingID
            left join @Rests r on r.OID = x.OID
            left join cabinet_ItemSDO s on s.BranchID = r.BranchID and s.ItemID = x.OID
            left join
                (
                select  i.OID, d.Price
                from    @Items i, ConditionPrice d
                where   d.OwnerID = @ConditionID and d.ItemID = i.OID and d.IsDeleted = 0
                        and IssueDate =
                            (
                            select  max(x.IssueDate)
                            from    ConditionPrice x
                            where   x.OwnerID = @ConditionID and x.ItemID = i.OID and x.IssueDate <= @Date
                            )
                ) pr on pr.OID = x.OID
    order by i.SortNO;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

/* =============================================================================================================
    declare @FilterString varchar(128) = '"ARI*"';
    declare @FilterID bigint = 8000001364267; -- 198000032684695 for Order
    declare @PageSize int = 10;

    exec cabinet_ItemFilterPagesCount  @FilterString, @FilterID, @PageSize;
   ============================================================================================================= */

PROCEDURE(cabinet_ItemFilterPagesCount)
    @FilterString   varchar(128),
    @FilterID       bigint,
    @PageSize       int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    if @FilterString is null or @FilterString = '' or @FilterString = '*' or @FilterString = '"*"' or @FilterString = '"**"'  begin
        if @FilterID is null -- filter by string
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    o_Item i
            where   i.FullTextSearch is not null

        else if exists (select * from o_DocImportPDA where OID = @FilterID) -- filter by order
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    DocImportPDALine l join o_Item i on i.OID = l.ItemID
            where   l.DocID = @FilterID

        else if exists (select * from o_Purpose where OID = @FilterID) -- filter by string and purpose
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    o_Item i
            where i.PurposeID = @FilterID and i.FullTextSearch is not null

        else -- filter by string and subbrand
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    Item i join o_Directory p on p.OID = i.ParentID and p.ParentID = @FilterID
            where   i.FullTextSearch is not null

    end else begin
        if @FilterID is null -- filter by string
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join o_Item i on i.OID = f.[KEY]

        else if exists (select * from o_DocImportPDA where OID = @FilterID)
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    DocImportPDALine l join o_Item i on i.OID = l.ItemID join CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f on f.[KEY] = i.OID
            where   l.DocID = @FilterID

        else if exists (select * from o_Purpose where OID = @FilterID) -- filter by string and purpose
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join o_Item i on i.OID = f.[KEY]
            where   i.PurposeID = @FilterID

        else -- filter by string and subbrand
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    CONTAINSTABLE(o_Item, FullTextSearch, @FilterString) f join Item i on i.OID = f.[KEY] join o_Directory p on p.OID = i.ParentID and p.ParentID = @FilterID
    end;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================
-- END OF FILE
