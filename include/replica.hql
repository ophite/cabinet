#ifndef __REPLICA_HQL__
#define __REPLICA_HQL__

#include "macroses.hql"

// test macro definitions for replication

#define ADDRESS_SELECTXML(_OID, _NodeID, _TST)                                                          \
        (                                                                                               \
        select  GUID                                                        [@GUID],                    \
                GUID_BY_OID(z1.ParentID)                                    [@ParentGUID],              \
                GUID_BY_OID(z1.OwnerID)                                     [@OwnerGUID],               \
                                                                                                        \
                Name                                                        [@Name],                    \
                FullName                                                    [@FullName],                \
                Comments                                                    [@Comments],                \
                                                                                                        \
                CODE                                                        [@CODE],                    \
                LOCCODE                                                     [@LOCCODE],                 \
                PostalCode                                                  [@PostalCode],              \
                GUID_BY_OID(z1.SettlementID)                                [@SettlementGUID],          \
                GUID_BY_OID(z1.StreetID)                                    [@StreetGUID],              \
                HouseNO                                                     [@HouseNO],                 \
                ExtraName                                                   [@ExtraName],               \
                FlatNO                                                      [@FlatNO]                   \
        from    PREFIX.Address z1                                                                       \
        where   OID = _OID and IsDeleted = 0                                                            \
        for xml path('Address'), type                                                                   \
        )

#define BANKACCOUNT_SELECTXML(_OID, _NodeID, _TST)                                                      \
        (                                                                                               \
        select  GUID                                                        [@GUID],                    \
                GUID_BY_OID(z2.ParentID)                                    [@ParentGUID],              \
                GUID_BY_OID(z2.OwnerID)                                     [@OwnerGUID],               \
                                                                                                        \
                Name                                                        [@Name],                    \
                FullName                                                    [@FullName],                \
                Comments                                                    [@Comments],                \
                                                                                                        \
                SortNO                                                      [@SortNO],                  \
                AccountNO                                                   [@AccountNO],               \
                GUID_BY_OID (z2.BankID)                                     [@BankGUID],                \
                GUID_BY_ENUM_OID (z2.CurrencyTypeID)                        [@CurrencyTypeGUID]         \
                                                                                                        \
        from    PREFIX.BankAccount z2                                                                   \
        where   OID = _OID                                                                              \
        for xml path('BankAccount'), type                                                               \
        )

#define EMPLOYEE_SELECTXML(_OID, _NodeID, _TST)                                                         \
        (                                                                                               \
        select  GUID                                                        [@GUID],                    \
                GUID_BY_OID(z3.ParentID)                                    [@ParentGUID],              \
                GUID_BY_OID(z3.OwnerID)                                     [@OwnerGUID],               \
                                                                                                        \
                Name                                                        [@Name],                    \
                FullName                                                    [@FullName],                \
                Comments                                                    [@Comments],                \
                                                                                                        \
                EMail                                                       [@EMail],                   \
                Phone                                                       [@Phone],                   \
                GUID_BY_ENUM_OID(z3.DutyTypeID)                             [@DutyTypeGUID],            \
                GUID_BY_OID(z3.IndividualID)                                [@IndividualGUID]           \
                                                                                                        \
        from    PREFIX.Employee z3                                                                      \
        where   OID = _OID                                                                              \
        for xml path('Employee'), type                                                                  \
        )

#define DEPARTMENT_SELECTXML(_OID, _NodeID, _TST)                                                       \
        (                                                                                               \
        select  GUID                                                        [@GUID],                    \
                GUID_BY_OID(z4.ParentID)                                    [@ParentGUID],              \
                GUID_BY_OID(z4.OwnerID)                                     [@OwnerGUID],               \
                                                                                                        \
                Name                                                        [@Name],                    \
                FullName                                                    [@FullName],                \
                Comments                                                    [@Comments],                \
                                                                                                        \
                Phone                                                       [@Phone],                   \
                Fax                                                         [@Fax],                     \
                                                                                                        \
                GUID_BY_OID(z4.ManagerID)                                   [@ManagerGUID],             \
                                                                                                        \
                ADDRESS_SELECTXML(z4.AddressID, _NodeID, _TST)                                          \
        from    PREFIX.Department z4                                                                    \
        where   OID = _OID                                                                              \
        for xml path('Department'), type                                                                \
        )

