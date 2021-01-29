SELECT
	patient_id ,
	visit_id ,
	hba1c ,
	fasting_blood_sugar_fbs
FROM
	lab_tests
WHERE
	hba1c > 8
 	OR
 	fasting_blood_sugar_fbs < 150
 	
