
-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go
-- =============================================================================================================

PROCEDURE(cabinet_CodaUserByName)
    @UserName varchar(128)
as begin
    set nocount on;
    set transaction isolation level read committed;
begin try

    select 	OID, UserName = Name  
    from 	CodaUser 
    where 	Name = @UserName;

    return 0;

end try
begin catch
    THROW_UP;
end catch
end
go

--=============================================================================================================
