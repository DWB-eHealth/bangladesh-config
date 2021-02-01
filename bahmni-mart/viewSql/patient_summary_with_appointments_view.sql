select
  pdd.person_id as "patient_id" ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  case
  	when eae.date_of_entry_into_cohort is not null and eae3.date_of_exit_from_cohort is null then
  	true
  end as "in_cohort" ,
  eae.date_of_entry_into_cohort as "first_date_of_entry_into_cohort" ,
  eae3.date_of_exit_from_cohort as "last_date_of_exit_from_cohort" ,
  pd.diagnosis as "last_diagnosis" ,
  pd.diagnosis_date as "last_diagnosis_date" ,
  pd.location_name as "last_diagnosis_location" ,
  pad.appointment_id ,
  pad.appointment_location ,
  pad.appointment_service ,
  pad.appointment_start_time ,
  pad.appointment_end_time ,
  pad.appointment_status ,
  case
  	when pad.appointment_start_time is not null then
  	DATE_PART('day', CURRENT_TIMESTAMP - pad.appointment_start_time)
  end as "days_since_start_time"
from person_details_default pdd
left outer join person_attributes pat
	on pat.person_id = pdd.person_id
left outer join patient_appointment_default pad
	on pad.patient_id = pdd.person_id
left outer join
     patient_diagnosis pd
         on pd.patient_id = pdd.person_id
         and pd.visit_id = (
             select MAX(visit_id)
         from patient_diagnosis pd2
         where
             pd2.patient_id = pdd.person_id
             and pd2.visit_id is not null
     )
     and pd.diagnosis_date = (
         select MAX(diagnosis_date)
         from patient_diagnosis pd3
         where
             pd3.patient_id = pdd.person_id
             and pd3.diagnosis_date is not null
     )
left outer join entrance_and_exit eae
  on eae.patient_id = pdd.person_id
  and eae.date_of_entry_into_cohort = (
    	select MIN(date_of_entry_into_cohort)
    	from entrance_and_exit eae2
    	where eae2.patient_id = pdd.person_id and eae2.date_of_entry_into_cohort is not null
    )
left outer join entrance_and_exit eae3
   on eae3.patient_id = pdd.person_id
   and eae3.date_of_exit_from_cohort = (
     	select MAX(date_of_exit_from_cohort)
     	from entrance_and_exit eae4
     	where eae4.patient_id = pdd.person_id and eae4.date_of_exit_from_cohort is not null
     )
where pat.person_id is not null
group by
  pdd.person_id ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  in_cohort ,
  eae.date_of_entry_into_cohort ,
  eae3.date_of_exit_from_cohort ,
  last_diagnosis ,
  last_diagnosis_date ,
  pd.location_name ,
  pad.appointment_id ,
  pad.appointment_location ,
  pad.appointment_service ,
  pad.appointment_start_time ,
  pad.appointment_end_time ,
  pad.appointment_status
