from sqlalchemy import create_engine, text

# MySQL local
mysql_engine = create_engine(
    "mysql+pymysql://root:@localhost:3306/food_app"
)

# PostgreSQL Neon
postgres_engine = create_engine(
    "postgresql://neondb_owner:npg_zkXYWgT5CGP4@ep-shy-mountain-aojdcxek-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
)

TABLES = [
    "area",
    "categories",
    "users",
    "restaurants",
    "restaurant_categories"
]

for table in TABLES:
    print(f"Migrating {table}...")

    with mysql_engine.connect() as mysql_conn:
        rows = mysql_conn.execute(
            text(f"SELECT * FROM {table}")
        ).mappings().all()

    if not rows:
        print(f"{table}: no data")
        continue

    with postgres_engine.begin() as pg_conn:

        for row in rows:
            columns = ", ".join(row.keys())
            placeholders = ", ".join(
                [f":{k}" for k in row.keys()]
            )

            sql = text(
                f"""
                INSERT INTO {table}
                ({columns})
                VALUES
                ({placeholders})
                """
            )

            try:
                pg_conn.execute(sql, row)
            except Exception as e:
                print(f"Skip: {e}")

    print(f"{table}: {len(rows)} rows migrated")

print("DONE")