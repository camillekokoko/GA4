  -- subquery to define static and/or dynamic start and end date for the whole query
WITH
  date_range AS (
  SELECT
    '20210801' AS start_date,
    '20210831' AS end_date),
  -- subquery to prepare and calculate page view data
  pages AS (
  SELECT
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
    event_date,
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
      device.web_info.hostname
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'page_location') AS hostname,
    (
    SELECT
      value.string_value
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'page_location') AS page,
    LAG((
      SELECT
        value.string_value
      FROM
        UNNEST(event_params)
      WHERE
        event_name = 'page_view'
        AND key = 'page_location'), 1) OVER (PARTITION BY user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params)
      WHERE
        event_name = 'page_view'
        AND key = 'ga_session_id')
    ORDER BY
      event_timestamp ASC) AS previous_page,
    (
    SELECT
      value.string_value
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'page_title') AS page_title,
    CASE
      WHEN ( SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'entrances') = 1 THEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')
  END
    AS landing_page,
    CASE
      WHEN ( SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'entrances') = 1 THEN LEAD(( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location'), 1) OVER (PARTITION BY user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'ga_session_id') ORDER BY event_timestamp ASC)
    ELSE
    NULL
  END
    AS second_page,
    CASE
      WHEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location') = FIRST_VALUE(( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')) OVER (PARTITION BY user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'ga_session_id') ORDER BY event_timestamp DESC) THEN ( SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = 'page_view' AND key = 'page_location')
    ELSE
    NULL
  END
    AS exit_page
  FROM
    `com-yesstyle-android.analytics_153826186.events_*`,
    date_range
  WHERE
    _table_suffix BETWEEN date_range.start_date
    AND date_range.end_date
    AND event_name = 'page_view')
