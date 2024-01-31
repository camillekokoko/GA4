with pages as (	
select event_date,	
user_pseudo_id,	
(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,	
event_timestamp,	
event_name,	
CASE WHEN device.category = "desktop" THEN "desktop"
WHEN device.category = "tablet" AND app_info.id IS NULL THEN "tablet-web"
WHEN device.category = "mobile" AND app_info.id IS NULL THEN "mobile-web"
WHEN device.category = "tablet" AND app_info.id IS NOT NULL THEN "tablet-app"
WHEN device.category = "mobile" AND app_info.id IS NOT NULL THEN "mobile-app" END AS device_platform,
case when (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'entrances') = 1	
then (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') end as landing_page,	(select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,	
case when (select value.string_value from unnest(event_params)	
where event_name = 'page_view' and key = 'page_location') =	
first_value((select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location'))	
over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id')	
order by event_timestamp desc) then ( select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') else null end as exit_page	
from	
`com-yesstyle-android.analytics_153826186.events_*`	
where	
_table_suffix BETWEEN '20210801'
    AND '20210831'
and event_name = 'page_view')	
	
SELECT       event_date,
device_platform,  SUM(uidsid)/SUM(session_all) as contributing_session FROM (	
SELECT * FROM(
SELECT	
      event_date,
device_platform, 
count(distinct concat(user_pseudo_id, session_id)) as uidsid, 	
from	
pages	
WHERE landing_page LIKE '%/info.html/pid.%' 
 GROUP BY 1,2) 
JOIN	
(SELECT       event_date,
 CASE WHEN device.category = "desktop" THEN "desktop"
WHEN device.category = "tablet" AND app_info.id IS NULL THEN "tablet-web"
WHEN device.category = "mobile" AND app_info.id IS NULL THEN "mobile-web"
WHEN device.category = "tablet" AND app_info.id IS NOT NULL THEN "tablet-app"
WHEN device.category = "mobile" AND app_info.id IS NOT NULL THEN "mobile-app" END AS device_platform,  count(concat(user_pseudo_id,key)) as session_all
FROM (	
select *	
from `com-yesstyle-android.analytics_153826186.events_*`, unnest(event_params)	
where	
_table_suffix BETWEEN '20210801'
    AND '20210831'
and event_name = 'session_start' and  key ='ga_session_id' AND platform = 'WEB')	
GROUP BY 1,2) USING (       event_date,
device_platform)
)GROUP BY 1,2


UNION ALL

SELECT         event_date,
'TOTAL',  SUM(uidsid)/SUM(session_all) as contributing_session FROM (	
SELECT * FROM(
SELECT	      event_date,

'TOTAL',count(distinct concat(user_pseudo_id, session_id)) as uidsid, 	
from	
pages	
WHERE landing_page LIKE '%/info.html/pid.%' GROUP BY 1
)  

  JOIN	
(SELECT       event_date,
'TOTAL', count(concat(user_pseudo_id,key)) as session_all 
FROM (	
select *	
from `com-yesstyle-android.analytics_153826186.events_*`, unnest(event_params)	
where	
_table_suffix BETWEEN '20210801'
    AND '20210831'
and event_name = 'session_start' and  key ='ga_session_id' AND platform = 'WEB')	GROUP BY 1
) USING (event_date) ) GROUP BY 1,2



	
  
  
  
  
  
  
  
  
  
  
  

