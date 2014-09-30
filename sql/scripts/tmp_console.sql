
-- =============================================================================================================

#include "macroses.hql"
#include "sigma.hql"
#include "messages.hql"
#include "coda.hql"

-- =============================================================================================================

set quoted_identifier on;
go
-- =============================================================================================================

--use me to run a custom query

-- =============================================================================================================

use coda

select  d.OID as DocID, d.CustomerID, d.DepartmentID as SalepointID, l.OID as LineID, s.OID as SubBrandID, b.OID as BrandID, b.ParentID as VendorID
into    #LineTradeMark
from    DocImportPDA d
	inner join DocImportPDALine l on l.DocID = d.OID
	inner join Item i on i.OID = l.ItemID
	inner join Product p on p.OID = i.ParentID
	inner join SubBrand s on s.OID = p.ParentID
	inner join Brand b on b.OID = s.ParentID
where   d.OID = 198000035405487;

--select 	sp.SellerID, sp.SubjectID, sp.SalepointID
--from 	SellerPoint sp, Seller s where s.OID = sp.SellerID
		--and sp.SubjectID = 8000000165438 and (sp.SalepointID = 8000000227268 or sp.SalepointID is null)
		--and s.IsDeleted = 0

-- однозначно определенные сейлсы
select  distinct t.DocID, t.LineID, min(m.SellerID) as SellerID, IIF(m.TradeMarkID = t.SubBrandID, 0, IIF(m.TradeMarkID = t.BrandID, 1, 2)) as BrandLevel
from    #LineTradeMark t
	inner join SellerPoint sp on sp.SubjectID = t.CustomerID and isnull(t.SalepointID, -1) = isnull(sp.SalepointID, isnull(t.SalepointID, -1))
	inner join SellerTrademark m on m.TradeMarkID in (t.SubBrandID, t.BrandID, t.VendorID)
	inner join Seller s on s.OID = sp.SellerID and s.OID = m.SellerID and s.IsDeleted = 0
group by t.DocID, t.LineID, m.TradeMarkID, t.SubBrandID, t.BrandID;





















go

