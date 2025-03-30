-- Create Schema
DROP SCHEMA IF EXISTS Group10Schema;
DROP SCHEMA IF EXISTS Group37Schema;
CREATE SCHEMA Group37Schema;
USE Group37Schema;
-- Tables (ordered by dependency)
-- EMPLOYEE TABLES (created first)
CREATE TABLE Doctor (
                        DoctorID INT AUTO_INCREMENT PRIMARY KEY,
                        FirstName VARCHAR(50) NOT NULL,
                        LastName VARCHAR(50) NOT NULL,
                        Specialization VARCHAR(50),
                        StreetAddress VARCHAR(100),
                        City VARCHAR(50),
                        Province VARCHAR(50),
                        PostalCode VARCHAR(10)
);
CREATE TABLE Nurse (
                       NurseID INT AUTO_INCREMENT PRIMARY KEY,
                       FirstName VARCHAR(50) NOT NULL,
                       LastName VARCHAR(50) NOT NULL,
                       HourlyRate DECIMAL(10,2) DEFAULT 35.00,
                       StreetAddress VARCHAR(100),
                       City VARCHAR(50),
                       Province VARCHAR(50),
                       PostalCode VARCHAR(10)
);
CREATE TABLE Secretary (
                           SecretaryID INT AUTO_INCREMENT PRIMARY KEY,
                           FirstName VARCHAR(50) NOT NULL,
                           LastName VARCHAR(50) NOT NULL,
                           HourlyRate DECIMAL(10,2) DEFAULT 25.00,
                           StreetAddress VARCHAR(100),
                           City VARCHAR(50),
                           Province VARCHAR(50),
                           PostalCode VARCHAR(10)
);
CREATE TABLE Administrative_Assistant (
                            AdminID INT AUTO_INCREMENT PRIMARY KEY,
                            FirstName VARCHAR(30) NOT NULL,
                            LastName VARCHAR(30) NOT NULL,
                            HourlyRate DECIMAL(10, 2) DEFAULT 20.00,
                            StreetAddress VARCHAR(100),
                            City VARCHAR(50),
                            Province VARCHAR(50),
                            PostalCode VARCHAR(10)
);
CREATE TABLE Manager (
                            ManagerID INT AUTO_INCREMENT PRIMARY KEY,
                            FirstName VARCHAR(20) NOT NULL,
                            LastName VARCHAR(20) NOT NULL,
                            HourlyRate DECIMAL(10,2) NOT NULL,
                            StreetAddress VARCHAR(100),
                            City VARCHAR(50),
                            Province VARCHAR(50),
                            PostalCode VARCHAR(10)
);
-- PATIENT RELATED TABLES
CREATE TABLE Patient (
           PatientID INT AUTO_INCREMENT PRIMARY KEY,
           FirstName VARCHAR(50) NOT NULL,
           LastName VARCHAR(50) NOT NULL,
           DateOfBirth DATE NOT NULL,
           Address VARCHAR(100),
           PhoneNumber VARCHAR(20) UNIQUE,
           Email VARCHAR(100),
           HealthCardNo VARCHAR(20) UNIQUE NOT NULL,
           Type ENUM ('Enrolled', 'Walk-in') NOT NULL,
           DoctorID INT,
           PrimaryMemberID INT NULL,
           Relationship ENUM('Husband', 'Wife', 'Son', 'Daughter', 'Father', 'Mother', 'Other') NULL,
           FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
           FOREIGN KEY (PrimaryMemberID) REFERENCES Patient(PatientID),
           CONSTRAINT CHK_EnrolledPatient CHECK (
               (Type = 'Enrolled' AND DoctorID IS NOT NULL) OR
               (Type = 'Walk-in' AND DoctorID IS NULL)
           )
);
CREATE TABLE Appointment (
  AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
  PatientID INT,
  DoctorID INT,
  NurseID INT,
  Date DATE NOT NULL,
  Time TIME NOT NULL,
  Status ENUM('Booked', 'Cancelled', 'Arrived', 'Checked In', 'Checked Out', 'LWT', 'No-Show')  ,
  Notes TEXT,
  FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
  FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
  FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID)
);
CREATE TABLE Visits (
    VisitsID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    Checkin_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Checkout_Time TIMESTAMP NULL,
    Symptoms TEXT,
    Diagnosis TEXT,
    Treatment TEXT,
    AppointmentID INT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);
CREATE TABLE Patient_Vitals (
    VitalsID INT AUTO_INCREMENT PRIMARY KEY,
    VisitsID INT NOT NULL,
    NurseID INT NOT NULL,
    Weight DECIMAL (10,2),
    Height DECIMAL (10,2),
    BloodPressure VARCHAR(15),
    Temperature DECIMAL (10,2),
    Recorded_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
    FOREIGN KEY (VisitsID) REFERENCES Visits(VisitsID)
);
CREATE TABLE DiagnosticTest (
    TestID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT NOT NULL,
    DoctorID INT NOT NULL,
    TestName VARCHAR(100) NOT NULL,
    ClinicalNotes TEXT NOT NULL,
    OrderedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VisitID) REFERENCES Visits(VisitsID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);
