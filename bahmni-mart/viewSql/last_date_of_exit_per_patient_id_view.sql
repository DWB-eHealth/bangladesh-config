select
	pi.patient_id ,
	eae.visit_id ,
	eae.date_of_entry_into_cohort ,
	eae.date_of_exit_from_cohort
from
	patient_identifier pi
left outer join entrance_and_exit eae
on eae.patient_id = pi.patient_id
and eae.visit_id = (
	select MAX(visit_id)
	from entrance_and_exit eae2
	where eae2.patient_id = pi.patient_id and eae2.visit_id is not null
)
and eae.date_of_exit_from_cohort = (
	select MAX(date_of_exit_from_cohort)
	from entrance_and_exit eae3
	where eae3.patient_id = pi.patient_id and eae3.date_of_exit_from_cohort is not null
)
where eae.visit_id is not null and eae.date_of_exit_from_cohort is not null
group by
	pi.patient_id ,
	eae.visit_id ,
	eae.date_of_entry_into_cohort ,
	eae.date_of_exit_from_cohort
