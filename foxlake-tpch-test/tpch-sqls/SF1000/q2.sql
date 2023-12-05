SELECT
   s_acctbal, s_name, n_name, p_partkey, p_mfgr,
       s_address, s_phone, s_comment
FROM
     PART JOIN PARTSUPP ON p_partkey = ps_partkey
     JOIN SUPPLIER ON s_suppkey = ps_suppkey
     JOIN NATION ON s_nationkey = n_nationkey
     JOIN REGION ON n_regionkey = r_regionkey
WHERE
     p_size = 15
     AND p_type LIKE '%BRASS'
     AND r_name = 'EUROPE'
     AND ps_supplycost = (
             SELECT
                 MIN(ps_supplycost)
             FROM
                 PARTSUPP JOIN SUPPLIER
                              ON s_suppkey = ps_suppkey
                 JOIN NATION
                          ON  s_nationkey = n_nationkey
                 JOIN REGION
                          ON n_regionkey = r_regionkey
             WHERE
                 p_partkey = ps_partkey
                 AND r_name = 'EUROPE'
    )
 ORDER BY
    s_acctbal desc, n_name, s_name, p_partkey LIMIT 100;
