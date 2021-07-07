WITH cte_all_morbidities AS (
	SELECT
		am.patient_id,
		MAX (CASE WHEN am.diagnosis = 'Asthma' THEN '1' ELSE NULL END) AS "Asthma",
		MAX (CASE WHEN am.diagnosis = 'Cardiovascular disease' THEN '1' ELSE NULL END) AS "Cardiovascular disease",
		MAX (CASE WHEN am.diagnosis = 'Chronic kidney insufficiency' THEN '1' ELSE NULL END) AS "Chronic kidney insufficiency",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage I' THEN '1' ELSE NULL END) AS "Chronic Kidney Disease, Stage I",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage II (Mild)' THEN '1' ELSE NULL END) AS "Chronic Kidney Disease, Stage II (Mild)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage III (Moderate)' THEN '1' ELSE NULL END) AS "Chronic Kidney Disease, Stage III (Moderate)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage IV (Severe)' THEN '1' ELSE NULL END) AS "Chronic Kidney Disease, Stage IV (Severe)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage V' THEN '1' ELSE NULL END) AS "Chronic Kidney Disease, Stage V",
		MAX (CASE WHEN am.diagnosis = 'Chronic obstructive pulmonary disease (COPD)' THEN '1' ELSE NULL END) AS "Chronic obstructive pulmonary disease (COPD)",
		MAX (CASE WHEN am.diagnosis = 'Epilepsy' THEN '1' ELSE NULL END) AS "Epilepsy",
		MAX (CASE WHEN am.diagnosis = 'Chronic Hepatitis C' THEN '1' ELSE NULL END) AS "Chronic Hepatitis C",
		MAX (CASE WHEN am.diagnosis = 'Hypertension' THEN '1' ELSE NULL END) AS "Hypertension",
		MAX (CASE WHEN am.diagnosis = 'Stroke' THEN '1' ELSE NULL END) AS "Stroke",
		MAX (CASE WHEN am.diagnosis = 'Thyroid disease' THEN '1' ELSE NULL END) AS "Thyroid disease",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 1' THEN '1' ELSE NULL END) AS "Diabetes mellitus, type 1",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 2' THEN '1' ELSE NULL END) AS "Diabetes mellitus, type 2",
		MAX (CASE WHEN am.diagnosis = 'Cirrhosis and Chronic Liver Disease' THEN '1' ELSE NULL END) AS "Cirrhosis and Chronic Liver Disease",
		MAX (CASE WHEN am.diagnosis = 'Other pathology' THEN '1' ELSE NULL END) AS "Other pathology"
	FROM (SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			diagnosis,
			concat('Primary Diagnosis') AS "type"
		FROM patient_diagnosis pd 
		WHERE diagnosis IS NOT NULL 
		UNION 
		SELECT
			patient_id,
			max(obs_datetime),
			co_morbid_conditions AS diagnosis,
			concat('Co-Morbidity') AS "type"
		FROM co_morbid_conditions
		GROUP BY obs_datetime, patient_id, co_morbid_conditions
		ORDER BY patient_id, obs_datetime DESC) am
	GROUP BY patient_id)
