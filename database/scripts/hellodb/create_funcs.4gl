#+ Database creation script for SQLite
#+
#+ The database creation requires those method to be provided:
#+ - db_create_tables: Create all tables in database
#+ - db_drop_tables: Drop all tables from database
#+ - db_list_serials: List serials columns from all tables in database
#+
#+ Note: This script is a helper script to create tables of a database schema
#+       Adapt it to fit your needs

# Public types for creation scripts

#+ Define a dynamic array containing table / column pairs
PUBLIC TYPE TableColumns DYNAMIC ARRAY OF RECORD table STRING, column STRING END RECORD

#+ Create all tables in database.
#+
#+ Note: Any table created here should be dropped in db_drop_tables()

PUBLIC FUNCTION db_create_tables()
    WHENEVER ERROR STOP

    # Create tables
    CREATE TABLE accounts (
        userid INTEGER NOT NULL PRIMARY KEY,
        firstname CHAR(80) NOT NULL,
        lastname CHAR(80) NOT NULL
    )
    CREATE TABLE orders (
        orderid INTEGER NOT NULL PRIMARY KEY,
        userid INTEGER NOT NULL,
        description CHAR(80),
        FOREIGN KEY(userid)
            REFERENCES accounts(userid)
    )

    # Populate tables
    CALL populate_tables()

END FUNCTION

#+ Drop all tables from database.
#+
#+ Note: Any table dropped here should be created in db_create_tables()
FUNCTION db_drop_tables()
    WHENEVER ERROR CONTINUE

    # Drop tables
    DROP TABLE accounts
    DROP TABLE orders
END FUNCTION

#+ List serials columns from all tables in database.
#+
#+ Note: Any table column containing serials should be listed here
#+
#+ @return The list of serial table columns
FUNCTION db_list_serials() RETURNS TableColumns

    # List SERIAL columns
    DEFINE cols TableColumns = [
        (table: "accounts", column: "userid"),
        (table: "orders", column: "orderid")
    ]
    RETURN cols
END FUNCTION

#+ Populate tables with values.
#+
FUNCTION populate_tables()
    INSERT INTO accounts VALUES (1, "Marcel", "Dupont")
    INSERT INTO accounts VALUES (2, "Zoé", "Test")
    INSERT INTO accounts VALUES (3, "Albert", "Martin")

    INSERT INTO orders VALUES (1, 1, "First order for Marcel")
    INSERT INTO orders VALUES (2, 3, "Order from Albert")
    INSERT INTO orders VALUES (3, 1, "Another order from Marcel")
END FUNCTION
