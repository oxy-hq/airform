#!/usr/bin/env python3
"""Execute SQL against Snowflake and return JSON results.

Usage: echo "SELECT 1" | python3 sf_exec.py
   Or: python3 sf_exec.py "SELECT 1"
   Or: python3 sf_exec.py --multi "stmt1" "stmt2" "stmt3"

Returns JSON: {"success": true, "columns": [...], "rows": [...], "rowcount": N}
"""
import json
import os
import sys

def main():
    from dotenv import load_dotenv
    load_dotenv()

    import snowflake.connector

    conn = snowflake.connector.connect(
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        warehouse=os.environ.get('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH'),
        database=os.environ.get('SNOWFLAKE_DATABASE', 'AIRFORM_TEST'),
    )

    try:
        if len(sys.argv) > 1 and sys.argv[1] == '--multi':
            # Multi-statement mode: execute each arg as a separate statement
            statements = sys.argv[2:]
            cur = conn.cursor()
            for stmt in statements:
                cur.execute(stmt)
            # Return result of last statement
            result = format_result(cur)
        elif len(sys.argv) > 1:
            sql = sys.argv[1]
            cur = conn.cursor()
            cur.execute(sql)
            result = format_result(cur)
        else:
            sql = sys.stdin.read().strip()
            cur = conn.cursor()
            cur.execute(sql)
            result = format_result(cur)

        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"success": False, "message": str(e)}))
        sys.exit(1)
    finally:
        conn.close()

def format_result(cur):
    columns = [desc[0] for desc in cur.description] if cur.description else []
    rows = cur.fetchall() if cur.description else []
    # Convert to JSON-serializable format
    json_rows = []
    for row in rows:
        json_row = []
        for val in row:
            if val is None:
                json_row.append(None)
            else:
                json_row.append(str(val))
        json_rows.append(json_row)

    return {
        "success": True,
        "columns": columns,
        "rows": json_rows,
        "rowcount": len(json_rows),
    }

if __name__ == '__main__':
    main()
