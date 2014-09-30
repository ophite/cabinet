
-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go
-- =============================================================================================================

declare @sql nvarchar(max), @name varchar(128);
declare @cr cursor;

set @cr = cursor for
    select name from sys.objects where type = 'p' and name like 'cabinet_%'
    order by name;

open @cr;

fetch @cr into @name;
while @@fetch_status = 0 begin
    set @sql = 'grant execute on ' + @name + ' to pydev';
    exec sp_executesql @sql;

    fetch @cr into @name;
end;

close @cr;
deallocate @cr;
go

grant execute on Enumerator_SerialIncrement to pydev
grant execute on type::TableValueType to pydev
