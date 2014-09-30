--=============================================================================================================
--  Error Message Codes
--=============================================================================================================

#ifndef __MESSAGES_HQL__
#define __MESSAGES_HQL__

--=============================================================================================================

#define  ERR_PAPER_ALREADY_EXISTS                       50001
#define  ERR_INVALID_OWNER_PARENT                       50002
#define  ERR_RECURSION_LEVEL_EXCEEDED                   50003
#define  ERR_CANT_DEFINE_OWNER                          50004
#define  ERR_INVALID_PARENT                             50005
#define  ERR_INVALID_CLASS_FOR_CREATOR                  50006
#define  ERR_CANT_CHANGE_OWNER                          50007
#define  ERR_REPLACE_OBJECT_DELETED                     50008
#define  ERR_REPLACE_GUID                               50009
#define  ERR_RESTORE_EXISTS                             50010
#define  ERR_RESTORE_HAS_HISTORY                        50011
#define  ERR_STREET_VALUE                               50012
#define  ERR_CANT_DELETE_ADDRESS                        50013
#define  ERR_CANT_CLONE_BANKACCOUNT                     50014
#define  ERR_CANT_CLONE_COUNTRY                         50015
#define  ERR_CANT_CREATE_ADDRESS                        50016
#define  ERR_CANT_DELETE_EMPLOYEE_SUBJECT               50017
#define  ERR_CANT_DELETE_EMPLOYEE_DEPARTMENT            50018
#define  ERR_CANT_DELETE_EMPLOYEE_CONTRACT              50019
#define  ERR_CANT_CREATE_ENUM                           50020
#define  ERR_CANT_DELETE_INDIVIDUAL_SUBJECT             50021
#define  ERR_CANT_DELETE_INDIVIDUAL_EMPLOYEE            50022
#define  ERR_CANT_CLONE_PROVINCE                        50023
#define  ERR_CANT_CLONE_REGION                          50024
#define  ERR_ILLEGAL_SECURITY_GROUP                     50025
#define  ERR_CANT_CREATE_SETTLEMENT                     50026
#define  ERR_CANT_CLONE_SETTLEMENT                      50027
#define  ERR_CANT_CREATE_STREET                         50028
#define  ERR_CANT_CLONE_STREET                          50029
#define  ERR_DUPLICATE_ADDRESS_SUBJECT                  50030
#define  ERR_DUPLIÑATE_LAWADDRESS_SUBJECT               50031
#define  ERR_CANT_CREATE_LOWADDRESS                     50032
#define  ERR_TRANSACTIONS_PROHIBITED                    50033
#define  ERR_NAME_EXISTS                                50034
#define  ERR_CANT_REMOVE_ROOT_SID                       50035
#define  ERR_CANT_INSERT_SET_INTO_SET                   50036
#define  ERR_CANT_REPLACE_REFERENCES                    50037
#define  ERR_SUBJECT_IS_NOT_FIRM                        50038
#define  ERR_DOC_VALIDATE                               50039
#define  ERR_CANT_REPLACE_DOCUMENTS_EXIST               50040
#define  ERR_CANT_DELETE_REFERENCES_EXISTS              50041
#define  ERR_CANT_RESTORE_PARENT_DELETED                50042
#define  ERR_CANT_MODIFY_ANALYTIC                       50043
#define  ERR_ACCOUNTS_CODING_VALIDATION_FAILED          50044
#define  ERR_CHECK_TABLE_ALREADY_EXISTS                 50045
#define  ERR_ACCOUNT_IN_USE                             50046
#define  ERR_MISSING_OBJECT                             50047
#define  ERR_OPERATION                                  50048
#define  ERR_PARAMETERS                                 50049
#define  ERR_REPLACE_IMPOSSIBLE_TOO_MANY_REFERENCES     50050
#define  ERR_VALIDATION_FAILED                          50051
#define  ERR_ILLEGAL_DATA                               50052
#define  ERR_ILLEGAL_OBJECT_DATA                        50053
#define  ERR_INVALID_PROCEDURE                          50054
#define  ERR_INVALID_OBJECT                             50055
#define  ERR_UNIQUE_CHECK                               50056

#define  ERR_TOO_MANY_RECORDS                           50057
#define  ERR_DOC_OUTSIDER                               50058
#define  ERR_DOC_COMITTED                               50058

#define  ERR_CANT_DELETE_WITH_REASON                    50059
#define  ERR_CODAUSER_EXISTS                            50060

#define  ERR_SPECIFICATION_ALREADY_ASSIGNED             50061
#define  ERR_CONDITIONPRICE_EXTRACODE                   50062
#define  ERR_CONDITIONPRICE_PRICE_ZERO                  50063

#define  ERR_DOCUMENT_SPLITTED                          50064

#define  ERR_CONTRACT_TWINS                             50065

#define  ERR_INVALID_SOURCEDOC                          50067

#define  ERR_DUBLICATE_ROW                              50068

#define  ERR_INVALID_SALEPOINT_FOR_SELLERPOINT          50069
#define  ERR_UNKNOWN_ROLE_FOR_DOCIMPORT                 50070

#define  ERR_INSUFFICIENT_STOCK                         50071
#define  ERR_INVALID_DELIVERY                           50072
#define  ERR_NULL_SALEPOINT                             50073

#define  ERR_INVALID_EMPLOYEE_FIRM                      50074
#define  ERR_INVALID_FILIAL_FIRM                        50075
#define  ERR_INVALID_EMPLOYEE_DELETED                   50076

#define  ERR_INVALID_CONTRACT_FIRM                      50077
#define  ERR_INVALID_CONTRACT_SUBJECT                   50078
#define  ERR_INVALID_DEPARTMENT_SUBJECT                 50079

#define  ERR_DOCUMENT_READ_ONLY                         50080

#define  ERR_DOCUMENT_EDI_GONE                          50081
#define  ERR_DOCMOVE_REFLEXIV                           50082

#define  ERR_DOCUMENT_ONLY_DOC                          50083

--=============================================================================================================

#endif // __MESSAGES_HQL__