SELECT
  event_date,
  CASE
    WHEN REGEXP_CONTAINS( exit_page, '.*shopping-bag.html.*') THEN 'shopping_bag'
    WHEN REGEXP_CONTAINS( exit_page, '.*sign-in.html.*')
  OR REGEXP_CONTAINS( exit_page, '.*/sign-up-success.html.*')
  OR REGEXP_CONTAINS (exit_page, '.*social-connect.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*/secure/oauth/response.*')
  OR REGEXP_CONTAINS(exit_page, '.*secure/do-reset-login-email.html.*')
  OR REGEXP_CONTAINS( exit_page, '.*/sign-up.html*') THEN 'sign_in_register'
    WHEN REGEXP_CONTAINS( exit_page, '.*elite-club-.*') OR REGEXP_CONTAINS( exit_page, '.*elite-club.html.*') THEN 'elite_club'
    WHEN REGEXP_CONTAINS( exit_page, '.*friend-rewards.html.*') THEN 'friend_rewards'
    WHEN REGEXP_CONTAINS( exit_page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( exit_page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( exit_page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/k-beauty.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(exit_page, '.*/high-street.*') OR REGEXP_CONTAINS(exit_page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(exit_page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(exit_page, '.*/us-beauty-cosmetics.*') OR REGEXP_CONTAINS(exit_page, '.*holiday-shopping-guide.*') THEN 'YS_SEO_pages'
    WHEN REGEXP_CONTAINS( exit_page, ".*influencers.html.*") THEN 'influencers'
    WHEN REGEXP_CONTAINS(exit_page, '.*/videos.html.*') THEN 'video_page'
    WHEN REGEXP_CONTAINS( exit_page, ".*home.html.*")
  OR REGEXP_CONTAINS(exit_page, 'https://ys.style.*')
  OR exit_page = 'https://yesstyle.com/'
  OR (REGEXP_CONTAINS(exit_page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(exit_page, '.*/women.html'))
  OR exit_page = 'https://www.yesstyle.com/' THEN 'homepage'
    WHEN REGEXP_CONTAINS( exit_page, ".*saved-items.*") THEN 'saved_item'
    WHEN REGEXP_CONTAINS( exit_page, ".*beauty.html.*") THEN 'beauty_frontpage'
    WHEN REGEXP_CONTAINS( exit_page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( exit_page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(exit_page, '.*/list.html/sb.*') OR REGEXP_CONTAINS (exit_page, '.*/list.html/ss.*') THEN 'PLP'
    WHEN REGEXP_CONTAINS( exit_page, ".*info.html/pid.*")
  OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/ja/.*')
    AND REGEXP_CONTAINS(LOWER(exit_page), '.*-%e3%.*'))
  OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/ja/.*')
    AND REGEXP_CONTAINS(LOWER(exit_page), '.*/info.*'))
  OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/zh_.*')
    AND REGEXP_CONTAINS(LOWER(exit_page), '.*/info.*'))
  OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/zh_.*')
    AND REGEXP_CONTAINS(LOWER(exit_page), '.*-%e.*')) THEN 'PDP'
    WHEN REGEXP_CONTAINS( exit_page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( exit_page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( exit_page, ".*/myaccount/order.html.*") THEN 'track_order'
    WHEN REGEXP_CONTAINS( exit_page, ".*/special-offers.html.*")
  OR REGEXP_CONTAINS(exit_page, '.*special-offers-men.html.*') THEN 'SALE_exit_page'
    WHEN REGEXP_CONTAINS( exit_page, ".*/checkout/.*") THEN 'checkout_pages'
    WHEN REGEXP_CONTAINS( exit_page, ".*/help/.*") THEN 'help_section'
    WHEN REGEXP_CONTAINS( exit_page, ".*list.html.*") AND REGEXP_CONTAINS( exit_page, '.*q=.*') THEN 'search_result_pages'
    WHEN REGEXP_CONTAINS( exit_page, ".*/secure/myaccount/summary.*")
  OR REGEXP_CONTAINS( exit_page, ".*/my-profile.html.*")
  OR REGEXP_CONTAINS( exit_page, ".*/personal-information.html.*")
  OR REGEXP_CONTAINS( exit_page, ".*/address-book.html/*")
  OR REGEXP_CONTAINS( exit_page, '.*/secure/do-reset-password.html.*')
  OR REGEXP_CONTAINS( exit_page, ".*/reset-password.html.*")
  OR REGEXP_CONTAINS(exit_page, '.*myaccount/return-items.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*/myaccount/email-preference.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*/myaccount.*')
  OR REGEXP_CONTAINS(exit_page, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
    WHEN REGEXP_CONTAINS(exit_page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(exit_page, '.*badid=.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/bpt.300_badid.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.3_bpt.299_bid.314576.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(exit_page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.2_bpt.299_bid.314036.*') OR (REGEXP_CONTAINS(exit_page, '.*/list.html/.*') AND REGEXP_CONTAINS(exit_page, '.*vn.33_bpt.299_bt.37_bid.*')) THEN 'brand_PLP'
    WHEN REGEXP_CONTAINS( exit_page, ".*/coupon.html.*")
  OR REGEXP_CONTAINS( exit_page, ".*/yspoints.html.*")
  OR REGEXP_CONTAINS( exit_page, ".*/credit.html.*")
  OR REGEXP_CONTAINS(exit_page, '.*/cash-out-verification.html.*') THEN 'virtual_money'
    WHEN REGEXP_CONTAINS( exit_page, ".*/blog/.*") THEN 'blog'
    WHEN REGEXP_CONTAINS(exit_page, '.*/about-us/company-overview.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*about-us/business-opportunities.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*about-us/jobs.html.*')
  OR REGEXP_CONTAINS(exit_page, '.*email-our-ceo.html.*') THEN 'others'
    WHEN REGEXP_CONTAINS(exit_page, '.*/affiliate-program.html.*') THEN 'affiliate_program'
    WHEN REGEXP_CONTAINS(exit_page, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
    WHEN REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(exit_page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(exit_page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(exit_page,'.*/TINY2020.*') OR REGEXP_CONTAINS(exit_page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(exit_page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR REGEXP_CONTAINS(exit_page,'.*instagram-easter-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(exit_page,'.*/instagram-easter-giveaway-entered.html.*') THEN 'limited_time_event'
    WHEN REGEXP_CONTAINS(exit_page, 'https://www.yesstyle.com/.*')
  AND REGEXP_CONTAINS(exit_page, '.*/app.*') THEN 'app'
  ELSE
  landing_page
END
  AS exit_page_in_exit_page_type,
  device_platform,
  -- exits (metric | the number of exits from the property)
  COUNT(exit_page) AS exits,
FROM
  pages,
  date_range
WHERE
  page_title NOT IN ('Page Not Available | YesStyle',
    'Interner Serverfehler | YesStyle',
    'Seite ist nicht verfügbar | YesStyle',
    'Página no disponible | YesStyle',
    'ページを表示できません | YesStyle',
    'Internal Server Error | YesStyle',
    'Error interno del servidor | YesStyle',
    'Erreur de serveur interne | YesStyle',
    '無法顯示此網頁 | YesStyle',
    '无法显示该页面 | YesStyle',
    '服务器错误 | YesStyle',
    'Trang không có sẵn | Có',
    '伺服器錯誤 | YesStyle',
    '内部サーバーエラー | YesStyle')
GROUP BY
  1,
  2,
  3
HAVING
  exits != 0
ORDER BY
  4 DESC
