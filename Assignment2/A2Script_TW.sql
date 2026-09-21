-- Testing
-- SELECT '1729171' as StuID, d.*
-- FROM department9171 d;
USE hospitalmanagementsystem;
USE trwong;

-- 1. How many surgeries did each patient have?
SELECT
	'1729171' AS StuID,
    p.patient_id AS pID,
    CONCAT(p.f_name, ' ', p.l_name) AS pName,
    COUNT(*) AS surgeryCount
FROM patients9171 p
INNER JOIN surgeryrecord9171 sr ON p.patient_id = sr.patient_id
GROUP BY pID
ORDER BY surgeryCount DESC;

-- 2. List of doctors, showing total amount earned from appointments.
-- List should include: Drs with no appts
-- Variables: doctor IDs, names, total amounts, ordered high to low
SELECT
	'1729171' AS StuID,
    d.doct_id AS dID,
    CONCAT(d.f_name, ' ', d.l_name) AS dName,
    SUM(a.payment_amount) AS totalAmountEarned
FROM doctor9171 AS d
LEFT JOIN appointment9171 a ON d.doct_id = a.doct_id
GROUP BY dID
ORDER BY totalAmountEarned DESC;

-- 3. Produce a report that shows number of shifts with
-- 		Only doctors on duty
-- 		Only nurses on duty
-- 		Only helpers on duty
SELECT
	'1729171' AS StuID,
    'doctor shift' AS `Staff on duty`,
    SUM(doct_id IS NOT NULL AND nurse_id IS NULL AND helper_id IS NULL) AS `Total shifts`
FROM staffshift9171
UNION ALL
SELECT 
	'1729171' AS StuID,
    'nurse shift' AS `Staff on duty`,
    SUM(doct_id IS NULL AND nurse_id IS NOT NULL AND helper_id IS NULL) AS `Total shifts`
FROM staffshift9171
UNION ALL
SELECT 
	'1729171' AS StuID,
    'helper shift' AS `Staff on duty`,
    SUM(doct_id IS NULL AND nurse_id IS NULL AND helper_id IS NOT NULL) AS `Total shifts`
FROM staffshift9171;

-- 4. List all patients with more than one cancelled appointment. Show
-- 		patient ID
-- 		last name, first name
-- 		gender
-- 		how many apt cancelled
-- Order by last name
SELECT
	'1729171' AS StuID,
	p.patient_id AS pID,
    p.l_name AS lName,
    p.f_name AS fName,
    p.gender,
	a.appointment_status AS aStatus,
    COUNT(*) AS numCancelledAppts
FROM patients9171 AS p
LEFT JOIN appointment9171 a ON p.patient_id = a.patient_id
WHERE a.appointment_status = 'Cancelled'
GROUP BY p.patient_id
HAVING COUNT(*) > 1
ORDER BY lName;


-- 5. List all helpers who have not been allocated to a staff shift. Show
-- 		Dept ID, name
-- 		Helper ID, full name 
-- Sort by Dept ID, full name
SELECT
	'1729171' AS StuID,
	d.dept_id AS deptID,
    d.dept_name AS deptName,
    h.helper_id AS helperID,
    CONCAT(h.f_name, ' ', h.l_name) AS helperName
FROM helpers9171 h
LEFT JOIN staffshift9171 ss ON h.helper_id = ss.helper_id
LEFT JOIN department9171 d ON h.dept_id = d.dept_id
WHERE ss.shift_id IS NULL
ORDER BY deptID, helperName;

-- 6. Total payments per calendar year, per payment method. Show:
-- 		Full total in first row
-- 		Subsequent rows: calendar year, mode of payment, money received ...
-- 		... ordered by year, mode of payment
SELECT
	'1729171' AS StuID,
	YEAR(appointment_date) AS calendarYear,
    mode_of_payment AS modeOfPayment,
    SUM(payment_amount) AS paymentsTotal,
    1 AS rowType,
    YEAR(appointment_date) AS sortYear
FROM appointment9171
GROUP BY YEAR(appointment_date), mode_of_payment
UNION ALL
SELECT
	'1729171' AS StuID,
    '' AS calendarYear,
    'Total' AS modeOfPayment,
    SUM(payment_amount) AS paymentsTotal,
    0 AS rowType,
    YEAR(appointment_date) AS sortYear
FROM appointment9171
GROUP BY YEAR(appointment_date)
ORDER BY sortYear ASC, rowType ASC, modeOfPayment ASC;


