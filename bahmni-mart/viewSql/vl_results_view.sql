select
  patient_id ,
  visit_id ,
  hcv_viral_load,
  hcv_viral_load ~ '\*.*([0-9]{3})' as "VL result format",
case
  when hcv_viral_load ~ '\*.*([0-9]{3})' then
  SPLIT_PART(hcv_viral_load, '*', 1)::numeric * 10 ^ right(hcv_viral_load,1)::integer
  end
as "VL result"
from hepatitis_c hc
where hcv_viral_load is not null 
