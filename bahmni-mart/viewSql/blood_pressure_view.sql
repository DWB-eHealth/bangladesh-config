SELECT
	patient_id ,
	visit_id ,
	diastolic_blood_pressure ,
	systolic_blood_pressure
FROM
	patient_vitals
WHERE
	diastolic_blood_pressure BETWEEN 90 AND 140
 	OR
 	systolic_blood_pressure BETWEEN 90 AND 140
