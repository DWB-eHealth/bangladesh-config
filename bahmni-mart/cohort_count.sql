select 
count(o.value_datetime) as 'Number of patients with an entry date during their first visit' ,
count(o2.value_datetime) as 'Number of patients with an exit date during their last visit' ,
count(o.value_datetime) - count(o2.value_datetime) as 'Number of active patients in cohort (no exit date)'
from patient p

join visit v
on v.patient_id = p.patient_id 
and v.visit_id = (
       select MIN(visit_id)
       from visit v2
       where v2.patient_id = p.patient_id and v2.visit_id is not null
     )
     
join visit v3
on v3.patient_id = p.patient_id 
and v3.visit_id = (
       select MAX(visit_id)
       from visit v4
       where v4.patient_id = p.patient_id and v4.visit_id is not null
     )
     
left outer join encounter e
on e.visit_id = v.visit_id 

left outer join encounter e2
on e2.visit_id = v3.visit_id 

join obs o
on o.encounter_id = e.encounter_id 
and o.concept_id = 220 

left outer join obs o2
on o2.encounter_id = e2.encounter_id 
and o2.concept_id = 221