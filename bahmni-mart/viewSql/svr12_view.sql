select
  hc.patient_id ,
  hc.visit_id ,
  hc.hcv_viral_load ,
  hc.hcv_viral_load ~ '\*.*([0-9]{3})' as "VL result numeral format" ,
  hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' as "VL result exponential format" ,
case
  when hc.hcv_viral_load ~ '\*.*([0-9]{3})' then
  SPLIT_PART(hc.hcv_viral_load, '*', 1)::numeric * 10 ^ right(hc.hcv_viral_load,1)::integer
  when hc.hcv_viral_load ~ '([0-9]{3,5})' then
  hc.hcv_viral_load::integer
  end
as "VL result" ,
hc.date_of_sample_collected_for_hcv_viral_load ,
hc2.date_of_daa_termination ,
hc2.visit_id ,
case
when hc2.date_of_daa_termination is not null then
EXTRACT(year FROM age(hc.date_of_sample_collected_for_hcv_viral_load::date,hc2.date_of_daa_termination::date))*12 + EXTRACT(month FROM age(hc.date_of_sample_collected_for_hcv_viral_load::date,hc2.date_of_daa_termination::date))
end as "duration_months"
from hepatitis_c hc
left outer join hepatitis_c hc2
  on hc2.patient_id = hc.patient_id
	and hc2.visit_id = (
		select MAX(visit_id)
		from hepatitis_c hc3
		where hc3.patient_id = hc2.patient_id and hc3.date_of_daa_termination is not null
	)
where hc.hcv_viral_load is not null
