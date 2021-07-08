SELECT
	pdd.person_id AS patient_id,
	pdd.gender,
	EXTRACT(YEAR FROM (SELECT age( pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy')))) AS age_at_appointment,
	age_group(pap.appointment_start_time, TO_DATE(CONCAT('01-01-', pdd.birthyear), 'dd-MM-yyyy')) As age_group_at_appointment,
	pa."Status_of_Patient",
	lpd.diagnosis AS "primary_diagnosis_last",
	pap.appointment_id,
	pap.appointment_provider,
	pap.appointment_start_time,
	pap.appointment_end_time,
	pap.appointment_service,
	pap.appointment_service_duration,
	pap.appointment_status,
	pap.appointment_location,
	pap.appointment_kind
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
		WHERE diagnosis IS NOT NULL) lpd
		ON lpd.patient_id = pap.patient_id