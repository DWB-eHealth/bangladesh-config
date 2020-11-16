/* Show specific tables from the list of tables in Metabase UI
visibility_type='technical' will hide a table from the UI
active=false will hide a table from then query builder ("New Question") - not from the database
*/
UPDATE public.metabase_table
SET active=true, visibility_type=null
WHERE display_name IN (
  'Patient Identifier',
  'Person Attributes',
  'Person Details Default',
  'Person Address Default',
  'Patient Details View',
  'Patient Information View',
  'Patient Diagnosis',
  'Co Morbid Conditions',
  'Patient Vitals',
  'Patient Data',
  'Point Of Care Tests',
  'Lab Tests',
  'Hepatitis C',
  'Other Tests',
  'Entrance And Exit',
  'Patient Visit Details Default',
  'Patient Visits Encounters View',
  'Patient Appointment Default',
  'Patient Appointment View'
);

/* Hide specific tables from the list of tables in Metabase UI
visibility_type='technical' will hide a table from the UI
active=false will hide a table from then query builder ("New Question") - not from the database
*/
UPDATE public.metabase_table
SET active=true, visibility_type='technical'
WHERE display_name IN (

  'Program Work Flow States Default',
  'Location Default',
  'Patient Program State View',
  'Surgical Appointment Attributes',
  'Location Tag Map Default',
  'Surgical Appointment Default',
  'Current Bed Details Default',
  'Disposition Set',
  'Database Changelog',
  'Patient Encounter Details Default',
  'Patient Program Data Default',
  'Database Changelog Lock',
  'Patient Allergy Status Default',
  'Address Hierarchy Level Default',
  'Conditions Default',
  'Provider Attributes',
  'Markers',
  'Batch Job Execution',
  'Patient Program View',
  'Programs Default',
  'Program Attributes',
  'Provider Default',
  'Medication Data Default',
  'Person Attribute Info Default',
  'Visit Attributes',
  'Bed Management View',
  'Bed Tags Default',
  'Batch Step Execution Context',
  'Task Execution Params',
  'Program Outcomes Default',
  'Task Execution',
  'Appointment Service Default',
  'Task Task Batch',
  'Patient Bed View',
  'Location Attribute Details Default',
  'Patient Bed Tags History View',
  'Meta Data Dictionary',
  'Bed Patient Assignment Default',
  'Bed Management Locations View',
  'Patient Operation Theater View',
  'Bacteriology Concept Set',
  'Surgical Block Default',
  'Appointment Admin Panel View',
  'Patient State Default',
  'Batch Job Instance',
  'Program Work Flow Default',
  'Visit Attribute Details Default',
  'Batch Job Execution Params',
  'Visit Diagnoses',
  'Surgical Appointment Attribute Type Details Default',
  'Service Availability Default',
  'Appointment Speciality Default',
  'Batch Step Execution',
  'Batch Job Execution Context',
  'Provider Attribute Details Default'
);
