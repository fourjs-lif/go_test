SCHEMA "hellodb"

MAIN
    DEFINE arr DYNAMIC ARRAY OF RECORD LIKE accounts.*
    DEFINE i INTEGER

    CLOSE WINDOW screen

    DATABASE "hellodb"

    DECLARE curs CURSOR FOR SELECT * FROM accounts 
    LET i = 1
    FOREACH curs INTO arr[i].*
        LET i = i+1
    END FOREACH
    CALL arr.deleteElement(arr.getLength())

    OPEN WINDOW w WITH FORM "accounts"

    DISPLAY ARRAY arr TO s_accounts.*
        ON ACTION quit
            EXIT DISPLAY
    END DISPLAY

    CLOSE WINDOW w
END MAIN