#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER lambertus WITH SUPERUSER PASSWORD '@Hasbunalloh2024';
        CREATE USER komar WITH SUPERUSER PASSWORD '@Hasbunalloh2024';
        CREATE USER odoo WITH SUPERUSER PASSWORD '@Hasbunalloh2024';
        CREATE USER offline WITH PASSWORD 'ra#asia';
EOSQL
