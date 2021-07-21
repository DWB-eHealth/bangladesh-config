SELECT
	DISTINCT ON (pap.appointment_id) pap.appointment_id::text AS "01_appointment_id",	
	pap.appointment_service AS "02_appointment_service",
	pap.appointment_service_duration AS "03_appointment_service_duration",
	CASE 
		WHEN pap.appointment_location IS NOT NULL THEN pap.appointment_location
		ELSE 'not recorded'
	END AS "04_appointment_location",
	pap.appointment_provider AS "05_appointment_provider",
	pap.appointment_kind AS "06_appointment_kind",
	pap.appointment_start_time AS "07_appointment_start_time",
	pap.appointment_end_time AS "08_appointment_end_time",
	pap.appointment_status AS "09_appointment_status",
	pid."Patient_Identifier" AS "10_patient_identifier",
	pdd.person_id::text AS "11_patient_id",
	EXTRACT(YEAR FROM (SELECT age( pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy'))))::int AS "12_age_at_appointment",
	age_group(pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy')) As "13_age_group_at_appointment",
	pdd.gender AS "14_sex",
	pa."Status_of_Patient" AS "15_status_of_patient",
	CASE 
		WHEN lpd.diagnosis IS NOT NULL THEN lpd.diagnosis
		ELSE 'Not Recorded'
	END AS "16_primary_diagnosis",
	CASE
		WHEN led.date_of_entry_into_cohort IS NOT NULL AND led2.cohort_exit_date IS NULL AND es.exit_outcome_of_patient IS NULL THEN 'Yes'
		ELSE NULL 
	END AS "17_current_cohort"
FROM patient_appointment_default pap 
LEFT JOIN person_attributes pa 
	ON pa.person_id = pap.patient_id
LEFT JOIN person_details_default pdd 
	ON pdd.person_id = pap.patient_id
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			diagnosis
		FROM patient_diagnosis
		WHERE diagnosis IS NOT NULL
		ORDER BY patient_id, obs_datetime desc) lpd
	ON lpd.patient_id = pap.patient_id
LEFT OUTER JOIN patient_identifier pid
	ON pid.patient_id = pap.patient_id
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id, 
			date_of_entry_into_cohort 
		FROM entrance_and_exit
		WHERE date_of_entry_into_cohort IS NOT NULL 
		ORDER BY patient_id, obs_datetime desc) led
	ON led.patient_id = pap.patient_id
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
	ON led2.patient_id = pap.patient_id
LEFT OUTER JOIN (
		SELECT
			DISTINCT ON (patient_id) patient_id,
			exit_outcome_of_patient 
		FROM entrance_and_exit
		WHERE exit_outcome_of_patient IS NOT null
		ORDER BY patient_id, obs_datetime desc) es
	ON es.patient_id = pap.patient_id
ORDER BY pap.appointment_id
