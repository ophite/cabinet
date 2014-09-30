cmd = """
exec cabinet_Test
"""
cmd = """ SET ANSI_NULLS, \
        QUOTED_IDENTIFIER, \
        CONCAT_NULL_YIELDS_NULL, \
        ANSI_WARNINGS, \
        ANSI_PADDING, \
        ARITHABORT ON; """  + cmd
cmd = cmd.encode('UTF-8')

import pyodbc
import settings

class CodaDBError(pyodbc.DatabaseError):
    def __init__(self, message):
        pyodbc.DatabaseError.__init__(self)
        self.error_text = message[1][29:-25]

connection = ';'.join([k + '=' + v for k,v in settings.SQL_DATABASES.items()])
con = pyodbc.connect(connection)
cur = con.cursor()
try:
	cur.execute(cmd)
except pyodbc.DatabaseError as inst:
    print(CodaDBError(inst).error_text)

