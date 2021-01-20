
select
  pdd.person_id as patient_id ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  pd.diagnosis as last_diagnosis ,
  pd.diagnosis_date as last_diagnosis_date ,
  pd.location_name ,
  pad.appointment_id ,
  pad.appointment_location ,
  pad.appointment_service ,
  pad.appointment_start_time
from person_details_default pdd
left outer join person_attributes pat
	on pat.person_id = pdd.person_id
left outer join patient_appointment_default pad
	on pad.patient_id = pdd.person_id
left outer join
     patient_diagnosis pd
         on pd.patient_id = pdd.person_id
         and pd.visit_id = (
             select
                 MAX(visit_id)
         from
             patient_diagnosis pd2
         where
             pd2.patient_id = pdd.person_id
             and pd2.visit_id is not null
     )
     and pd.diagnosis_date = (
         select
             MAX(diagnosis_date)
         from
             patient_diagnosis pd3
         where
             pd3.patient_id = pdd.person_id
             and pd3.diagnosis_date is not null
     )
where pat.person_id is not null
group by
  pdd.person_id ,
  pdd.gender ,
  pdd.age ,
  pdd.age_group ,
  last_diagnosis ,
  last_diagnosis_date ,
  pd.location_name ,
  pad.appointment_id ,
  pad.appointment_location ,
  pad.appointment_service ,
  pad.appointment_start_time 
