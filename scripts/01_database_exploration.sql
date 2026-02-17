/*
=====================================================
Datenbankerkundung
=====================================================
Zweck:
    - Erkundung der Datenbankstruktur, einschließlich der Liste der Tabellen und ihrer Schemata.
    - Überprüfung der Spalten und Metadaten für bestimmte Tabellen.

Verwendete Tabelle:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS

===============================================================================
*/

-- Liste aller Tabellen in der Datenbank abrufen
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Alle Spalten für eine bestimmte Tabelle (dim_customers) abrufen
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
