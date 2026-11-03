-- Профиль клиента из истории чеков (до 18.03.2019)
-- Сначала строки (позиции) сворачиваются в чеки, потом чеки — в клиента

WITH checks AS (            -- одна строка = один чек
    SELECT client_id,
           transaction_id,
           MAX(transaction_datetime)  AS dt,
           MAX(purchase_sum)          AS check_sum,  -- сумма чека повторяется в каждой позиции
           MAX(express_points_received) > 0                                      AS is_promo,
           MAX(ABS(regular_points_spent)) + MAX(ABS(express_points_spent)) > 0  AS points_spent,
           ANY_VALUE(store_id)        AS store_id
    FROM read_csv_auto('data/data/purchases.csv')
    WHERE client_id IN (SELECT client_id FROM read_csv_auto('data/data/uplift_train.csv'))
    GROUP BY client_id, transaction_id
)
SELECT u.client_id,
       u.treatment_flg,
       u.target,
       COUNT(c.transaction_id)                              AS n_checks,
       SUM(c.check_sum)                                     AS total_sum,
       AVG(c.check_sum)                                     AS avg_check,
       date_diff('day', MAX(c.dt), TIMESTAMP '2019-03-19')  AS recency_days,
       AVG(c.is_promo::INT)                                 AS share_promo_checks,
       AVG(c.points_spent::INT)                             AS share_points_checks,
       COUNT(DISTINCT c.store_id)                           AS n_stores
FROM read_csv_auto('data/data/uplift_train.csv') u
LEFT JOIN checks c USING (client_id)
GROUP BY u.client_id, u.treatment_flg, u.target
