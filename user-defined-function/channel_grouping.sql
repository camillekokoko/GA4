CASE  
#rank_1 paid search
WHEN regexp_contains(traffic_medium, r'^(cpc|ppc|paidsearch|medium_cpc)$') OR traffic_source IN ('ac_RW2LBDEW', 'ac_77R696DK', 'ac_PRJE94MH', 'ac_PRJE94MH' ,'ac_B7E1QAJM', 'ac_HPV6W3NZ', 'ac_M7S6I5AW', 'ac_15Q8UX9T', 'ac_LN8PC3CF', 'ac_LWSCL4MH', 'ac_99ENGADG', 'ac_Z62MSNHF', 'ac_A9WBRY70', 'ac_APJQMWDP', 'ac_RWOAYQQJ', 'ac_LN8PC3CF', 'ac_UXRLI14Y', 'ac_6XWB5WY8', 'ac_389R3MWY', 'ac_GP0JV0W4', 'ac_2X44634R', 'ac_KX6H9MT5', 'ac_K2AMOAC0', 'ac_B7E1QAJM', 'ac_GP0JV0W4', 'ac_J1ZE5O8M', 'ac_UXRLI14Y', 'ac_GS05G73Y', 'ac_ZDCUT1SF', 'ac_RWOAYQQJ', 'ac_BT8OOPX8', 
'ac_7KF2WYU9', 'ac_LSX2FXR0', 'ac_GLAQCUVE', 'ac_RWOAYQQJ', 'ac_RW2LBDEW', 'ac_Q4FXBKRG', 
'ac_GLAQCUVE', 'ac_H6XM7U8D', 'ac_4L4LWCFK', 'ac_IGYN4SMQ', 'ac_2XGG00AU', 'ac_GP0JV0W4', 
'ac_JKNTZAOC', 'ac_EXUXNBGL', 'ac_MIEU1SGQ')
OR (regexp_contains(traffic_source, r'^(GoogleAds|Google Ads|google ads|source_Google Ads|source_GoogleAds||BingAds)$') AND  regexp_contains(traffic_medium , r'^(Shopping|shopping|YSKW|medium_YSKW|(not set)|search|Search|medium_Shopping|medium_YSKW|medium_search|medium_Search)$'))
then 'Paid Search'

#rank_2 display
WHEN  regexp_contains(traffic_medium, r'^(display|cpm|banner|rt)$') 
OR regexp_contains(traffic_source, r'^(rtb|rtbhouse)$') OR traffic_campaign = 'DRMKT' 
OR (regexp_contains(traffic_source, r'(GoogleAds|Google Ads|source_GoogleAds)') AND  regexp_contains(traffic_medium , r'(etargeting|Display|medium_banner)$'))
then 'Display'


#rank_3 influencer
WHEN regexp_contains(traffic_medium,r'(Influencer|influencer|ipreferral2|ipreferral|Rewards|LinkShare|medium_influencer|influencerprogram|medium_influencerprogram)') OR regexp_contains(traffic_source, r'(Influencer|influencer|medium_influencerprogram|ac_D9ONY0MY)') 
THEN 'Influencer'

#rank_4 kol
WHEN  (regexp_contains(traffic_source, r'^(yt|dynamic|source_yt)$') OR  regexp_contains(traffic_medium, r'kol') )
AND NOT regexp_contains(traffic_medium, r'(ctw|owned|influencer|medium_ctw)') then 'KOL'


#rank_5 affiliates
when regexp_contains(traffic_medium, r'^(affiliate|affilia|medium_affiliate|affi|Affiliates|medium_Affiliates)$')
OR regexp_contains(traffic_source, r'(mediumshareasale|webgains|shareasale|shopbot|awin|click0.vipaffiliatenetwork.com|shareasale-analytics.com|cf|fr.igraal.com|trendupdeal.com|narrativ)')
OR traffic_source IN ('ac_EOCCL4PL', 'ac_WRKB7OI4', 'ac_1EZS31AM', 'ac_R966LIHE', 'ac_8PDYGLUD', 'ac_2WKLPG0R', 'ac_1EZS31AM', 'ac_GIMTOJRK', 'ac_1EZS31AM', 'ac_1EZS31AM', 'ac_QEMTZ9Y1', 'ac_2WKLPG0R', 'ac_QEMTZ9Y1', 'ac_YLLNUBNS', 'ac_G8A7A49E') AND NOT regexp_contains(traffic_medium,   r'(owned|brands)')
then 'Affiliates'