SELECT
	pi."Patient_Identifier" AS "01_emr_id",
	pi.patient_id AS "02_patient_id",
	pdd.age AS "03_current_age",
	pdd.age_group AS "04_current_age_group",
	pdd.gender AS "05_sex", 
	pa."Status_of_Patient" AS "06_status_of_patient",
	lv.location_name AS "07_last_visit_location",
	led.date_of_entry_into_cohort AS "08_cohort_entry_date",
	led2.cohort_exit_date AS "09_cohort_exit_date",
	CASE 
		WHEN es.exit_outcome_of_patient IS NOT NULL THEN es.exit_outcome_of_patient 
		WHEN es.exit_outcome_of_patient IS NULL AND led2.deceased IS NOT NULL THEN 'Deceased'
		ELSE NULL 
	END AS "10_cohort_exit_status",
	ROUND((CASE 
		WHEN led2.cohort_exit_date IS NOT NULL THEN (DATE_PART('day',(led2.cohort_exit_date::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
		WHEN led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NOT NULL THEN NULL
		ELSE (DATE_PART('day',(now()::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
	END)::NUMERIC,1) AS "11_length_of_follow_(months)",
	pd.diagnosis AS "12_primary_diagnosis",
	cam."Asthma" AS "13_asthma",
	cam."Cardiovascular disease" AS "14_cardiovasular_disease",
	cam."Chronic kidney insufficiency" AS "15_chronic_kidney_insufficiency",
	cam."Chronic Kidney Disease, Stage I" AS "16_chronic_kidney_disease_stage_I",
	cam."Chronic Kidney Disease, Stage II (Mild)" AS "17_chronic_kidney_disease_stage_II",
	cam."Chronic Kidney Disease, Stage III (Moderate)" AS "18_chronic_kidney_disease_stage_III",
	cam."Chronic Kidney Disease, Stage IV (Severe)" AS "19_chronic_kidney_disease_stage_IV",
	cam."Chronic Kidney Disease, Stage V" AS "20_chronic_kidney_disease_stage_V",
	cam."Chronic obstructive pulmonary disease (COPD)" AS "21_COPD",
	cam."Epilepsy" AS "22_epilepsy",
	cam."Chronic Hepatitis C" AS "23_chronic_hepatitis_C",
	cam."Hypertension" AS "24_hypertension",
	cam."Stroke" AS "25_stroke",
	cam."Thyroid disease" AS "26_thyroid_disease",
	cam."Diabetes mellitus, type 1" AS "27_diabetes_type_1",
	cam."Diabetes mellitus, type 2" AS "28_diabetes_type_2",
	cam."Cirrhosis and Chronic Liver Disease" AS "29_cirrhosis_chronic_liver_disease",
	cam."Other pathology" AS "30_other_pathology",
	lpa.appointment_start_time::date AS "31_last_appointment_date",
	lpa.appointment_service AS "32_last_appointment_service",
	lpa.appointment_status AS "33_last_appointment_status",/*
	>>> REMOVE? Not sure this is needed for indicators
	lmpa.appointment_start_time AS "last_appointment_not_attended_date",
	lmpa.appointment_service AS "last_appointment_service_not_attended",
	lmpa.appointment_status AS "last_appointment_status_not_attended",
	CASE
		WHEN lmpa.appointment_start_time > lpa.appointment_start_time AND lpa.appointment_status <> 'Missed' THEN 'Yes'
		WHEN lmpa.appointment_start_time = lpa.appointment_start_time THEN 'Yes'
		ELSE NULL
	END AS "last_appointment_not_attended",*/
	CASE
		WHEN lpa.appointment_status = 'Missed' THEN (DATE_PART('day',(now())-(lpa.appointment_start_time::timestamp)))
		ELSE NULL 
	END AS "34_days_since_last_missed_appointment",
	/* >>> REMOVE? replaced by the above column
	CASE
		WHEN lmpa.appointment_start_time > lpa.appointment_start_time AND lpa.appointment_status <> 'Missed' THEN (DATE_PART('day',(now())-(lmpa.appointment_start_time::timestamp)))
		WHEN lmpa.appointment_start_time = lpa.appointment_start_time THEN (DATE_PART('day',(now())-(lmpa.appointment_start_time::timestamp)))
		ELSE NULL
	END AS "last_appointment_missed_days_since",*/
	/* >>>>>>> REMOVE? Used for backgroud checks
	lamt3.appointment_status AS "last_appointment_status_3m+",
	lalt3nm.appointment_status AS "last_appointment_status_<3m_not_missed",*/
	CASE
		WHEN lamt3.appointment_status = 'Missed' AND laalt3.appointment_status IS NULL THEN 'Yes'
		ELSE NULL 
	END AS "35_inactive",
	lpv.date_recorded AS "36_last_bp_date",
	CASE
		WHEN lpv.systolic_blood_pressure IS NOT NULL THEN concat(lpv.systolic_blood_pressure,'/',lpv.diastolic_blood_pressure) 
		ELSE NULL 
	END AS "37_last_bp",
	CASE
		WHEN lma.appointment_start_time::date = lpv.date_recorded THEN 'Yes'
		WHEN lma.appointment_start_time::date <> lpv.date_recorded THEN 'No'
		ELSE NULL
	END AS "38_bp_checked_at_last_appointment",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND lpv.systolic_blood_pressure <= 140 OR lpv.diastolic_blood_pressure <= 90 THEN 'Yes'
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lpv.systolic_blood_pressure > 140 OR lpv.diastolic_blood_pressure > 90) THEN 'No'
		ELSE null
	END AS "39_bp_controlled",
	lhba1c.date_of_sample_collected_for_hba1c AS "40_last_hba1c_date",
	lhba1c.hba1c AS "41_last_hba1c",
	CASE 
		WHEN lhba1c.hba1c <= 6.5 THEN '<=6.5%'
		WHEN lhba1c.hba1c > 6.5 AND lhba1c.hba1c <= 8 THEN '6.6-8.0%'
		WHEN lhba1c.hba1c > 8 THEN '>=8.1%'
		ELSE NULL 
	END AS "42_last_hba1c_categories",
	CASE
		WHEN lhba1c.date_of_sample_collected_for_hba1c >= date_trunc('day', now())- INTERVAL '12 month' THEN 'Yes'
		WHEN lhba1c.date_of_sample_collected_for_hba1c < date_trunc('day', now())- INTERVAL '12 month' THEN 'No'
		ELSE NULL
	END AS "43_hba1c_checked_in last_12_months",
	lfbs.date_of_sample_collected_for_fasting_blood_sugar_fbs AS "44_last_fbs_date",
	lfbs.fasting_blood_sugar_fbs AS "45_last_fbs_date",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lhba1c.hba1c < 8 OR lfbs.fasting_blood_sugar_fbs < 150) THEN 'Yes'
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lhba1c.hba1c >= 8 OR lfbs.fasting_blood_sugar_fbs >= 150) THEN 'No'
		ELSE null
	END AS "46_diabetes_controlled", 
	daai.date_of_daa_initiation AS "47_hepatitis_C_DAA_initiation_date", 
	daat.date_of_daa_termination AS "48_hepatitis_C_DAA_termination_date",
	hcr.date_of_sample_collected_for_hcv_viral_load AS "49_last_VL_date",
	hcr.hcv_viral_load AS "50_last_VL_result",
	hcr.hcv_viral_load_calc AS "50_last_VL_result_calc",
	(DATE_PART('day',(daat.date_of_daa_termination::timestamp)-(hcr.date_of_sample_collected_for_hcv_viral_load::timestamp)))/365*12 AS "51_duration_last_VL_DAA_termination",
	CASE 
		WHEN ((DATE_PART('day',(daat.date_of_daa_termination::timestamp)-(hcr.date_of_sample_collected_for_hcv_viral_load::timestamp)))/365*12) > 3 AND
			hcr.hcv_viral_load_calc < 1000 THEN 'Yes'
		WHEN ((DATE_PART('day',(daat.date_of_daa_termination::timestamp)-(hcr.date_of_sample_collected_for_hcv_viral_load::timestamp)))/365*12) > 3 AND
			hcr.hcv_viral_load_calc >= 1000 THEN 'No'
		ELSE NULL
	END AS "52_cured_hepatitis_C"
FROM patient_identifier pi
/*Joins age and gender for each patient*/
LEFT OUTER JOIN person_details_default pdd 
	ON pi.patient_id = pdd.person_id 
/*Joins status of patient for each patient*/
LEFT OUTER JOIN person_attributes pa 
	ON pi.patient_id = pa.person_id
/*Joins last visit location according to login location used for more recent data entry*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id, 
			location_name 
		FROM patient_visit_details_default 
		ORDER BY patient_id, visit_start_date DESC) lv
	ON pi.patient_id = lv.patient_id
/*Joins last reported cohort entry date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id, 
			date_of_entry_into_cohort 
		FROM entrance_and_exit
		WHERE date_of_entry_into_cohort IS NOT NULL 
		ORDER BY patient_id, obs_datetime desc) led
	ON pi.patient_id = led.patient_id
/*Joins last reported date of cohort exit or date of death (which ever is reported last)*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			CASE 
				WHEN date_of_exit_from_cohort IS NOT NULL AND date_of_death IS NULL THEN date_of_exit_from_cohort
				WHEN date_of_exit_from_cohort IS NULL AND date_of_death IS NOT NULL THEN date_of_death 
				WHEN date_of_exit_from_cohort < date_of_death THEN date_of_exit_from_cohort 
				ELSE date_of_death 
			END AS "cohort_exit_date",
			CASE 
				WHEN date_of_death IS NOT NULL THEN TRUE
				ELSE NULL 
			END AS "deceased"
		FROM entrance_and_exit
		WHERE date_of_exit_from_cohort IS NOT NULL OR date_of_death IS NOT null
		ORDER BY patient_id, obs_datetime desc) led2
	ON pi.patient_id = led2.patient_id
/*Joins last reported exit status (not tied to last reported exit/death date if reported at different times)*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			exit_outcome_of_patient 
		FROM entrance_and_exit
		WHERE exit_outcome_of_patient IS NOT null
		ORDER BY patient_id, obs_datetime desc) es
	ON pi.patient_id = es.patient_id
/*Joins last reported primary diagnosis*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			diagnosis
		FROM patient_diagnosis
		WHERE diagnosis IS NOT NULL 
		ORDER BY patient_id, obs_datetime) pd
	ON pi.patient_id = pd.patient_id
/*Joins last reported primary diagnois and co-morbidities from pivoted table created in the WITH clause*/
LEFT OUTER JOIN cte_all_morbidities cam
	ON pi.patient_id = cam.patient_id
/*Joins last appointment that took place (date, service, status). Excludes appointments scheduled in the future*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now()
		ORDER BY patient_id, appointment_start_time DESC) lpa
	ON pi.patient_id = lpa.patient_id
/*REMOVE? Joins last appointment that was not marked as completed or checkedIn. Excludes appointments scheduled in the future*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND appointment_status <> 'CheckedIn' AND appointment_status <> 'Completed'
		ORDER BY patient_id, appointment_start_time DESC) lmpa
	ON pi.patient_id = lmpa.patient_id
/*Joins last appointment status from last appointment more than 3 months prior to current date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default PAD
		WHERE appointment_start_time < date_trunc('day', now())- INTERVAL '3 month'
		ORDER BY patient_id, appointment_start_time DESC) lamt3
	ON pi.patient_id = lamt3.patient_id
/*Joins last appointment status from last appointment within the last 3 months from current date that was marked as completed/checkedIn*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND appointment_start_time >= date_trunc('day', now())- INTERVAL '3 month' AND (appointment_status = 'Completed' OR appointment_status = 'CheckedIn')
		ORDER BY patient_id, appointment_start_time DESC) laalt3
	ON pi.patient_id = laalt3.patient_id
/*Joins last recorded complete blood pressure for all patients*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			date_recorded,
			systolic_blood_pressure,
			diastolic_blood_pressure
		FROM patient_vitals
		WHERE systolic_blood_pressure IS NOT NULL AND diastolic_blood_pressure IS NOT NULL 
		ORDER BY patient_id, obs_datetime desc) lpv
	ON pi.patient_id = lpv.patient_id
/*Joins last checkedIn/completed medical appointment*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND 
			(appointment_status = 'CheckedIn' OR appointment_status = 'Completed') AND 
			(appointment_service = 'Medical consultation follow-up' OR appointment_service = 'Medical initial consultation')
		ORDER BY patient_id, appointment_start_time DESC) lma
	ON pi.patient_id = lma.patient_id
/*Joins last recorded hbA1c lab*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_sample_collected_for_hba1c,
			hba1c
		FROM lab_tests lt 
		WHERE hba1c IS NOT NULL
		ORDER BY patient_id, obs_datetime desc) lhba1c
	ON pi.patient_id = lhba1c.patient_id
/*Joins last recorded fasting blood sugar lab*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_sample_collected_for_fasting_blood_sugar_fbs,
			fasting_blood_sugar_fbs 
		FROM lab_tests lt 
		WHERE hba1c IS NOT NULL OR fasting_blood_sugar_fbs IS NOT NULL
		ORDER BY patient_id, obs_datetime desc) lfbs
	ON pi.patient_id = lfbs.patient_id
/*REMOVE??? Joins last recorded hbA1c or fasting blood sugar lab. Only one per patient*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_sample_collected_for_hba1c,
			hba1c,
			date_of_sample_collected_for_fasting_blood_sugar_fbs,
			fasting_blood_sugar_fbs 
		FROM lab_tests lt 
		WHERE hba1c IS NOT NULL OR fasting_blood_sugar_fbs IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) ldc
	ON pi.patient_id = ldc.patient_id
/*Joins last recorded DAA initiation date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_daa_initiation 
		FROM hepatitis_c hc 
		WHERE date_of_daa_initiation IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) daai
	ON pi.patient_id = daai.patient_id
/*Joins last recorded DAA termination date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_daa_termination 
		FROM hepatitis_c hc 
		WHERE date_of_daa_termination IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) daat
	ON pi.patient_id = daat.patient_id
/*Joins last viral load reported and calculated out based on format*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_sample_collected_for_hcv_viral_load,
			hcv_viral_load,
			hcv_viral_load ~ '\*.*([0-9]{3})' as "VL result numeral format" ,
  			hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' as "VL result exponential format" ,
  			CASE
			  	WHEN NOT hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' AND hc.hcv_viral_load ~ '\*.*([0-9]{3})' THEN
			  		split_part(hc.hcv_viral_load, '*', 1)::numeric * 10 ^ right(hc.hcv_viral_load,1)::integer
			  	WHEN NOT hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' AND hc.hcv_viral_load ~ '([0-9]{3,5})' THEN
			  		hc.hcv_viral_load::integer
			  	WHEN hcv_viral_load = '0' THEN 0
			END AS "hcv_viral_load_calc"
		FROM hepatitis_c hc 
		WHERE hcv_viral_load IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) hcr
	ON pi.patient_id = hcr.patient_id