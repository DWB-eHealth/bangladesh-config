SELECT
	patient_id ,
	appointment_service ,
	count(distinct appointment_id) as "Number of drug refill"
FROM
	patient_appointment_default pad
WHERE
	appointment_service = 'Hep C drug refill' and appointment_status = 'CheckedIn'
	or
	appointment_service = 'Hep C drug refill' and appointment_status = 'Completed'
GROUP BY
	patient_id ,
	appointment_service
