IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'acerta_db')
BEGIN
	CREATE DATABASE acerta_db;
END;
GO
USE acerta_db;
GO
CREATE TABLE acerta_db.dbo.demo_data (
	measuredAt datetime2(0) NULL,
	signalValue real NULL,
	signalHighLimit real NULL,
	signalLowLimit real NULL,
	modelNumber varchar(50) NULL,
	testResult int NULL,
	color varchar(50) NULL,
	[size] varchar(50) NULL,
	shift int NULL,
	partId varchar(50) NULL,
	station varchar(50) NULL,
	line varchar(50) NULL,
	ingestedAt datetime2(0) NULL,
	signalName varchar(100) NULL,
	recordId varchar(36) NULL
);
GO