#rank_6 paid social
WHEN regexp_contains(traffic_medium, r'(ads|medium_conversion)')  OR 
regexp_contains(traffic_source, r'(FACEBOOK|SNAPCHAT|INSTAGRAM|YOUTUBE|PINTEREST)') OR 
regexp_contains(traffic_source,r'^(fb|ig|an|msg|yt|source_ig|ac_XCB0Q5PJ)$')
OR (traffic_source = 'facebook.com' AND traffic_medium = 'Paid')
AND NOT regexp_contains(traffic_medium,r'(ig_profile|home|story)')
then 'Paid Social'

#rank_9 email
WHEN regexp_contains(traffic_medium, r'(email|e-mail|e_mail|e mail|medium_email|notification)') OR  regexp_contains(traffic_source, r'(edm_|live.com|qmail.com|email|web-mail|sp-web.search.auone.jp|cableone.net|web noti|webmail|mail)')
# mail02.orange.fr)|webmail.freenet.de|mail.google.com|exmail.qq.com|web-010.citromail.hu&|mail.inbox.lv|webmailb.netzero.net|mail.azet.sk|posti.mail.ee|outlook.live.com
OR traffic_source IN ('ac_EP83MKK5', 'ac_3XW6O22X', 'ac_LW2T14QJ', 'ac_JM8Z64Q3', 'ac_LK7N4QHP', 'ac_LJM3Z1KI', 'ac_8NZZ2L9A', 'ac_WEA1K2U0', 'ac_TWMHOZK7', 'ac_BLQG8AI8', 'ac_9F0QS69C', 'ac_9J8B14K4', 'ac_0MMSBST4', 'ac_I5ZV49F5', 'ac_V2H0P2SC', 'ac_V3F27IJQ', 'ac_384H8LTD', 'ac_Y1M37DX0', 'ac_CVV8C232', 'ac_PYGUPDKL', 'ac_0IPUPUH3', 'ac_O4EPHVF4', 'ac_VFXUHVHF', 'ac_Y108WTXD', 'ac_Y108WTXD', 'ac_G5LEEBIU', 'ac_KJEGEF7X', 'ac_4TS28ULK',  'ac_JXDQRUR6', 'ac_MY6YZVRL', 'ac_SS5OBE8B', 'ac_RKZZ5ML2', 'ac_JU06WG4S', 'ac_VIUOWSIJ', 'ac_01DN6K00', 'ac_TXJ9EZ7Y', 'ac_X3RP8DAI', 'ac_JPVYFSHL', 'ac_WIRFT5VW', 'ac_VFXUHVHF', 'ac_AYHBRKF0', 'ac_8T6JSEB0', 'ac_42LONN0D', 'ac_1YBUTKHT', 'ac_2NETN8H8', 'ac_5E92J13X', 'ac_NASUBXM3', 'ac_Y108WTXD', 'ac_CNVGOV6I', 'ac_OZL2SR24', 'ac_FPAYI2D6', 'ac_7I34O77G', 'ac_5Z7M6QUV',
'ac_1JBKG75Q', 'ac_QPUFQFPU', 'ac_IJLY4WST', 'ac_KGL97HWY', 'ac_AB3YOJY9', 'ac_DY1ICHLR', 'ac_UT4G8E7U', 'ac_0NJPJ4SY', 'ac_KJZOLZ1P', 'ac_1JBKG75Q', 'ac_PX4RRUBT', 'ac_N1Z60D9Z', 'ac_K00Z8N0G', 'ac_IJLY4WST', 'ac_70KKTL1P', 'ac_539VZYDG', 'ac_22VWPGOH','ac_I5BLTUXC' , 'ac_8Z3819BO', 'ac_KYS2HPIZ', 'ac_GO54S33G', 'ac_4BT488T5', 'ac_HQKFCAED', 'ac_52GCYKO0', 'ac_CZTLJUKJ', 'ac_8LF9LMXI', 'ac_TLH227U1', 'ac_ERBDCQ0G', 'ac_RWOVKTXX', 'ac_EP83MKK5', 'ac_L9QL66VU', 'ac_5ATVC7RM', 'ac_HQ0ZUFNE', 'ac_CGEEO4I1', 'ac_WIMC4RVP', 'ac_844H49D7', 'ac_89HM7AAG', 'ac_7V8GJL66', 'ac_74CCIZP8', 'ac_F9FQTCS9', 'ac_W5XQXLL9', 'ac_KJEGEF7X', 'ac_VFXASDQB', 'ac_PJHTDXJE', 'ac_7IU1USC7', 'ac_DTQTVVVE', 'ac_G0ZSP7YS', 'ac_D88JF40X', 'ac_J9RLQ5HZ', 'ac_RV1J3U5I', 'ac_SNHDFVME', 'ac_WQ2MAXGV', 'ac_NLGUX4WT', 'ac_EJTP7DH2', 'ac_Y6BPMKQI', 'ac_GXVSA8ZG', 'ac_2FW0V0LF', 'ac_ZA897MPC', 'ac_1J0TN4RP', 'ac_J8YP00QZ', 'ac_35IHOLCZ', 'ac_RPXEMAUS', 'ac_22YKEY7Z', 'ac_ZRD8H19Q', 'ac_E73F8MIN', 'ac_YOPTMPS1', 
'ac_XFVT963F', 'ac_1EZS31AM', 'ac_7FEDLQ6E', 'ac_EXNLR7QV', 'ac_8TR1LSZJ', 'ac_M4O6JBP2', 
'ac_IJLY4WST', 'ac_8DD2G4JG', 'ac_MARO9AX0', 'ac_Y108WTXD', 'ac_GPLPZ7WD', 'ac_SV96YHZN', 
'ac_VIUOWSIJ', 'ac_1014OCYJ', 'ac_12DT6J3A', 'ac_E89RKGAE', 'ac_G67WADJD', 'ac_SX246MD7', 'ac_EXNLR7QV', 'ac_Y108WTXD', 'ac_18ODQZN1', 'ac_LX1PG38J', 'ac_CVV8C232', 'ac_E89RKGAE', 
'ac_Y6BPMKQI', 'ac_4J0ND13J', 'ac_JPVYFSHL', 'ac_MD9H9XN8', 'ac_5IR2DIL8', 'ac_Q25404R2', 
'ac_AS2LRO55', 'ac_RUW9K0PA', 'ac_7F9MFBUW', 'ac_KO4496NT', 'ac_H9UC3F1V', 'ac_UOTYOYAT', 
'ac_BZZXWDA4', 'ac_RUW9K0PA', 'ac_92PRX8GL'
) THEN 'Email' 

