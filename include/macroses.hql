//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Макросы
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#ifndef __MACROSES_HQL__
#define __MACROSES_HQL__

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#define CR char(13)
// DEFAULT for missing parameters
#define MISSING -31415926
// for rounding
#define EPSILON cast(0.00000000000001 as float)
// just very big number
#define BIGNUMBER cast(999999999999999999 as bigint)
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define ___STRING(a)            #a
#define __STRING(a)             ___STRING(#a)
#define MAC_STRING(a)           __STRING(a)
#define PRINT_LINE(s)           print MAC_STRING(Line __LINE__: s)
#define __CONCAT(x,y)           x ## y
#define CONCAT(x,y)             __CONCAT(x, y)
#define __CONCAT3(x,y,z)        x ## y ## z
#define CONCAT3(x,y,z)          __CONCAT3(x, y, z)
#define TRIM(x)                 ltrim(rtrim(x))
#define STRING(x)               isnull(cast(x as varchar(255)), 'NULL')

// unique variable name
#define VARIABLE(x)             CONCAT(x, __LINE__)

#define SLEEP                   if @@trancount = 0 waitfor delay '00:00:00.01'

// shrink multiple spaces
#define STR_PACK(_s)            set _s = ltrim(rtrim(_s)); while charindex('  ', _s) > 0 set _s = replace(_s, '  ', ' ')
// first token (_char delimited)
#define STR_TOKEN(_s, _char)    IIF(charindex(_char, TRIM(_s)) > 0, substring(TRIM(_s), 1, charindex(_char, TRIM(_s)) - 1), TRIM(_s))
// rest of string without first token (_char delimited)
#define STR_REST(_s, _char)     IIF(charindex(_char, TRIM(_s)) = 0, '', substring(TRIM(_s), charindex(_char, TRIM(_s)) + 1, 4000))

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define UNQUOTE(s)              replace (s, '''', '’') //В АДВ проблемы с кавычкой в Аксесе

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define PROCEDURE(p)            if exists (select * from sysobjects where id = object_id(MAC_STRING(p))) drop procedure p; [go] PRINT_LINE(p); [go] create procedure p
#define FUNCTION(f)             if exists (select * from sysobjects where id = object_id(MAC_STRING(f))) drop function  f; [go] PRINT_LINE(f); [go] create function  f
#define VIEW(v)                 if exists (select * from sysobjects where id = object_id(MAC_STRING(v))) drop view      v; [go] PRINT_LINE(v); [go] create view      v
#define TRIGGER(t)              if exists (select * from sysobjects where id = object_id(MAC_STRING(t))) drop trigger   t; [go] PRINT_LINE(t); [go] create trigger   t
#define SYNONYM(s)              if exists (select * from sysobjects where id = object_id(MAC_STRING(s))) drop synonym   s; [go] PRINT_LINE(s); [go] create synonym   s

#define DROP(p)                                                                 \
    declare @t char (2)                                                         \
    set @t = (select type from sysobjects where id = object_id(MAC_STRING(p)))  \
         if (@t = 'p' ) drop procedure p                                        \
    else if (@t = 'tr') drop trigger   p                                        \
    else if (@t = 'v' ) drop view      p                                        \
    else if (@t in ('f', 'fn', 'fs', 'if')) drop function  p                    \
    else if (@t = 'u' ) drop table     p

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define IIF(x,y,z)              (case when x then y else z end)
#define MIN(x, y)               IIF(x < y, x, y)
#define MAX(x, y)               IIF(x > y, x, y)

// non zero conversion
#define NZ(z)                   IIF(isnull(z, 0) = 0, 1, z)

#define TRUNC_DATE(x)           convert(varchar,x,112)
#define MAC_DATE(x)             convert(char(6), x, 112) + '01'

#define ISO_DATE_TO_STRING(x)   convert(varchar(24), (x), 126) // ISO 86001 yyyy-mm-ddThh:mi:ss.mmm
#define EDI_DATE(x)             convert(varchar(10), (x), 120) // yyyy-mm-dd
#define TO_DATE(s) (IIF( (ISDATE(s)=1), cast(s as datetime), NULL))

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// XML

#define EMPTY_XML(x)            (isnull(cast(x as varchar(max)), '') = '')

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define PAUSE                           if (@@trancount = 0)  waitfor delay '00:00:00.1'

#define WRITE(_s)                       raiserror(_s, 0, 1) with nowait
#define WRITE_2(_s, _p1)                raiserror(_s, 0, 1, _p1) with nowait
#define WRITE_3(_s, _p1, _p2)           raiserror(_s, 0, 1, _p1, _p2) with nowait
#define WRITE_4(_s, _p1, _p2, _p3)      raiserror(_s, 0, 1, _p1, _p2, _p3) with nowait
#define WRITE_5(_s, _p1, _p2, _p3, _p4) raiserror(_s, 0, 1, _p1, _p2, _p3, _p4) with nowait

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//#define TIMER_BEGIN                     declare @timer datetime = getdate(); declare @timer_str varchar(32)
//#define TIMER_WRITE(x)                  set @timer_str = MAC_STRING(x) + ' = ' + convert(varchar(32), datediff(ms, @timer, getdate())); set @timer = getdate(); WRITE(@timer_str)
#define TIMER_BEGIN
#define TIMER_WRITE(x)

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define THROW(_s)                       begin if (@@trancount > 0) rollback tran; raiserror (_s, 16, 1) end

// with additional params
#define THROW_2(_s, _p1)                begin if (@@trancount > 0) rollback tran; declare VARIABLE(@err1) varchar(128); select VARIABLE(@err1)=isnull(cast(_p1 as varchar(128)), '[1]'); raiserror (_s, 16, 1, VARIABLE(@err1)) end
#define THROW_3(_s, _p1, _p2)           begin if (@@trancount > 0) rollback tran; declare VARIABLE(@err1) varchar(128), VARIABLE(@err2) varchar(128); select VARIABLE(@err1)=isnull(cast(_p1 as varchar(128)),'[1]'), VARIABLE(@err2)=isnull(cast(_p2 as varchar(128)), '[2]');  raiserror (_s, 16, 1, VARIABLE(@err1), VARIABLE(@err2)) end
#define THROW_4(_s, _p1, _p2, _p3)      begin if (@@trancount > 0) rollback tran; raiserror (_s, 16, 1, _p1, _p2, _p3) end
#define THROW_5(_s, _p1, _p2, _p3, _p4) begin if (@@trancount > 0) rollback tran; raiserror (_s, 16, 1, _p1, _p2, _p3, _p4) end

// for SQL2000 compatibility
#define CHECK_ERROR(_msg)           \
    if (@@error != 0) begin         \
        THROW(_msg);                \
        return 1;                   \
    end

// for SQL2000 compatibility
#define CHECK_ERROR_TRIGGER(_msg)   \
        if (@@error != 0) begin     \
            THROW(_msg);            \
            return;                 \
        end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// check @@rowcount and exit trigger if @@rowcount==0
#define TRIGGER_CHECK begin declare @_rowcount int; set @_rowcount = @@rowcount; if @_rowcount = 0 return; end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  rollback + передать ошибку выше

#define THROW_UP \
    begin  \
        if (@@trancount > 0) rollback tran;  \
        declare VARIABLE(@_ErrorMessage) varchar(max), VARIABLE(@_ErrorNumber) int, VARIABLE(@_ErrorLine) int, VARIABLE(@_ErrorProcedure) nvarchar(255);  \
        select VARIABLE(@_ErrorNumber) = ERROR_NUMBER(), VARIABLE(@_ErrorLine) = ERROR_LINE(), VARIABLE(@_ErrorProcedure) = ISNULL(ERROR_PROCEDURE(), '-');  \
        select VARIABLE(@_ErrorMessage) = 'ERROR: %d, PROC: %s, LINE: %d' + char(13) + char(10) + ERROR_MESSAGE();  \
        raiserror (VARIABLE(@_ErrorMessage), 16, 1, VARIABLE(@_ErrorNumber), VARIABLE(@_ErrorProcedure), VARIABLE(@_ErrorLine));  \
        return;  \
    end

//  rollback + передать ошибку выше
#define THROW_ERROR_ONLY_MSG \
    begin  \
        if (@@trancount > 0) rollback tran;  \
        declare VARIABLE(@_ErrorMessage) varchar(max), VARIABLE(@_ErrorNumber) int, VARIABLE(@_ErrorLine) int, VARIABLE(@_ErrorProcedure) nvarchar(255);  \
        select VARIABLE(@_ErrorNumber) = ERROR_NUMBER(), VARIABLE(@_ErrorLine) = ERROR_LINE(), VARIABLE(@_ErrorProcedure) = ISNULL(ERROR_PROCEDURE(), '-');  \
        select VARIABLE(@_ErrorMessage) = 'ERROR: %d, PROC: %s, LINE: %d' + char(13) + char(10) + ERROR_MESSAGE();  \
        raiserror (VARIABLE(@_ErrorMessage), 0, 1, VARIABLE(@_ErrorNumber), VARIABLE(@_ErrorProcedure), VARIABLE(@_ErrorLine));  \
        return;  \
    end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  debug

#ifdef DEBUG
#define DEBUG_PRINT(_s) print _s
#else
#define DEBUG_PRINT(_s) ;
#endif

#ifndef NO_ASSERT
#define ASSERT(_cond) begin if (not (_cond)) THROW_2('ASSERTION FAILED : %s', MAC_STRING(_cond)); end
#else
#define ASSERT(_cond, _msg) ;
#endif

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// append cursor results to string

#define SUM_STRING(cr, str)                     begin                                       \
                                                    declare VARIABLE(@s_) varchar(max);     \
                                                    open cr;                                \
                                                    fetch cr into VARIABLE(@s_);            \
                                                    while @@fetch_status = 0 begin          \
                                                        set str = str + VARIABLE(@s_);      \
                                                        fetch cr into VARIABLE(@s_);        \
                                                    end;                                    \
                                                    close cr;                               \
                                                    deallocate cr;                          \
                                                end

#endif // __MACROSES_HQL__
