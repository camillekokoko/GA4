CASE
    WHEN LOWER(geo_country) = "united states" THEN "US"
    WHEN LOWER(geo_country) = "australia" THEN "AU"
    WHEN LOWER(geo_country) = "canada" THEN "CA"
    WHEN LOWER(geo_country) = "france" THEN "FR"
    WHEN ( LOWER(geo_country) = 'germany' OR LOWER(geo_country) = 'austria') THEN 'DE'
    WHEN ( LOWER(geo_country) = 'spain'
    OR LOWER(geo_country) = 'mexico'
    OR LOWER(geo_country) ='argentina'
    OR LOWER(geo_country) = 'bolivia'
    OR LOWER(geo_country) = 'chile'
    OR LOWER(geo_country) = 'colombia'
    OR LOWER(geo_country) ='costa rica'
    OR LOWER(geo_country) ='cuba'
    OR LOWER(geo_country) ='dominican republic'
    OR LOWER(geo_country) ='ecuador'
    OR LOWER(geo_country) ='equatorial guinea'
    OR LOWER(geo_country) = 'el salvador'
    OR LOWER(geo_country) ='guatemala'
    OR LOWER(geo_country) = 'honduras'
    OR LOWER(geo_country) ='nicaragua'
    OR LOWER(geo_country) = 'panama'
    OR LOWER(geo_country) = 'paraguay'
    OR LOWER(geo_country) = 'peru'
    OR LOWER(geo_country) = 'puerto rico'
    OR LOWER(geo_country) = 'uruguay'
    OR LOWER(geo_country) = 'venezuela'
    OR LOWER(geo_country) = 'austria') THEN 'ES'
    WHEN LOWER(geo_country) = 'united kingdom' THEN 'UK'
    WHEN LOWER(geo_country) = 'japan' THEN 'JP'
  ELSE
'ROW'
 END
