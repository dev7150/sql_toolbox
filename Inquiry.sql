
Select top 10 
*
FROM contact
LEFT OUTER JOIN  account ON account.accountid = contact.ms_employerid
LEFT OUTER JOIN  appointment ON appointment.ms_client = contact.contactid
LEFT OUTER JOIN  ms_vaccination ON ms_vaccination.ms_contact = contact.contactid
LEFT OUTER JOIN  ms_consent ON ms_consent.ms_client = contact.contactid
where 
contact.ms_clientid ='CLNT-0003251793'?
or contact.firstname = ?
or contact.lastname = ?
or contact.birthdate = ?
or contact.address1_composite = ?
or contact.emailaddress1=?
or contact.mobilephone = ?
or contact.ms_medicarenumber = ?
or contact.ms_medicarecardnumber = ?
or contact.ms_medicarecardposition = ?
or cast(appointment.actualend as date) = ? -- (yyyy-mm-dd)
--or appointment.ms_providername = ? --(Gippsland COVID-19 Vaccine Mobile Hub SEPHU Vaccination Bus Wodonga Vaccination Hub - Outreach Team 1 Austin Mobile Outreach Clinic SEPHU Vaccination Bus)
or account.name = ? (--Sunshine Hospital, Melbourne Airport, Macintosh Center-Shepparton Show grounds)
or account.parentaccountidname = ? (--Western Health, NULL, Monash Health, Bendigo Health, Goulburn Valley Health)
or account.address1_composite = ? (--1 Departure Drive Melbourne Airport, Victoria 3045)


SELECT        
FROM            
SELECT TOP 50 *
FROM contact
LEFT OUTER JOIN account account ON account.accountid = contact.ms_employerid
LEFT OUTER JOIN appointment appointment ON appointment.ms_client = contact.contactid
LEFT OUTER JOIN ms_vaccination ms_vaccination ON ms_vaccination.ms_contact = contact.contactid
LEFT OUTER JOIN ms_consent ms_consent ON ms_consent.ms_client = contact.contactid
WHERE ms_clientid = 'CLNT-0003251793'
