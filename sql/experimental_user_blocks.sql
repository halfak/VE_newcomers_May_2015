SELECT
  user_id,
  IF(log_comment RLIKE "(S|s)pam", "spam",
    IF(log_comment RLIKE "((V|v)and|(D|d)isrupt|(U|u)w-vaublock|(A|a)bus(e|ing)|(A|a)ttack|(D|d)eliberate|NOTHERE)", "vandalism",
    IF(log_comment RLIKE "((S|s)ock|(C|c)heckuser|(E|e)vasion)", "sock",
    IF(log_comment RLIKE "softerblock|soft block", "soft username",
    IF(log_comment RLIKE "(U|u)w-uhblock|user\.\.\.|(U|u)w-ublock", "hard username",
    "other"
  ))))) AS type
FROM enwiki.logging
INNER JOIN enwiki.user ON
  REPLACE(log_title, "_", " ") = user_name
INNER JOIN staging.ve2_experimental_users USING (user_id)
WHERE
  log_type = "block" AND
  log_action = "block" AND
  log_timestamp BETWEEN
    registration AND
    DATE_FORMAT(
      DATE_ADD(registration, INTERVAL 7 DAY),
      "%Y%m%d%H%M%S"
    );
