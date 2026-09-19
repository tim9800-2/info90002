-- Testing
-- SELECT '1729171' as StuID, d.*
-- FROM department9171 d;

-- 1. How many surgeries did each patient have?
select
	'1729171' as StuID,
    p.patient_id as pID,
    CONCAT(p.f_name, ' ', p.l_name) as pName,
    COUNT(*) as sCount
from patients9171 p
inner join surgeryrecord9171 sr on p.patient_id = sr.patient_id
group by pID
order by sCount desc;

-- 2. List of doctors, showing total amount earned from appointments.
-- List should include: Drs with no appts
-- Variables: doctor IDs, names, total amounts, ordered high to low
select
	'1729171' as StuID,
    d.doct_id as dID,
    CONCAT(d.f_name, ' ', d.l_name) as dName,
    IFNULL(SUM(a.payment_amount), 0) as dTotalAmountEarned
from doctor9171 as d
left join appointment9171 a on d.doct_id = a.doct_id
group by dID
order by dTotalAmountEarned desc;

-- 3. Produce a report that shows number of shifts with
-- 		Only doctors on duty
-- 		Only nurses on duty
-- 		Only helpers on duty
select
	'1729171' as StuID,
    'doctor shift' as `Staff on duty`,
    COUNT(*) as `Total shifts`
from staffshift9171
where (nurse_id is null and helper_id is null) and doct_id is not null
union all
select 
	'1729171' as StuID,
    'nurse shift' as `Staff on duty`,
    COUNT(*) as `Total shifts`
from staffshift9171
where (doct_id is null and helper_id is null) and nurse_id is not null
union all
select 
	'1729171' as StuID,
    'helper shift' as `Staff on duty`,
    COUNT(*) as `Total shifts`
from staffshift9171
where (doct_id is null and nurse_id is null) and helper_id is not null;

select
	'1729171' as StuID,
    'doctor shift' as `Staff on duty`,
    SUM(doct_id is not null and nurse_id is null and helper_id is null) as `Total shifts`
from staffshift9171
union all
select 
	'1729171' as StuID,
    'nurse shift' as `Staff on duty`,
    SUM(doct_id is null and nurse_id is not null and helper_id is null) as `Total shifts`
from staffshift9171
union all
select 
	'1729171' as StuID,
    'helper shift' as `Staff on duty`,
    SUM(doct_id is null and nurse_id is null and helper_id is not null) as `Total shifts`
from staffshift9171;

-- 4. List all patients with more than one cancelled appointment. Show
-- 		patient ID
-- 		last name, first name
-- 		gender
-- 		how many apt cancelled
-- Order by last name
select
	p.patient_id as pID,
    p.l_name as lName,
    p.f_name as fName,
    p.gender,
	a.appointment_status as aStatus,
    count(*) as numCancelledAppts
from patients9171 as p
left join appointment9171 a on p.patient_id = a.patient_id
where a.appointment_status = 'Cancelled'
group by p.patient_id
having count(*) > 1
order by lName;

-- 5. List all helpers who have not been allocated to a staff shift. Show
-- 		Dept ID, name
-- 		Helper ID, full name 
-- Sort by Dept ID, full name
select
	'1729171' as StuID,
	d.dept_id as deptID,
    d.dept_name as deptName,
    h.helper_id as hID,
    CONCAT(h.f_name, ' ', h.l_name) as hName
from helpers9171 h
left join staffshift9171 ss on h.helper_id = ss.helper_id
left join department9171 d on h.dept_id = d.dept_id
where ss.shift_id is null
order by deptID, hName;

-- 6. Total payments per calendar year, per payment method. Show:
-- 		Full total in first row
-- 		Subsequent rows: calendar year, mode of payment, money received ...
-- 		... ordered by year, mode of payment
select
	'1729171' as StuID,
	year(appointment_date) as calendarYear,
    mode_of_payment as modeOfPayment,
    sum(payment_amount) as paymentsTotal,
    1 as rowType,
    year(appointment_date) as sortYear
from appointment9171
group by year(appointment_date), mode_of_payment
union all
select
	'1729171' as StuID,
    '' as calendarYear,
    'Total' as modeOfPayment,
    sum(payment_amount) as paymentsTotal,
    0 as rowType,
    year(appointment_date) as sortYear
from appointment9171
group by year(appointment_date)
order by sortYear asc, rowType asc, modeOfPayment asc;

-- 7. List the number of surgeries performed by each surgeon per year. Show
-- 		Year when the surgery performed
-- 		Surgeon ID, last name
-- 		Number of surgeries performed
select
	'1729171' as StuID,
	d.doct_id as sID,
    d.l_name as sLastName,
	IFNULL(year(sr.surgery_date), '') as yearOfSurgery,
    IFNULL(COUNT(surgery_id), 0) as numSurgeries
from doctor9171 d
left join surgeryrecord9171 sr
on d.doct_id = sr.surgeon_id
group by IFNULL(year(sr.surgery_date), ''), d.doct_id;
