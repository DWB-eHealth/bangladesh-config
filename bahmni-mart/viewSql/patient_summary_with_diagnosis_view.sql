
select
	distinct diagnosis_list_view.diagnosis ,
	patient_id ,
	gender ,
	age ,
	age_group ,
	visit_id ,
	location_name ,
	visit_start_date ,
	visit_end_date
	from (
    select
    diagnosis as diagnosis ,
    pd.patient_id ,
	pdd.gender ,
	pdd.age ,
	pdd.age_group ,
	pvdd.visit_id ,
	pvdd.location_name ,
	pvdd.visit_start_date ,
	pvdd.visit_end_date
    from patient_diagnosis pd
	left outer join person_details_default pdd
		on pdd.person_id = pd.patient_id
	left outer join patient_visit_details_default pvdd
	  on pvdd.patient_id = pd.patient_id
	  and pvdd.visit_id = (
	    	select MAX(visit_id)
	    	from patient_visit_details_default pvdd2
	    	where pvdd2.patient_id = pd.patient_id and pvdd2.visit_id is not null
	    )
	  and pvdd.visit_start_date = (
	    	select MAX(visit_start_date)
	    	from patient_visit_details_default pvdd3
	    	where pvdd3.patient_id = pd.patient_id and pvdd3.visit_start_date is not null
	    )
    union
    select
    co_morbid_conditions as diagnosis ,
    cmc.patient_id ,
	pdd.gender ,
	pdd.age ,
	pdd.age_group ,
	pvdd.visit_id ,
	pvdd.location_name ,
	pvdd.visit_start_date ,
	pvdd.visit_end_date
    from co_morbid_conditions cmc
	left outer join person_details_default pdd
		on pdd.person_id = cmc.patient_id
	left outer join patient_visit_details_default pvdd
	  on pvdd.patient_id = cmc.patient_id
	  and pvdd.visit_id = (
	    	select MAX(visit_id)
	    	from patient_visit_details_default pvdd2
	    	where pvdd2.patient_id = cmc.patient_id and pvdd2.visit_id is not null
	    )
	  and pvdd.visit_start_date = (
	    	select MAX(visit_start_date)
	    	from patient_visit_details_default pvdd3
	    	where pvdd3.patient_id = cmc.patient_id and pvdd3.visit_start_date is not null
	    )
	) diagnosis_list_view
