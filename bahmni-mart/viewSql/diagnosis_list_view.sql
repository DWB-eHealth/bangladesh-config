
select
	distinct diagnosis_list_view.diagnosis ,
	patient_id ,
	location_name
	from (
    select
    diagnosis as diagnosis ,
    pd.patient_id ,
    pvdd.visit_id ,
    pvdd.location_name
    from patient_diagnosis pd
    left outer join patient_visit_details_default pvdd
    	on pvdd.patient_id = pd.patient_id
    union
    select
    co_morbid_conditions as diagnosis ,
    cmc.patient_id ,
    pvdd.visit_id ,
    pvdd.location_name
    from co_morbid_conditions cmc
    left outer join patient_visit_details_default pvdd
    	on pvdd.patient_id = cmc.patient_id
	) diagnosis_list_view
