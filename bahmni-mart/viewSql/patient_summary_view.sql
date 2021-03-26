select
  pdd.person_id as patient_id ,
  case
  	when eae.date_of_entry_into_cohort is not null and eae3.date_of_exit_from_cohort is null then
  	true
  end as "in_cohort" ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  pat."Status_of_Patient" ,
  pvdd.visit_id as "last_visit_id" ,
  pvdd.location_name as "last_visit_location" ,
  pvdd.visit_start_date as "last_visit_start_date" ,
  pvdd.visit_end_date as "last_visit_end_date" ,
  eae.date_of_entry_into_cohort as "first_date_of_entry_into_cohort" ,
  eae3.date_of_exit_from_cohort as "last_date_of_exit_from_cohort" ,
  pd.diagnosis as "last_diagnosis" ,
  pd.diagnosis_date as "last_diagnosis_date"
from person_details_default pdd
left outer join person_attributes pat
	on pat.person_id = pdd.person_id
left outer join patient_visit_details_default pvdd
  on pvdd.patient_id = pdd.person_id
  and pvdd.visit_id = (
    	select MAX(visit_id)
    	from patient_visit_details_default pvdd2
    	where pvdd2.patient_id = pdd.person_id and pvdd2.visit_id is not null
    )
  and pvdd.visit_start_date = (
    	select MAX(visit_start_date)
    	from patient_visit_details_default pvdd3
    	where pvdd3.patient_id = pdd.person_id and pvdd3.visit_start_date is not null
    )
left outer join patient_diagnosis pd
   on pd.patient_id = pdd.person_id
   and pd.visit_id = (
       select MAX(visit_id)
       from patient_diagnosis pd2
       where pd2.patient_id = pdd.person_id and pd2.visit_id is not null
     )
   and pd.diagnosis_date = (
       select MAX(diagnosis_date)
       from patient_diagnosis pd3
       where pd3.patient_id = pdd.person_id and pd3.diagnosis_date is not null
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
  in_cohort ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  pat."Status_of_Patient" ,
  pvdd.visit_id ,
  pvdd.location_name ,
  pvdd.visit_start_date ,
  pvdd.visit_end_date ,
  eae.date_of_entry_into_cohort ,
  eae3.date_of_exit_from_cohort ,
  pd.diagnosis ,
  pd.diagnosis_date
