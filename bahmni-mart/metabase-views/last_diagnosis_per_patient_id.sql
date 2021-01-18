create view last_diagnosis_per_patient_id as
  select
       pdv.patient_id ,
       pd2.diagnosis
   from
       patient_details_view pdv
   left outer join
       person_details_default pdd
           on pdd.person_id = pdv.person_id
   left outer join
       patient_diagnosis pd2
           on pd2.patient_id = pdv.patient_id
           and pd2.visit_id = (
               select
                   MAX(visit_id)
           from
               patient_diagnosis pd3
           where
               pd3.patient_id = pdv.patient_id
               and pd3.visit_id is not null
       )
       and pd2.diagnosis_date = (
           select
               MAX(diagnosis_date)
           from
               patient_diagnosis pd4
           where
               pd4.patient_id = pdv.patient_id
               and pd4.diagnosis_date is not null
       )
   where
       pd2.visit_id is not null
       and pd2.diagnosis_date is not null
   group by
       pdv.patient_id ,
       pd2.diagnosis 
