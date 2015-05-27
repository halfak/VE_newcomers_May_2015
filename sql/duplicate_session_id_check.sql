SELECT
  event_editor,
  COUNT(*) AS sessions,
  SUM(revisions > 1) AS cross_revision,
  SUM(pages > 1) AS cross_page,
  SUM(users > 1) AS cross_user
FROM (
  SELECT
    event_editingSessionId,
    event_editor,
    COUNT(DISTINCT `event_page.revid`) AS revisions,
    COUNT(DISTINCT `event_page.id`) AS pages,
    COUNT(DISTINCT `event_user.id`) AS users
  FROM Edit_11448630
  WHERE
    timestamp BETWEEN "20150401" AND "20150402" AND
    event_action = "saveSuccess"
  GROUP BY 1
) AS session_counts
GROUP BY 1;


SELECT
  event_editingSessionId,
  event_editor,
  COUNT(DISTINCT `event_page.revid`) AS revisions,
  COUNT(DISTINCT `event_page.id`) AS pages,
  COUNT(DISTINCT `event_user.id`) AS users
FROM Edit_11448630
WHERE
  timestamp BETWEEN "20150401" AND "20150402" AND
  event_action = "saveSuccess"
GROUP BY 1
HAVING revisions > 1
LIMIT 10;


SELECT
  event_action,
  timestamp,
  `event_page.revid`,
  `event_page.id`,
  `event_user.id`,
  `event_action.abort.type`
FROM Edit_11448630
WHERE
  timestamp BETWEEN "20150401" AND "20150402" AND
  event_editingSessionId = "004132dfc66adbd0421e19c118c2b5c5"
ORDER BY id;

SELECT
  init_events,
  COUNT(*)
FROM (
  SELECT
    event_editingSessionId,
    COUNT(*) AS init_events
  FROM Edit_11448630
  WHERE
    timestamp BETWEEN "20150401" AND "20150402" AND
    event_editingSessionId IN (
      SELECT
        event_editingSessionId
      FROM Edit_11448630
      WHERE
        timestamp BETWEEN "20150401" AND "20150402" AND
        event_action = "saveSuccess"
      GROUP BY 1
      HAVING COUNT(DISTINCT `event_page.revid`) > 1
    ) AND
    event_action = "init"
  GROUP BY 1
) AS foo
GROUP BY 1;
