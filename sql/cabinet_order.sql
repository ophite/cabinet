-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderCreate)
    @DocDate        datetime,
    @DelayLimit     int,
    @CustomerID     bigint,
    @DepartmentID   bigint,
    @Comments       varchar(128),
    @OrderID        bigint output
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try
    begin tran;

    set @DocDate = isnull(@DocDate, getdate());
    declare @ConditionID bigint = 8000001692604; --TODO - move to Settings

    exec DocImportPDA_Create @FirmID = 8000000241646, @BranchID = null, @SellerID = null, @CustomerID = @CustomerID, @DepartmentID = @DepartmentID,
        @DocDate = @DocDate, @FilialID = null, @FullName = null, @Name = 'NewOrder', @Comments = @Comments, @DocCode = null, @RevenueID = null, @EmployeeID = null,
        @DeliverID = null, @ReceiverID = null, @Amount = 0, @RGB = 'G', @SourceDocID = null, @DelayLimit = @DelayLimit, @ConditionID = @ConditionID,
        @DocType = 'W', @State = 'E', @PaymentDeliveryPoint = 'C', @IsFinished = 0, @OID = @OrderID output;

    exec DocImportPDA_SetDocCode @OrderID;

    commit tran;
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderNew)
    @DocDate        datetime,
    @DelayLimit     int,
    @CustomerID     bigint,
    @DepartmentID   bigint,
    @Comments       varchar(128)
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try
    begin tran;

    declare @OrderID bigint = null;
    exec cabinet_OrderCreate    @DocDate = @DocDate, @DelayLimit = @DelayLimit,  @CustomerID = @CustomerID, @DepartmentID = @DepartmentID,
                                @Comments = @Comments, @OrderID = @OrderID output;

    select OrderID = @OrderID;

    commit tran;
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderGet)
    @OrderID  bigint
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    select  x.*, SubjectFullName = s.FullName, DepartmentFullName = d.FullName
    from    DocImportPDA x
            left join Subject s on s.OID = x.CustomerID
            left join Department d on d.OID = x.DepartmentID
    where   x.OID = @OrderID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderList)
    @BegDate        datetime,
    @EndDate        datetime,
    @FilterString   varchar(128),
    @CustomerID     bigint,
    @WithFinished   bit,
    @PageSize       int,
    @PageNumber     int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    declare @Orders table (OID bigint, ROW bigint);
    set @BegDate = isnull(@BegDate, getdate() - 30);
    set @EndDate = isnull(@EndDate, getdate());
    
    if @FilterString is null or @FilterString = '' or @FilterString = '*' or @FilterString = '"*"' or @FilterString = '"**"' begin -- searching by Customer or null
        if @CustomerID is null
            insert @Orders select  x.OID, x.ROW
            from    (
                    select  o.OID, ROW = row_number() over (order by d.DocDate, o.OID)
                    from    o_DocImportPDA o join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
                    where   o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)
                    ) x
            where   x.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else
            insert @Orders select  x.OID, x.ROW
            from    (
                    select  o.OID, ROW = row_number() over (order by d.DocDate, o.OID)
                    from    o_DocImportPDA o join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
                    where   o.CustomerID = @CustomerID and o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)
                    ) x
            where   x.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

    end else begin -- searching by Filter and Customer or null
        if @CustomerID is null
            insert @Orders select  x.OID, x.ROW
            from    (
                    select  o.OID, ROW = row_number() over (order by (f.RANK + isnull(dep.RANK, 0)) desc, d.DocDate, o.OID)
                    from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f
                            join o_DocImportPDA o on o.CustomerID = f.[KEY]
                            join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
                            left join CONTAINSTABLE(o_Department, FullTextSearch, @FilterString) dep on dep.[KEY] = o.DepartmentID
                    where   o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)
                    ) x
            where   x.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

        else
            insert @Orders select  x.OID, x.ROW
            from    (
                    select  o.OID, ROW = row_number() over (order by (f.RANK + isnull(dep.RANK, 0)) desc, d.DocDate, o.OID)
                    from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f
                            join o_DocImportPDA o on o.CustomerID = f.[KEY]
                            join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
                            left join CONTAINSTABLE(o_Department, FullTextSearch, @FilterString) dep on dep.[KEY] = o.DepartmentID
                    where   o.CustomerID = @CustomerID and o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)
                    ) x
            where   x.ROW between @PageSize * (@PageNumber - 1) + 1 and @PageSize * @PageNumber;

    end;

    select  x.*, SubjectFullName = s.FullName, DepartmentFullName = d.FullName
    from    @Orders o
            join DocImportPDA x on x.OID = o.OID
            left join Subject s on s.OID = x.CustomerID
            left join Department d on d.OID = x.DepartmentID
    order by o.ROW;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderListPagesCount)
    @BegDate        datetime,
    @EndDate        datetime,
    @FilterString   varchar(128),
    @CustomerID     bigint,
    @WithFinished   bit,
    @PageSize       int
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    set @BegDate = isnull(@BegDate, getdate() - 30);
    set @EndDate = isnull(@EndDate, getdate());

    if @FilterString is null or @FilterString = '' or @FilterString = '*' or @FilterString = '"*"' or @FilterString = '"**"' begin -- searching by Customer or null
        if @CustomerID is null
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    o_DocImportPDA o join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
            where   o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)

        else
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    o_DocImportPDA o join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
            where   o.CustomerID = @CustomerID and o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)

    end else begin -- searching by Filter and Customer or null
        if @CustomerID is null
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f
                    join o_DocImportPDA o on o.CustomerID = f.[KEY]
                    join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
            where   o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)

        else
            select  CNT = (count(*) + @PageSize - 1) / @PageSize
            from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f
                    join o_DocImportPDA o on o.CustomerID = f.[KEY]
                    join o_Document d on d.OID = o.OID and d.DocDate between @BegDate and @EndDate
            where   o.CustomerID = @CustomerID and o.DocType = 'W' and State = 'E' and (@WithFinished = 1 or o.IsFinished = 0)

    end;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderUpdate)
    @OrderID        bigint,
    @DocDate        datetime,
    @DelayLimit     int,
    @CustomerID     bigint,
    @DepartmentID   bigint,
    @Comments       varchar(128)
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try
    begin tran;

    update  DocImportPDA
    set     DocDate         = @DocDate,
            DelayLimit      = @DelayLimit,
            CustomerID      = @CustomerID,
            DepartmentID    = @DepartmentID,
            Comments        = @Comments
    where   OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0;

    commit tran;

    select TST from DocImportPDA where OID = @OrderID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderDelete)
    @OrderID        bigint
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try
    begin tran;

    update  DocImportPDA
    set     State = 'D'
    where   OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0;

    commit tran;

    select TST from DocImportPDA where OID = @OrderID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderFinished)
    @OrderID    bigint
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    if not exists (select * from DocImportPDA where OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0) begin
        select TST from DocImportPDA where OID = @OrderID;
        return;
    end;

    begin tran;

    select  d.OID as DocID, d.CustomerID, d.DepartmentID as SalepointID, l.OID as LineID, s.OID as SubBrandID, b.OID as BrandID, b.ParentID as VendorID
    into    #LineTradeMark
    from    DocImportPDA d
    		inner join DocImportPDALine l on l.DocID = d.OID
            inner join Item i on i.OID = l.ItemID
            inner join Product p on p.OID = i.ParentID
            inner join SubBrand s on s.OID = p.ParentID
            inner join Brand b on b.OID = s.ParentID
    where   d.OID = @OrderID;

    -- однозначно определенные сейлсы
    select  distinct t.DocID, t.LineID, min(m.SellerID) as SellerID, IIF(m.TradeMarkID = t.SubBrandID, 0, IIF(m.TradeMarkID = t.BrandID, 1, 2)) as BrandLevel
    into    #SellerLine
    from    #LineTradeMark t
    		inner join SellerPoint sp on sp.SubjectID = t.CustomerID and isnull(t.SalepointID, -1) = isnull(sp.SalepointID, isnull(t.SalepointID, -1))
            inner join SellerTrademark m on m.TradeMarkID in (t.SubBrandID, t.BrandID, t.VendorID)
            inner join Seller s on s.OID = sp.SellerID and s.OID = m.SellerID and s.IsDeleted = 0
    group by t.DocID, t.LineID, m.TradeMarkID, t.SubBrandID, t.BrandID;
    
    delete
    from    #SellerLine
    where   exists(select * from #SellerLine slMain where #SellerLine.LineID = slMain.LineID and #SellerLine.BrandLevel > slMain.BrandLevel);

    -- разбиваем по Seller
    select  dense_rank() over (partition by DocID order by DocID, isnull(SellerID, BIGNUMBER))      as NewDocNumber,
            isnull(SellerID, BIGNUMBER)                                                             as SellerID,
            DocID                                                                                 	as OldDocID,
            LineID                                                                                  as LineID
    into    #NewLine
    from    #SellerLine;

    select  NewDocNumber            as NewDocNumber,
            OldDocID                as OldDocID,
            dbo.NewOID('Document')  as NewDocID,
            SellerID                as SellerID
    into    #NewDoc
    from    #NewLine
    group by NewDocNumber, OldDocID, SellerID;
    
    if @@rowcount = 0
        THROW('Невозможно завершить документ, для клиента не указан торговый представитель по введенным брендам!');

    insert into DocImportPDA(OID, FirmID, BranchID, FilialID, CustomerID, DepartmentID, FullName, Name, Comments, SourceDocCode, DocDate, DocCode, RevenueID, EmployeeID, DeliverID, ReceiverID,
            Amount, RGB, SourceDocID, SellerID, DelayLimit, ConditionID, DocType, State, PaymentDeliveryPoint, IsFinished)
    select  nd.NewDocID, pda.FirmID, pda.BranchID, pda.FilialID, pda.CustomerID, pda.DepartmentID, pda.FullName, pda.Name, pda.Comments, pda.SourceDocCode, pda.DocDate, DocCode, pda.RevenueID, pda.EmployeeID, pda.DeliverID, pda.ReceiverID,
            0, pda.RGB, pda.OID, nd.SellerID, pda.DelayLimit, pda.ConditionID, pda.DocType, pda.State, pda.PaymentDeliveryPoint, pda.IsFinished
    from    DocImportPDA pda
			inner join #NewDoc nd on nd.OldDocID = pda.OID;

	insert into DocImportPDALine(OID, DocID, ItemID, BasePrice, Discount, Price, Ordered, Quantity, CasefillrateID, CostSum, VatPercent, VatSum, SortNO)
    select  dbo.NewOID('DocImportPDALine') as OID,
            nd.NewDocID as DocID, l.ItemID, l.BasePrice, l.Discount, l.Price, l.Ordered, l.Quantity, l.CasefillrateID, l.CostSum, l.VatPercent, l.VatSum, l.SortNO
    from    DocImportPDALine l
            inner join #NewLine nl on nl.LineID = l.OID
            inner join #NewDoc nd on nd.OldDocID = nl.OldDocID and nl.NewDocNumber = nd.NewDocNumber;

    update  o_DocImportPDA
    set     IsFinished 	= 1
    where   OID in (select NewDocID from #NewDoc);

    update DocImportPDA set State = 'D' where OID = @OrderID;

    -- update Order
    update  o_Document
    set     Amount = isnull((
                select  round(sum(Price * Quantity), 2) + round(sum(VatSum), 2)
                from    o_DocImportPDALine
                where   DocID = o_Document.OID), 0)
    where   OID in (select NewDocID from #NewDoc);

    commit tran;

    select max(TST) from DocImportPDA where OID in (select NewDocID from #NewDoc);

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderGetQuantityPrice)
    @OrderID    bigint
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    select  f.ItemID, f.Quantity, f.BasePrice, f.VatPercent
    from    DocImportPDALine f
    where   f.DocID = @OrderID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderUpdateAmounts)
    @OrderID    bigint
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    if not exists (select * from DocImportPDA where OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0)
        return;

    begin tran;

    declare @ConditionID bigint = null;
    declare @Date datetime = null;
    declare @DelayLimit int = null;

    select  @ConditionID = ConditionID, @Date = isnull(DocDate, getdate()), @DelayLimit = isnull(DelayLimit, 0)
    from    DocImportPDA
    where   OID = @OrderID;

    if (@ConditionID is null)
        set @ConditionID = 8000001692604; --TODO - move to Settings

    -- update BasePrice and parameters
    update  l
    set     l.SortNO = i.SortNO,
            l.VatPercent = p.Vat * 100,
            l.BasePrice = isnull(d.Price, 0)
    from    o_DocImportPDALine l
            join Item i on i.OID = l.ItemID
            join Product p on p.OID = i.ParentID
            left join ConditionPrice d on d.OwnerID = @ConditionID and d.ItemID = l.ItemID and d.IsDeleted = 0
            and IssueDate = (select max(x.IssueDate) from ConditionPrice x where  x.OwnerID = @ConditionID and x.ItemID = l.ItemID and x.IssueDate <= @Date)
    where   l.DocID = @OrderID;

    -- calc total Amount
    declare @Amount money = (select sum(BasePrice * Quantity) from o_DocImportPDALine where DocID = @OrderID);

    -- calc Condition rules
    declare @DelayTypeID bigint = 7000000001216; --TODO move to Constatns.hql
    declare @Delay money = isnull((
        select  top 1 Value
        from    ConditionRule
        where   OwnerID = @ConditionID and TermTypeID = @DelayTypeID and IsDeleted = 0
                and (isnull(MinLimit, 0) = 0 or MinLimit <= @DelayLimit)
                and (isnull(MaxLimit, 0) = 0 or @DelayLimit < MaxLimit)
        order by isnull(MinLimit, 0), isnull(MaxLimit, 0), Value), 0);

    declare @ValueTypeID bigint = 7000000001215; --TODO move to Constatns.hql
    declare @Value money = isnull((
        select  top 1 Value
        from    ConditionRule
        where   OwnerID = @ConditionID and TermTypeID = @ValueTypeID and IsDeleted = 0
                and (isnull(MinLimit, 0) = 0 or MinLimit <= @Amount)
                and (isnull(MaxLimit, 0) = 0 or @Amount < MaxLimit)
        order by isnull(MinLimit, 0), isnull(MaxLimit, 0), Value), 0);

    -- so, we have discount
    declare @Discount money = @Value + @Delay;

    -- update Lines
    update  o_DocImportPDALine
    set     Discount = @Discount,
            Price    = floor(BasePrice * (100.0 - @Discount) + 0.5) / 100.0,
            VatSum   = floor(BasePrice * (100.0 - @Discount) + 0.5) * Quantity * VatPercent / 10000.0
    where   DocID = @OrderID;

    -- update Order
    update  o_Document
    set     Amount = isnull((
                select  round(sum(Price * Quantity), 2) + round(sum(VatSum), 2)
                from    o_DocImportPDALine
                where   DocID = @OrderID), 0)
    where   OID = @OrderID;

    commit tran;
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderInsertUpdateLines)
    @OrderID    bigint,
    @Lines      TableValueType readonly
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    if not exists (select * from DocImportPDA where OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0)
        return;

    begin tran;

    update  l
    set     l.Ordered = i.Value,
            l.Quantity = i.Value
    from    o_DocImportPDALine l
            join @Lines i on i.Object = l.ItemID
    where   l.DocID = @OrderID;

    declare @IconIndex int = (select IconIndex from z_DocImportPDALine);
    insert into DocImportPDALine (OID, IconIndex, DocID, ItemID, BasePrice, Discount, Price, Ordered, Quantity, CasefillrateID, CostSum, VatPercent, VatSum, SortNO)
        select  dbo.NEWOID('DocImportPDALine'), @IconIndex, @OrderID, l.Object, 0, 0, 0, l.Value, l.Value, null, 0, 0, 0, null
        from    @Lines l
        where   not exists (select * from o_DocImportPDALine where DocID = @OrderID and ItemID = l.Object);

    exec cabinet_OrderUpdateAmounts @OrderID;

    commit tran;
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_OrderDeleteLines)
    @OrderID    bigint,
    @Lines      TableValueType readonly
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    if not exists (select * from DocImportPDA where OID = @OrderID and DocType = 'W' and State = 'E' and IsFinished = 0)
        return;

    begin tran;

    delete
        from    DocImportPDALine
        where   DocID = @OrderID and ItemID in (select Object from @Lines);

    exec cabinet_OrderUpdateAmounts @OrderID;

    commit tran;
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

PROCEDURE(cabinet_ConditionRulesGet)
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    declare @ConditionID bigint = 8000001692604; --TODO - move to Settings

    select  TermTypeID, FullName, MinLimit, MaxLimit, Value
    from    ConditionRule
    where   OwnerID = @ConditionID;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

-- =============================================================================================================

-- END OF FILE
