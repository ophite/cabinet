select	OID, PaperRegistrationCode, FullName
from	Subject
where	OID in 
		(
		select	top 10 d.CustomerID
		from	DocSale d
				join Subject s on d.CustomerID = s.OID and s.IsDeleted = 0
		where	d.DocDate between '20101201' and '20101231'
				and d.BranchID = 8000003129149
				and	s.PaperRegistrationCode is not null
				and s.PaperVATCode is not null
				and (select count(*) from Department where OwnerID = s.OID and IsDeleted = 0) = 1
		group by d.CustomerID
		order by count(*) desc
		)
