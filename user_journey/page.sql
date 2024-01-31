-- subquery to define static and/or dynamic start and end date for the whole query
with date_range as (
select
    '20210907' as start_date,
    format_date('%Y%m%d',date_sub(current_date(), interval 3 day)) as end_date),

-- subquery to prepare and calculate page view data
pages as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    event_timestamp,
    event_name,
    (select device.web_info.hostname from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as hostname,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,
    lag((select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location'), 1) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') order by event_timestamp asc) as previous_page,
  
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_title') as page_title,
    case when (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'entrances') = 1 then (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') end as landing_page,
    case when (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'entrances') = 1 then lead((select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location'), 1) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') order by event_timestamp asc) else null end as second_page,
    case when (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') = first_value((select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location')) over (partition by user_pseudo_id,(select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') order by event_timestamp desc) then ( select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') else null end as exit_page
from
      `com-yesstyle-android.analytics_153826186.events_*`,
    date_range
where
    _table_suffix between date_range.start_date and date_range.end_date
    and event_name = 'page_view')


select
   CASE
      WHEN REGEXP_CONTAINS( page, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( page, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( page, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (page, '.*social-connect.html.*') OR REGEXP_CONTAINS(page, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(page, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( page, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( page, '.*elite-club-.*') OR  REGEXP_CONTAINS( page, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( page, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( page, '.*/k-beauty.*') OR REGEXP_CONTAINS( page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(page, '.*/high-street.*') OR REGEXP_CONTAINS(page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(page, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(page, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( page, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(page, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( page, ".*home.html.*") OR REGEXP_CONTAINS(page, 'https://ys.style.*') 
    OR page = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(page, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(page, '.*/women.html'))
    OR page = 'https://www.yesstyle.com/' THEN 'homepage'
      WHEN REGEXP_CONTAINS( page, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( page, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(page, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (page, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( page, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(page), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(page), '.*/info.*'))
       OR (REGEXP_CONTAINS(page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(page), '.*/info.*'))
      OR (REGEXP_CONTAINS(page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(page), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( page, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( page, ".*/special-offers.html.*") OR REGEXP_CONTAINS(page, '.*special-offers-men.html.*') THEN 'SALE_page'
      WHEN REGEXP_CONTAINS( page, ".*/checkout/.*") THEN 'checkout_pages'
      WHEN REGEXP_CONTAINS( page, ".*/help/.*") THEN 'help_section'
      WHEN REGEXP_CONTAINS( page, ".*list.html.*") AND REGEXP_CONTAINS( page, '.*q=.*') THEN 'search_result_pages'
      WHEN REGEXP_CONTAINS( page, ".*/secure/myaccount/summary.*")
    OR REGEXP_CONTAINS( page, ".*/my-profile.html.*")
    OR REGEXP_CONTAINS( page, ".*/personal-information.html.*")
    OR REGEXP_CONTAINS( page, ".*/address-book.html/*")
    OR REGEXP_CONTAINS( page, '.*/secure/do-reset-password.html.*')
    OR REGEXP_CONTAINS( page, ".*/reset-password.html.*")
    OR REGEXP_CONTAINS(page, '.*myaccount/return-items.html.*')
    OR REGEXP_CONTAINS(page, '.*/myaccount/email-preference.html.*')
    OR REGEXP_CONTAINS(page, '.*/myaccount.*')
    OR REGEXP_CONTAINS(page, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
      WHEN REGEXP_CONTAINS(page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(page, '.*badid=.*') OR REGEXP_CONTAINS(page, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(page, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(page, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(page, '.*/list.html/.*') AND REGEXP_CONTAINS(page, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
      WHEN REGEXP_CONTAINS( page, ".*/coupon.html.*")
    OR REGEXP_CONTAINS( page, ".*/yspoints.html.*")
    OR REGEXP_CONTAINS( page, ".*/credit.html.*")
    OR REGEXP_CONTAINS(page, '.*/cash-out-verification.html.*') THEN 'virtual_money'
      WHEN REGEXP_CONTAINS( page, ".*/blog/.*") THEN 'blog'
      WHEN REGEXP_CONTAINS(page, '.*/about-us/company-overview.html.*')
    OR REGEXP_CONTAINS(page, '.*about-us/business-opportunities.html.*')
    OR REGEXP_CONTAINS(page, '.*about-us/jobs.html.*')
    OR REGEXP_CONTAINS(page, '.*email-our-ceo.html.*') THEN 'others'
      WHEN REGEXP_CONTAINS(page, '.*/affiliate-program.html.*') THEN 'affiliate_program'
      WHEN REGEXP_CONTAINS(page, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
      WHEN REGEXP_CONTAINS(page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(page,'.*/TINY2020.*') OR REGEXP_CONTAINS(page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(page,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(page,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(page, '.*/app.*') THEN 'app'
    ELSE
    page
  END
    AS page_in_page_type ,   CASE
      WHEN REGEXP_CONTAINS( previous_page, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( previous_page, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( previous_page, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (previous_page, '.*social-connect.html.*') OR REGEXP_CONTAINS(previous_page, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(previous_page, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( previous_page, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( previous_page, '.*elite-club-.*') OR  REGEXP_CONTAINS( previous_page, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( previous_page, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( previous_page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( previous_page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( previous_page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( previous_page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( previous_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( previous_page, '.*/k-beauty.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( previous_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( previous_page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(previous_page, '.*/high-street.*') OR REGEXP_CONTAINS(previous_page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(previous_page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(previous_page, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(previous_page, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( previous_page, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(previous_page, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( previous_page, ".*home.html.*") OR REGEXP_CONTAINS(previous_page, 'https://ys.style.*') 
    OR previous_page = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(previous_page, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(previous_page, '.*/women.html'))
    OR previous_page = 'https://www.yesstyle.com/' THEN 'homepage'
      WHEN REGEXP_CONTAINS( previous_page, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( previous_page, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( previous_page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( previous_page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(previous_page, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (previous_page, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( previous_page, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(previous_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(previous_page), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(previous_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(previous_page), '.*/info.*'))
       OR (REGEXP_CONTAINS(previous_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(previous_page), '.*/info.*'))
      OR (REGEXP_CONTAINS(previous_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(previous_page), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( previous_page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( previous_page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( previous_page, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( previous_page, ".*/special-offers.html.*") OR REGEXP_CONTAINS(previous_page, '.*special-offers-men.html.*') THEN 'SALE_page'
      WHEN REGEXP_CONTAINS( previous_page, ".*/checkout/.*") THEN 'checkout_pages'
      WHEN REGEXP_CONTAINS( previous_page, ".*/help/.*") THEN 'help_section'
      WHEN REGEXP_CONTAINS( previous_page, ".*list.html.*") AND REGEXP_CONTAINS( previous_page, '.*q=.*') THEN 'search_result_pages'
      WHEN REGEXP_CONTAINS( previous_page, ".*/secure/myaccount/summary.*")
    OR REGEXP_CONTAINS( previous_page, ".*/my-profile.html.*")
    OR REGEXP_CONTAINS( previous_page, ".*/personal-information.html.*")
    OR REGEXP_CONTAINS( previous_page, ".*/address-book.html/*")
    OR REGEXP_CONTAINS( previous_page, '.*/secure/do-reset-password.html.*')
    OR REGEXP_CONTAINS( previous_page, ".*/reset-password.html.*")
    OR REGEXP_CONTAINS(previous_page, '.*myaccount/return-items.html.*')
    OR REGEXP_CONTAINS(previous_page, '.*/myaccount/email-preference.html.*')
    OR REGEXP_CONTAINS(previous_page, '.*/myaccount.*')
    OR REGEXP_CONTAINS(previous_page, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
      WHEN REGEXP_CONTAINS(previous_page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(previous_page, '.*badid=.*') OR REGEXP_CONTAINS(previous_page, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(previous_page, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(previous_page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(previous_page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(previous_page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(previous_page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(previous_page, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(previous_page, '.*/list.html/.*') AND REGEXP_CONTAINS(previous_page, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
      WHEN REGEXP_CONTAINS( previous_page, ".*/coupon.html.*")
    OR REGEXP_CONTAINS( previous_page, ".*/yspoints.html.*")
    OR REGEXP_CONTAINS( previous_page, ".*/credit.html.*")
    OR REGEXP_CONTAINS(previous_page, '.*/cash-out-verification.html.*') THEN 'virtual_money'
      WHEN REGEXP_CONTAINS( previous_page, ".*/blog/.*") THEN 'blog'
      WHEN REGEXP_CONTAINS(previous_page, '.*/about-us/company-overview.html.*')
    OR REGEXP_CONTAINS(previous_page, '.*about-us/business-opportunities.html.*')
    OR REGEXP_CONTAINS(previous_page, '.*about-us/jobs.html.*')
    OR REGEXP_CONTAINS(previous_page, '.*email-our-ceo.html.*') THEN 'others'
      WHEN REGEXP_CONTAINS(previous_page, '.*/affiliate-program.html.*') THEN 'affiliate_program'
      WHEN REGEXP_CONTAINS(previous_page, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
      WHEN REGEXP_CONTAINS(previous_page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(previous_page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(previous_page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(previous_page,'.*/TINY2020.*') OR REGEXP_CONTAINS(previous_page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(previous_page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(previous_page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(previous_page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(previous_page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(previous_page,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(previous_page,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(previous_page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(previous_page, '.*/app.*') THEN 'app'
    ELSE
    previous_page
  END
    AS previous_page_in_previous_page_type,    CASE
      WHEN REGEXP_CONTAINS( landing_page, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( landing_page, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( landing_page, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (landing_page, '.*social-connect.html.*') OR REGEXP_CONTAINS(landing_page, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(landing_page, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( landing_page, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( landing_page, '.*elite-club-.*') OR  REGEXP_CONTAINS( landing_page, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( landing_page, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( landing_page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( landing_page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( landing_page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( landing_page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( landing_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( landing_page, '.*/k-beauty.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( landing_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( landing_page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(landing_page, '.*/high-street.*') OR REGEXP_CONTAINS(landing_page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(landing_page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(landing_page, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(landing_page, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( landing_page, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(landing_page, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( landing_page, ".*home.html.*") OR REGEXP_CONTAINS(landing_page, 'https://ys.style.*') 
    OR landing_page = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(landing_page, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(landing_page, '.*/women.html'))
    OR landing_page = 'https://www.yesstyle.com/' THEN 'homepage'
      WHEN REGEXP_CONTAINS( landing_page, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( landing_page, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( landing_page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( landing_page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(landing_page, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (landing_page, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( landing_page, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(landing_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(landing_page), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(landing_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(landing_page), '.*/info.*'))
       OR (REGEXP_CONTAINS(landing_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(landing_page), '.*/info.*'))
      OR (REGEXP_CONTAINS(landing_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(landing_page), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( landing_page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( landing_page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( landing_page, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( landing_page, ".*/special-offers.html.*") OR REGEXP_CONTAINS(landing_page, '.*special-offers-men.html.*') THEN 'SALE_landing_page'
      WHEN REGEXP_CONTAINS( landing_page, ".*/checkout/.*") THEN 'checkout_pages'
      WHEN REGEXP_CONTAINS( landing_page, ".*/help/.*") THEN 'help_section'
      WHEN REGEXP_CONTAINS( landing_page, ".*list.html.*") AND REGEXP_CONTAINS( landing_page, '.*q=.*') THEN 'search_result_pages'
      WHEN REGEXP_CONTAINS( landing_page, ".*/secure/myaccount/summary.*")
    OR REGEXP_CONTAINS( landing_page, ".*/my-profile.html.*")
    OR REGEXP_CONTAINS( landing_page, ".*/personal-information.html.*")
    OR REGEXP_CONTAINS( landing_page, ".*/address-book.html/*")
    OR REGEXP_CONTAINS( landing_page, '.*/secure/do-reset-password.html.*')
    OR REGEXP_CONTAINS( landing_page, ".*/reset-password.html.*")
    OR REGEXP_CONTAINS(landing_page, '.*myaccount/return-items.html.*')
    OR REGEXP_CONTAINS(landing_page, '.*/myaccount/email-preference.html.*')
    OR REGEXP_CONTAINS(landing_page, '.*/myaccount.*')
    OR REGEXP_CONTAINS(landing_page, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
      WHEN REGEXP_CONTAINS(landing_page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(landing_page, '.*badid=.*') OR REGEXP_CONTAINS(landing_page, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(landing_page, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(landing_page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(landing_page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(landing_page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(landing_page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(landing_page, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(landing_page, '.*/list.html/.*') AND REGEXP_CONTAINS(landing_page, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
      WHEN REGEXP_CONTAINS( landing_page, ".*/coupon.html.*")
    OR REGEXP_CONTAINS( landing_page, ".*/yspoints.html.*")
    OR REGEXP_CONTAINS( landing_page, ".*/credit.html.*")
    OR REGEXP_CONTAINS(landing_page, '.*/cash-out-verification.html.*') THEN 'virtual_money'
      WHEN REGEXP_CONTAINS( landing_page, ".*/blog/.*") THEN 'blog'
      WHEN REGEXP_CONTAINS(landing_page, '.*/about-us/company-overview.html.*')
    OR REGEXP_CONTAINS(landing_page, '.*about-us/business-opportunities.html.*')
    OR REGEXP_CONTAINS(landing_page, '.*about-us/jobs.html.*')
    OR REGEXP_CONTAINS(landing_page, '.*email-our-ceo.html.*') THEN 'others'
      WHEN REGEXP_CONTAINS(landing_page, '.*/affiliate-program.html.*') THEN 'affiliate_program'
      WHEN REGEXP_CONTAINS(landing_page, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
      WHEN REGEXP_CONTAINS(landing_page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(landing_page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(landing_page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(landing_page,'.*/TINY2020.*') OR REGEXP_CONTAINS(landing_page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(landing_page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(landing_page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(landing_page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(landing_page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(landing_page,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(landing_page,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(landing_page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(landing_page, '.*/app.*') THEN 'app'
    ELSE
    landing_page
  END
    AS landing_page_in_landing_page_type,    CASE
      WHEN REGEXP_CONTAINS( second_page, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( second_page, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( second_page, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (second_page, '.*social-connect.html.*') OR REGEXP_CONTAINS(second_page, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(second_page, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( second_page, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( second_page, '.*elite-club-.*') OR  REGEXP_CONTAINS( second_page, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( second_page, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( second_page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( second_page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( second_page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( second_page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( second_page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( second_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( second_page, '.*/k-beauty.*') OR REGEXP_CONTAINS( second_page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( second_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( second_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( second_page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( second_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( second_page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(second_page, '.*/high-street.*') OR REGEXP_CONTAINS(second_page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(second_page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(second_page, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(second_page, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( second_page, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(second_page, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( second_page, ".*home.html.*") OR REGEXP_CONTAINS(second_page, 'https://ys.style.*') 
    OR second_page = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(second_page, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(second_page, '.*/women.html'))
    OR second_page = 'https://www.yesstyle.com/' THEN 'homepage'
      WHEN REGEXP_CONTAINS( second_page, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( second_page, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( second_page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( second_page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(second_page, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (second_page, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( second_page, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(second_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(second_page), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(second_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(second_page), '.*/info.*'))
       OR (REGEXP_CONTAINS(second_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(second_page), '.*/info.*'))
      OR (REGEXP_CONTAINS(second_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(second_page), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( second_page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( second_page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( second_page, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( second_page, ".*/special-offers.html.*") OR REGEXP_CONTAINS(second_page, '.*special-offers-men.html.*') THEN 'SALE_page'
      WHEN REGEXP_CONTAINS( second_page, ".*/checkout/.*") THEN 'checkout_pages'
      WHEN REGEXP_CONTAINS( second_page, ".*/help/.*") THEN 'help_section'
      WHEN REGEXP_CONTAINS( second_page, ".*list.html.*") AND REGEXP_CONTAINS( second_page, '.*q=.*') THEN 'search_result_pages'
      WHEN REGEXP_CONTAINS( second_page, ".*/secure/myaccount/summary.*")
    OR REGEXP_CONTAINS( second_page, ".*/my-profile.html.*")
    OR REGEXP_CONTAINS( second_page, ".*/personal-information.html.*")
    OR REGEXP_CONTAINS( second_page, ".*/address-book.html/*")
    OR REGEXP_CONTAINS( second_page, '.*/secure/do-reset-password.html.*')
    OR REGEXP_CONTAINS( second_page, ".*/reset-password.html.*")
    OR REGEXP_CONTAINS(second_page, '.*myaccount/return-items.html.*')
    OR REGEXP_CONTAINS(second_page, '.*/myaccount/email-preference.html.*')
    OR REGEXP_CONTAINS(second_page, '.*/myaccount.*')
    OR REGEXP_CONTAINS(second_page, '.*/newsletter-unsubscribe.html.*') THEN 'myaccount'
      WHEN REGEXP_CONTAINS(second_page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(second_page, '.*badid=.*') OR REGEXP_CONTAINS(second_page, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(second_page, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(second_page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(second_page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(second_page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(second_page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(second_page, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(second_page, '.*/list.html/.*') AND REGEXP_CONTAINS(second_page, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
      WHEN REGEXP_CONTAINS( second_page, ".*/coupon.html.*")
    OR REGEXP_CONTAINS( second_page, ".*/yspoints.html.*")
    OR REGEXP_CONTAINS( second_page, ".*/credit.html.*")
    OR REGEXP_CONTAINS(second_page, '.*/cash-out-verification.html.*') THEN 'virtual_money'
      WHEN REGEXP_CONTAINS( second_page, ".*/blog/.*") THEN 'blog'
      WHEN REGEXP_CONTAINS(second_page, '.*/about-us/company-overview.html.*')
    OR REGEXP_CONTAINS(second_page, '.*about-us/business-opportunities.html.*')
    OR REGEXP_CONTAINS(second_page, '.*about-us/jobs.html.*')
    OR REGEXP_CONTAINS(second_page, '.*email-our-ceo.html.*') THEN 'others'
      WHEN REGEXP_CONTAINS(second_page, '.*/affiliate-program.html.*') THEN 'affiliate_program'
      WHEN REGEXP_CONTAINS(second_page, '.*/asianbeautywholesale-introduction.html.*') THEN 'wholesale'
      WHEN REGEXP_CONTAINS(second_page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(second_page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(second_page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(second_page,'.*/TINY2020.*') OR REGEXP_CONTAINS(second_page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(second_page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(second_page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(second_page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(second_page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(second_page,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(second_page,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(second_page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(second_page, '.*/app.*') THEN 'app'
    ELSE
    second_page
  END
    AS second_page_in_second_page_type,    CASE
      WHEN REGEXP_CONTAINS( exit_page, '.*shopping-bag.html.*') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( exit_page, '.*sign-in.html.*')
    OR REGEXP_CONTAINS( exit_page, '.*/sign-up-success.html.*') OR REGEXP_CONTAINS (exit_page, '.*social-connect.html.*') OR REGEXP_CONTAINS(exit_page, '.*/secure/oauth/response.*')  OR REGEXP_CONTAINS(exit_page, '.*secure/do-reset-login-email.html.*') OR REGEXP_CONTAINS( exit_page, '.*/sign-up.html*') THEN 'sign_in_register'
      WHEN REGEXP_CONTAINS( exit_page, '.*elite-club-.*') OR  REGEXP_CONTAINS( exit_page, '.*elite-club.html.*') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( exit_page, '.*friend-rewards.html.*') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( exit_page, '.*/korean-fashion-women.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-skin-care.*') OR REGEXP_CONTAINS( exit_page, ".* /us-beauty-cosmetics.*") OR REGEXP_CONTAINS( exit_page, '.*/korean-fashion-men.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-fashion-women.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/k-beauty.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/japanese-beauty-cosmetics.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-sunscreen.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-face-mask.*') OR REGEXP_CONTAINS( exit_page, '.*/korean-lip-tint.*') OR REGEXP_CONTAINS(exit_page, '.*/high-street.*') OR REGEXP_CONTAINS(exit_page, '.*/korean-bb-creams.*') OR REGEXP_CONTAINS(exit_page, '.*/korean-moisturizers.*') OR REGEXP_CONTAINS(exit_page, '.*/us-beauty-cosmetics.*')
      OR REGEXP_CONTAINS(exit_page, '.*holiday-shopping-guide.*')       THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( exit_page, ".*influencers.html.*") THEN 'influencers'
      WHEN REGEXP_CONTAINS(exit_page, '.*/videos.html.*') THEN 'video_page'
      WHEN REGEXP_CONTAINS( exit_page, ".*home.html.*") OR REGEXP_CONTAINS(exit_page, 'https://ys.style.*') 
    OR exit_page = 'https://yesstyle.com/' OR (REGEXP_CONTAINS(exit_page, 'https://www.yesstyle.com/.*') AND  REGEXP_CONTAINS(exit_page, '.*/women.html'))
    OR exit_page = 'https://www.yesstyle.com/' THEN 'homeexit_page'
      WHEN REGEXP_CONTAINS( exit_page, ".*saved-items.*") THEN 'saved_item'
      WHEN REGEXP_CONTAINS( exit_page, ".*beauty.html.*") THEN 'beauty_frontpage'
      WHEN REGEXP_CONTAINS( exit_page, ".*list.html/bcc.*") OR REGEXP_CONTAINS( exit_page, ".*/list.html/bpt.299.*") OR REGEXP_CONTAINS(exit_page, '.*/list.html/sb.*')
      OR REGEXP_CONTAINS (exit_page, '.*/list.html/ss.*') THEN 'PLP'
      WHEN REGEXP_CONTAINS( exit_page, ".*info.html/pid.*") 
      OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(exit_page), '.*-%e3%.*'))
         OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/ja/.*') AND REGEXP_CONTAINS(lower(exit_page), '.*/info.*'))
       OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(exit_page), '.*/info.*'))
      OR (REGEXP_CONTAINS(exit_page, '.*www.yesstyle.com/zh_.*') AND REGEXP_CONTAINS(lower(exit_page), '.*-%e.*'))
      THEN 'PDP' 
      WHEN REGEXP_CONTAINS( exit_page, ".*/secure/myaccount/track-your-order.html.*") OR REGEXP_CONTAINS( exit_page, ".*/secure/myaccount/order.html.*") OR REGEXP_CONTAINS( exit_page, ".*/myaccount/order.html.*") THEN 'track_order'
      WHEN REGEXP_CONTAINS( exit_page, ".*/special-offers.html.*") OR REGEXP_CONTAINS(exit_page, '.*special-offers-men.html.*') THEN 'SALE_page'
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
      WHEN REGEXP_CONTAINS(exit_page, '.*bcs=1&badid=.*') OR REGEXP_CONTAINS(exit_page, '.*badid=.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/bpt.300_badid.*')  OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.3_bpt.299_bid.314576.*')  OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.10_vn.33_bpt.299_bt.37_bid.*') OR REGEXP_CONTAINS(exit_page, '.*list.html/pn.2_vn.33_bpt.299_bt.37_bid.311751.*') 
      OR REGEXP_CONTAINS(exit_page, '.*/list.html/pr.0~25_bpt.299_bt.299_bid.311789.*') OR REGEXP_CONTAINS(exit_page, '.*/list.html/vn.33_bpt.299_bt.37_bid.312066.*') 
      OR REGEXP_CONTAINS(exit_page, '.*/list.html/pn.2_bpt.299_bid.314036.*') 
       OR (REGEXP_CONTAINS(exit_page, '.*/list.html/.*') AND REGEXP_CONTAINS(exit_page, '.*vn.33_bpt.299_bt.37_bid.*'))
      THEN 'brand_PLP'
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
      WHEN REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway.html.*') OR REGEXP_CONTAINS(exit_page, '.*/inssakit-vol-4-kwijeu-edition-box-set-promotion-quiz.html.*') OR REGEXP_CONTAINS(exit_page, '.*instagram-easter-giveaway.html.*') OR REGEXP_CONTAINS(exit_page,'.*/TINY2020.*') OR REGEXP_CONTAINS(exit_page, '.*/exclusive-sale.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-entered.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-congrats.html.*') OR REGEXP_CONTAINS(exit_page, '.*/instagram-website-giveaway-grand-prize.html.*') OR REGEXP_CONTAINS(exit_page, '.*/yesstyle-beauty-free-gift-beauty-sample-1-pc.*') OR  REGEXP_CONTAINS(exit_page,'.*instagram-easter-giveaway-grand-prize.html.*')
      
     OR  REGEXP_CONTAINS(exit_page,'.*/instagram-easter-giveaway-entered.html.*')
      THEN 'limited_time_event'
      WHEN REGEXP_CONTAINS(exit_page, 'https://www.yesstyle.com/.*')
    AND REGEXP_CONTAINS(exit_page, '.*/app.*') THEN 'app'
    ELSE
    exit_page
  END
    AS exit_page_in_exit_page_type

    
from
    pages,
    date_range
       
        WHERE  page_title NOT IN ('Page Not Available | YesStyle','Interner Serverfehler | YesStyle','Seite ist nicht verfügbar | YesStyle','Página no disponible | YesStyle','ページを表示できません | YesStyle','Internal Server Error | YesStyle', 'Error interno del servidor | YesStyle', 'Erreur de serveur interne | YesStyle', '無法顯示此網頁 | YesStyle', '无法显示该页面 | YesStyle', '服务器错误 | YesStyle', 'Trang không có sẵn | Có', '伺服器錯誤 | YesStyle', '内部サーバーエラー | YesStyle'
) 

 GROUP BY 1,2,3,4,5
