select
	patient_id ,
	visit_id ,
	gender ,
	age ,
	age_group ,
	location_name ,
	pa."Status_of_Patient" ,
	diagnosis ,
	concat('Primary Diagnosis') as "type" ,
	diagnosis_date
from patient_diagnosis pd
left outer join person_attributes pa
	on pa.person_id = pd.patient_id
left outer join person_details_default pdd
	on pdd.person_id = pd.patient_id
where diagnosis is not null and diagnosis_date is not null
and pd.visit_id = (
       select MAX(visit_id)
       from patient_diagnosis pd2
       where pd2.patient_id = pd.patient_id and pd2.visit_id is not null
     )
and pd.diagnosis_date = (
       select MAX(diagnosis_date)
       from patient_diagnosis pd6
       where pd6.patient_id = pd.patient_id and pd6.diagnosis_date is not null
     )
union all
select
	cmc.patient_id ,
	cmc.visit_id ,
	gender ,
	age ,
	age_group ,
	pd4.location_name ,
	pa1."Status_of_Patient" ,
	co_morbid_conditions ,
	concat('Co-morbid condition') as "type" ,
	pd4.diagnosis_date
from co_morbid_conditions cmc
left outer join patient_diagnosis pd4
	on pd4.patient_id = cmc.patient_id
left outer join person_attributes pa1
	on pa1.person_id = cmc.patient_id
left outer join person_details_default pdd
	on pdd.person_id = cmc.patient_id
where co_morbid_conditions is not null
and pd4.diagnosis is not null and pd4.diagnosis_date is not null
and cmc.visit_id = (
       select MAX(visit_id)
       from patient_diagnosis pd3
       where pd3.patient_id = cmc.patient_id and pd3.visit_id is not null
     )
and pd4.diagnosis_date = (
       select MAX(diagnosis_date)
       from patient_diagnosis pd5
       where pd5.patient_id = cmc.patient_id and pd5.diagnosis_date is not null
     )
