/*
01_patient_id
02_age
03_age_group
04_sex

05_last_enrollment_location
06_first_cohort_enrollment_date
07_last_cohort_exit_date
08_last_cohort_exit_status
09_total_length_of_follow

10_last_primary_diagnosis
11_last_co_morbidity
28_last_morbidity_other

29_last_appointment_date
30_last_appointment_status
31_inactive_patients ? > 3 months?
32_days_since_last_missed_appointment

33_last_BP_date
34_last_BP_recorded
35_BP_checked_last_appointment - not linkable
36_last_BP_controlled
37_last_HbA1c_date
38_last_HbA1c_recorded
39_HbA1c_checked_last_appointment - not linkable
40_last_HbA1c_controlled
*/

select
  pdd.person_id as patient_id ,
  pdd.age as age,
  pdd.age_group as age_group,
  pdd.gender as gender,

  pvdd.location_name as last_enrollment_location ,
  eae.date_of_entry_into_cohort as first_cohort_enrollment_date ,
  eae3.date_of_exit_from_cohort as last_cohort_exit_date ,
  eae3.exit_outcome_of_patient as last_cohort_exit_status ,
  case
	when eae3.date_of_exit_from_cohort is null then
	EXTRACT(year FROM age(current_date::date,eae.date_of_entry_into_cohort::date))*12 + EXTRACT(month FROM age(current_date::date,eae.date_of_entry_into_cohort::date))
	else
	EXTRACT(year FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date))*12 + EXTRACT(month FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date))
	end as total_length_of_follow_in_months ,

  pd.diagnosis as last_primary_diagnosis ,
  pd.diagnosis as last_morbidity_other ,
  MAX (CASE
	WHEN
	pd.diagnosis = 'Asthma' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Asthma' THEN concat('2')
	ELSE NULL END) AS "Asthma",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Cardiovascular disease' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Cardiovascular disease' THEN concat('2')
	ELSE NULL END) AS "Cardiovascular disease",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic kidney insufficiency' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic kidney insufficiency' THEN concat('2')
	ELSE NULL END) AS "Chronic kidney insufficiency",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Kidney Disease, Stage I' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Kidney Disease, Stage I' THEN concat('2')
	ELSE NULL END) AS "Chronic Kidney Disease, Stage I",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Kidney Disease, Stage II (Mild)' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Kidney Disease, Stage II (Mild)' THEN concat('2')
	ELSE NULL END) AS "Chronic Kidney Disease, Stage II (Mild)",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Kidney Disease, Stage III (Moderate)' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Kidney Disease, Stage III (Moderate)' THEN concat('2')
	ELSE NULL END) AS "Chronic Kidney Disease, Stage III (Moderate)",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Kidney Disease, Stage IV (Severe)' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Kidney Disease, Stage IV (Severe)' THEN concat('2')
	ELSE NULL END) AS "Chronic Kidney Disease, Stage IV (Severe)",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Kidney Disease, Stage V' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Kidney Disease, Stage V' THEN concat('2')
	ELSE NULL END) AS "Chronic Kidney Disease, Stage V",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic obstructive pulmonary disease (COPD)' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic obstructive pulmonary disease (COPD)' THEN concat('2')
	ELSE NULL END) AS "Chronic obstructive pulmonary disease (COPD)",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Epilepsy' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Epilepsy' THEN concat('2')
	ELSE NULL END) AS "Epilepsy",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Chronic Hepatitis C' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Chronic Hepatitis C' THEN concat('2')
	ELSE NULL END) AS "Chronic Hepatitis C",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Hypertension' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Hypertension' THEN concat('2')
	ELSE NULL END) AS "Hypertension",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Stroke' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Stroke' THEN concat('2')
	ELSE NULL END) AS "Stroke",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Thyroid disease' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Thyroid disease' THEN concat('2')
	ELSE NULL END) AS "Thyroid disease",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Diabetes mellitus, type 1' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Diabetes mellitus, type 1' THEN concat('2')
	ELSE NULL END) AS "Diabetes mellitus, type 1",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Diabetes mellitus, type 2' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Diabetes mellitus, type 2' THEN concat('2')
	ELSE NULL END) AS "Diabetes mellitus, type 2",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Cirrhosis and Chronic Liver Disease' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Cirrhosis and Chronic Liver Disease' THEN concat('2')
	ELSE NULL END) AS "Cirrhosis and Chronic Liver Disease",
	MAX (CASE
	WHEN
	pd.diagnosis = 'Other pathology' THEN concat('1')
	WHEN
	cmc.co_morbid_conditions = 'Other pathology' THEN concat('2')
	ELSE NULL END) AS "Other pathology" ,

	pad.appointment_start_time as appointment_start_time ,
	pad.appointment_status as last_appointment_status ,
  case
  	when pad.appointment_start_time is not null and pad.appointment_status = 'Missed' and EXTRACT(month FROM age(current_date::date,pad.appointment_start_time::date)) > 3 then
  	'Inactive patient'
  end as "inactive_patients (> 3 months)",
  case
  	when pad.appointment_start_time is not null and pad.appointment_status = 'Missed' then
  	DATE_PART('day', CURRENT_TIMESTAMP - pad.appointment_start_time)
  end as days_since_last_missed_appointment ,

  pv.date_recorded as last_BP_date,
  pv.systolic_blood_pressure as last_SBP_recorded ,
  pv.diastolic_blood_pressure as last_DBP_recorded ,
  case when
  pv.systolic_blood_pressure between 90 and 140 and EXTRACT(month FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date)) > 6
  or
  pv.diastolic_blood_pressure between 90 and 140 and EXTRACT(month FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date)) > 6
    then
    'Yes'
  end as "Patients in cohort > 6 months with hypertension (SBP/DBP <140/90)" ,

  lt.date_of_sample_collected_for_hba1c as last_HbA1c_date ,
  lt.hba1c as last_HbA1c_recorded ,
  case when lt.hba1c < 8 and EXTRACT(month FROM age(eae3.date_of_exit_from_cohort::date,eae.date_of_entry_into_cohort::date)) > 6 then
    'Yes'
  end as "HbA1c < 8% for patients in cohort > 6 months"

