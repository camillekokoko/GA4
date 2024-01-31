with pages as (
select event_date,
user_pseudo_id,
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

(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
event_timestamp,
event_name,
(select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,								
case when (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') = first_value((select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location')) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') order by event_timestamp desc) then ( select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') else null end as exit_page
from
`com-yesstyle-android.analytics_153826186.events_*`
where
_table_suffix BETWEEN @DS_START_DATE AND @DS_END_DATE
and event_name = 'page_view')

select
event_date,
device_platform,
count(exit_page) / count(page) as exit_rate
from
pages
WHERE page LIKE '%/info.html/pid.%'
group by 1,2


UNION ALL

select
event_date,
'TOTAL',
count(exit_page) / count(page) as exit_rate
from
pages
WHERE page LIKE '%/info.html/pid.%'
group by 1