-- 7. List the number of surgeries performed by each surgeon per year. Show
-- 		Year when the surgery performed
-- 		Surgeon ID, last name
-- 		Number of surgeries performed
SELECT
	'1729171' AS StuID,
	d.doct_id AS surgeonID,
    d.l_name AS surgeonLastName,
	YEAR(sr.surgery_date) AS yearOfSurgery,
    COUNT(surgery_id) AS numSurgeries
FROM doctor9171 d
LEFT JOIN surgeryrecord9171 sr
ON d.doct_id = sr.surgeon_id
GROUP BY YEAR(sr.surgery_date), d.doct_id
ORDER BY numSurgeries DESC;


-- 8. For each letter, list number of patients whose last name begins
-- with that letter. Hint: LEFT(string, n)
SELECT
	'1729171' AS StuID,
	LEFT(p.l_name, 1) AS Letter,
    COUNT(*) AS HowMany
FROM patients9171 p
GROUP BY Letter
ORDER BY Letter;


-- 9. Which patient(s) has the highest number of appointments? Show:
-- 		patientID, fullname as "[lastName], [firstName]"
-- 		number of appointments
SELECT
	'1729171' AS StuID,
    p.patient_id AS pID,
    CONCAT(l_name, ', ', f_name) AS pName,
    COUNT(*) AS numAppts
FROM patients9171 p
INNER JOIN appointment9171 a
ON p.patient_id = a.patient_id
GROUP BY p.patient_id
HAVING COUNT(*) >= ALL(
	SELECT COUNT(*)
    FROM appointment9171 a2
    GROUP BY a2.patient_id
);

-- 10a. Add yourself as a patient
INSERT INTO patients9171
	VALUES(1729171, 'Timothy', 'Wong', 'M', '1999-12-25', '0467897622', '1 Park Road, Carlton VIC 3010, Australia');

    
-- 10b. Schedule an appt with Dr. Sonia Ali on any date in Oct 2026.
-- 		Appointment status should be "scheduled"
-- 		In person, no payment details
-- 		Done as transaction: retrieve dr ID first, then save appt details
START TRANSACTION;
-- Step 1. Find Dr. Sonia Ali's ID
SET @DrSoniaAliID = (
	SELECT doct_id FROM doctor9171
	WHERE l_name = 'Ali' AND f_name = 'Dr. Sonia'
);
-- Step 2. Find the last appointment number
SET @LastApptNum = (
	SELECT MAX(appointment_id) FROM appointment9171
);
-- Step 3. Schedule an appointment
INSERT INTO appointment9171(appointment_id, patient_id, doct_id, appointment_date, appointment_status)
	VALUES(@LastApptNum + 1, 1729171, @DrSoniaAliID, '2026-10-15', 'Scheduled');
COMMIT;

-- 10c. Create statement showing my ID, name, appt details including
-- 		appt id
-- 		doctor's id and full name ([lName], [fName]),
-- 		date, mode of appt, status of appt
SELECT
	'1729171' AS StuID,
    p.patient_id AS pID,
    CONCAT(p.l_name, ', ', p.f_name) AS pName,
    appointment_id AS apptID,
    d.doct_id AS dID,
    CONCAT(d.l_name, ', ', d.f_name) AS dName,
    appointment_date AS apptDate,
    mode_of_appointment AS apptMode,
    mode_of_payment AS paymentMode,
    appointment_status AS apptStatus
FROM patients9171 p
LEFT JOIN appointment9171 a ON p.patient_id = a.patient_id
LEFT JOIN doctor9171 d ON d.doct_id = a.doct_id
WHERE p.patient_id = 1729171;

-- 11a. Create a view that counts num. of wards per dept. Your list should include:
-- 		deptID, deptName, numWards
-- DO NOT include StuID. In addition to code, provide:
-- 		Screenshot of list of tables and views in the left pane, showing the created view

CREATE VIEW WardCount AS
	SELECT 
		d.dept_id AS deptID,
		d.dept_name AS deptName,
		COUNT(*) AS numWards
	FROM department9171 d
	LEFT JOIN ward9171 w ON d.dept_id = w.dept_id
	GROUP BY d.dept_id;

-- 		The result of running select from your view (recommend showing the SELECT statement used to create the view)
SELECT
	d.dept_id AS deptID,
	d.dept_name AS deptName,
	COUNT(*) AS numWards
FROM department9171 d
LEFT JOIN ward9171 w ON d.dept_id = w.dept_id
GROUP BY d.dept_id;
    
-- 11b. Using the view, list depts with the highest number of wards. Show
-- 		deptID, deptName, numWards and STUDENT ID
SELECT
	'1729171' AS StuID,
    WardCount.*
FROM WardCount
WHERE numWards = (
	SELECT MAX(numWards)
    FROM WardCount
);


