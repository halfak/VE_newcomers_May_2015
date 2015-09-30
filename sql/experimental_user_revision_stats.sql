SELECT
  user_id,
  current.rev_id,
  CAST(current.rev_len AS INT) -
    CAST(IFNULL(parent.rev_len, 0) AS INT) bytes_changed,
  ve_tag.ct_rev_id IS NOT NULL AS ve_tagged
FROM staging.ve2_experimental_users
INNER JOIN enwiki.revision current ON user_id = current.rev_user
LEFT JOIN enwiki.revision parent ON parent.rev_id = current.rev_parent_id
LEFT JOIN enwiki.change_tag ve_tag ON
  ct_rev_id = current.rev_id AND
  ct_tag = "visualeditor"
WHERE
  current.rev_timestamp BETWEEN "2015052823" and "2015061123" AND
  current.rev_timestamp BETWEEN
    registration AND
    DATE_FORMAT(
      DATE_ADD(registration, INTERVAL 7 DAY),
      "%Y%m%d%H%i%S"
    );
