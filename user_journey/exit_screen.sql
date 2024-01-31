WITH  date_range AS (
  SELECT
    '20210801' AS start_date,
    '20210831' AS end_date),
page as(
SELECT  
CASE
      WHEN device.category = "desktop" THEN "desktop"
      WHEN device.category = "tablet"
    AND app_info.id IS NULL THEN "tablet-web"
      WHEN device.category = "mobile" AND app_info.id IS NULL THEN "mobile-web"
      WHEN device.category = "tablet"
    AND app_info.id IS NOT NULL THEN "tablet-app"
      WHEN device.category = "mobile" AND app_info.id IS NOT NULL THEN "mobile-app"
  END
    AS device_platform,
event_date,
   user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'ga_session_id') as session_id,
    event_timestamp,
    event_name,
  CASE
    WHEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'screen_view' AND key = 'firebase_screen') = FIRST_VALUE(( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'screen_view' AND key = 'firebase_screen')) OVER (PARTITION BY user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'screen_view' AND key = 'ga_session_id') ORDER BY event_timestamp DESC) THEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'screen_view' AND key = 'firebase_screen')
  ELSE
  NULL
END
  AS exit_page
FROM
  `com-yesstyle-android.analytics_153826186.events_*`, date_range
WHERE
    _table_suffix BETWEEN date_range.start_date
    AND date_range.end_date AND  event_name = 'screen_view')
  
  SELECT
  event_date,
exit_page,
 COUNT(exit_page) AS exits
 
 FROM page
 GROUP BY 1,2
 HAVING
  exits != 0

 ORDER BY 3 DESC