#define SUBJECT_SELECTXML(_OID, _NodeID, _TST)                                                                                          \
        (                                                                                                                               \
        select  GUID                                                        [@GUID],                                                    \
                GUID_BY_OID(z.ParentID)                                     [@ParentGUID],                                              \
                GUID_BY_OID(z.OwnerID)                                      [@OwnerGUID],                                               \
                                                                                                                                        \
                Name                                                        [@Name],                                                    \
                FullName                                                    [@FullName],                                                \
                Comments                                                    [@Comments],                                                \
                                                                                                                                        \
                Phone                                                       [@Phone],                                                   \
                Fax                                                         [@Fax],                                                     \
                Kind                                                        [@Kind],                                                    \
                ShortName                                                   [@ShortName],                                               \
                GUID_BY_ENUM_OID(z.TaxTypeID)                               [@TaxTypeGUID],                                             \
                GUID_BY_OID(z.DirectorID)                                   [@DirectorGUID],                                            \
                GUID_BY_OID(z.AccountantID)                                 [@AccountantGUID],                                          \
                IsSupplier                                                  [@IsSupplier],                                              \
                IsCustomer                                                  [@IsCustomer],                                              \
                GUID_BY_OID(z.IndividualID)                                 [@IndividualGUID],                                          \
                                                                                                                                        \
                (select ADDRESS_SELECTXML(z.AddressID, _NodeID, _TST) for xml path(''), type, root('MainAddress')),                     \
                (select ADDRESS_SELECTXML(z.LawAddressID, _NodeID, _TST) for xml path(''), type, root('LawAddress')),                   \
                                                                                                                                        \
                (                                                                                                                       \
                select  BANKACCOUNT_SELECTXML(OID, _NodeID, _TST)                                                                       \
                from    PREFIX.BankAccount                                                                                              \
                where   OwnerID = z.OID and IsDeleted = 0 and TST > _TST                                                                \
                order by SortNO                                                                                                         \
                for xml path(''), type, root('BankAccounts')                                                                            \
                ),                                                                                                                      \
                                                                                                                                        \
                (                                                                                                                       \
                select  EMPLOYEE_SELECTXML(OID, _NodeID, dbo.Mapping_TST(_NodeID, GUID, _TST))                                          \
                from    PREFIX.Employee                                                                                                 \
                where   OwnerID = z.OID and IsDeleted = 0 and TST > dbo.Mapping_TST(_NodeID, GUID, _TST)                                \
                for xml path(''), type, root('Employees')                                                                               \
                ),                                                                                                                      \
                                                                                                                                        \
                (                                                                                                                       \
                select  DEPARTMENT_SELECTXML(d.OID, _NodeID, dbo.Mapping_TST(_NodeID, d.GUID, _TST))                                    \
                from    PREFIX.Department d, PREFIX.Classes c                                                                           \
                where   d.OwnerID = z.OID and d.IsDeleted = 0 and d.TST > dbo.Mapping_TST(_NodeID, d.GUID, _TST) and c.CID = d.CID      \
                for xml path(''), type, root('Departments')                                                                             \
                )                                                                                                                       \
                                                                                                                                        \
        from    PREFIX.Subject z                                                                                                        \
        where   OID = _OID                                                                                                              \
        for xml path('Subject'), type                                                                                                   \
        )


-- линки уходят либо по TST, либо при наличии временной подписки
#define LINK_SELECTXML(_NodeID, _TST, _StopTST)                                                                                                 \
        (                                                                                                                                       \
        select  dbo.Link_SelectXMLByClassName(c.class_name, l.OID, _NodeID, _TST, _StopTST)                                                     \
        from    o_Link l                                                                                                                        \
                join Classes c on c.CID = l.CID                                                                                                 \
                join o_Directory d on d.OID = l.ObjectID                                                                                        \
        where   l.ParentID = z.OID and                                                                                                          \
                exists (select * from o_Mapping m where m.GUID = d.GUID and m.StartTST > 0x00 and m.NodeID = _NodeID) and                       \
                ((l.TST > _TST and d.TST <= _StopTST) or exists(select * from Mapping ml where ml.GUID = l.GUID and ml.NodeID = _NodeID))       \
        for xml path(''), type                                                                                                                  \
        )

#endif // __REPLICA_HQL__
