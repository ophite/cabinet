
-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go
-- =============================================================================================================

DROP(cabinet_Test)
go

DROP(cabinet_Branches);
go

/*
PROCEDURE(cabinet_Branches)
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    select  b.OID, BranchName = b.FullName
    from    Branch b
    where   b.IsDeleted = 0
    order by b.FullName

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go
*/

-- =============================================================================================================

DROP(cabinet_BranchByUser)
go

/*
PROCEDURE(cabinet_BranchByUser)
	@UserID bigint
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

	declare @BranchOwnerID bigint = OID_BY_GUID(GUID_REGION_CLASSIFICATION); -- 8000003129145;

	if exists (select * from CodaUser where OID = @UserID) begin

		select  e.OID as EmployeeID, e.ParentID
		into	#Employee
		from    Employee e
		where   e.CodaUserID = @UserID and IsDeleted = 0;

		with Tree (EmployeeID, DepartmentID, ParentID) as
		(
			select  e.EmployeeID, e.DepartmentID, d.ParentID from #Employee e, Department d where d.OID = e.DepartmentID
			union all
			select  t.EmployeeID, d.OID, d.ParentID from Tree t, Department d where d.OID = t.ParentID
		)
		select 	distinct l.ParentID as BranchID
		into	#Branch
		from    Tree t
				inner join Filial f on f.OID = t.DepartmentID
				inner join RegionLink l on l.ObjectID = f.OID and l.IsRemoved = 0 and l.OwnerID = @BranchOwnerID;

		if (select count(*) from #Branch) = 1
			select OID, BranchName = FullName from Branch where OID = (select OID from #Branch);
		else
			THROW('Branch must be unique for User');

	end else if exists (select * from Subject where OID = @UserID) begin

		select 	b.OID, BranchName = b.FullName
		from    RegionLink l
				inner join Branch b on b.OID = l.ParentID
		where	l.ObjectID = @UserID and l.IsRemoved = 0 and l.OwnerID = @BranchOwnerID;
	end else
		THROW('User not exists');

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go
*/
-- =============================================================================================================
