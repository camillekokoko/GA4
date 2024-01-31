WITH
  pages AS (
  SELECT
    event_date,
    user_pseudo_id,
    (
    SELECT
      value.int_value
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'ga_session_id') AS session_id,
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
      WHEN ( SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'entrances') = 1 THEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')
  END
    AS landing_page,
    (
    SELECT
      value.string_value
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'page_location') AS page,
    CASE
      WHEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location') = FIRST_VALUE(( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')) OVER (PARTITION BY user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'ga_session_id') ORDER BY event_timestamp DESC) THEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')
    ELSE
    NULL
  END
    AS exit_page
  FROM
    `com-yesstyle-android.analytics_153826186.events_*`
  WHERE
    _table_suffix BETWEEN '20210801'
    AND '20210831'
    AND event_name = 'page_view')
SELECT
  device_platform,       event_date,

  SUM(page)/SUM(all_page) AS contributing_view
FROM (
  SELECT
    *
  FROM (
    SELECT
      event_date,
      device_platform,
      COUNT(page) AS page,
    FROM
      pages
    WHERE
      page LIKE '%/info.html/pid.%'
    GROUP BY
      1,
      2)
  JOIN (
    SELECT
      event_date,
      device_platform,
      COUNT(page) AS all_page,
    FROM
      pages
    GROUP BY
      1,
      2 )
  USING
    (event_date,
      device_platform) )
GROUP BY
  1,2
UNION ALL
SELECT
  'TOTAL',       event_date,

  SUM(page)/SUM(all_page) AS contributing_view
FROM (
  SELECT
    *
  FROM (
    SELECT
      event_date,
      'TOTAL',
      COUNT(page) AS page,
    FROM
      pages
    WHERE
      page LIKE '%/info.html/pid.%'
    GROUP BY
      1,
      2)
  JOIN (
    SELECT
      event_date,
      'TOTAL',
      COUNT(page) AS all_page,
    FROM
      pages
    GROUP BY
      1,
      2 )
  USING
    (event_date) )
GROUP BY
  1,2