CREATE TABLE TestResult (
    ResultID INT AUTO_INCREMENT PRIMARY KEY,
    TestID INT NOT NULL,
    NurseID INT NOT NULL,
    Findings TEXT NOT NULL,
    ResultDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestID) REFERENCES DiagnosticTest(TestID),
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID)
);
CREATE TABLE Prescription (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    VisitsID INT,
    DoctorID INT,
    ResultID INT,
    MedicineName VARCHAR(100) NOT NULL,
    Dosage VARCHAR(50),
    FOREIGN KEY (ResultID) REFERENCES TestResult (ResultID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (VisitsID) REFERENCES Visits(VisitsID)
);
-- SHIFT RELATED TABLES
CREATE TABLE Shift (
    ShiftID INT AUTO_INCREMENT PRIMARY KEY,
    ShiftType ENUM('Morning', 'Evening') NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL
);
CREATE TABLE AdminAssistant_Shifts (
    AdminShiftID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    ClockInTime TIMESTAMP NULL,
    ClockOutTime TIMESTAMP NULL,
    AdminID INT NOT NULL,
    ShiftID INT NOT NULL,
    HoursWorked DECIMAL(5,2) GENERATED ALWAYS AS (TIMESTAMPDIFF(HOUR, ClockInTime, ClockOutTime)) VIRTUAL,
    FOREIGN KEY (AdminID) REFERENCES Administrative_Assistant(AdminID),
    FOREIGN KEY (ShiftID) REFERENCES Shift(ShiftID)
);
CREATE TABLE Doctors_Shifts (
    Doctors_ShiftID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    ClockInTime TIMESTAMP NULL,
    ClockOutTime TIMESTAMP NULL,
    DoctorID INT NOT NULL,
    ShiftID INT NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (ShiftID) REFERENCES Shift(ShiftID)
);
CREATE TABLE NurseShifts (
    NurseShiftID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    ClockInTime TIMESTAMP NULL,
    ClockOutTime TIMESTAMP NULL,
    NurseID INT NOT NULL,
    ShiftID INT NOT NULL,
    HoursWorked DECIMAL(5,2) GENERATED ALWAYS AS (TIMESTAMPDIFF(HOUR, ClockInTime, ClockOutTime)) VIRTUAL,
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
    FOREIGN KEY (ShiftID) REFERENCES Shift(ShiftID)
);
CREATE TABLE Secretary_Shifts (
    Secretary_ShiftID INT AUTO_INCREMENT PRIMARY KEY,
    SecretaryID INT NOT NULL,
    Date DATE NOT NULL,
    ClockInTime TIMESTAMP NULL,
    ClockOutTime TIMESTAMP NULL,
    ShiftID INT NOT NULL,
    HoursWorked DECIMAL(5,2) GENERATED ALWAYS AS (TIMESTAMPDIFF(HOUR, ClockInTime, ClockOutTime)) VIRTUAL,
    FOREIGN KEY (SecretaryID) REFERENCES Secretary(SecretaryID),
    FOREIGN KEY (ShiftID) REFERENCES Shift(ShiftID)
);
-- REFERRAL AND FEE TABLES
CREATE TABLE Referral (
    ReferralID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT NOT NULL,
    ReferringDoctorID INT NOT NULL,
    SpecialistDoctorID INT NOT NULL,
    Notes TEXT,
    FOREIGN KEY (VisitID) REFERENCES Visits(VisitsID),
    FOREIGN KEY (ReferringDoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (SpecialistDoctorID) REFERENCES Doctor(DoctorID)
);
CREATE TABLE Fee (
    FeeID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    FeeDate DATETIME,
    ServiceName VARCHAR(100) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);



-- DATA INSERTION (ordered by dependency)
SET FOREIGN_KEY_CHECKS = 0;
-- Employees first
INSERT INTO Doctor (FirstName, LastName, Specialization, StreetAddress, City, Province, PostalCode)
VALUES
    ('Michael',       'Johnson',     'Pediatrics',             '789 Pine Rd',          'Montreal',       'QC', 'H2B2B2'),
    ('Sarah',         'Brown',       'Dermatology',            '1010 Birch Blvd',      'Calgary',        'AB', 'T3C3C3'),
    ('David',         'Wilson',      'Oncology',               '246 Cedar Ln',         'Ottawa',         'ON', 'K1A0B1'),
    ('Emma',          'Taylor',      'Neurology',              '369 Spruce Cir',       'Edmonton',       'AB', 'T5J2Z7'),
    ('Liam',          'Anderson',    'Orthopedics',            '135 Elm St',           'Winnipeg',       'MB', 'R3C4T6'),
    ('Olivia',        'Thomas',      'Endocrinology',          '791 Maple Cres',       'Halifax',        'NS', 'B3H4R2'),
    ('Noah',          'Lee',         'Gastroenterology',       '357 Oakwood Ave',      'Victoria',       'BC', 'V8W1P3'),
    ('Ava',           'Harris',      'Radiology',              '963 Willow Way',       'Regina',         'SK', 'S4P3X2'),
    ('William',       'Clark',       'Psychiatry',             '159 Aspen Dr',         'Quebec City',    'QC', 'G1V2L7'),
    ('Sophia',        'Lewis',       'Rheumatology',           '753 Redwood Blvd',     'Saskatoon',      'SK', 'S7K1N9'),
    ('James',         'Walker',      'Urology',                '852 Sycamore Rd',      'St. John''s',    'NL', 'A1C5S9'),
    ('Isabella',      'Hall',        'Ophthalmology',          '426 Magnolia Trl',     'Charlottetown',  'PE', 'C1A7N5'),
    ('Benjamin',      'Young',       'ENT',                    '684 uniper Pl',        'Fredericton',    'NB', 'E3B5H1'),
    ('Mia',           'King',        'Nephrology',             '315 Poplar Ave',       'Whitehorse',     'YT', 'Y1A5V7'),
    ('Ethan',         'Wright',      'Pulmonology',            '972 Acacia Blvd',      'Yellowknife',    'NT', 'X1A2B3'),
    ('Charlotte',     'Lopez',       'Infectious Disease',     '531 Chestnut St',      'Iqaluit',        'NU', 'X0A0H0'),
    ('Mason',         'Hill',        'Hematology',             '863 Sequoia Way',      'Kelowna',        'BC', 'V1Y9T2'),
    ('Amelia',        'Scott',       'Allergy and Immunology', '297 Cypress Rd',       'London',         'ON', 'N6A1B7'),
    ('Lucas',         'Green',       'Geriatrics',             '738 Fir Ct',           'Mississauga',    'ON', 'L5B2P4'),
    ('Harper',        'Adams',       'Sports Medicine',        '164 Hemlock Dr',       'Hamilton',       'ON', 'L8P1A3'),
    ('Evelyn',        'Baker',       'Family Medicine',        '429 Linden Ave',       'Brampton',       'ON', 'L6T3T5'),
    ('Alexander',     'Gonzalez',    'Emergency Medicine',     '875 Mahogany Ln',      'Surrey',         'BC', 'V3S8P4'),
    ('Ella',          'Nelson',      'Plastic Surgery',        '612 Walnut Cres',      'Laval',          'QC', 'H7M2W6'),
    ('Jackson',       'Carter',      'Neurosurgery',           '358 Pecan Way',        'Markham',        'ON', 'L3R0Y7'),
    ('Luna',          'Mitchell',    'Thoracic Surgery',       '941 Spruce Blvd',      'Vaughan',        'ON', 'L4H1S3'),
    ('Aiden',         'Perez',       'Vascular Surgery',       '527 Red Cedar Rd',     'Longueuil',      'QC', 'J4N1E8'),
    ('Grace',         'Roberts',     'Pediatric Surgery',      '736 Birchwood Dr',     'Burnaby',        'BC', 'V5G1M5'),
    ('Oliver',        'Turner',      'Obstetrics/Gynecology',  '183 Pinegrove Ave',    'Richmond',       'BC', 'V6Y1T9'),
    ('Chloe',         'Phillips',    'Anesthesiology',         '654 Cedarhill Rd',     'Richmond Hill',  'ON', 'L4C3V2'),
    ('Logan',         'Campbell',    'Pathology',              '319 Maplewood Ln',     'Oakville',       'ON', 'L6J2X1'),
    ('Zoe',           'Parker',      'Preventive Medicine',    '457 Oakridge Dr',      'Burlington',     'ON', 'L7L1H3'),
    ('Henry',         'Evans',       'Nuclear Medicine',       '892 Willowbrook St',   'Barrie',         'ON', 'L4M4Y5'),
    ('Lily',          'Edwards',     'Physical Medicine',      '125 Pinecrest Ave',    'Abbotsford',     'BC', 'V2S3P7'),
    ('Gabriel',       'Collins',     'Pain Management',        '734 Elmhurst Blvd',    'Coquitlam',      'BC', 'V3B7M1');


INSERT INTO Nurse (FirstName, LastName, HourlyRate, StreetAddress, City, Province, PostalCode)
VALUES
    ('Emily',        'Wilson',       34.50, '123 Maple St',         'Toronto',       'ON', 'M5A1A1'),
    ('Liam',         'Taylor',       36.00, '456 Oak Ave',          'Vancouver',     'BC', 'V6B2B2'),
    ('Olivia',       'Anderson',     33.50, '789 Pine Rd',          'Montreal',      'QC', 'H3A2B2'),
    ('Noah',         'Thomas',       35.75, '321 Birch Ln',         'Calgary',       'AB', 'T2P1J9'),
    ('Ava',          'Jackson',      37.25, '654 Cedar St',         'Ottawa',        'ON', 'K1P5E4'),
    ('William',      'White',        32.00, '987 Spruce Ave',       'Edmonton',      'AB', 'T5J2R7'),
    ('Sophia',       'Harris',       34.00, '135 Willow Way',       'Halifax',       'NS', 'B3H4R2'),
    ('James',        'Martin',       38.00, '246 Elm St',           'Winnipeg',      'MB', 'R3C4T5'),
    ('Isabella',     'Thompson',     33.00, '369 Spruce Cir',       'Quebec City',   'QC', 'G1V2L7'),
    ('Benjamin',     'Garcia',       35.50, '753 Redwood Blvd',     'Saskatoon',     'SK', 'S7K1N9'),
    ('Mia',          'Martinez',     36.75, '852 Sycamore Rd',      'St. John''s',   'NL', 'A1C5S9'),
    ('Ethan',        'Robinson',     34.25, '426 Magnolia Trl',     'Charlottetown', 'PE', 'C1A7N5'),
    ('Charlotte',    'Clark',        37.50, '684 Juniper Pl',       'Fredericton',   'NB', 'E3B5H1'),
    ('Lucas',        'Rodriguez',    32.75, '315 Poplar Ave',       'Whitehorse',    'YT', 'Y1A5V7'),
    ('Amelia',       'Lewis',        35.00, '972 Acacia Blvd',      'Yellowknife',   'NT', 'X1A2B3'),
    ('Mason',        'Lee',          36.25, '531 Chestnut St',      'Iqaluit',       'NU', 'X0A0H0'),
    ('Harper',       'Walker',       33.75, '863 Sequoia Way',      'Kelowna',       'BC', 'V1Y9T2'),
    ('Evelyn',       'Hall',         34.50, '297 Cypress Rd',       'London',        'ON', 'N6A1B7'),
    ('Alexander',    'Young',        37.00, '738 Fir Ct',           'Mississauga',   'ON', 'L5B2P4'),
    ('Ella',         'Hernandez',    32.50, '164 Hemlock Dr',       'Hamilton',      'ON', 'L8P1A3'),
    ('Daniel',       'King',         35.25, '429 Linden Ave',       'Brampton',      'ON', 'L6T3T5'),
    ('Matthew',      'Wright',       36.50, '875 Mahogany Ln',      'Surrey',        'BC', 'V3S8P4'),
    ('Abigail',      'Lopez',        33.25, '612 Walnut Cres',      'Laval',         'QC', 'H7M2W6'),
    ('Elizabeth',    'Hill',         34.75, '358 Pecan Way',        'Markham',       'ON', 'L3R0Y7'),
    ('Logan',        'Scott',        37.75, '941 Spruce Blvd',      'Vaughan',       'ON', 'L4H1S3'),
    ('Grace',        'Green',        32.25, '527 Red Cedar Rd',     'Longueuil',     'QC', 'J4N1E8'),
    ('Chloe',        'Adams',        35.75, '736 Birchwood Dr',     'Burnaby',       'BC', 'V5G1M5'),
    ('Victoria',     'Baker',        36.00, '183 Pinegrove Ave',    'Richmond',      'BC', 'V6Y1T9'),
    ('Avery',        'Gonzalez',     33.50, '654 Cedarhill Rd',     'Richmond Hill', 'ON', 'L4C3V2'),
    ('Scarlett',     'Nelson',       34.25, '319 Maplewood Ln',     'Oakville',      'ON', 'L6J2X1'),
    ('Zoey',         'Carter',       37.25, '457 Oakridge Dr',      'Burlington',    'ON', 'L7L1H3'),
    ('Hannah',       'Mitchell',     32.75, '892 Willowbrook St',   'Barrie',        'ON', 'L4M4Y5'),
    ('Addison',      'Perez',        35.50, '125 Pinecrest Ave',    'Abbotsford',    'BC', 'V2S3P7'),
    ('Eleanor',      'Roberts',      36.75, '734 Elmhurst Blvd',    'Coquitlam',     'BC', 'V3B7M1'),
    ('Natalie',      'Turner',       33.00, '246 Maple Cir',        'Guelph',        'ON', 'N1H6H6'),
    ('Hazel',        'Phillips',     34.50, '369 Oakwood Dr',       'Cambridge',     'ON', 'N3C1T1'),
    ('Penelope',     'Campbell',     37.00, '852 Cedar Ave',        'Waterloo',      'ON', 'N2J1J1'),
    ('Luna',         'Parker',       32.50, '753 Pine St',          'Kingston',      'ON', 'K7K1K1'),
    ('Aiden',        'Evans',        35.25, '159 Birch Blvd',       'Thunder Bay ',  'ON', 'P7B1B1'),
    ('Zoe',          'Edwards',      36.50, '987 Spruce Ln',        'Sudbury',       'ON', 'P3E2E2');


INSERT INTO Secretary (FirstName, LastName, HourlyRate, StreetAddress, City, Province, PostalCode)
VALUES
    ('Emma',      'Collins',    24.50, '123 Oak St',        'Toronto',      'ON', 'M5A1A1'),
    ('Oliver',    'Stewart',    25.75, '456 Maple Ave',     'Vancouver',    'BC', 'V6B2B2'),
    ('Sophia',    'Morris',     25.00, '789 Cedar Rd',      'Montreal',     'QC', 'H3A2B2'),
    ('Liam',      'Barnes',     24.00, '321 Pine Cres',     'Calgary',      'AB', 'T2P1J9'),
    ('Ava',       'Foster',     26.00, '654 Birch Blvd',    'Ottawa',       'ON', 'K1P5E4'),
    ('Noah',      'Bryant',     25.25, '987 Spruce Way',    'Edmonton',     'AB', 'T5J2R7'),
    ('Isabella',  'Griffin',    24.75, '135 Elm Dr',        'Halifax',      'NS', 'B3H4R2'),
    ('James',     'Russell',    25.50, '246 Willow Ln',     'Winnipeg',     'MB', 'R3C4T5'),
    ('Charlotte', 'Dixon',      24.25, '369 Aspen Cir',     'Quebec City',  'QC', 'G1V2L7'),
    ('Benjamin',  'Hayes',      25.00, '753 Redwood Rd',    'Saskatoon',    'SK', 'S7K1N9');



INSERT INTO Administrative_Assistant (FirstName, LastName, HourlyRate, StreetAddress, City, Province, PostalCode)
VALUES
    ('Mason',     'Griffin',   19.50, '456 Birch Ave',    'Vancouver',   'BC', 'V6B2B2'),
    ('Amelia',    'Russell',   20.75, '789 Spruce Rd',    'Montreal',    'QC', 'H3A2B2'),
    ('William',   'White',     21.00, '321 Cedar Ln',     'Calgary',     'AB', 'T2P1J9'),
    ('Sophia',    'Harris',    19.75, '654 Pine St',      'Ottawa',      'ON', 'K1P5E4'),
    ('Ethan',     'Robinson',  20.25, '987 Oak Ave',      'Edmonton',    'AB', 'T5J2R7'),
    ('Olivia',    'Clark',     20.50, '135 Maple Way',    'Halifax',     'NS', 'B3H4R2'),
    ('Lucas',     'Rodriguez', 19.00, '246 Willow Dr',    'Winnipeg',    'MB', 'R3C4T5'),
    ('Emily',     'Lewis',     20.00, '369 Aspen Cir',    'Quebec City', 'QC', 'G1V2L7'),
    ('Alexander', 'Young',     21.25, '753 Hemlock Rd',   'Saskatoon',   'SK', 'S7K1N9'),
    ('Ella',      'Hernandez', 19.95, '159 Redwood Blvd', 'Victoria',    'BC', 'V8W1P3');



INSERT INTO Manager (FirstName, LastName, HourlyRate, StreetAddress, City, Province, PostalCode)
VALUES
('Robert', 'Taylor', 45.00, '246 Elm St', 'Winnipeg', 'MB', 'R3C4T5');





-- Patients
INSERT INTO Patient (FirstName, LastName, DateOfBirth, Address, PhoneNumber, Email, HealthCardNo, Type, DoctorID, PrimaryMemberID, Relationship)
VALUES
('John', 'Doe',  '1980-05-15', '123 Main St', '416-123-3450', 'john@email.com', 'NC193456', 'Enrolled', 1,    NULL, NULL),
('Jane', 'Doe',  '1985-08-20', '123 Main St', '567-123-4568', 'jane@email.com', 'HQ123357', 'Enrolled', 1,    1,    'Wife'),
('Alice','Doe',  '2010-02-10', '123 Main St', '416-823-4569', NULL,             'LX163418', 'Walk-in',  NULL, 1,    'Daughter'),


('Bob',  'Smith','1995-11-30', '456 Elm St',  '647-987-6543', 'bob@email.com',  'HC654321', 'Walk-in',  NULL, NULL,    'son'),



('Eweka', 'Travis', '2005-11-30', '38 Elgin dr', '565-332-739', 'traviseweka@icloud.com', 'DU73HJ45','Enrolled', 6, NULL, NULL ),

('Michael','Johnson', '1975-03-22', '789 Oak Ave', '416-739-0123', 'michael.johnson@email.com', 'MB112233', 'Enrolled', 2,    NULL, NULL),
('Sarah',  'Johnson', '1980-07-14', '789 Oak Ave', '416-555-0124', 'sarah.johnson@email.com',   'MB223344', 'Enrolled', 2,    6,    'Wife'),
('Emily',  'Johnson', '2015-09-05', '789 Oak Ave', NULL,           NULL,                        'MB334455', 'Walk-in',  NULL, 6,    'Daughter'),
('David',  'Johnson', '2018-12-25', '789 Oak Ave', NULL,           NULL,                        'MB445566', 'Walk-in',  NULL, 6,    'Son'),



('Sophia', 'Martinez', '1990-12-05', '1010 Cedar Blvd', '416-8284-8239', 'sophia@email.com', 'MC556677', 'Enrolled', 5,    NULL, NULL),
('Carlos', 'Martinez', '1988-03-20', '1010 Cedar Blvd', '416-363-9950', 'carlos@email.com', 'MC667788', 'Enrolled', 5,    10,   'Husband'),
('Mia',    'Martinez', '2019-04-22', '1010 Cedar Blvd', NULL,           NULL,               'MC778899', 'Walk-in',  NULL, 10,   'Daughter'),


('Noah',   'Davis',    '1999-06-30', '2020 Birch Ln',  '647-949-9020', 'noah@email.com', 'ND889900', 'Walk-in', NULL, NULL, NULL),

('Olivia', 'Wilson', '1985-02-14', '3030 Spruce Ave', '416-444-5555', 'olivia@email.com', 'OW990011', 'Enrolled', 7,    NULL, NULL),
('Liam',   'Wilson', '2012-08-19', '3030 Spruce Ave', NULL,           NULL,               'LW001122', 'Walk-in',  NULL, 13,   'Son'),


('William', 'Taylor', '1965-11-11', '4040 Pine St', '905-555-6666', 'william@email.com', 'WT112233', 'Enrolled', 8, NULL, NULL),
('Ava',     'Taylor', '1968-04-05', '4040 Pine St', '905-484-4498', 'ava@email.com',     'WT223344', 'Enrolled', 8, 15,   'Wife'),

('Charlotte', 'Anderson', '1983-07-07', '5050 Oak Rd', '647-666-7777', 'charlotte@email.com', 'CA334455', 'Enrolled', 9,    NULL, NULL),
('Harper',    'Anderson', '2016-03-03', '5050 Oak Rd', NULL,           NULL,                  'HA445566', 'Walk-in',  NULL, 17,   'Daughter'),


('Lucas', 'Thomas', '2001-09-09', '6060 Elm Dr', '416-707-8579', 'lucas@email.com', 'LT556677', 'Walk-in', NULL, NULL, NULL),

('Amelia',   'White', '1992-10-10', '7070 Maple Cir', '647-838-8489', 'amelia@email.com',   'AW667788', 'Enrolled', 10,   NULL, NULL),
('Benjamin', 'White', '1990-12-12', '7070 Maple Cir', '647-098-9998', 'benjamin@email.com', 'BW778899', 'Enrolled', 10,   20,   'Husband'),
('Henry',    'White', '2021-01-01', '7070 Maple Cir', NULL,           NULL,                 'HW889900', 'Walk-in',  NULL, 20,   'Son'),


('Evelyn', 'Harris', '1978-03-25', '8080 Cedar Way', '905-999-0000', 'evelyn@email.com', 'EH990011', 'Enrolled', 2,    NULL, NULL),
('Mason',  'Harris', '2005-05-05', '8080 Cedar Way', NULL,           NULL,               'MH001122', 'Walk-in',  NULL, 23,   'Son'),


('Logan', 'Clark', '1997-04-18', '9090 Birch Ct', '416-987-2345', 'logan@email.com', 'LC112233', 'Walk-in', NULL, NULL, NULL),

('Grace', 'Lewis', '1980-06-30', '111 Fir Ave', '647-767-5670', 'grace@email.com', 'GL223344', 'Enrolled', 3,    NULL, NULL),
('Ethan', 'Lewis', '1979-08-15', '111 Fir Ave', '647-848-9293', 'ethan@email.com', 'EL334455', 'Enrolled', 3,    26,   'Husband'),
('Sofia', 'Lewis', '2014-07-04', '111 Fir Ave', NULL,           NULL,              'SL445566', 'Walk-in',  NULL, 26,   'Daughter'),


('Michael', 'Rodriguez', '1995-09-22', '222 Pine Rd', '416-222-3333', 'michael@email.com', 'MR556677', 'Enrolled', 4,    NULL, NULL),
('Abigail', 'Rodriguez', '1996-11-23', '222 Pine Rd', '416-222-3574', 'abigail@email.com', 'AR667788', 'Enrolled', 4,    29,   'Wife'),
('Daniel', 'Rodriguez',  '2022-02-14', '222 Pine Rd', NULL,           NULL,                'DR778899', 'Walk-in',  NULL, 29,   'Son'),


('Emily', 'Hall', '2003-12-25', '333 Oak Ln', '647-333-4444', 'emily@email.com', 'EH889900', 'Walk-in', NULL, NULL, NULL),

('Oliver', 'Young', '1987-01-01', '444 Maple Dr', '905-444-5555', 'oliver@email.com', 'OY990011', 'Enrolled', 5,    NULL, NULL),
('Chloe',  'Young', '1989-02-02', '444 Maple Dr', '905-444-5786', 'chloe@email.com',  'CY001122', 'Enrolled', 5,    33,   'Wife'),
('Lily',   'Young', '2020-03-03', '444 Maple Dr', NULL,           NULL,               'LY112233', 'Walk-in',  NULL, 33,   'Daughter'),


('Jacob',    'Walker', '1970-04-04', '555 Elm St', '416-838-8923', 'jacob@email.com',    'JW223344', 'Enrolled', 6,    NULL, NULL),
('Victoria', 'Walker', '1972-05-05', '555 Elm St', '416-555-6097', 'victoria@email.com', 'VW334455', 'Enrolled', 6,    36,   'Wife'),
('Ryan',     'Walker', '2009-06-06', '555 Elm St', NULL,           NULL,                 'RW445566', 'Walk-in',  NULL, 36,   'Son'),


('Ava', 'Perez', '2000-07-07', '666 Cedar Blvd', '647-098-4665', 'ava@email.com', 'AP556677', 'Walk-in', NULL, NULL, NULL),

('James',    'King', '1984-08-08', '777 Birch Way', '905-777-8888', 'james@email.com',    'JK667788', 'Enrolled', 7,    NULL, NULL),
('Scarlett', 'King', '1986-09-09', '777 Birch Way', '908-783-5489', 'scarlett@email.com', 'SK778899', 'Enrolled', 7,    40,   'Wife'),
('Zoey',     'King', '2018-10-10', '777 Birch Way', NULL,           NULL,                 'ZK889900', 'Walk-in',  NULL, 40,   'Daughter'),


('Henry',   'Scott', '1993-11-11', '888 Spruce Dr', '416-888-9999', 'henry@email.com',   'HS990011', 'Enrolled', 8,    NULL, NULL),
('Madison', 'Scott', '1994-12-12', '888 Spruce Dr', '416-087-3548', 'madison@email.com', 'MS001122', 'Enrolled', 8,    43,   'Wife'),
('Leo',     'Scott', '2023-01-12', '888 Spruce Dr', NULL,           NULL,                'LS112233', 'Walk-in',  NULL, 43,   'Son');





-- Appointments
INSERT INTO Appointment (PatientID, DoctorID, NurseID, Date, Time, Status) VALUES
(1,  6,   9,  '2023-01-05', '08:30:00', 'Arrived'),
(2,  2,   2,  '2023-01-10', '14:00:00', 'Checked Out'),
(3,  3,   3,  '2023-01-15', '09:45:00', 'Cancelled'),
(4,  4,   4,  '2023-01-20', '11:15:00', 'LWT'),
(5,  5,   5,  '2023-01-25', '16:30:00', 'No-Show'),
(6,  6,   6,  '2023-02-01', '10:00:00', 'Booked'),
(7,  7,   7,  '2023-02-05', '13:20:00', 'Arrived'),
(8,  8,   8,  '2023-02-10', '15:45:00', 'Checked Out'),
(9,  9,   9,  '2023-02-15', '08:15:00', 'Cancelled'),
(10, 10,  10, '2023-02-20', '12:00:00', 'LWT'),
(1,  1,   1,  '2023-03-05', '09:30:00', 'Arrived'),
(2,  2,   2,  '2023-03-10', '14:45:00', 'Checked Out'),
(3,  3,   3,  '2023-03-15', '11:10:00', 'Cancelled'),
(4,  4,   4,  '2023-03-20', '16:00:00', 'Arrived'),
(5,  5,   5,  '2023-03-25', '10:30:00', 'No-Show'),
(6,  6,   6,  '2023-04-01', '08:00:00', 'Booked'),
(7,  7,   7,  '2023-04-05', '13:15:00', 'Arrived'),
(8,  8,   8,  '2023-04-10', '15:30:00', 'Checked Out'),
(9,  9,   9,  '2023-04-15', '09:45:00', 'Cancelled'),
(10, 10,  10, '2023-04-20', '12:20:00', 'LWT'),
(1,  1,   1,  '2023-05-05', '10:00:00', 'LWT'),
(2,  2,   2,  '2023-05-10', '14:30:00', 'Checked Out'),
(3,  3,   3,  '2023-05-15', '11:45:00', 'Cancelled'),
(4,  4,   4,  '2023-05-20', '16:15:00', 'Arrived'),
(5,  5,   5,  '2023-05-25', '09:00:00', 'No-Show'),
(6,  6,   6,  '2023-06-01', '13:00:00', 'Booked'),
(7,  7,   7,  '2023-06-05', '08:45:00', 'LWT'),
(8,  8,   8,  '2023-06-10', '15:10:00', 'Checked Out'),
(9,  9,   9,  '2023-06-15', '10:20:00', 'Cancelled'),
(10, 10,  10, '2023-06-20', '12:45:00', 'Arrived'),

(1, 1, 1, '2024-01-05', '08:30:00', 'Arrived'),
(2, 2, 2, '2024-01-10', '14:00:00', 'Checked Out'),
(3, 3, 3, '2024-01-15', '09:45:00', 'Cancelled'),
(4, 4, 4, '2024-01-20', '11:15:00', 'Arrived'),
(5, 5, 5, '2024-01-25', '16:30:00', 'No-Show'),
(6, 6, 6, '2024-02-01', '10:00:00', 'Booked'),
(7, 7, 7, '2024-02-05', '13:20:00', 'Arrived'),
(8, 8, 8, '2024-02-10', '15:45:00', 'Checked Out'),
(9, 9, 9, '2024-02-15', '08:15:00', 'Cancelled'),
(10,10,10,'2024-02-20', '12:00:00', 'LWT'),
(1, 1, 1, '2024-03-05', '09:30:00', 'LWT'),
(2, 2, 2, '2024-03-10', '14:45:00', 'Checked Out'),
(3, 3, 3, '2024-03-15', '11:10:00', 'Cancelled'),
(4, 4, 4, '2024-03-20', '16:00:00', 'Arrived'),
(5, 5, 5, '2024-03-25', '10:30:00', 'No-Show'),
(6, 6, 6, '2024-04-01', '08:00:00', 'Booked'),
(7, 7, 7, '2024-04-05', '13:15:00', 'Arrived'),
(8, 8, 8, '2024-04-10', '15:30:00', 'Checked Out'),
(9, 9, 9, '2024-04-15', '09:45:00', 'Cancelled'),
(10,10,10,'2024-04-20', '12:20:00', 'LWT'),
(1, 1, 1, '2024-05-05', '10:00:00', 'Arrived'),
(2, 2, 2, '2024-05-10', '14:30:00', 'Checked Out'),
(3, 3, 3, '2024-05-15', '11:45:00', 'Cancelled'),
(4, 4, 4, '2024-05-20', '16:15:00', 'LWT'),
(5, 5, 5, '2024-05-25', '09:00:00', 'No-Show'),
(6, 6, 6, '2024-06-01', '13:00:00', 'Booked'),
(7, 7, 7, '2024-06-05', '08:45:00', 'Arrived'),
(8, 8, 8, '2024-06-10', '15:10:00', 'Checked Out'),
(9, 9, 9, '2024-06-15', '10:20:00', 'Cancelled'),
(10,10,10,'2024-06-20', '12:45:00', 'Arrived'),

(1, 1, 1, '2025-01-05', '08:30:00', 'Arrived'),
(2, 2, 2, '2025-01-10', '14:00:00', 'Checked Out'),
(3, 3, 3, '2025-01-15', '09:45:00', 'Cancelled'),
(4, 4, 4, '2025-01-20', '11:15:00', 'LWT'),
(5, 5, 5, '2025-01-25', '16:30:00', 'No-Show'),
(6, 6, 6, '2025-02-01', '10:00:00', 'Booked'),
(7, 7, 7, '2025-02-05', '13:20:00', 'LWT'),
(8, 8, 8, '2025-02-10', '15:45:00', 'Checked Out'),
(9, 9, 9, '2025-02-15', '08:15:00', 'Cancelled'),
(10,10,10,'2025-02-20', '12:00:00', 'Arrived'),
(1, 1, 1, '2025-03-05', '09:30:00', 'Checked Out'),
(2, 2, 2, '2025-03-10', '14:45:00', 'Checked Out'),
(3, 3, 3, '2025-03-15', '11:10:00', 'Cancelled'),
(4, 4, 4, '2025-03-20', '16:00:00', 'LWT'),
(5, 5, 5, '2025-03-25', '10:30:00', 'No-Show'),
(6, 6, 6, '2025-04-01', '08:00:00', 'Booked'),
(7, 7, 7, '2025-04-05', '13:15:00', 'Arrived'),
(8, 8, 8, '2025-04-10', '15:30:00', 'Checked Out'),
(9, 9, 9, '2025-04-15', '09:45:00', 'Cancelled'),
(10,10,10,'2025-04-20', '12:20:00', 'No-Show');


;
INSERT INTO Visits (PatientID, Checkin_Time, Checkout_Time, Symptoms, Diagnosis, Treatment, AppointmentID) VALUES
(1, '2023-01-05 08:25:00', '2023-01-05 09:00:00', 'Fatigue',             'Vitamin D deficiency', 'Supplements',                 1),
(2, '2023-01-10 13:55:00', '2023-01-10 14:30:00', 'Chest pain',          'Acid reflux',          'Antacids',                    2),
(4, '2023-01-20 11:10:00', '2023-01-20 11:45:00', 'Fever, cough',        'Viral infection',      'Rest and fluids',             4),
(7, '2023-02-05 13:15:00', '2023-02-05 13:50:00', 'Rash',                'Allergic reaction',    'Antihistamines',              7),
(10,'2023-02-20 11:55:00', '2023-02-20 12:30:00', 'Joint pain',          'Arthritis',            'NSAIDs',                      10),
(3, '2023-03-05 09:25:00', '2023-03-05 10:00:00', 'Headache',            'Migraine',             'Triptans',                    11),
(5, '2023-03-10 13:55:00', '2023-03-10 14:30:00', 'Shortness of breath', 'Asthma',               'Inhaler',                     12),
(6, '2023-04-01 08:45:00', '2023-04-01 09:20:00', 'Sore throat',         'Strep throat',         'Antibiotics',                 13),
(8, '2023-04-10 14:10:00', '2023-04-10 14:45:00', 'Fatigue',             'Anemia',               'Iron supplements',            14),
(9, '2023-05-05 10:25:00', '2023-05-05 11:00:00', 'Rash',                'Eczema',               'Topical steroids',            15),
(1, '2023-05-10 14:25:00', '2023-05-10 15:00:00', 'Back pain',           'Muscle strain',        'Physical therapy',            16),
(2, '2023-06-01 10:45:00', '2023-06-01 11:20:00', 'Dizziness',           'Dehydration',          'IV fluids',                   17),
(3, '2023-06-15 08:30:00', '2023-06-15 09:05:00', 'Abdominal pain',      'Gastritis',            'Antacids',                    18),
(4, '2023-07-07 13:10:00', '2023-07-07 13:45:00', 'Ear pain',            'Ear infection',        'Antibiotics',                 19),
(5, '2023-07-20 09:50:00', '2023-07-20 10:25:00', 'Blurred vision',      'Myopia',               'Eye exam',                    20),
(6, '2023-08-05 11:15:00', '2023-08-05 11:50:00', 'Nausea',              'Food poisoning',       'Anti-nausea meds',            21),
(7, '2023-08-18 15:00:00', '2023-08-18 15:35:00', 'Knee swelling',       'Sprain',               'RICE protocol',               22),
(8, '2023-09-02 10:10:00', '2023-09-02 10:45:00', 'Insomnia',            'Stress',               'Sleep hygiene counseling',    23),
(9, '2023-09-14 14:50:00', '2023-09-14 15:25:00', 'Sinus pressure',      'Sinusitis',            'Decongestants',               24),
(10, '2023-10-01 08:20:00','2023-10-01 08:55:00', 'Toothache',           'Dental caries',        'Dental referral',             25),
(1, '2023-10-15 12:30:00', '2023-10-15 13:05:00', 'Palpitations',        'Anxiety',              'CBT referral',                26),
(2, '2023-11-05 09:40:00', '2023-11-05 10:15:00', 'Constipation',        'Dietary imbalance',    'Fiber supplements',           27),
(3, '2023-11-20 16:00:00', '2023-11-20 16:35:00', 'Wheezing',            'Bronchitis',           'Bronchodilators',             28),
(4, '2023-12-10 11:50:00', '2023-12-10 12:25:00', 'Swollen ankle',       'Sprain',               'Compression bandage',         29),
(5, '2023-12-20 12:15:00', '2023-12-20 12:50:00', 'Chest pain',          'GERD',                 'PPIs',                        30);


INSERT INTO Patient_Vitals (VisitsID, NurseID, Weight, Height, BloodPressure, Temperature) VALUES
(1,  1,  70.0, 1.75, '120/80', 36.6),
(2,  2,  85.0, 1.80, '130/85', 36.8),
(3,  4,  60.0, 1.65, '118/75', 38.2),
(4,  7,  55.0, 1.60, '110/70', 37.1),
(5,  10, 90.0, 1.85, '140/90', 36.5),
(6,  3,  68.0, 1.72, '125/82', 36.7),
(7,  4,  90.5, 1.88, '135/88', 37.0),
(8,  5,  55.0, 1.60, '118/76', 38.1),
(9,  6,  72.0, 1.70, '122/78', 36.9),
(10, 7,  88.0, 1.82, '138/85', 37.2),
(11, 8,  63.0, 1.63, '115/75', 37.5),
(12, 9,  95.0, 1.90, '142/92', 36.8),
(13, 10, 58.0, 1.58, '116/74', 38.0),
(14, 1,  67.0, 1.68, '124/80', 36.6),
(15, 2,  82.0, 1.78, '128/84', 37.1),
(16, 3,  53.0, 1.55, '112/70', 38.3),
(17, 4,  89.0, 1.83, '136/88', 36.7),
(18, 5,  61.0, 1.62, '117/76', 37.8),
(19, 6,  73.0, 1.71, '123/79', 36.5),
(20, 7,  87.0, 1.81, '137/86', 37.3),
(21, 8,  64.0, 1.64, '114/74', 37.6),
(22, 9,  94.0, 1.89, '141/91', 36.9),
(23, 10, 57.0, 1.57, '115/73', 38.4),
(24, 1,  66.0, 1.67, '123/79', 36.7),
(25, 2,  81.0, 1.77, '127/83', 37.0),
(26, 3,  52.0, 1.54, '111/69', 38.5),
(27, 4,  88.0, 1.82, '135/87', 36.8),
(28, 5,  60.0, 1.61, '116/75', 37.9),
(29, 6,  72.0, 1.70, '122/78', 36.6),
(30, 7,  86.0, 1.80, '136/85', 37.4);

-- Tests
INSERT INTO DiagnosticTest (VisitID, DoctorID, TestName, ClinicalNotes) VALUES
(1,  1,  'Blood Panel',             'Check vitamin levels'),
(2,  2,  'ECG',                     'Rule out cardiac issues'),
(3,  4,  'Throat Swab',             'Test for strep throat'),
(4,  7,  'Allergy Panel',           'Identify allergens'),
(5,  10, 'X-Ray',                   'Assess joint inflammation'),
(6,  2,  'Neurological Exam',       'Assess migraine triggers'),
(7,  3,  'Spirometry',              'Evaluate lung function'),
(8,  4,  'Rapid Strep Test',        'Confirm streptococcus'),
(9,  5,  'CBC',                     'Check hemoglobin levels'),
(10, 6,  'Skin Scrape',             'Test for eczema'),
(11, 7,  'MRI',                     'Assess back injury'),
(12, 8,  'Blood Glucose Test',      'Check for hypoglycemia'),
(13, 9,  'Stool Test',              'Rule out infection'),
(14, 10, 'CT Scan',                 'Evaluate sinus blockage'),
(15, 1,  'Dental X-Ray',            'Check for cavities'),
(16, 2,  'Holter Monitor',          'Assess heart rhythm'),
(17, 3,  'Colonoscopy',             'Evaluate GI tract'),
(18, 4,  'Pulmonary Function Test', 'Assess bronchitis'),
(19, 5,  'Ultrasound',              'Check ankle ligaments'),
(20, 6,  'Endoscopy',               'Check esophageal damage'),
(21, 7,  'Vitamin B12 Test',        'Evaluate deficiency'),
(22, 8,  'Stress Test',             'Assess cardiac health'),
(23, 9,  'Urinalysis',              'Check for UTI'),
(24, 10, 'EKG',                     'Rule out arrhythmia'),
(25, 1,  'Thyroid Panel',           'Check hormone levels'),
(26, 2,  'Liver Function Test',     'Assess enzyme levels'),
(27, 3,  'Bone Density Scan',       'Check for osteoporosis'),
(28, 4,  'Allergy Skin Test',       'Identify triggers'),
(29, 5,  'Echocardiogram',          'Evaluate heart function'),
(30, 6,  'Biopsy',                  'Rule out malignancy');

INSERT INTO TestResult (TestID, NurseID, Findings) VALUES
(1,  1,  'Low Vitamin D (20 ng/mL)'),
(2,  2,  'Normal sinus rhythm'),
(3,  4,  'Negative for Group A Strep'),
(4,  7,  'Pollen allergy detected'),
(5,  10, 'Mild osteoarthritis'),
(6,  3,  'No abnormalities detected'),
(7,  4,  'Reduced FEV1/FVC ratio'),
(8,  5,  'Positive for Group A Strep'),
(9,  6,  'Hemoglobin: 10.2 g/dL'),
(10, 7,  'Eczema confirmed'),
(11, 8,  'Herniated disc L4-L5'),
(12, 9,  'Blood glucose: 85 mg/dL'),
(13, 10, 'Negative for pathogens'),
(14, 1,  'Severe sinus blockage'),
(15, 2,  'Cavity in molar #3'),
(16, 3,  'No arrhythmia detected'),
(17, 4,  'Mild colitis'),
(18, 5,  'Airway obstruction present'),
(19, 6,  'Ligament tear'),
(20, 7,  'Esophagitis Grade A'),
(21, 8,  'Vitamin B12: 150 pg/mL'),
(22, 9,  'Normal cardiac stress response'),
(23, 10, 'UTI confirmed'),
(24, 1,  'Sinus tachycardia'),
(25, 2,  'TSH: 4.5 mIU/L'),
(26, 3,  'Elevated ALT: 80 U/L'),
(27, 4,  'Osteopenia detected'),
(28, 5,  'Dust mite allergy'),
(29, 6,  'Ejection fraction: 55%'),
(30, 7,  'Benign lesion');

-- Prescriptions
INSERT INTO Prescription (VisitsID, DoctorID, ResultID, MedicineName, Dosage) VALUES
(1,  1,  1,  'Vitamin D3',              '2000 IU daily'),
(2,  2,  2,  'Omeprazole',              '20mg daily'),
(3,  4,  3,  'Acetaminophen',           '500mg every 6 hours'),
(4,  7,  4,  'Cetirizine',              '10mg daily'),
(5,  10, 5,  'Ibuprofen',               '400mg every 8 hours'),
(6,  2,  6,  'Sumatriptan',             '50mg as needed'),
(7,  3,  7,  'Albuterol',               '2 puffs every 4 hours'),
(8,  4,  8,  'Amoxicillin',             '500mg 3x/day'),
(9,  5,  9,  'Ferrous Sulfate',         '325mg daily'),
(10, 6,  10, 'Hydrocortisone Cream',    'Apply 2x/day'),
(11, 7,  11, 'Naproxen',                '500mg twice daily'),
(12, 8,  12, 'Dextrose Gel',            '15g as needed'),
(13, 9,  13, 'Loperamide',              '4mg initially, then 2mg after loose stool'),
(14, 10, 14, 'Fluticasone Spray',       '2 sprays/nostril daily'),
(15, 1,  15, 'Amoxicillin-Clavulanate', '875mg/125mg twice daily'),
(16, 2,  16, 'Sertraline',              '50mg daily'),
(17, 3,  17, 'Mesalamine',              '1.2g 3x/day'),
(18, 4,  18, 'Prednisone',              '40mg daily for 5 days'),
(19, 5,  19, 'Ace Bandage',             'Wear daily for 2 weeks'),
(20, 6,  20, 'Esomeprazole',            '40mg daily'),
(21, 7,  21, 'Vitamin B12 Injection',   '1000mcg weekly'),
(22, 8,  22, 'Metoprolol',              '25mg daily'),
(23, 9,  23, 'Nitrofurantoin',          '100mg twice daily'),
(24, 10, 24, 'Propranolol',             '10mg as needed'),
(25, 1,  25, 'Levothyroxine',           '50mcg daily'),
(26, 2,  26, 'Ursodiol',                '300mg twice daily'),
(27, 3,  27, 'Calcium + Vitamin D',     '1000mg/800IU daily'),
(28, 4,  28, 'Loratadine',              '10mg daily'),
(29, 5,  29, 'Lisinopril',              '10mg daily'),
(30, 6,  30, 'Topical Retinoid',        'Apply nightly');



INSERT INTO Shift (ShiftType, StartTime, EndTime)
VALUES
-- 2023
('Morning', '2023-01-05 07:00:00', '2023-01-05 14:00:00'),
('Evening', '2023-01-05 14:00:00', '2023-01-05 20:00:00'),
('Morning', '2023-02-10 07:00:00', '2023-02-10 14:00:00'),
('Evening', '2023-02-10 14:00:00', '2023-02-10 20:00:00'),
('Morning', '2023-03-15 07:00:00', '2023-03-15 14:00:00'),
('Evening', '2023-03-15 14:00:00', '2023-03-15 20:00:00'),
('Morning', '2023-04-20 07:00:00', '2023-04-20 14:00:00'),
('Evening', '2023-04-20 14:00:00', '2023-04-20 20:00:00'),
('Morning', '2023-05-25 07:00:00', '2023-05-25 14:00:00'),
('Evening', '2023-05-25 14:00:00', '2023-05-25 20:00:00'),
('Morning', '2023-06-30 07:00:00', '2023-06-30 14:00:00'),
('Evening', '2023-06-30 14:00:00', '2023-06-30 20:00:00'),
('Morning', '2023-07-05 07:00:00', '2023-07-05 14:00:00'),
('Evening', '2023-07-05 14:00:00', '2023-07-05 20:00:00'),
('Morning', '2023-08-10 07:00:00', '2023-08-10 14:00:00'),
('Evening', '2023-08-10 14:00:00', '2023-08-10 20:00:00'),
('Morning', '2023-09-15 07:00:00', '2023-09-15 14:00:00'),
('Evening', '2023-09-15 14:00:00', '2023-09-15 20:00:00'),
('Morning', '2023-10-20 07:00:00', '2023-10-20 14:00:00'),
('Evening', '2023-10-20 14:00:00', '2023-10-20 20:00:00'),

-- 2024
('Morning', '2024-01-05 07:00:00', '2024-01-05 14:00:00'),
('Evening', '2024-01-05 14:00:00', '2024-01-05 20:00:00'),
('Morning', '2024-02-10 07:00:00', '2024-02-10 14:00:00'),
('Evening', '2024-02-10 14:00:00', '2024-02-10 20:00:00'),
('Morning', '2024-03-15 07:00:00', '2024-03-15 14:00:00'),
('Evening', '2024-03-15 14:00:00', '2024-03-15 20:00:00'),
('Morning', '2024-04-20 07:00:00', '2024-04-20 14:00:00'),
('Evening', '2024-04-20 14:00:00', '2024-04-20 20:00:00'),
('Morning', '2024-05-25 07:00:00', '2024-05-25 14:00:00'),
('Evening', '2024-05-25 14:00:00', '2024-05-25 20:00:00'),
('Morning', '2024-06-30 07:00:00', '2024-06-30 14:00:00'),
('Evening', '2024-06-30 14:00:00', '2024-06-30 20:00:00'),
('Morning', '2024-07-05 07:00:00', '2024-07-05 14:00:00'),
('Evening', '2024-07-05 14:00:00', '2024-07-05 20:00:00'),
('Morning', '2024-08-10 07:00:00', '2024-08-10 14:00:00'),
('Evening', '2024-08-10 14:00:00', '2024-08-10 20:00:00'),
('Morning', '2024-09-15 07:00:00', '2024-09-15 14:00:00'),
('Evening', '2024-09-15 14:00:00', '2024-09-15 20:00:00'),
('Morning', '2024-10-20 07:00:00', '2024-10-20 14:00:00'),
('Evening', '2024-10-20 14:00:00', '2024-10-20 20:00:00'),

-- 2025
('Morning', '2025-01-05 07:00:00', '2025-01-05 14:00:00'),
('Evening', '2025-01-05 14:00:00', '2025-01-05 20:00:00');




INSERT INTO Fee (PatientID, DoctorID, FeeDate, ServiceName, Amount)
VALUES
-- 2023 Fees
(1,  1,  '2023-01-15 09:30:00', 'Annual Physical Exam',           150.00),
(2,  2,  '2023-02-02 14:15:00', 'Vaccination - Flu Shot',         45.00),
(3,  3,  '2023-03-10 10:00:00', 'X-Ray - Chest',                  220.00),
(4,  4,  '2023-04-22 11:45:00', 'Blood Work Panel',               89.50),
(5,  5,  '2023-05-05 08:30:00', 'MRI Scan',                       475.00),
(6,  6,  '2023-06-18 13:20:00', 'Allergy Testing',                285.00),
(7,  7,  '2023-07-01 15:00:00', 'ECG Heart Test',                 325.00),
(8,  8,  '2023-08-09 10:45:00', 'Dermatology Consultation',       175.00),
(9,  9,  '2023-09-12 09:15:00', 'Vaccination - Tetanus',          55.00),
(10, 10, '2023-10-25 16:30:00', 'Ultrasound Abdomen',             410.00),
(1,  1,  '2023-11-07 14:00:00', 'Follow-up Consultation',         95.00),
(2,  2,  '2023-12-14 11:10:00', 'Pulmonary Function Test',        275.00),
(3,  3,  '2023-01-30 08:45:00', 'Chiropractic Adjustment',        125.00),
(4,  4,  '2023-02-14 10:30:00', 'Vitamin B12 Injection',          35.00),
(5,  5,  '2023-03-22 13:45:00', 'Colonoscopy',                    850.00),
(6,  6,  '2023-04-05 15:20:00', 'Physical Therapy Session',       110.00),
(7,  7,  '2023-05-19 09:00:00', 'Mammogram Screening',            240.00),
(8,  8,  '2023-06-27 14:50:00', 'Mental Health Consultation',     195.00),
(9,  9,  '2023-07-11 16:15:00', 'Diabetes Management',            155.00),
(10, 10, '2023-08-03 11:30:00', 'CT Scan Head',                   525.00),
(1,  1,  '2023-09-28 10:00:00', 'Hearing Test',                   85.00),
(2,  2,  '2023-10-19 13:10:00', 'Vaccination - COVID Booster',    0.00),
(3,  3,  '2023-11-09 15:45:00', 'Sleep Study',                    695.00),
(4,  4,  '2023-12-21 08:20:00', 'Nutrition Counseling',           120.00),
(5,  5,  '2023-01-07 14:30:00', 'Wart Removal',                   75.00),
(6,  6,  '2023-02-28 09:50:00', 'EKG Test',                       185.00),
(7,  7,  '2023-03-15 16:00:00', 'Allergy Shots',                  65.00),
(8,  8,  '2023-04-18 11:15:00', 'Vision Screening',               45.00),
(9,  9,  '2023-05-23 13:30:00', 'Pap Smear',                      135.00),
(10, 10, '2023-06-06 10:10:00', 'Bone Density Scan',              395.00),

-- 2024 Fees
(1, 2,  '2024-01-18 08:45:00', 'Annual Physical Exam',            155.00),
(2, 3,  '2024-02-05 14:20:00', 'Vaccination - Shingles',          185.00),
(3, 4,  '2024-03-12 10:30:00', 'X-Ray - Ankle',                   210.00),
(4, 5,  '2024-04-19 11:15:00', 'Advanced Blood Panel',            145.00),
(5, 6,  '2024-05-08 09:00:00', 'MRI - Spinal',                    525.00),
(6, 7,  '2024-06-25 13:45:00', 'Food Allergy Test',               295.00),
(7, 8,  '2024-07-03 15:30:00', 'Stress Test',                     350.00),
(8, 9,  '2024-08-14 10:10:00', 'Skin Cancer Screening',           165.00),
(9, 10, '2024-09-19 09:45:00', 'Vaccination - Pneumonia',         85.00),
(10,1,  '2024-10-28 16:00:00', 'Ultrasound Thyroid',              395.00),
(1, 2,  '2024-11-06 14:15:00', 'Chronic Pain Consultation',       125.00),
(2, 3,  '2024-12-11 11:25:00', 'Lung Capacity Test',              285.00),
(3, 4,  '2024-01-29 08:30:00', 'Massage Therapy',                 95.00),
(4, 5,  '2024-02-13 10:45:00', 'Iron Infusion',                   225.00),
(5, 6,  '2024-03-20 13:20:00', 'Endoscopy',                       795.00),
(6, 7,  '2024-04-09 15:00:00', 'Post-Op Therapy',                 135.00),
(7, 8,  '2024-05-21 09:30:00', 'Breast Ultrasound',               265.00),
(8, 9,  '2024-06-24 14:40:00', 'Psych Evaluation',                250.00),
(9, 10, '2024-07-15 16:20:00', 'Insulin Management',              165.00),
(10,1,  '2024-08-05 11:35:00', 'CT Scan Abdomen',                 575.00),
(1, 2,  '2024-09-30 10:05:00', 'Audiogram',                       90.00),
(2, 3,  '2024-10-17 13:50:00', 'Travel Vaccination',              120.00),
(3, 4,  '2024-11-14 15:15:00', 'Sleep Apnea Study',               725.00),
(4, 5,  '2024-12-19 08:25:00', 'Weight Management',               130.00),
(5, 6,  '2024-01-09 14:45:00', 'Mole Removal',                    85.00),
(6, 7,  '2024-02-27 09:55:00', 'Holter Monitor',                  195.00),
(7, 8,  '2024-03-14 16:10:00', 'Immunotherapy',                   75.00),
(8, 9,  '2024-04-17 11:20:00', 'Glaucoma Test',                   55.00),
(9, 10, '2024-05-25 13:35:00', 'STD Screening',                   145.00),
(10,1,  '2024-06-08 10:15:00', 'DEXA Scan',                       415.00),

-- 2025 Fees
(1,  3,  '2025-01-22 08:50:00', 'Comprehensive Physical',         165.00),
(2,  4,  '2025-02-07 14:25:00', 'Vaccination - HPV',              210.00),
(3,  5,  '2025-03-14 10:35:00', 'X-Ray - Wrist',                  205.00),
(4,  6,  '2025-04-21 11:25:00', 'Hormone Panel',                  155.00),
(5,  7,  '2025-05-12 09:10:00', 'MRI - Brain',                    550.00),
(6,  8,  '2025-06-23 13:55:00', 'Environmental Allergy Test',     315.00),
(7,  9,  '2025-07-05 15:35:00', 'Echocardiogram',                 375.00),
(8,  10, '2025-08-16 10:20:00', 'Psoriasis Treatment',            185.00),
(9,  1,  '2025-09-21 09:55:00', 'Vaccination - MMR',              95.00),
(10, 2,  '2025-10-29 16:10:00', 'Ultrasound Pelvic',              405.00),
(1,  3,  '2025-11-07 14:25:00', 'Pain Management',                135.00),
(2,  4,  '2025-12-12 11:35:00', 'Bronchoscopy',                   895.00),
(3,  5,  '2025-01-30 08:35:00', 'Acupuncture Session',            105.00),
(4,  6,  '2025-02-14 10:55:00', 'Vitamin D Injection',            45.00),
(5,  7,  '2025-03-21 13:25:00', 'Sigmoidoscopy',                  675.00),
(6,  8,  '2025-04-10 15:10:00', 'Rehab Session',                  145.00),
(7,  9,  '2025-05-22 09:40:00', 'Cardiac Ultrasound',             295.00),
(8,  10, '2025-06-25 14:50:00', 'Cognitive Testing',              275.00),
(9,  1,  '2025-07-16 16:30:00', 'Thyroid Management',             175.00),
(10, 2,  '2025-08-06 11:45:00', 'CT Scan Chest',                  595.00),
(1,  3,  '2025-09-29 10:15:00', 'Tinnitus Evaluation',            110.00),
(2,  4,  '2025-10-18 13:55:00', 'Yellow Fever Vaccine',           250.00),
(3,  5,  '2025-11-15 15:25:00', 'CPAP Titration',                 755.00),
(4,  6,  '2025-12-20 08:35:00', 'Dietary Planning',               140.00),
(5,  7,  '2025-01-10 14:55:00', 'Cyst Removal',                   95.00),
(6,  8,  '2025-02-28 09:45:00', 'Event Monitor',                  215.00),
(7,  9,  '2025-03-15 16:20:00', 'Asthma Treatment',               85.00),
(8,  10, '2025-04-18 11:30:00', 'Retinal Scan',                   65.00),
(9,  1,  '2025-05-26 13:45:00', 'Fertility Testing',              355.00),
(10, 2,  '2025-06-09 10:25:00', 'Body Composition Scan',          125.00);



INSERT INTO Referral (VisitID, ReferringDoctorID, SpecialistDoctorID, Notes)
VALUES
    (1,  1, 5,   'Referred to cardiologist for chest pain evaluation.'),
    (2,  2, 8,   'Dermatology referral for persistent rash.'),
    (3,  3, 10,  'Orthopedic consult for chronic knee pain.'),
    (4,  4, 6,   'Neurology referral for recurrent migraines.'),
    (5,  5, 7,   'Gastroenterology consult for suspected IBS.'),
    (6,  1, 9,   'Endocrinology referral for abnormal thyroid levels.'),
    (7,  2, 5,   'Cardiology follow-up for arrhythmia.'),
    (8,  3, 8,   'Dermatology consult for mole biopsy.'),
    (9,  4, 10,  'Orthopedic evaluation for shoulder dislocation.'),
    (10, 5, 6,   'Neurology referral for numbness in extremities.'),
    (11, 1, 7,   'Gastroenterology consult for acid reflux.'),
    (12, 2, 9,   'Endocrinology referral for diabetes management.'),
    (13, 3, 5,   'Cardiology stress test for chest discomfort.'),
    (14, 4, 8,   'Dermatology referral for psoriasis treatment.'),
    (15, 5, 10,  'Orthopedic consult for spinal disc herniation.'),
    (16, 1, 6,   'Neurology referral for seizure evaluation.'),
    (17, 2, 7,   'Gastroenterology consult for ulcerative colitis.'),
    (18, 3, 9,   'Endocrinology referral for adrenal insufficiency.'),
    (19, 4, 5,   'Cardiology referral for hypertension management.'),
    (20, 5, 8,   'Dermatology consult for eczema flare-up.'),
    (21, 1, 10,  'Orthopedic evaluation for fractured wrist.'),
    (22, 2, 6,   'Neurology referral for Parkinson’s monitoring.'),
    (23, 3, 7,   'Gastroenterology consult for liver function tests.'),
    (24, 4, 9,   'Endocrinology referral for hyperthyroidism.'),
    (25, 5, 5,   'Cardiology follow-up for post-MI care.'),
    (26, 1, 8,   'Dermatology referral for acne scarring.'),
    (27, 2, 10,  'Orthopedic consult for torn meniscus.'),
    (28, 3, 6,   'Neurology referral for peripheral neuropathy.'),
    (29, 4, 7,   'Gastroenterology consult for colonoscopy follow-up.'),
    (30, 5, 9,   'Endocrinology referral for osteoporosis screening.');































































