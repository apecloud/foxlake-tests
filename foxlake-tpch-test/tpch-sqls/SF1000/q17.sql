SELECT
    SUM(l_extendedprice) / 7.0 AS avg_yearly
FROM
    PART JOIN LINEITEM ON p_partkey = l_partkey
WHERE
    p_brand = 'Brand#23'
    AND p_container = 'MED BOX'
    AND l_quantity < (
              SELECT
                  0.2 * AVG(l_quantity)
              FROM
                  LINEITEM
              WHERE
                  l_partkey = p_partkey
              );