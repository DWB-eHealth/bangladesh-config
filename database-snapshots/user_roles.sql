select
	user_id as 'user id',
	username,
	givenname as 'given name',
    familyname as 'family name',
    MAX(CASE 
	WHEN 
	role = 'Bahmni-App-User-Login' THEN 'Yes'
	ELSE '' END) AS "Bahmni-App-User-Login",
	MAX(CASE 
	WHEN 
	role = 'Registration-App-Read-Only' THEN 'Yes'
	ELSE '' END) AS "Registration-App-Read-Only",
	MAX(CASE 
	WHEN 
	role = 'Registration-App' THEN 'Yes'
	ELSE '' END) AS "Registration-App",
	MAX(CASE 
	WHEN 
	role = 'Appointments:ReadOnly' THEN 'Yes'
	ELSE '' END) AS "Appointments:ReadOnly",
	MAX(CASE 
	WHEN 
	role = 'Appointments:ManageAppointments' THEN 'Yes'
	ELSE '' END) AS "Appointments:ManageAppointments",
	MAX(CASE 
	WHEN 
	role = 'Appointments:FullAccess' THEN 'Yes'
	ELSE '' END) AS "Appointments:FullAccess",
	MAX(CASE 
	WHEN 
	role = 'Provider' THEN 'Yes'
	ELSE '' END) AS "Provider",
	MAX(CASE 
	WHEN 
	role = 'SuperAdmin' THEN 'Yes'
	ELSE '' END) AS "SuperAdmin"
from (
	select 
		usr.user_id as user_id,
		usr.username as username,
		pn.given_name as givenname,
		pn.family_name as familyname,
		ur.role as role 
	from users as usr
	left outer join user_role as ur
	 on ur.user_id = usr.user_id 
	left outer join person_name as pn
	 on pn.person_id = usr.person_id 
	where ur.role IS NOT null
	) AS user_role
	group by user_id 
	order by username ASC 
