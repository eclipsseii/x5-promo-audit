-- Сегменты клиентов
-- частота и средний чек: делим на трети через NTILE
-- давность, баллы, возраст: группы через CASE

WITH base AS (
    SELECT f.client_id,
           f.treatment_flg,
           f.target,
           f.n_checks,
           f.avg_check,
           f.recency_days,
           f.share_points_checks,
           c.age,
           c.gender
    FROM features f
    JOIN clients c ON c.client_id = f.client_id
)
SELECT client_id,
       treatment_flg,
       target,
       avg_check,

       CASE NTILE(3) OVER (ORDER BY n_checks, client_id)
           WHEN 1 THEN '1. редко'
           WHEN 2 THEN '2. средне'
           ELSE '3. часто'
       END AS freq_group,

       CASE NTILE(3) OVER (ORDER BY avg_check, client_id)
           WHEN 1 THEN '1. низкий'
           WHEN 2 THEN '2. средний'
           ELSE '3. высокий'
       END AS check_group,

       CASE
           WHEN recency_days <= 3 THEN '1. 1–3 дня'
           WHEN recency_days <= 9 THEN '2. 4–9 дней'
           ELSE '3. 10–23 дня'
       END AS recency_group,

       CASE
           WHEN share_points_checks = 0   THEN '1. не тратит'
           WHEN share_points_checks <= 0.1 THEN '2. до 10% чеков'
           ELSE '3. больше 10% чеков'
       END AS points_group,

       CASE
           WHEN age BETWEEN 14 AND 30  THEN '1. 14–30'
           WHEN age BETWEEN 31 AND 45  THEN '2. 31–45'
           WHEN age BETWEEN 46 AND 60  THEN '3. 46–60'
           WHEN age BETWEEN 61 AND 100 THEN '4. 61+'
           ELSE 'нет данных'          -- в данных есть невозможные возрасты
       END AS age_group,

       CASE gender
           WHEN 'F' THEN 'женский'
           WHEN 'M' THEN 'мужской'
           ELSE 'не указан'
       END AS gender

FROM base
