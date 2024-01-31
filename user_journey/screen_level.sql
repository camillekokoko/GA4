-- subquery to define static and/or dynamic start and end date for the whole query
with date_range as (
select
    '20210829' as start_date,
 '20210830' as end_date),

-- subquery to prepare and calculate page view data
pages as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'ga_session_id') as session_id,
    event_timestamp,event_date,
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
    (select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen') as screen,
    lag((select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen'), 1) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'ga_session_id') order by event_timestamp asc) as previous_screen,
    case when (select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'entrances') = 1 then (select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen') end as landing_screen,
    case when (select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'entrances') = 1 then lead((select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen'), 1) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'ga_session_id') order by event_timestamp asc) else null end as second_screen,
    case when (select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen') = first_value((select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen')) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'screen_view' and key = 'ga_session_id') order by event_timestamp desc) then ( select value.string_value from unnest(event_params) where event_name = 'screen_view' and key = 'firebase_screen') else null end as exit_screen,


from
      `com-yesstyle-android.analytics_153826186.events_*`,
    date_range
where
    _table_suffix between date_range.start_date and date_range.end_date
    and event_name = 'screen_view')

select event_date, 
   device_platform, screen, previous_screen, second_screen, landing_screen,  exit_screen,
   count(screen) as view,
    count(distinct concat(screen,session_id)) as unique_view,
     count(landing_screen) as entrances,
  count(exit_screen) as exits


from
    pages,
    date_range
       
GROUP BY 1,2,3,4,5,6,7
ORDER BY exits DESC 
