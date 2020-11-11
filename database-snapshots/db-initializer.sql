-- Create a person
set @uid = uuid();

INSERT INTO openmrs.person (gender, birthdate, birthdate_estimated, dead, death_date, cause_of_death, creator, date_created, changed_by, date_changed, voided,
voided_by, date_voided, void_reason, uuid, deathdate_estimated, birthtime) VALUES ('M', null, 0, 0, null, null, 1, now(), null, null, 0, null, null, null, @uid, 0, null);

-- Create a provider with person ID
set @pid = null;

SELECT person_id into @pid from person where uuid = @uid;

INSERT INTO openmrs.person_name (preferred, person_id, prefix, given_name, middle_name, family_name_prefix, family_name, family_name2, family_name_suffix, degree, creator, date_created, voided, voided_by, date_voided, void_reason, changed_by, date_changed, uuid) VALUES (1, @pid, null, 'admin', '', null, '', null, null, null, 1, now(), 0, null, null, null, null, null, uuid());

INSERT INTO openmrs.provider (person_id, name, identifier, creator, date_created, changed_by, date_changed, retired, retired_by, date_retired, retire_reason, uuid, provider_role_id) VALUES (@pid, null, 'admin', 1, now(), null, null, 0, null, null, null,uuid(), null);

-- Create a User with person Id

INSERT INTO openmrs.users (system_id, username, password, salt, secret_question, secret_answer, creator, date_created, changed_by, date_changed, person_id, retired, retired_by, date_retired, retire_reason, uuid) VALUES ('admin', 'admin', 'f1feccee0f5b7fa1ff89628d020618677606906ee67c398d285b7b4fcf913989d71ccdeb4e542c70d1474bfb45a2440f2dba543a70dcade5123098b3b94142c5', 'c788c6ad82a157b712392ca695dfcf2eed193d7f', '', null, 1, now(), 1, now(), @pid, 0, null, null, null, uuid());


-- Insert OPD, IPD visit types


INSERT INTO openmrs.visit_type (name, description, creator, date_created, changed_by, date_changed, retired, retired_by, date_retired, retire_reason, uuid) VALUES ('OPD', 'Visit for patients coming for OPD', 1, now(), null, null, 0, null, null, null, uuid());

-- Insert a sample Location

set @hospital_uuid = uuid();

set @location_id = null;
set @location_tag_id = null;
set @visit_location_tag_id = null;

INSERT INTO openmrs.location (name, description, address1, address2, city_village, state_province, postal_code, country, latitude, longitude, creator, date_created, county_district, address3, address4, address5, address6, retired, retired_by, date_retired, retire_reason, parent_location, uuid, changed_by, date_changed) VALUES ('OPD2', null, null, null, null, null, null, null, null, null, 1, now(), null, null, null, null, null, 0, null, null, null, null, @hospital_uuid, null, null);

select location_id into @location_id from location where uuid=@hospital_uuid;

SELECT location_tag_id into @location_tag_id from location_tag where name = 'Login Location';

SELECT location_tag_id into @visit_location_tag_id from location_tag where name = 'Visit Location';

INSERT INTO openmrs.location_tag_map values(@location_id,@location_tag_id);

INSERT INTO openmrs.location_tag_map values(@location_id,@visit_location_tag_id);


set @hospital_uuid = uuid();

set @location_id = null;
set @location_tag_id = null;
set @visit_location_tag_id = null;

INSERT INTO openmrs.location (name, description, address1, address2, city_village, state_province, postal_code, country, latitude, longitude, creator, date_created, county_district, address3, address4, address5, address6, retired, retired_by, date_retired, retire_reason, parent_location, uuid, changed_by, date_changed) VALUES ('OPD3', null, null, null, null, null, null, null, null, null, 1, now(), null, null, null, null, null, 0, null, null, null, null, @hospital_uuid, null, null);

select location_id into @location_id from location where uuid=@hospital_uuid;

SELECT location_tag_id into @location_tag_id from location_tag where name = 'Login Location';

SELECT location_tag_id into @visit_location_tag_id from location_tag where name = 'Visit Location';

INSERT INTO openmrs.location_tag_map values(@location_id,@location_tag_id);

INSERT INTO openmrs.location_tag_map values(@location_id,@visit_location_tag_id);


set @hospital_uuid = uuid();

set @location_id = null;
set @location_tag_id = null;
set @visit_location_tag_id = null;

INSERT INTO openmrs.location (name, description, address1, address2, city_village, state_province, postal_code, country, latitude, longitude, creator, date_created, county_district, address3, address4, address5, address6, retired, retired_by, date_retired, retire_reason, parent_location, uuid, changed_by, date_changed) VALUES ('Pharmacy', null, null, null, null, null, null, null, null, null, 1, now(), null, null, null, null, null, 0, null, null, null, null, @hospital_uuid, null, null);

select location_id into @location_id from location where uuid=@hospital_uuid;

SELECT location_tag_id into @location_tag_id from location_tag where name = 'Login Location';

SELECT location_tag_id into @visit_location_tag_id from location_tag where name = 'Visit Location';

INSERT INTO openmrs.location_tag_map values(@location_id,@location_tag_id);

INSERT INTO openmrs.location_tag_map values(@location_id,@visit_location_tag_id);


-- Add Basic Roles to Access Bahmni

INSERT INTO role (role, description, uuid) values ('bahmni-document-uploader', 'bahmni-document-uploader', uuid());
INSERT INTO role (role, description, uuid) values ('Doctor', 'Role for the doctor', uuid());
INSERT INTO role (role, description, uuid) values ('Nurse', 'Role for the nurse', uuid());
INSERT INTO role (role, description, uuid) values ('RegistrationClerk', 'RegistrationClerk', uuid());



-- Give Required Privileges to superman
set @superman_id = null;
select  user_id into @superman_id from openmrs.users where username = 'admin';
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'bahmni-document-uploader');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'Doctor');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'Nurse');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'Privilege Level: Full');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'RegistrationClerk');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'System Developer');
INSERT INTO openmrs.user_role (user_id, role) VALUES (@superman_id, 'Provider');

-- Give 'Get Locations' Privilege to Anonymous
INSERT INTO openmrs.role_privilege (role, privilege) VALUES ('Anonymous', 'Get Locations');
