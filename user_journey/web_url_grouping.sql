SELECT
page_type, page_title
FROM (
  SELECT
    CASE
      WHEN REGEXP_CONTAINS( value.string_value, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( value.string_value, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( value.string_value, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (value.string_value, '.*social-connect.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(value.string_value, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( value.string_value, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( value.string_value, '.*elite-club-.*') OR  REGEXP_CONTAINS( value.string_value, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( value.string_value, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( value.string_value, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( value.string_value, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( value.string_value, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( value.string_value, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( value.string_value, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( value.string_value, '.*/k-beauty.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( value.string_value, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( value.string_value, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(value.string_value, '.*/high-street.*') OR REGEXP_CONTAINS(value.string_value, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(value.string_value, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(value.string_value, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(value.string_value, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( value.string_value, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(value.string_value, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( value.string_value, ".*home.html.*") OR REGEXP_CONTAINS(value.string_value, 'https://ys.style.*') 
    OR value.string_value = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(value.string_value, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(value.string_value, '.*/women.html'))
    OR value.string_value = 'https://www.yesstyle.com/' THEN 'homepage'
      WHEN REGEXP_CONTAINS( value.string_value, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( value.string_value, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( value.string_value, ".*list.html/bcc.*") OR REGEXP_CONTAINS( value.string_value, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(value.string_value, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (value.string_value, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( value.string_value, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(value.string_value, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(value.string_value), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(value.string_value, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(value.string_value), '.*/info.*'))
       OR (REGEXP_CONTAINS(value.string_value, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(value.string_value), '.*/info.*'))
      OR (REGEXP_CONTAINS(value.string_value, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(value.string_value), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( value.string_value, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( value.string_value, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( value.string_value, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/special-offers.html.*") OR REGEXP_CONTAINS(value.string_value, '.*special-offers-men.html.*') THEN 'SALE_page'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/checkout/.*") THEN 'checkout_pages'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/help/.*") THEN 'help_section'
      WHEN REGEXP_CONTAINS( value.string_value, ".*list.html.*") AND REGEXP_CONTAINS( value.string_value, '.*q=.*') THEN 'search_result_pages'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/secure/myaccount/summary.*")
    OR REGEXP_CONTAINS( value.string_value, ".*/my-profile.html.*")
    OR REGEXP_CONTAINS( value.string_value, ".*/personal-information.html.*")
    OR REGEXP_CONTAINS( value.string_value, ".*/address-book.html/*")
    OR REGEXP_CONTAINS( value.string_value, '.*/secure/do-reset-password.html.*')
    OR REGEXP_CONTAINS( value.string_value, ".*/reset-password.html.*")
    OR REGEXP_CONTAINS(value.string_value, '.*myaccount/return-items.html.*')
    OR REGEXP_CONTAINS(value.string_value, '.*/myaccount/email-preference.html.*')
    OR REGEXP_CONTAINS(value.string_value, '.*/myaccount.*')
    OR REGEXP_CONTAINS(value.string_value, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
      WHEN REGEXP_CONTAINS(value.string_value, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(value.string_value, '.*badid=.*') OR REGEXP_CONTAINS(value.string_value, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(value.string_value, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(value.string_value, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(value.string_value, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(value.string_value, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(value.string_value, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(value.string_value, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(value.string_value, '.*/list.html/.*') AND REGEXP_CONTAINS(value.string_value, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/coupon.html.*")
    OR REGEXP_CONTAINS( value.string_value, ".*/yspoints.html.*")
    OR REGEXP_CONTAINS( value.string_value, ".*/credit.html.*")
    OR REGEXP_CONTAINS(value.string_value, '.*/cash-out-verification.html.*') THEN 'virtual_money'
      WHEN REGEXP_CONTAINS( value.string_value, ".*/blog/.*") THEN 'blog'
      WHEN REGEXP_CONTAINS(value.string_value, '.*/about-us/company-overview.html.*')
    OR REGEXP_CONTAINS(value.string_value, '.*about-us/business-opportunities.html.*')
    OR REGEXP_CONTAINS(value.string_value, '.*about-us/jobs.html.*')
    OR REGEXP_CONTAINS(value.string_value, '.*email-our-ceo.html.*') THEN 'others'
      WHEN REGEXP_CONTAINS(value.string_value, '.*/affiliate-program.html.*') THEN 'affiliate_program'
      WHEN REGEXP_CONTAINS(value.string_value, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
      WHEN REGEXP_CONTAINS(value.string_value, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(value.string_value, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(value.string_value,'.*/TINY2020.*') OR REGEXP_CONTAINS(value.string_value, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(value.string_value, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(value.string_value,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(value.string_value,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(value.string_value, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(value.string_value, '.*/app.*') THEN 'app'
    ELSE
    value.string_value
  END
    AS page_type,
    (
    SELECT
      value.string_value
    FROM
      UNNEST(event_params)
    WHERE
      event_name = 'page_view'
      AND key = 'page_title') AS page_title
  FROM
    `com-yesstyle-android.analytics_153826186.events_*`,
    UNNEST(event_params)
  WHERE
    event_name = 'page_view'
    AND key = 'page_location'
    AND _table_suffix BETWEEN '20210330' AND '20210430' )
WHERE
 page_title NOT IN ('Page Not Available | YesStyle','Interner Serverfehler | YesStyle','Seite ist nicht verfügbar | YesStyle','Página no disponible | YesStyle','ページを表示できません | YesStyle','Internal Server Error | YesStyle', 'Error interno del servidor | YesStyle', 'Erreur de serveur interne | YesStyle', '無法顯示此網頁 | YesStyle', '无法显示该页面 | YesStyle', '服务器错误 | YesStyle', 'Trang không có sẵn | Có', '伺服器錯誤 | YesStyle', '内部サーバーエラー | YesStyle'
) AND    page_type LIKE '%http%'
ORDER BY
  1
