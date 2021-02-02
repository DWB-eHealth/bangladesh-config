select
	pi.patient_id ,
	hc.visit_id as "visit_id" ,
	hc.date_of_daa_initiation as "first_date_of_daa_initiation"
from
	patient_identifier pi
left outer join hepatitis_c hc
on hc.patient_id = pi.patient_id
and hc.date_of_daa_initiation = (
	select MAX(date_of_daa_initiation)
	from hepatitis_c hc2
	where hc2.patient_id = pi.patient_id and hc2.date_of_daa_initiation is not null
)
where hc.date_of_daa_initiation is not null
group by
	pi.patient_id ,
	hc.visit_id ,
	hc.date_of_daa_initiation
