/*Creates a table with pivoted primary and co-morbidity date*/
WITH cte_all_morbidities AS (
	SELECT
		am.patient_id,
		MAX (CASE WHEN am.diagnosis = 'Asthma' THEN '1' ELSE NULL END)::int AS "Asthma",
		MAX (CASE WHEN am.diagnosis = 'Cardiovascular disease' THEN '1' ELSE NULL END)::int AS "Cardiovascular disease",
		MAX (CASE WHEN am.diagnosis = 'Chronic kidney insufficiency' THEN '1' ELSE NULL END)::int AS "Chronic kidney insufficiency",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage I' THEN '1' ELSE NULL END)::int AS "Chronic Kidney Disease, Stage I",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage II (Mild)' THEN '1' ELSE NULL END)::int AS "Chronic Kidney Disease, Stage II (Mild)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage III (Moderate)' THEN '1' ELSE NULL END)::int AS "Chronic Kidney Disease, Stage III (Moderate)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage IV (Severe)' THEN '1' ELSE NULL END)::int AS "Chronic Kidney Disease, Stage IV (Severe)",
		MAX (CASE WHEN am.diagnosis = 'Chronic Kidney Disease, Stage V' THEN '1' ELSE NULL END)::int AS "Chronic Kidney Disease, Stage V",
		MAX (CASE WHEN am.diagnosis = 'Chronic obstructive pulmonary disease (COPD)' THEN '1' ELSE NULL END)::int AS "Chronic obstructive pulmonary disease (COPD)",
		MAX (CASE WHEN am.diagnosis = 'Epilepsy' THEN '1' ELSE NULL END)::int AS "Epilepsy",
		MAX (CASE WHEN am.diagnosis = 'Chronic Hepatitis C' THEN '1' ELSE NULL END)::int AS "Chronic Hepatitis C",
		MAX (CASE WHEN am.diagnosis = 'Hypertension' THEN '1' ELSE NULL END)::int AS "Hypertension",
		MAX (CASE WHEN am.diagnosis = 'Stroke' THEN '1' ELSE NULL END)::int AS "Stroke",
		MAX (CASE WHEN am.diagnosis = 'Thyroid disease' THEN '1' ELSE NULL END)::int AS "Thyroid disease",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 1' THEN '1' ELSE NULL END)::int AS "Diabetes mellitus, type 1",
		MAX (CASE WHEN am.diagnosis = 'Diabetes mellitus, type 2' THEN '1' ELSE NULL END)::int AS "Diabetes mellitus, type 2",
		MAX (CASE WHEN am.diagnosis = 'Cirrhosis and Chronic Liver Disease' THEN '1' ELSE NULL END)::int AS "Cirrhosis and Chronic Liver Disease",
		MAX (CASE WHEN am.diagnosis = 'Other pathology' THEN '1' ELSE NULL END)::int AS "Other pathology"
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
	pid."Patient_Identifier" AS "01_patient_identifier",
	pid.patient_id::text AS "02_patient_id",
	pdd.age::int AS "03_current_age",
	pdd.age_group AS "04_current_age_group",
	pdd.gender AS "05_sex", 
	pa."Status_of_Patient" AS "06_status_of_patient",
	lv.location_name AS "07_last_visit_location",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NULL THEN 'Yes'
		ELSE NULL 
	END AS "08_current_cohort",
	led.date_of_entry_into_cohort::date AS "09_cohort_entry_date",
	led2.cohort_exit_date::date AS "10_cohort_exit_date",
	CASE 
		WHEN es.exit_outcome_of_patient IS NOT NULL THEN es.exit_outcome_of_patient 
		WHEN es.exit_outcome_of_patient IS NULL AND led2.deceased IS NOT NULL THEN 'Deceased'
		ELSE NULL 
	END AS "11_cohort_exit_status",
	ROUND((CASE 
		WHEN led2.cohort_exit_date IS NOT NULL THEN (DATE_PART('day',(led2.cohort_exit_date::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
		WHEN led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NOT NULL THEN NULL
		ELSE (DATE_PART('day',(now()::timestamp)-(led.date_of_entry_into_cohort::timestamp)))/365*12
	END)::NUMERIC,1) AS "12_length_of_follow_(months)",
	lpa.appointment_start_time::date AS "13_last_appointment_date",
	lpa.appointment_service AS "14_last_appointment_service",
	lpa.appointment_status AS "15_last_appointment_status",
	CASE
		WHEN lpa.appointment_status = 'Missed' THEN (DATE_PART('day',(now())-(lpa.appointment_start_time::timestamp)))::int
		ELSE NULL 
	END AS "16_days_since_last_missed_appointment",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND (led2.cohort_exit_date IS NULL OR led2.deceased IS NULL OR es.exit_outcome_of_patient IS NULL) AND lpa3.appointment_status IS NULL THEN 'Yes'
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND (led2.cohort_exit_date IS NULL OR led2.deceased IS NULL OR es.exit_outcome_of_patient IS NULL) AND lpa3.appointment_status IS NOT NULL THEN 'No'
		ELSE NULL
	END AS "17_inactive",
		CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND (led2.cohort_exit_date IS NULL OR led2.deceased IS NULL OR es.exit_outcome_of_patient IS NULL) AND lpa12.appointment_status IS NULL THEN 'Yes'
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND (led2.cohort_exit_date IS NULL OR led2.deceased IS NULL OR es.exit_outcome_of_patient IS NULL) AND lpa12.appointment_status IS NOT NULL THEN 'No'
		ELSE NULL
	END AS "18_possible_ltfu",
	lpd.diagnosis AS "19_primary_diagnosis",
	cam."Asthma" AS "20_asthma",
	cam."Cardiovascular disease" AS "21_cardiovascular_disease",
	cam."Chronic kidney insufficiency" AS "22_chronic_kidney_insufficiency",
	cam."Chronic Kidney Disease, Stage I" AS "23_chronic_kidney_disease_stage_1",
	cam."Chronic Kidney Disease, Stage II (Mild)" AS "24_chronic_kidney_disease_stage_2",
	cam."Chronic Kidney Disease, Stage III (Moderate)" AS "25_chronic_kidney_disease_stage_3",
	cam."Chronic Kidney Disease, Stage IV (Severe)" AS "26_chronic_kidney_disease_stage_4",
	cam."Chronic Kidney Disease, Stage V" AS "27_chronic_kidney_disease_stage_5",
	cam."Chronic obstructive pulmonary disease (COPD)" AS "28_copd",
	cam."Epilepsy" AS "29_epilepsy",
	cam."Chronic Hepatitis C" AS "30_chronic_hepatitis_c",
	cam."Hypertension" AS "31_hypertension",
	cam."Stroke" AS "32_stroke",
	cam."Thyroid disease" AS "33_thyroid_disease",
	cam."Diabetes mellitus, type 1" AS "34_diabetes_type_1",
	cam."Diabetes mellitus, type 2" AS "35_diabetes_type_2",
	CASE 
		WHEN cam."Diabetes mellitus, type 1" IS NOT NULL THEN '1'
		WHEN cam."Diabetes mellitus, type 2" IS NOT NULL THEN '1' 
		ELSE NULL 
	END AS "36_diabetes_any_type",
	cam."Cirrhosis and Chronic Liver Disease" AS "37_cirrhosis_chronic_liver_disease",
	cam."Other pathology" AS "38_other_pathology",
	lpv.date_recorded::date AS "39_last_bp_date",
	CASE
		WHEN lpv.systolic_blood_pressure IS NOT NULL THEN concat(lpv.systolic_blood_pressure,'/',lpv.diastolic_blood_pressure) 
		ELSE NULL 
	END AS "40_last_bp",
	CASE
		WHEN lma.appointment_start_time::date = lpv.date_recorded THEN 'Yes'
		WHEN lma.appointment_start_time::date <> lpv.date_recorded THEN 'No'
		ELSE 'No'
	END AS "41_bp_checked_at_last_appointment",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND lpv.systolic_blood_pressure <= 140 OR lpv.diastolic_blood_pressure <= 90 THEN 'Yes'
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lpv.systolic_blood_pressure > 140 OR lpv.diastolic_blood_pressure > 90) THEN 'No'
		ELSE NULL 
	END AS "42_bp_controlled",
	lhba1c.date_of_sample_collected_for_hba1c::date AS "43_last_hba1c_date",
	lhba1c.hba1c AS "44_last_hba1c",
	CASE 
		WHEN lhba1c.hba1c <= 6.5 THEN '<=6.5%'
		WHEN lhba1c.hba1c > 6.5 AND lhba1c.hba1c <= 8 THEN '6.6-8.0%'
		WHEN lhba1c.hba1c > 8 THEN '>=8.1%'
		ELSE NULL 
	END AS "45_last_hba1c_categories",
	CASE
		WHEN lhba1c.date_of_sample_collected_for_hba1c >= date_trunc('day', now())- INTERVAL '12 month' THEN 'Yes'
		WHEN lhba1c.date_of_sample_collected_for_hba1c < date_trunc('day', now())- INTERVAL '12 month' THEN 'No'
		ELSE 'No'
	END AS "46_hba1c_checked_in_last_12_months",
	lfbs.date_of_sample_collected_for_fasting_blood_sugar_fbs::date AS "47_last_fbs_date",
	lfbs.fasting_blood_sugar_fbs AS "48_last_fbs",
	CASE 
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lhba1c.hba1c < 8 OR lfbs.fasting_blood_sugar_fbs < 150) THEN 'Yes'
		WHEN led.date_of_entry_into_cohort <= date_trunc('day', now())- INTERVAL '6 month' AND (lhba1c.hba1c >= 8 OR lfbs.fasting_blood_sugar_fbs >= 150) THEN 'No'
		ELSE NULL
	END AS "49_diabetes_controlled", 
	daai.date_of_daa_initiation::date AS "50_daa_initiation_date", 
	daat.date_of_daa_termination::date AS "51_daa_termination_date",
	CASE 
		WHEN svr.numeric_vl < 1000 THEN 'Yes' 
		WHEN svr.numeric_vl >= 1000 THEN 'No' 
		WHEN svr.numeric_vl IS NULL AND daat.date_of_daa_termination < date_trunc('day', now())- INTERVAL '12 week' THEN 'No VL Result'
		ELSE NULL 
	END AS "52_svr12"
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
/*Joins last appointment status from last appointment within the last 3 months from current date that was marked as completed/checkedIn*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND appointment_start_time >= date_trunc('day', now())- INTERVAL '3 month' AND (appointment_status = 'Completed' OR appointment_status = 'CheckedIn')
		ORDER BY patient_id, appointment_start_time DESC) lpa3
	ON pid.patient_id = lpa3.patient_id
/*Joins last appointment status from last appointment within the last 12 months from current date that was marked as completed/checkedIn*/
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			appointment_start_time,
			appointment_status,
			appointment_service 
		FROM patient_appointment_default
		WHERE appointment_start_time < now() AND appointment_start_time >= date_trunc('day', now())- INTERVAL '12 month' AND (appointment_status = 'Completed' OR appointment_status = 'CheckedIn')
		ORDER BY patient_id, appointment_start_time DESC) lpa12
	ON pid.patient_id = lpa12.patient_id
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
		WHERE hba1c IS NOT NULL OR fasting_blood_sugar_fbs IS NOT NULL
		ORDER BY patient_id, obs_datetime desc) lfbs
	ON pid.patient_id = lfbs.patient_id
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
