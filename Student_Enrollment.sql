-- Step 1: Ensure the database exists and use it
USE master;
IF DB_ID('CollegeDb') IS NULL
    CREATE DATABASE CollegeDb;
GO
USE CollegeDb;
GO

-- Step 2: Drop existing tables in correct order
IF OBJECT_ID('Enrollment', 'U') IS NOT NULL DROP TABLE Enrollment;
IF OBJECT_ID('Course', 'U') IS NOT NULL DROP TABLE Course;
IF OBJECT_ID('Instructor', 'U') IS NOT NULL DROP TABLE Instructor;
IF OBJECT_ID('Student', 'U') IS NOT NULL DROP TABLE Student;
GO

-- Step 3: Create Student table
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Age INT CHECK (Age >= 18)
);
GO

-- Step 4: Create Instructor table
CREATE TABLE Instructor (
    InstructorID INT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL
);
GO

-- Step 5: Create Course table
CREATE TABLE Course (
    CourseID INT PRIMARY KEY,
    CourseTitle VARCHAR(100) NOT NULL,
    InstructorID INT NOT NULL,
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID)
);
GO

-- Step 6: Create Enrollment table
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE DEFAULT GETDATE(),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
GO

-- Step 7: Insert data into Instructor
INSERT INTO Instructor (InstructorID, FullName, Email) VALUES
(1, 'Dr. Smith', 'smith@gmail.com'),
(2, 'Prof. Rajesh', 'rajesh@gmail.com'),
(3, 'Prof. Navneet', 'navneet@gmail.com');
GO

-- Step 8: Insert data into Course
INSERT INTO Course (CourseID, CourseTitle, InstructorID) VALUES
(101, 'Data Science', 1),
(102, 'Computer Applications', 3),
(103, 'C# using .NET', 2);
GO

-- Step 9: Insert data into Student
INSERT INTO Student (StudentID, FullName, Email, Age) VALUES
(1, 'Rohit', 'rohit@ucla.uk', 19),
(2, 'Rashi', 'rashi@ucla.uk', 20),
(4, 'Parth', 'parth@gmail.com', 20),
(5, 'Tushar', 'tushar@gmail.com', 20);
GO

-- Step 10: Insert data into Enrollment
INSERT INTO Enrollment (EnrollmentID, StudentID, CourseID, EnrollmentDate) VALUES
(1001, 1, 101, GETDATE()),
(1002, 4, 101, GETDATE()),
(1003, 5, 102, GETDATE());
GO

-- Step 11: View which student is enrolled in which course
SELECT 
    s.FullName AS StudentName, 
    c.CourseTitle AS Course
FROM 
    Student s
JOIN 
    Enrollment e ON s.StudentID = e.StudentID
JOIN 
    Course c ON e.CourseID = c.CourseID;
GO

-- Step 12: View who is teaching each course
SELECT 
    c.CourseTitle, 
    i.FullName AS InstructorName
FROM 
    Course c
JOIN 
    Instructor i ON c.InstructorID = i.InstructorID;
GO

-- Step 13: Stored procedure to get student info by ID
GO
CREATE OR ALTER PROCEDURE GetStudentInfoById
    @StudentID INT
AS
BEGIN
    SELECT * FROM Student WHERE StudentID = @StudentID;
END;
GO

-- Step 14: Test the procedure
EXEC GetStudentInfoById 4;
GO

-- Step 15: Create login and user for 'auditor' if not already exists
-- Create login at server level
IF NOT EXISTS (
    SELECT * FROM sys.server_principals WHERE name = 'auditor'
)
BEGIN
    CREATE LOGIN auditor1 WITH PASSWORD = 'StrongPassword123!';
END;
GO

-- Create user at database level
USE CollegeDb;
GO
IF NOT EXISTS (
    SELECT * FROM sys.database_principals WHERE name = 'auditor'
)
BEGIN
    CREATE USER auditor FOR LOGIN auditor;
END;
GO

-- Step 16: Grant SELECT permissions to auditor
GRANT SELECT ON Student TO auditor;
GRANT SELECT ON Enrollment TO auditor;
GO

-- Step 17: COMMIT transaction example
BEGIN TRANSACTION;
    INSERT INTO Student (StudentID, FullName, Email, Age)
    VALUES (6, 'Alex', 'alex@hwd.edu', 20);
    
    INSERT INTO Enrollment (EnrollmentID, StudentID, CourseID, EnrollmentDate)
    VALUES (1004, 6, 103, GETDATE());
COMMIT;
GO

-- Step 18: ROLLBACK transaction example
BEGIN TRANSACTION;
    INSERT INTO Student (StudentID, FullName, Email, Age)
    VALUES (7, 'Angel', 'angel@gmail.com', 20);
ROLLBACK;
GO

-- Step 19: Final data check
SELECT * FROM Student;
SELECT * FROM Instructor;
SELECT * FROM Course;
SELECT * FROM Enrollment;
GO
