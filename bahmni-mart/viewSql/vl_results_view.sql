select
  patient_id ,
  visit_id ,
  hcv_viral_load ,
  hcv_viral_load ~ '\*.*([0-9]{3})' as "VL result numeral format" ,
  hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' as "VL result exponential format" ,
  case
  	when not hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' and hc.hcv_viral_load ~ '\*.*([0-9]{3})' then
  	split_part(hc.hcv_viral_load, '*', 1)::numeric * 10 ^ right(hc.hcv_viral_load,1)::integer
  	when not hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' and hc.hcv_viral_load ~ '([0-9]{3,5})' then
  	hc.hcv_viral_load::integer
  	end
  as "VL result"
from hepatitis_c hc
where hcv_viral_load is not null
