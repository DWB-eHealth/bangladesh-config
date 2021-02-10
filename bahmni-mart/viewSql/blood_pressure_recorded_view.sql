select
	patient_id ,
	visit_id ,
	diastolic_blood_pressure ,
	systolic_blood_pressure
from
	patient_vitals
where
	diastolic_blood_pressure is not null
 	or
 	systolic_blood_pressure is not null
