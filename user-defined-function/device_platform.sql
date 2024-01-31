CASE
      WHEN device_category = "desktop" THEN "desktop"
      WHEN device_category = "tablet"
    AND app_info_id IS NULL THEN "tablet-web"
      WHEN device_category = "mobile" AND app_info_id IS NULL THEN "mobile-web"
      WHEN device_category = "tablet"
    AND app_info_id IS NOT NULL THEN "tablet-app"
      WHEN device_category = "mobile" AND app_info_id IS NOT NULL THEN "mobile-app"
  END
