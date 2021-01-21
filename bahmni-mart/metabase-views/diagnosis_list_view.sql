create view diagnosis_list_view as
select
	distinct diagnosis_list_view.diagnosis
	from (
    select
      diagnosis as diagnosis ,
      patient_id
    from patient_diagnosis
    union
    select
      co_morbid_conditions as diagnosis ,
      patient_id
    from co_morbid_conditions
	) diagnosis_list_view
