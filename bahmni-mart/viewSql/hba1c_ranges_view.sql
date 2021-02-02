SELECT
	patient_id ,
	visit_id ,
	hba1c ,
	case
  	when hba1c <=6.5 then
  	'<=6.5'
		when hba1c between 6.6 and 8.0 then
  	'6.6-8.0'
		when hba1c >=8.1 then
  	'>=8.1'
  end as "hba1c_ranges"
FROM
	lab_tests