#rank_8 organic search
WHEN traffic_medium = 'organic' OR regexp_contains(traffic_source, r'(search.yahoo.com|search.becovi.com|bing.com|yandex|baidu.com|msn.com|petalsearch.com|google|google-play|yaani.com.tr|lite.qwant.com|search.|suche.t-online.de|blacksearch|sogou.com)') 
OR traffic_source in ('ac_1YBGMF7K', 'ac_FETJLDPJ')
#|search.lilo.org|search.bip|search.gexsi.com|docomo.ne.jp|websearch.rakuten.co.jp|search.desideriosoldi.com||search.aol.com|sp-web.search.auone.jp|engine.presearch.org|web-search.co
OR regexp_contains(traffic_source,r'^(google.com)$') THEN 'Organic Search' 

#rank_12
WHEN traffic_source = '(direct)'  AND (traffic_medium = '(none)' OR traffic_medium = '(not set)' ) OR (traffic_source IS NULL AND traffic_medium IS NULL AND traffic_campaign IS NULL) THEN 'Direct' 

#rank_7 social
WHEN regexp_contains(traffic_medium, r'(social|social-network|social-media|sm|social network|social media|medium_social|linkinbio|owned|brands|medium_prom)') OR traffic_medium = 'igtv'
OR traffic_campaign = 'Product_Tag' OR regexp_contains(traffic_campaign, r'^(IG_Profile|silvermember)$') 
OR regexp_contains(traffic_source, r'(acebook|interest|source_pinterest|nstagram|source_Instagram|youtube|t.co|reddit|tiktok|wechat|IGShopping|twitter|l.messenger.com||buzzfeed|snapchat|ac_YV4KWMTX|ac_Y9A9T2A5|ac_YV4KWMTX|ac_YV4KWMTX|ac_YV4KWMTX)') AND NOT regexp_contains(traffic_source, r'(trustpilot|source_trustpilot)')
then 'Social'

#rank_10 referral
WHEN (traffic_medium = 'referral'
OR regexp_contains(traffic_source, r'(trustpilot|source_trustpilot)')) AND NOT regexp_contains(traffic_source, r'facebook|Instagram|youtube|wechat') 
then 'Referral'


#rank_11 Other adverstising
WHEN regexp_contains(traffic_medium, r'^(cpv|cpa|cpp|content-text)$')

THEN 'Other Advertising'
ELSE 
'Others'
END
