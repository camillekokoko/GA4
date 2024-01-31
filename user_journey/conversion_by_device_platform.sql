WITH
pages AS (
SELECT
PARSE_DATE('%Y%m%d',	
event_date) AS date,

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


CASE
    WHEN LOWER(geo.country) = "united states" THEN "US"
    WHEN LOWER(geo.country) = "australia" THEN "AU"
    WHEN LOWER(geo.country) = "canada" THEN "CA"
    WHEN LOWER(geo.country) = "france" THEN "FR"
    WHEN ( LOWER(geo.country) = 'germany' OR LOWER(geo.country) = 'austria') THEN 'DE'
    WHEN ( LOWER(geo.country) = 'spain'
    OR LOWER(geo.country) = 'mexico'
    OR LOWER(geo.country) ='argentina'
    OR LOWER(geo.country) = 'bolivia'
    OR LOWER(geo.country) = 'chile'
    OR LOWER(geo.country) = 'colombia'
    OR LOWER(geo.country) ='costa rica'
    OR LOWER(geo.country) ='cuba'
    OR LOWER(geo.country) ='dominican republic'
    OR LOWER(geo.country) ='ecuador'
    OR LOWER(geo.country) ='equatorial guinea'
    OR LOWER(geo.country) = 'el salvador'
    OR LOWER(geo.country) ='guatemala'
    OR LOWER(geo.country) = 'honduras'
    OR LOWER(geo.country) ='nicaragua'
    OR LOWER(geo.country) = 'panama'
    OR LOWER(geo.country) = 'paraguay'
    OR LOWER(geo.country) = 'peru'
    OR LOWER(geo.country) = 'puerto rico'
    OR LOWER(geo.country) = 'uruguay'
    OR LOWER(geo.country) = 'venezuela'
    OR LOWER(geo.country) = 'austria') THEN 'ES'
    WHEN LOWER(geo.country) = 'united kingdom' THEN 'UK'
    WHEN LOWER(geo.country) = 'japan' THEN 'JP'
  
  ELSE
'ROW'
 END
  AS country, 

(
SELECT
value.int_value
FROM
UNNEST(event_params)
WHERE
key = 'ga_session_id') AS session_id,
FROM
`com-yesstyle-android.analytics_153826186.events_*`
WHERE
_table_suffix BETWEEN '20210628'
AND '20210905'
AND event_name IN( 'session_start', 'purchase', 'ecommerce_purchase')
)

SELECT 
isoweek,
device_platform,
SAFE_DIVIDE(purchase_event_count, session_start_event_count)as CVR FROM ( 

SELECT
format_date('%G%W',date) as isoweek,
device_platform, 
#country,
COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN  CONCAT(user_pseudo_id, "-", session_id) END) AS session_start_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN  CONCAT(user_pseudo_id, "-", event_timestamp)END) AS session_start_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN user_pseudo_id END) AS session_start_user_count, 
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN  CONCAT(user_pseudo_id, "-", session_id) END) AS purchase_session_count,
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN  CONCAT(user_pseudo_id, "-", event_timestamp)END) AS purchase_event_count,
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN user_pseudo_id END) AS purchase_user_count
FROM
pages
GROUP BY
1,2
UNION ALL 
SELECT
format_date('%G%W',date) as isoweek,
'TOTAL',

COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN  CONCAT(user_pseudo_id, "-", session_id) END) AS session_start_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN  CONCAT(user_pseudo_id, "-", event_timestamp)END) AS session_start_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN user_pseudo_id END) AS session_start_user_count, 
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN  CONCAT(user_pseudo_id, "-", session_id) END) AS purchase_session_count,
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN  CONCAT(user_pseudo_id, "-", event_timestamp)END) AS purchase_event_count,
COUNT(DISTINCT CASE WHEN event_name IN ('purchase', 'ecommerce_purchase') THEN user_pseudo_id END) AS purchase_user_count
FROM
pages
GROUP BY
1)
GROUP BY 1,2,3
