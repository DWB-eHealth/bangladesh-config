select
	pi.patient_id ,
	eae.visit_id as "first_visit_id" ,
	eae.date_of_entry_into_cohort as "first_date_of_entry_into_cohort" ,
	eae3.visit_id as "last_visit_id" ,
	eae3.date_of_exit_from_cohort as "last_date_of_exit_from_cohort" ,
	case
	when eae3.date_of_exit_from_cohort is null then
	EXTRACT(year FROM age(current_date::date,eae.date_of_entry_into_cohort::date))*12 + EXTRACT(month FROM age(current_date::date,eae.date_of_entry_into_cohort::date))
	else
	EXTRACT(year FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date))*12 + EXTRACT(month FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date))
	end as "duration_months"
from
	patient_identifier pi
left outer join entrance_and_exit eae
on eae.patient_id = pi.patient_id
and eae.date_of_entry_into_cohort = (
	select MIN(date_of_entry_into_cohort)
	from entrance_and_exit eae2
	where eae2.patient_id = pi.patient_id and eae2.date_of_entry_into_cohort is not null
)
left outer join entrance_and_exit eae3
on eae3.patient_id = pi.patient_id
and eae3.date_of_exit_from_cohort = (
	select MAX(date_of_exit_from_cohort)
	from entrance_and_exit eae4
	where eae4.patient_id = pi.patient_id and eae4.date_of_exit_from_cohort is not null
)
group by
	pi.patient_id ,
	eae.visit_id ,
	eae.date_of_entry_into_cohort ,
	eae3.visit_id ,
	eae3.date_of_exit_from_cohort
