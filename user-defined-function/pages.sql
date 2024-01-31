CASE
      WHEN REGEXP_CONTAINS( exit_page, r'shopping-bag.html') THEN 'shopping_bag'
      WHEN REGEXP_CONTAINS( exit_page, r'sign-in.html|sign-up-success.html|social-connect.html|secure/oauth/response|secure/do-reset-login-email.html') THEN 'login_in_register'
      WHEN REGEXP_CONTAINS( exit_page, r'elite-club-|elite-club.html') THEN 'elite_club'
      WHEN REGEXP_CONTAINS( exit_page, r'friend-rewards.html') THEN 'friend_rewards'
      WHEN REGEXP_CONTAINS( exit_page, r'/korean-fashion-women|/korean-skin-care|/us-beauty-cosmetics|/korean-fashion-men|/japanese-fashion-women|/japanese-beauty-cosmetics|/k-beauty|/korean-beauty-cosmetics|/japanese-beauty-cosmetics|/korean-face-mask|/korean-sunscreen|/korean-face-mask|/korean-lip-tint|/high-street|/korean-bb-creams|/korean-moisturizers|/us-beauty-cosmetics|/holiday-shopping-guide') AND NOT REGEXP_CONTAINS( exit_page, r'.html') THEN 'YS_SEO_pages'
      WHEN REGEXP_CONTAINS( exit_page, r'influencers.html|influencer-request.html') THEN 'influencers'
      WHEN REGEXP_CONTAINS(exit_page, r'/videos.html') THEN 'video_page'
      WHEN REGEXP_CONTAINS( exit_page, r'home.html')
    #  OR REGEXP_CONTAINS(exit_page, 'https://ys.style.*')
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
    exit_page
  END
