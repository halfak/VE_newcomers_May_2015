SELECT
    user_id,
    SUM(revisions_1_to_2_weeks) AS revisions_1_to_2_weeks,
    SUM(revisions_1_to_2_months) AS revisions_1_to_2_months,
    SUM(revisions_2_to_3_months) AS revisions_2_to_3_months
FROM (
    (SELECT 
        user_id,
        SUM(
            rev_timestamp IS NOT NULL AND 
            DATEDIFF(rev_timestamp, user_registration) BETWEEN 7 AND 14
        ) AS revisions_1_to_2_weeks,
        SUM(
            rev_timestamp IS NOT NULL AND 
            DATEDIFF(rev_timestamp, user_registration) BETWEEN 30 AND 60
        ) AS revisions_1_to_2_months,
        SUM(
            rev_timestamp IS NOT NULL AND 
            DATEDIFF(rev_timestamp, user_registration) BETWEEN 60 AND 90
        ) AS revisions_2_to_3_months
    FROM staging.ve2_experimental_users as user
    INNER JOIN user USING (user_id)
    LEFT JOIN revision ON 
        rev_user = user_id AND
        rev_timestamp >= DATE_FORMAT(
            DATE_ADD(user_registration, INTERVAL 7 DAY), 
            "%Y%m%d%H%i%S"
        )
    GROUP BY 1)
    UNION
    (SELECT 
        user_id,
        SUM(
            ar_timestamp IS NOT NULL AND 
            DATEDIFF(ar_timestamp, user_registration) BETWEEN 7 AND 14
        ) AS revisions_1_to_2_weeks,
        SUM(
            ar_timestamp IS NOT NULL AND 
            DATEDIFF(ar_timestamp, user_registration) BETWEEN 30 AND 60
        ) AS revisions_1_to_2_months,
        SUM(
            ar_timestamp IS NOT NULL AND 
            DATEDIFF(ar_timestamp, user_registration) BETWEEN 60 AND 90
        ) AS revisions_2_to_3_months
    FROM staging.ve2_experimental_users AS user
    INNER JOIN user USING (user_id)
    LEFT JOIN archive ON 
        ar_user = user_id AND
        ar_timestamp >= DATE_FORMAT(
            DATE_ADD(user_registration, INTERVAL 21 DAY), 
            "%Y%m%d%H%i%S"
        )
    GROUP BY 1)
) user_span_revisions
GROUP BY user_id;
