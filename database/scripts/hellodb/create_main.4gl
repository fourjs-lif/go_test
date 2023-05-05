#+ Database creation script for SQLite

IMPORT FGL create_funcs

MAIN
    DATABASE "hellodb"

    CALL main_drop_tables()
    CALL main_create_tables()
    CALL main_update_seqreg()
END MAIN

#+ Create all tables in database.
FUNCTION main_create_tables()
    WHENEVER ERROR STOP

    # Create user tables
    CALL create_funcs.db_create_tables()

    # Required: System table handling the serial sequence generators
    EXECUTE IMMEDIATE "CREATE TABLE seqreg (
        sr_name VARCHAR(30) NOT NULL,
        sr_last INTEGER NOT NULL,
        CONSTRAINT pk_seqreg PRIMARY KEY(sr_name)
    )"
END FUNCTION

#+ Drop all tables from database.
FUNCTION main_drop_tables()
    WHENEVER ERROR CONTINUE

    # Drop user tables
    CALL create_funcs.db_drop_tables()

    # Required: System table handling the serial sequence generators
    EXECUTE IMMEDIATE "DROP TABLE seqreg"
END FUNCTION

#+ Update the System table handling the serial sequence generators
FUNCTION main_update_seqreg()
    DEFINE columns create_funcs.TableColumns
    DEFINE i INTEGER

    # List serial columns from user tables
    LET columns = create_funcs.db_list_serials()

    FOR i = 1 TO columns.getLength()
        CALL main_update_seqreg_value(columns[i].table, columns[i].column)
    END FOR
END FUNCTION

#+ Update the System table handling the serial sequence generators for the
#+ given table and field
#+
#+ @param tableName Name of the table using a serial sequence generator
#+ @param serialFieldName Name of the serial field
FUNCTION main_update_seqreg_value(tableName, serialFieldName)
    DEFINE
        tableName       STRING,
        serialFieldName STRING,
        lastSerial      INTEGER

    WHENEVER ERROR STOP

    DELETE FROM seqreg WHERE sr_name = tableName

    # Get the largest serial value found in the table data
    PREPARE selectmax FROM "SELECT MAX(" || serialFieldName || ") FROM " || tableName
    EXECUTE selectmax INTO lastSerial
    FREE selectmax

    IF lastSerial IS NULL THEN
        LET lastSerial = 0
    END IF

    INSERT INTO seqreg(sr_name, sr_last) VALUES (tableName, lastSerial)
END FUNCTION
