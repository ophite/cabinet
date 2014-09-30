-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go

/* =============================================================================================================
    declare @FilterString varchar(128) = '"’мель*"';
    declare @TopRecords int = 10;

    exec cabinet_SubjectFilter @FilterString, @TopRecords;
   ============================================================================================================= */

PROCEDURE(cabinet_SubjectFilter)
    @FilterString   varchar(128),
    @TopRecords     int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    select  top (@TopRecords) i.OID, i.FullName
    from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f join o_Directory i on i.OID = f.[KEY]
    order by f.RANK desc

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

--=============================================================================================================
   
   PROCEDURE(cabinet_SubjectFilter)
    @FilterString   varchar(128),
    @TopRecords     int
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    select  top (@TopRecords) i.OID, i.FullName
    from    CONTAINSTABLE(o_Subject, FullTextSearch, @FilterString) f join o_Directory i on i.OID = f.[KEY]
    order by f.RANK desc

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

--=============================================================================================================

PROCEDURE(cabinet_SubjectGet)
    @SubjectID      bigint
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    select  d.OID, FullName = d.FullName
    from    Subject d
    where   d.OID = @SubjectID
    order by d.FullName;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

--=============================================================================================================
   
PROCEDURE(cabinet_SubjectDepartments)
    @SubjectID      bigint
as begin
    set nocount on;
    set transaction isolation level read uncommitted;
begin try

    select  d.OID, DepartmentName = d.FullName
    from    Department d
    where   d.OwnerID = @SubjectID and d.IsDeleted = 0
    order by d.FullName;
  
    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go
   
-- END OF FILE
