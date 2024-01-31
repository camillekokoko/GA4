WITH pages AS (
  SELECT
    event_date,
    user_pseudo_id,
    event_timestamp,
    event_name,
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
    
    (
    SELECT      value.string_value    FROM      UNNEST(event_params)    WHERE      event_name = 'session_start'      AND key = 'page_location') AS page,
    (
    SELECT      value.int_value    FROM      UNNEST(event_params)    WHERE      event_name = 'session_start'      AND key = 'ga_session_number') = 1 AS new_visitor,
  FROM
    `com-yesstyle-android.analytics_153826186.events_*`
  WHERE
    _table_suffix BETWEEN @DS_START_DATE
    AND @DS_END_DATE
    AND event_name = 'session_start' )
    
SELECT device_platform, SUM(new_visitor)/SUM(all_visitor) AS Conbributing_NEWall_user  FROM (SELECT
  * FROM (  SELECT device_platform,   COUNT(DISTINCT user_pseudo_id) AS new_visitor
  FROM    pages 
 WHERE    page LIKE '%/info.html/pid.%'    AND new_visitor IS TRUE GROUP BY 1)
   JOIN (
    SELECT device_platform,       COUNT(DISTINCT user_pseudo_id) AS all_visitor
    FROM      pages    WHERE      #page LIKE '%/info.html/pid.%'
    new_visitor IS TRUE GROUP BY 1) using (device_platform)) GROUP BY 1
    
    UNION ALL 
    
    SELECT 'TOTAL', SUM(new_visitor)/SUM(all_visitor) AS Conbributing_NEWall_user  FROM (SELECT
  * FROM (  SELECT 'TOTAL',   COUNT(DISTINCT user_pseudo_id) AS new_visitor
  FROM    pages 
 WHERE    page LIKE '%/info.html/pid.%'    AND new_visitor IS TRUE GROUP BY 1)
  CROSS JOIN (
    SELECT 'TOTAL',       COUNT(DISTINCT user_pseudo_id) AS all_visitor
    FROM      pages    WHERE      #page LIKE '%/info.html/pid.%'
    new_visitor IS TRUE GROUP BY 1) ) GROUP BY 1
