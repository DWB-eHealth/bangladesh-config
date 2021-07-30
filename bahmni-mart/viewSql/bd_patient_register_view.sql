/*Creates a table with pivoted primary and co-morbidity date*/
WITH cte_all_morbidities AS (
	SELECT
		am.patient_id,
		MAX (CASE WHEN am.diagnosis = 'Asthma' THEN '1' ELSE NULL END)::INT AS "asthma",
		MAX (CASE WHEN am.diagnosis = 'Cardiovascular disease' THEN '1' ELSE NULL END)::INT AS "cardiovascular_disease",
		MAX (CASE WHEN am.diagnosis = 'Chronic kidney insufficiency' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_insufficiency",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage I' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_disease_stage_1",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage II (Mild)' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_disease_stage_2",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage III (Moderate)' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_disease_stage_3",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage IV (Severe)' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_disease_stage_4",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage V' THEN '1' ELSE NULL END)::INT AS "chronic_kidney_disease_stage_5",
		MAX (CASE WHEN am.diagnosis = 'Chronic obstructive pulmonary disease (COPD)' THEN '1' ELSE NULL END)::INT AS "copd",
		MAX (CASE WHEN am.diagnosis = 'Epilepsy' THEN '1' ELSE NULL END)::INT AS "epilepsy",
		MAX (CASE WHEN am.diagnosis = 'Chronic Hepatitis C' THEN '1' ELSE NULL END)::INT AS "chronic_hepatitis_c",
		MAX (CASE WHEN am.diagnosis = 'Hypertension' THEN '1' ELSE NULL END)::INT AS "hypertension",
		MAX (CASE WHEN am.diagnosis = 'Stroke' THEN '1' ELSE NULL END)::INT AS "stroke",
		MAX (CASE WHEN am.diagnosis = 'Thyroid disease' THEN '1' ELSE NULL END)::INT AS "thyroid_disease",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 1' THEN '1' ELSE NULL END)::INT AS "diabetes_mellitus_type_1",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 2' THEN '1' ELSE NULL END)::INT AS "diabetes_mellitus_type_2",
		MAX (CASE WHEN am.diagnosis = 'Cirrhosis and Chronic Liver Disease' THEN '1' ELSE NULL END)::INT AS "cirrhosis_and_chronic_liver_disease",
		MAX (CASE WHEN am.diagnosis = 'Other pathology' THEN '1' ELSE NULL END)::INT AS "other_pathology",
		COUNT(DISTINCT am.diagnosis) AS "count_diagnosis"
	FROM (SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			diagnosis,
			CONCAT('Primary Diagnosis') AS "type"
		FROM patient_diagnosis pd 
		WHERE diagnosis IS NOT NULL 
		UNION 
		SELECT
			patient_id,
			MAX(obs_datetime),
			co_morbid_conditions AS diagnosis,
			CONCAT('Co-Morbidity') AS "type"
		FROM co_morbid_conditions
		GROUP BY obs_datetime, patient_id, co_morbid_conditions
		ORDER BY patient_id, obs_datetime DESC) am
	GROUP BY patient_id)
