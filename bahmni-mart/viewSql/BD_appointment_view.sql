SELECT
	DISTINCT ON (pap.appointment_id) pap.appointment_id::text AS "01_appointment_id",	
	pap.appointment_service AS "02_appointment_service",
	pap.appointment_service_duration AS "03_appointment_service_duration",
	pap.appointment_location AS "04_appointment_location",
	pap.appointment_provider AS "05_appointment_provider",
	pap.appointment_kind AS "06_appointment_kind",
	pap.appointment_start_time AS "07_appointment_start_time",
	pap.appointment_end_time AS "08_appointment_end_time",
	pap.appointment_status AS "09_appointment_status",
	pid."Patient_Identifier" AS "10_emr_id",
	pdd.person_id::text AS "11_patient_id",
	EXTRACT(YEAR FROM (SELECT age( pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy'))))::int AS "12_age_at_appointment",
	age_group(pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy')) As "13_age_group_at_appointment",
	pdd.gender AS "14_sex",
	pa."Status_of_Patient" AS "15_status_of_patient",
	lpd.diagnosis AS "16_primary_diagnosis"
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
ORDER BY pap.appointment_id
