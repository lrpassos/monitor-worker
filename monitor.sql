import os
import time
import psycopg2
from ping3 import ping

DATABASE_URL = os.getenv("DATABASE_URL")

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True

while True:

    try:

        cursor = conn.cursor()

        cursor.execute("""
            SELECT ip
            FROM ips
            WHERE ativo = true
        """)

        ips = cursor.fetchall()

        for item in ips:

            ip = item[0]

            resposta = ping(ip, timeout=2)

            status = "Ativo" if resposta else "Inativo"

            resposta_ms = (
                str(round(resposta * 1000, 2))
                if resposta
                else "Timeout"
            )

            cursor.execute("""
                INSERT INTO historico_ping
                (ip, status, resposta_ms)
                VALUES (%s, %s, %s)
            """, (ip, status, resposta_ms))

            print(f"{ip} - {status}")

        cursor.close()

    except Exception as e:
        print("Erro:", e)

    time.sleep(300)