SELECT
	pid."Patient_Identifier" AS "01_patient_identifier",
	pid.patient_id::TEXT AS "02_patient_id",
	pdd.age::INT AS "03_current_age",
	pdd.age_group AS "04_current_age_group",
	pdd.gender AS "05_sex", 
	pa."Status_of_Patient" AS "06_status_of_patient",
	lv.location_name AS "07_last_visit_location",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NULL THEN 'Yes'
		ELSE NULL 
	END AS "08_current_cohort",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NULL AND 
			(lpa.patient_id IS NULL OR
			led.date_of_entry_into_cohort >= (date_trunc('day', now()) - INTERVAL '90 day') OR
			lpa.appointment_service = 'CheckedIn' OR lpa.appointment_service = 'Completed' OR
			(aa.appointment_start_time >= (date_trunc('day', lpa.appointment_start_time)- INTERVAL '90 day'))) THEN 'Yes'
		ELSE NULL
	END AS "09_active",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NULL AND 
			led.date_of_entry_into_cohort < (date_trunc('day', now()) - INTERVAL '90 day') AND 
			(lpa.appointment_service <> 'CheckedIn' OR lpa.appointment_service <> 'Completed') AND
			(aa.appointment_status IS NULL OR aa.appointment_start_time < (date_trunc('day', lpa.appointment_start_time)- INTERVAL '90 day')) THEN 'Yes'
		ELSE NULL
	END AS "10_inactive",
	led.date_of_entry_into_cohort::date AS "11_cohort_entry_date",
	led2.cohort_exit_date::date AS "12_cohort_exit_date",
	CASE 
		WHEN es.exit_outcome_of_patient IS NOT NULL THEN es.exit_outcome_of_patient 
		WHEN es.exit_outcome_of_patient IS NULL AND led2.deceased IS NOT NULL THEN 'Deceased'
		WHEN es.exit_outcome_of_patient IS NULL AND led2.deceased IS NULL AND led2.cohort_exit_date IS NOT NULL THEN 'Not recorded'
		ELSE NULL 
	END AS "13_cohort_exit_status",
	ROUND((CASE 
		WHEN led2.cohort_exit_date IS NOT NULL THEN (DATE_PART('day',(led2.cohort_exit_date::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
		WHEN led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NOT NULL THEN NULL
		ELSE (DATE_PART('day',(now()::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
	END)::NUMERIC,1) AS "14_length_of_follow_(months)",
	lpa.appointment_start_time::date AS "15_last_appointment_date",
	lpa.appointment_service AS "16_last_appointment_service",
	lpa.appointment_status AS "17_last_appointment_status",
	CASE
		WHEN (lpa.appointment_service <> 'CheckedIn' OR lpa.appointment_service <> 'Completed') THEN (DATE_PART('day',(now())-(lpa.appointment_start_time::timestamp)))::int
		ELSE NULL 
	END AS "18_days_since_last_missed_appointment",
	lpd.diagnosis AS "19_primary_diagnosis",
	CASE WHEN cam.asthma IS NOT NULL THEN cam.asthma ELSE '0' END AS "20_asthma",
	CASE WHEN cam.cardiovascular_disease IS NOT NULL THEN cam.cardiovascular_disease ELSE '0' END AS "21_cardiovascular_disease",
	CASE WHEN cam.chronic_kidney_insufficiency IS NOT NULL THEN cam.chronic_kidney_insufficiency ELSE '0' END AS "22_chronic_kidney_insufficiency",
	CASE WHEN cam.chronic_kidney_disease_stage_1 IS NOT NULL THEN cam.chronic_kidney_disease_stage_1 ELSE '0' END AS "23_chronic_kidney_disease_stage_1",
	CASE WHEN cam.chronic_kidney_disease_stage_2 IS NOT NULL THEN cam.chronic_kidney_disease_stage_2 ELSE '0' END AS "24_chronic_kidney_disease_stage_2",
	CASE WHEN cam.chronic_kidney_disease_stage_3 IS NOT NULL THEN cam.chronic_kidney_disease_stage_3 ELSE '0' END AS "25_chronic_kidney_disease_stage_3",
	CASE WHEN cam.chronic_kidney_disease_stage_4 IS NOT NULL THEN cam.chronic_kidney_disease_stage_4 ELSE '0' END AS "26_chronic_kidney_disease_stage_4",
	CASE WHEN cam.chronic_kidney_disease_stage_5 IS NOT NULL THEN cam.chronic_kidney_disease_stage_5 ELSE '0' END AS "27_chronic_kidney_disease_stage_5",
	CASE 
		WHEN cam.chronic_kidney_insufficiency IS NOT NULL THEN '1'
		WHEN cam.chronic_kidney_disease_stage_1 IS NOT NULL THEN '1'
		WHEN cam.chronic_kidney_disease_stage_2 IS NOT NULL THEN '1'
		WHEN cam.chronic_kidney_disease_stage_3 IS NOT NULL THEN '1'
		WHEN cam.chronic_kidney_disease_stage_4 IS NOT NULL THEN '1'
		WHEN cam.chronic_kidney_disease_stage_5 is NOT NULL THEN '1'
		ELSE '0' 
	END AS "28_chronic_kidney_disease_any_stage",
	CASE WHEN cam.copd IS NOT NULL THEN cam.copd ELSE '0' END AS "29_copd",
	CASE WHEN cam.epilepsy IS NOT NULL THEN cam.epilepsy ELSE '0' END AS "30_epilepsy",
	CASE WHEN cam.chronic_hepatitis_c IS NOT NULL THEN cam.chronic_hepatitis_c ELSE '0' END AS "31_chronic_hepatitis_c",
	CASE WHEN cam.hypertension IS NOT NULL THEN cam.hypertension ELSE '0' END AS "32_hypertension",
	CASE WHEN cam.stroke IS NOT NULL THEN cam.stroke ELSE '0' END AS "33_stroke",
	CASE WHEN cam.thyroid_disease IS NOT NULL THEN cam.thyroid_disease ELSE '0' END AS "34_thyroid_disease",
	CASE WHEN cam.diabetes_mellitus_type_1 IS NOT NULL THEN cam.diabetes_mellitus_type_1 ELSE '0' END AS "35_diabetes_type_1",
	CASE WHEN cam.diabetes_mellitus_type_2 IS NOT NULL THEN cam.diabetes_mellitus_type_2 ELSE '0' END AS "36_diabetes_type_2",
	CASE 
		WHEN cam.diabetes_mellitus_type_1 IS NOT NULL THEN '1'
		WHEN cam.diabetes_mellitus_type_2 IS NOT NULL THEN '1' 
		ELSE '0' 
	END AS "37_diabetes_any_type",
	CASE WHEN cam.cirrhosis_and_chronic_liver_disease IS NOT NULL THEN cam.cirrhosis_and_chronic_liver_disease ELSE '0' END AS "38_cirrhosis_chronic_liver_disease",
	CASE WHEN cam.other_pathology IS NOT NULL THEN cam.other_pathology ELSE '0' END AS "39_other_pathology",
	cam.count_diagnosis AS "40_count_morbidities",
	lpv.date_recorded::date AS "41_last_bp_date",
	CASE
		WHEN lpv.systolic_blood_pressure IS NOT NULL THEN concat(lpv.systolic_blood_pressure,'/',lpv.diastolic_blood_pressure) 
		ELSE NULL 
	END AS "42_last_bp",
	CASE
		WHEN lma.appointment_start_time::date = lpv.date_recorded THEN 'Yes'
		WHEN lma.appointment_start_time::date <> lpv.date_recorded THEN 'No'
		ELSE 'No'
	END AS "43_bp_checked_at_last_appointment",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND lpv.date_recorded > date_trunc('day', now())- INTERVAL '6 month' AND (lpv.systolic_blood_pressure <= 140 OR lpv.diastolic_blood_pressure <= 90) THEN 'Yes'
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND lpv.date_recorded > date_trunc('day', now())- INTERVAL '6 month' AND (lpv.systolic_blood_pressure > 140 OR lpv.diastolic_blood_pressure > 90) THEN 'No'
		ELSE NULL 
	END AS "44_bp_controlled",
	lhba1c.date_of_sample_collected_for_hba1c::date AS "45_last_hba1c_date",
	lhba1c.hba1c AS "46_last_hba1c",
	CASE 
		WHEN lhba1c.hba1c <= 6.5 THEN '<=6.5%'
		WHEN lhba1c.hba1c > 6.5 AND lhba1c.hba1c <= 8 THEN '6.6-8.0%'
		WHEN lhba1c.hba1c > 8 THEN '>=8.1%'
		ELSE NULL 
	END AS "47_last_hba1c_categories",
	CASE
		WHEN lhba1c.date_of_sample_collected_for_hba1c >= date_trunc('day', now())- INTERVAL '12 month' THEN 'Yes'
		WHEN lhba1c.date_of_sample_collected_for_hba1c < date_trunc('day', now())- INTERVAL '12 month' THEN 'No'
		ELSE 'No'
	END AS "48_hba1c_checked_in_last_12_months",
	lfbs.date_of_sample_collected_for_fasting_blood_sugar_fbs::date AS "49_last_fbs_date",
	lfbs.fasting_blood_sugar_fbs AS "50_last_fbs",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' THEN (
			CASE
				WHEN ldcc.date_of_sample_collected_for_hba1c > date_trunc('day', now())- INTERVAL '6 month' AND ldcc.hba1c IS NOT NULL THEN (
					CASE
						WHEN ldcc.hba1c < 8  THEN 'Yes'
						WHEN ldcc.hba1c >= 8  THEN 'No'
						ELSE NULL 
					END)
				ELSE (
					CASE 
						WHEN ldcc.date_of_sample_collected_for_fasting_blood_sugar_fbs > date_trunc('day', now())- INTERVAL '6 month' AND ldcc.fasting_blood_sugar_fbs IS NOT NULL THEN (
							CASE
								WHEN ldcc.fasting_blood_sugar_fbs < 150  THEN 'Yes'
								WHEN ldcc.fasting_blood_sugar_fbs >= 150  THEN 'No'
								ELSE NULL
							END)
						ELSE 'No results recorded'
					END)
			END)
		ELSE NULL
	END AS "51_diabetes_controlled", 	
	daai.date_of_daa_initiation::date AS "52_daa_initiation_date", 
	daat.date_of_daa_termination::date AS "53_daa_termination_date",
	CASE 
		WHEN svr.numeric_vl < 1000 THEN 'Yes' 
		WHEN svr.numeric_vl >= 1000 THEN 'No' 
		WHEN svr.numeric_vl IS NULL AND daat.date_of_daa_termination < date_trunc('day', now())- INTERVAL '12 week' THEN 'No VL Result'
		ELSE NULL 
	END AS "54_svr12"
FROM patient_identifier pid
/*Joins age and gender for each patient*/
LEFT OUTER JOIN person_details_default pdd 
	ON pid.patient_id = pdd.person_id 
/*Joins status of patient for each patient*/
LEFT OUTER JOIN person_attributes pa 
	ON pid.patient_id = pa.person_id
/*Joins last visit location according to login location used for more recent data entry*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id, 
			location_name 
		FROM patient_visit_details_default 
		ORDER BY patient_id, visit_start_date DESC) lv
	ON pid.patient_id = lv.patient_id
/*Joins last reported cohort entry date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id, 
			date_of_entry_into_cohort 
		FROM entrance_and_exit
		WHERE date_of_entry_into_cohort IS NOT NULL 
		ORDER BY patient_id, obs_datetime desc) led
	ON pid.patient_id = led.patient_id
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
	ON pid.patient_id = led2.patient_id
/*Joins last reported exit status (not tied to last reported exit/death date if reported at different times)*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			exit_outcome_of_patient 
		FROM entrance_and_exit
		WHERE exit_outcome_of_patient IS NOT null
		ORDER BY patient_id, obs_datetime desc) es
	ON pid.patient_id = es.patient_id
/*Joins last reported primary diagnosis*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			diagnosis
		FROM patient_diagnosis
		WHERE diagnosis IS NOT NULL 
		ORDER BY patient_id, obs_datetime desc) lpd
	ON pid.patient_id = lpd.patient_id
/*Joins last reported primary diagnois and co-morbidities from pivoted table created in the WITH clause*/
LEFT OUTER JOIN cte_all_morbidities cam
	ON pid.patient_id = cam.patient_id
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
	ON pid.patient_id = lpa.patient_id
/*Joins list of appointments prior to current date that were marked as completed/checkedIn*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND (appointment_status = 'Completed' OR appointment_status = 'CheckedIn')
		ORDER BY patient_id, appointment_start_time DESC) aa
	ON pid.patient_id = aa.patient_id
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
	ON pid.patient_id = lpv.patient_id
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
	ON pid.patient_id = lma.patient_id
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
	ON pid.patient_id = lhba1c.patient_id
/*Joins last recorded fasting blood sugar lab*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_sample_collected_for_fasting_blood_sugar_fbs,
			fasting_blood_sugar_fbs 
		FROM lab_tests lt 
		WHERE fasting_blood_sugar_fbs IS NOT NULL
		ORDER BY patient_id, obs_datetime desc) lfbs
	ON pid.patient_id = lfbs.patient_id
/*Joins last recorded HbA1c or fasting blood sugar lab*/
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
		ORDER BY patient_id, obs_datetime desc) ldcc
	ON pid.patient_id = ldcc.patient_id
/*Joins last recorded DAA initiation date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_daa_initiation 
		FROM hepatitis_c hc 
		WHERE date_of_daa_initiation IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) daai
	ON pid.patient_id = daai.patient_id
/*Joins last recorded DAA termination date*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			obs_datetime,
			date_of_daa_termination 
		FROM hepatitis_c hc 
		WHERE date_of_daa_termination IS NOT NULL
		ORDER BY patient_id, obs_datetime DESC) daat
	ON pid.patient_id = daat.patient_id
/*Joins numeric viral loads reported 12-15 weeks after last reported DAA termination date. Only includes cases with DAA termination date, vl sample date and numeric vl result*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (nvl.patient_id) nvl.patient_id,
			daat.date_of_daa_termination,
			nvl.date_of_sample_collected_for_hcv_viral_load,
			CASE
				WHEN nvl.hcv_viral_load ~ '^\d+$' THEN nvl.hcv_viral_load::int 
				ELSE NULL
			END AS "numeric_vl"
		FROM hepatitis_c nvl
		LEFT OUTER JOIN (
			SELECT
				DISTINCT ON (patient_id) patient_id,
				obs_datetime,
				date_of_daa_termination 
			FROM hepatitis_c hc 
			WHERE date_of_daa_termination IS NOT NULL
			ORDER BY patient_id, obs_datetime DESC) daat
		ON nvl.patient_id = daat.patient_id
		WHERE nvl.hcv_viral_load ~ '^\d+$' AND 
			nvl.date_of_sample_collected_for_hcv_viral_load IS NOT NULL AND 
			daat.date_of_daa_termination IS NOT NULL AND 
			nvl.date_of_sample_collected_for_hcv_viral_load >= (date_trunc('day', daat.date_of_daa_termination)+ INTERVAL '12 week') AND 
			nvl.date_of_sample_collected_for_hcv_viral_load < (date_trunc('day', daat.date_of_daa_termination)+ INTERVAL '15 week')
		ORDER BY nvl.patient_id, nvl.obs_datetime DESC) svr
	ON pid.patient_id = svr.patient_id
