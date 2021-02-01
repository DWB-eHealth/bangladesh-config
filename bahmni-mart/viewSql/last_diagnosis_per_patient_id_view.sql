select
     pi.patient_id ,
     pd2.visit_id as "last_visit_id",
     pd2.diagnosis as "last_primary_diagnosis",
     pd2.diagnosis_date as "last_diagnosis_date"
 from
     patient_identifier pi
 left outer join
     patient_diagnosis pd2
       on pd2.patient_id = pi.patient_id
       and pd2.visit_id = (
         select MAX(visit_id)
         from patient_diagnosis pd3
         where
           pd3.patient_id = pi.patient_id
           and pd3.visit_id is not null
     )
     and pd2.diagnosis_date = (
         select MAX(diagnosis_date)
         from patient_diagnosis pd4
         where
           pd4.patient_id = pi.patient_id
           and pd4.diagnosis_date is not null
     )
 where
     pd2.visit_id is not null
     and pd2.diagnosis_date is not null
     and pd2.diagnosis is not null
 group by
     pi.patient_id ,
     pd2.visit_id ,
     pd2.diagnosis ,
     pd2.diagnosis_date
