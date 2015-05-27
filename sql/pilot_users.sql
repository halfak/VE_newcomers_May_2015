SELECT 
  event_userId AS user_id, 
  IF(event_userId % 2 = 0, "experimental", "control") AS bucket, 
  timestamp AS registration, 
  event_displayMobile AS via_mobile, 
  ve.up_user IS NOT NULL AS ve_enabled 
FROM log.ServerSideAccountCreation_5487345 
LEFT JOIN enwiki.user_properties ve ON 
  event_userId = up_user AND 
  up_property = 'visualeditor-enable' 
WHERE 
  wiki = "enwiki" AND 
  event_isSelfMade AND 
  timestamp BETWEEN "2015052115" and "2015052215";
