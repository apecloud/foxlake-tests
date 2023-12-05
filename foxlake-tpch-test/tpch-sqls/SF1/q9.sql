SELECT
    nation, o_year, SUM(amount) AS sum_profit
FROM
    (SELECT
        n_name AS nation,
            YEAR(o_ORDERdate) AS o_year,
            l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity AS amount
    FROM
        PART
    JOIN PARTSUPP
    JOIN LINEITEM
    JOIN SUPPLIER
    JOIN ORDERS
    JOIN NATION
    WHERE
        s_suppkey = l_suppkey
            AND ps_suppkey = l_suppkey
            AND ps_partkey = l_partkey
            AND p_partkey = l_partkey
            AND o_ORDERkey = l_ORDERkey
            AND s_nationkey = n_nationkey
            AND p_name LIKE '%green%') AS profit
GROUP BY nation , o_year
ORDER BY nation , o_year DESC;
