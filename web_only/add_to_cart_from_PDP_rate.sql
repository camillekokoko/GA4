WITH
pages AS (
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
SELECT
value.int_value
FROM
UNNEST(event_params)
WHERE
key = 'ga_session_id') AS session_id,
(
SELECT
value.string_value
FROM
UNNEST(event_params)
WHERE
key = 'page_location') AS url,
FROM
`com-yesstyle-android.analytics_153826186.events_*`
WHERE
_table_suffix BETWEEN '20210701'
 AND '20210831'

AND event_name IN( 'view_item', 'add_to_cart') AND platform = 'WEB')

SELECT event_date, 
device_platform,
SAFE_DIVIDE(addtc_PDP_session_count, view_item_session_count) as session,
SAFE_DIVIDE(addtc_PDP_event_count, view_item_event_count) as event,
SAFE_DIVIDE(addtc_PDP_user_count, view_item_user_count)as user 




FROM (

SELECT
event_date,
device_platform,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", session_id)END) AS view_item_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS view_item_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END)  AS  view_item_user_count, 

COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%' ) THEN CONCAT(user_pseudo_id, "-", session_id)END) AS addtc_PDP_session_count,
COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%' ) THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS addtc_PDP_event_count,
COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%') THEN user_pseudo_id END)  AS addtc_PDP_user_count,
FROM
pages
GROUP BY 1,2
UNION ALL 
SELECT
event_date,
'TOTAL',

COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", session_id)END) AS view_item_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS view_item_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END)  AS  view_item_user_count, 

COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%' ) THEN CONCAT(user_pseudo_id, "-", session_id)END) AS addtc_PDP_session_count,
COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%' ) THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS addtc_PDP_event_count,
COUNT(DISTINCT CASE WHEN (event_name = 'add_to_cart' and url LIKE '%/info.html/pid.%') THEN user_pseudo_id END)  AS addtc_PDP_user_count,

FROM
pages
GROUP BY
1

)
