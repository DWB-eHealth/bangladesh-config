select
	pi.patient_id ,
	pvdd.visit_id ,
	pvdd.visit_start_date ,
	pvdd.visit_end_date
from
	patient_identifier pi
left outer join patient_visit_details_default pvdd
on pvdd.patient_id = pi.patient_id
and pvdd.visit_id = (
	select MAX(visit_id)
	from patient_visit_details_default pvdd2
	where pvdd2.patient_id = pi.patient_id and pvdd2.visit_id is not null
)
and pvdd.visit_start_date = (
	select MAX(visit_start_date)
	from patient_visit_details_default pvdd3
	where pvdd3.patient_id = pi.patient_id and pvdd3.visit_start_date is not null
)
where pvdd.visit_id is not null and pvdd.visit_start_date is not null
group by
	pi.patient_id ,
	pvdd.visit_id ,
	pvdd.visit_start_date ,
	pvdd.visit_end_date