from person_details_default pdd
left outer join person_attributes pat
	on pat.person_id = pdd.person_id
left outer join patient_appointment_default pad
  on pad.patient_id = pdd.person_id
  and pad.appointment_start_time = (
      select MAX(appointment_start_time)
      from patient_appointment_default pad2
      where pad2.patient_id = pdd.person_id and pad2.appointment_start_time is not null
    )
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
   and pd.visit_id = pvdd.visit_id
   and pd.diagnosis_date = (
       select MAX(diagnosis_date)
       from patient_diagnosis pd3
       where pd3.patient_id = pdd.person_id and pd3.diagnosis_date is not null
     )
left outer join co_morbid_conditions cmc
    on cmc.patient_id = pdd.person_id
    and cmc.visit_id = pvdd.visit_id
left outer join lab_tests lt
    on lt.patient_id = pdd.person_id
    and lt.visit_id = pvdd.visit_id
left outer join patient_vitals pv
    on pv.patient_id = pdd.person_id
    and pv.visit_id = pvdd.visit_id
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
  pat."Status_of_Patient" ,
  pvdd.visit_id ,
  pvdd.location_name ,
  pvdd.visit_start_date ,
  pvdd.visit_end_date ,
  eae.date_of_entry_into_cohort ,
  eae3.date_of_exit_from_cohort ,
  eae3.exit_outcome_of_patient ,
  pd.diagnosis ,
  pd.diagnosis_date ,
  pad.appointment_start_time ,
  pad.appointment_status ,
  pv.date_recorded ,
  pv.systolic_blood_pressure ,
  pv.diastolic_blood_pressure ,
  lt.date_of_sample_collected_for_hba1c ,
  lt.hba1c
