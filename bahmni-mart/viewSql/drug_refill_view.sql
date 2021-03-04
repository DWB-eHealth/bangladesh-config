SELECT
	patient_id ,
	appointment_service ,
	count(distinct appointment_id) as "Number of drug refill"
FROM
	patient_appointment_default pad
WHERE
	appointment_service = 'Pharmacy - Fast Track' OR
	appointment_service = 'Pharmacy - Fast Track(NCD)'
GROUP BY
	patient_id ,
	appointment_service
