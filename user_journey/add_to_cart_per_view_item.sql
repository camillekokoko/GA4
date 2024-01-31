WITH
pages AS (
SELECT
event_date,
user_pseudo_id,
event_timestamp,
event_name,
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
_table_suffix BETWEEN @DS_START_DATE AND @DS_END_DATE

AND event_name IN( 'view_item', 'add_to_cart') AND platform = 'WEB')

SELECT event_date, add_to_cart_event_count/view_item_event_count as Add_to_cart_rate FROM (

SELECT
event_date,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", session_id)END) AS view_item_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS view_item_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END)  AS  view_item_user_count, 

COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN CONCAT(user_pseudo_id, "-", session_id)END) AS add_to_cart_session_count,
COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN CONCAT(user_pseudo_id, "-", event_timestamp)END) AS add_to_cart_event_count,
COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_pseudo_id END)  AS  add_to_cart_user_count, 
FROM
pages
GROUP BY 1

)
