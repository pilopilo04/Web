-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 20, 2022 at 07:39 AM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_freelance`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCustomerLevel` (IN `p_customerNumber` INT(11), OUT `p_customerLevel` VARCHAR(10))  BEGIN
    DECLARE creditlim double;

    SELECT creditlimit INTO creditlim
    FROM customers
    WHERE customerNumber = p_customerNumber;

    IF creditlim > 50000 THEN
    SET p_customerLevel = 'PLATINUM';
    ELSEIF (creditlim <= 50000 AND creditlim >= 10000) THEN
        SET p_customerLevel = 'GOLD';
    ELSEIF creditlim < 10000 THEN
        SET p_customerLevel = 'SILVER';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_audittrail` (IN `UserAction` VARCHAR(100), IN `FldName` VARCHAR(100), IN `FormType` VARCHAR(100), IN `NewValue` VARCHAR(250), IN `OldValue` VARCHAR(250), IN `TransactBy` VARCHAR(250))  BEGIN
  
  	 insert into audittrail(ACTION,FLDNAME,FORMTYPE,NEWVALUE,OLDVALUE,TRANSACTBY) values (UserAction,FldName,FormType,NewValue,OldValue,TransactBy);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_employee` (IN `Hold_ID` INT, IN `Name` VARCHAR(100), IN `UserName` VARCHAR(200), IN `Password` VARCHAR(100), IN `UserType` VARCHAR(100), IN `ImageUser` VARCHAR(100), IN `EmployeeID` VARCHAR(100), IN `ContactNumber` VARCHAR(20), IN `Gender` VARCHAR(10), IN `Addr` VARCHAR(1000), IN `EmailAdd` VARCHAR(100), IN `InCase_Name` VARCHAR(200), IN `InCase_Addr` VARCHAR(1000), IN `InCase_Contact` VARCHAR(50), IN `RecoveryQuestion` VARCHAR(250), IN `RecoveryAnswer` VARCHAR(200), IN `TransactBy` VARCHAR(200), IN `EmpType` VARCHAR(200), IN `VacationLeave` INT, IN `SickLeave` INT, IN `MaternityLeave` INT, IN `PaternityLeave` INT, IN `ReportingID` INT)  BEGIN
	IF Hold_ID <> 0 THEN
    	update employee set ImageUser = ImageUser ,Name=Name 					,UserName=UserName,Password=Password,UserType=UserType,EmployeeID=EmployeeID,ContactNumber=ContactNumber,Gender=Gender,Addr=Addr,EmailAdd=EmailAdd,InCase_Name=InCase_Name
        ,InCase_Contact=InCase_Contact,InCase_Addr=InCase_Addr,RecoveryQuestion=RecoveryQuestion,RecoveryAnswer=RecoveryAnswer
  where ID = Hold_ID;
   
    ELSE
    	insert into employee(ImageUser,Name,UserName,Password,UserType,EmployeeID,ContactNumber,Gender,Addr,EmailAdd,InCase_Name,InCase_Contact,InCase_Addr,RecoveryQuestion,RecoveryAnswer,EmpType,VacationLeave,SickLeave,MaternityLeave,PaternityLeave,ReportingID) 
 values(ImageUser,Name,UserName,Password,UserType,EmployeeID,ContactNumber,Gender,Addr,EmailAdd,InCase_Name,InCase_Contact,InCase_Addr,RecoveryQuestion,RecoveryAnswer,EmpType,VacationLeave,SickLeave,MaternityLeave,PaternityLeave,ReportingID);
                             
   		call sp_save_audittrail('INSERT','Name','EMPLOYEE',Name,'--',TransactBy);
        call sp_save_audittrail('INSERT','Username','EMPLOYEE',UserName,'--',TransactBy);
   		call sp_save_audittrail('INSERT','Password','EMPLOYEE',Password,'--',TransactBy);
        call sp_save_audittrail('INSERT','User Type','EMPLOYEE',UserType,'--',TransactBy);
        call sp_save_audittrail('INSERT','Email Employee ID','EMPLOYEE',EmployeeID,'--',TransactBy);
        call sp_save_audittrail('INSERT','Contact Number','EMPLOYEE',ContactNumber,'--',TransactBy);
        call sp_save_audittrail('INSERT','Gender','EMPLOYEE',Gender,'--',TransactBy);
        call sp_save_audittrail('INSERT','Address','EMPLOYEE',Addr,'--',TransactBy);
        call sp_save_audittrail('INSERT','Email Address','EMPLOYEE',EmailAdd,'--',TransactBy);
        call sp_save_audittrail('INSERT','In-Case Emergency : Name','EMPLOYEE',InCase_Name,'--',TransactBy);
        call sp_save_audittrail('INSERT','In-Case Emergency : Contact','EMPLOYEE',InCase_Contact,'--',TransactBy);
        call sp_save_audittrail('INSERT','In-Case Emergency : Address','EMPLOYEE',InCase_Addr,'--',TransactBy);
        call sp_save_audittrail('INSERT','Recovery Answer','EMPLOYEE',RecoveryAnswer,'--',TransactBy);
   		
        call sp_save_audittrail('INSERT','Employee Type','EMPLOYEE',EmpType,'--',TransactBy);
        call sp_save_audittrail('INSERT','Vacation Leave','EMPLOYEE',VacationLeave,'--',TransactBy);
        call sp_save_audittrail('INSERT','Sick Leave','EMPLOYEE',SickLeave,'--',TransactBy);
        call sp_save_audittrail('INSERT','Maternity Leave','EMPLOYEE',MaternityLeave,'--',TransactBy);
        call sp_save_audittrail('INSERT','Paternity Leave','EMPLOYEE',PaternityLeave,'--',TransactBy);
        call sp_save_audittrail('INSERT','Reporting ID','EMPLOYEE',ReportingID,'--',TransactBy);

    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_maintenance` (IN `Hold_ID` BIGINT, IN `desc_data` VARCHAR(250), IN `TransactBy` VARCHAR(250), IN `TblName` VARCHAR(250), IN `FldName` VARCHAR(250), IN `FrmName` VARCHAR(250))  BEGIN	
	IF Hold_ID <> 0 THEN
        set @sql_text= concat('update ',TblName, ' set ' ,FldName, ' = ',CHAR(39) ,desc_data, CHAR(39) , ' where ID =', Hold_ID);

     
    ELSE
set @sql_text= concat('insert into ',TblName,'(', FldName , ') values(',CHAR(39), desc_data , CHAR(39), ')');

call sp_save_audittrail('INSERT','Description',FrmName,desc_data,'--',TransactBy);
   
   
    END IF;
select @sql_text;

PREPARE stmt FROM @sql_text;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_select` (IN `Hold_ID` BIGINT, IN `tblName` VARCHAR(250), IN `FldName` VARCHAR(250))  BEGIN

set @sql_text= concat('select ',FldName, ' into ',@Data,'  from ' ,tblName, ' where ID = ',Hold_ID );
PREPARE stmt FROM @sql_text;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT @Data;

    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audittrail`
--

CREATE TABLE `audittrail` (
  `ID` bigint(20) NOT NULL,
  `FormType` varchar(1000) DEFAULT NULL,
  `FldName` varchar(100) DEFAULT NULL,
  `NewValue` varchar(100) DEFAULT NULL,
  `OldValue` varchar(100) DEFAULT NULL,
  `Action` varchar(50) DEFAULT NULL,
  `TransactBy` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `chatmessages`
--

CREATE TABLE `chatmessages` (
  `ID` bigint(20) NOT NULL,
  `From_UserID` varchar(250) DEFAULT NULL,
  `ChatDesc` varchar(1000) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `To_UserID` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `chatmessages`
--

INSERT INTO `chatmessages` (`ID`, `From_UserID`, `ChatDesc`, `timestamp`, `To_UserID`) VALUES
(1, '8', 'Test', '2022-04-29 01:04:54', '1'),
(2, '1', 'reply ko', '2022-04-29 01:04:54', '8'),
(3, ' ', 'adasdad', '2022-05-04 18:21:43', ' '),
(4, '8 ', 'adsasdasdad', '2022-05-04 18:22:13', '1 '),
(5, '1', 'Hello ulit', '2022-05-04 18:33:32', '8'),
(6, '<br />\r\n<b>Warning</b>:  Undefined variable $ActiveID in <b>C:xampphtdocsTHESISmicrotaskingadminfreelance_chat.php</b> on line <b>93</b><br />\r\n ', 'test test test', '2022-05-04 19:46:20', '<br />\r\n<b>Warning</b>:  Undefined variable $F_ID in <b>C:xampphtdocsTHESISmicrotaskingadminfreelance_chat.php</b> on line <b>94</b><br />\r\n '),
(7, '<br />\r\n<b>Warning</b>:  Undefined variable $ActiveID in <b>C:xampphtdocsTHESISmicrotaskingadminfreelance_chat.php</b> on line <b>93</b><br />\r\n ', 'tesssssssssssst', '2022-05-04 19:47:04', '<br />\r\n<b>Warning</b>:  Undefined variable $F_ID in <b>C:xampphtdocsTHESISmicrotaskingadminfreelance_chat.php</b> on line <b>94</b><br />\r\n '),
(8, '1 ', 'tessssssssssssssssst', '2022-05-04 19:47:51', '8 '),
(9, '1 ', 'Hello my friend.', '2022-05-04 19:48:08', '8 '),
(10, '1 ', 'Ui Hello Friend!', '2022-05-04 19:50:09', '8 '),
(11, '1 ', 'Ui Hello Friend!', '2022-05-04 19:50:17', '8 '),
(12, '1 ', 'HELLOOO!!!!', '2022-05-04 19:50:49', '8 '),
(13, '1 ', 'HELLOOO!!!!', '2022-05-04 19:51:05', '8 '),
(14, '1 ', 'HELLOOO!!!!', '2022-05-04 19:51:32', '8 '),
(15, '1 ', 'HELLOOO!!!!', '2022-05-04 19:51:37', '8 '),
(16, '1 ', 'HELLOOO!!!!', '2022-05-04 19:52:17', '8 '),
(17, '8 ', 'YES BROTHER?', '2022-05-04 19:52:36', '1 '),
(18, '8 ', 'HOW ARE YOU?', '2022-05-04 19:53:36', '1 '),
(19, '8 ', 'I AM GOOD SO FAR.', '2022-05-04 19:54:29', '1 '),
(20, '1 ', 'GOOD TO HEAR.', '2022-05-04 19:54:46', '8 '),
(21, '8 ', 'Hi Roy, How are you?', '2022-05-09 23:43:43', '1 '),
(22, '1 ', 'Yeah, I am good so far..', '2022-05-09 23:45:08', '8 '),
(23, '8 ', 'hi philip', '2022-05-12 15:07:46', '2 '),
(24, '8 ', 'Hi,', '2022-05-12 19:56:53', '5 '),
(25, '8 ', 'test', '2022-05-12 20:00:49', '4 '),
(26, '8 ', 'test', '2022-05-18 00:55:57', '1 '),
(27, '8 ', 'tesssst', '2022-05-18 01:05:35', '1 '),
(28, '8 ', 'hi', '2022-05-18 11:55:22', '3 '),
(29, '1 ', 'test', '2022-05-20 00:43:50', '1 '),
(30, '1 ', 'test data only', '2022-05-20 00:44:19', '1 '),
(31, '1 ', 'test data', '2022-05-20 00:45:33', '1 '),
(32, '1 ', 'test data', '2022-05-20 00:45:40', '1 '),
(33, '1 ', 'test data', '2022-05-20 00:45:56', '1 '),
(34, '1 ', 'data ', '2022-05-20 00:46:38', '1 '),
(35, '1 ', 'data ko', '2022-05-20 00:49:26', '8 '),
(36, '1 ', 'oonga', '2022-05-20 00:49:53', '8 '),
(37, '8 ', 'hi', '2022-05-20 01:03:23', '1 '),
(38, '8 ', 'Hi there 05/24/2022', '2022-05-23 16:11:51', '1 '),
(39, '1 ', 'hello :)', '2022-05-23 16:12:51', '8 '),
(40, '8 ', 'hi philip 2', '2022-05-23 16:22:45', '2 '),
(41, '2 ', 'hello', '2022-05-23 16:23:35', '8 '),
(42, '8 ', 'hello reyna', '2022-10-01 14:31:47', '8 '),
(43, '8 ', 'test', '2022-10-01 14:35:42', '1 '),
(44, '8 ', 'hello friend', '2022-10-01 14:54:40', '1 '),
(45, '8 ', 'hello jonathan', '2022-10-01 14:59:45', '4 '),
(46, '4 ', 'hi there', '2022-10-01 15:00:29', '8 ');

-- --------------------------------------------------------

--
-- Table structure for table `clients`
--

CREATE TABLE `clients` (
  `ID` bigint(20) NOT NULL,
  `C_Name` varchar(250) DEFAULT NULL,
  `C_Addr` varchar(250) DEFAULT NULL,
  `C_Contact` varchar(250) DEFAULT NULL,
  `C_Username` varchar(250) DEFAULT NULL,
  `C_Password` varchar(250) DEFAULT NULL,
  `C_EmailAdd` varchar(250) DEFAULT NULL,
  `C_Img` varchar(250) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `C_AuotoNo` varchar(20) DEFAULT NULL,
  `Status_` varchar(250) DEFAULT 'In-Progress',
  `RecoveryQuestion` varchar(250) DEFAULT NULL,
  `RecoveryAnswer` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `clients`
--

INSERT INTO `clients` (`ID`, `C_Name`, `C_Addr`, `C_Contact`, `C_Username`, `C_Password`, `C_EmailAdd`, `C_Img`, `timestamp`, `C_AuotoNo`, `Status_`, `RecoveryQuestion`, `RecoveryAnswer`) VALUES
(8, 'tengtengteng', 'malakas street kamote subdivision novaliches quezon city', '12334', 'test', 'Test12345', '44444@gmail.com', 'sova-avatar.jpg', '2022-03-27 18:41:22', '000001', 'Active', 'NAME OF YOUR FIRST DOG', 'navidog'),
(11, 'Marie Claire Mendoza', NULL, '1234123', 'TEST', 'Freelancer', 'te33st@gmail.com', 'default-avatar.jpg', '2022-04-20 23:49:58', '000012', 'In-Progress', NULL, NULL),
(12, 'CACACA', NULL, '12312', 'CACA', 'CACACACA', 'test@gmail.com', NULL, '2022-04-23 00:51:40', '000013', 'Active', NULL, NULL),
(13, 'tennnnnng', NULL, '12312', 'test', 'test', 'te33st@gmail.com', 'default-avatar.jpg', '2022-04-25 23:46:21', NULL, 'In-Progress', NULL, NULL),
(14, 'qwe', 'qwe', '12312', 'TEWST', '123aseAas', 'stest@gmail.com', 'default-avatar.jpg', '2022-04-26 00:43:05', '000014', 'In-Progress', NULL, NULL),
(15, 'test now', 'test', '12312', 'test123', 'test123456A', 'freelancer@gmail.com', 'default-avatar.jpg', '2022-05-04 20:01:47', '000015', 'Active', NULL, NULL),
(16, 'test', NULL, '1234123', 'test', '', '123@gmail.com', 'default-avatar.jpg', '2022-10-16 15:10:31', NULL, 'In-Progress', NULL, NULL),
(17, 'Marie Claire Mendoza22', NULL, '12312', 'testmarie', 'testmarie', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 15:37:03', NULL, 'In-Progress', NULL, NULL),
(18, 'Marie Claire Mendoza333', NULL, '1234123', 'MARIE3', '', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 16:00:11', NULL, 'In-Progress', NULL, NULL),
(19, 'Marie Claire Mendoza4444', NULL, '12312', 'test', '', 'test@gmail.com', 'default-avatar.jpg', '2022-10-16 16:07:52', NULL, 'For-Approval', NULL, NULL),
(20, 'Marie Claire Mendoza666', NULL, '12312', 'test', '', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 16:08:50', NULL, 'For-Approval', NULL, NULL),
(21, 'Marie Claire Mendoza7', NULL, '12312', 'mariemarie', '', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 16:14:29', NULL, 'For-Approval', NULL, NULL),
(22, 'Marie Claire Mendoza8', NULL, '1234123', 'mariemarie', '', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 16:15:47', NULL, 'For-Approval', NULL, NULL),
(23, 'Marie Claire Mendoza99', NULL, '12312', 'test', 'Password_8', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-16 16:17:19', '000025', 'Active', NULL, NULL),
(24, 'Marie Claire Mendoza 999', NULL, '1234123', 'marie9', 'marie9', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-20 04:32:49', NULL, 'For-Approval', NULL, NULL),
(25, 'marie10', NULL, '12312', 'marie10', 'marie10', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-20 04:39:05', NULL, 'For-Approval', NULL, NULL),
(26, 'Marie Claire Mendoza11', NULL, '1234123', 'marie_1', 'marie_1', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-20 04:46:41', NULL, 'For-Approval', NULL, NULL),
(27, 'Marie Claire Mendoza _ 1', NULL, '1234123', 'MARIE_11', 'MARIE_11', 'justinpaulbernas.lucero@gmail.com', 'default-avatar.jpg', '2022-10-20 04:56:29', '000028', 'Activate', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `clients_freelancerrating`
--

CREATE TABLE `clients_freelancerrating` (
  `ID` bigint(20) NOT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `FreelancerID` int(11) DEFAULT NULL,
  `RateDesc` varchar(1000) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `RateScore` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `clients_freelancerrating`
--

INSERT INTO `clients_freelancerrating` (`ID`, `ClientID`, `FreelancerID`, `RateDesc`, `timestamp`, `RateScore`) VALUES
(1, 8, 1, 'It was really amazing to work with him, He is a highly understanding human being. Looking forward to future projects.', '2022-04-04 21:46:22', 4),
(2, 8, 1, 'asd', '2022-04-04 22:04:02', 4),
(3, 8, 1, 'ssdfsd', '2022-04-04 22:04:25', 5),
(4, 8, 1, 'test', '2022-05-17 20:44:47', 1),
(5, 8, 1, 'test', '2022-05-17 23:48:25', 4),
(6, 8, 1, 'testsssssssssssss', '2022-05-17 23:49:55', 3),
(7, 8, 1, 'testsssssssssssss', '2022-05-17 23:50:18', 3),
(8, 8, 1, 'testsssssssssssss', '2022-05-17 23:52:15', 3),
(9, 8, 1, 'testsssssssssssss', '2022-05-17 23:52:50', 3),
(10, 8, 1, 'asdasd', '2022-05-17 23:53:13', 2),
(11, 8, 1, 'sdadasdadsasdxc', '2022-05-17 23:54:03', 1),
(12, 8, 1, 'ASAsS', '2022-05-17 23:54:16', 2);

-- --------------------------------------------------------

--
-- Table structure for table `client_projectinvited`
--

CREATE TABLE `client_projectinvited` (
  `ID` bigint(20) NOT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `FreelancerID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `client_projectinvited`
--

INSERT INTO `client_projectinvited` (`ID`, `ClientID`, `FreelancerID`, `timestamp`) VALUES
(3, 8, 4, '2022-04-05 05:46:48'),
(4, 10, 1, '2022-04-06 09:41:24'),
(5, 10, 3, '2022-04-06 09:41:41'),
(6, 8, 7, '2022-04-06 20:05:35'),
(7, 8, 7, '2022-04-06 20:05:36'),
(8, 8, 7, '2022-04-06 20:05:52'),
(9, 8, 1, '2022-04-08 10:41:32'),
(12, 8, 5, '2022-04-23 00:23:44'),
(13, 8, 2, '2022-05-12 17:33:45'),
(15, 8, 1, '2022-08-24 09:19:38'),
(16, 8, 1, '2022-08-24 09:29:38'),
(17, 8, 1, '2022-09-01 06:33:02'),
(18, 8, 2, '2022-09-12 02:14:59'),
(19, 8, 1, '2022-09-12 02:16:29'),
(20, 8, 1, '2022-09-12 02:24:20'),
(21, 8, 6, '2022-10-13 21:34:10');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `ID` bigint(20) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `UserName` varchar(100) DEFAULT NULL,
  `Password` varchar(100) DEFAULT NULL,
  `UserType` varchar(100) DEFAULT NULL,
  `ImageUser` varchar(100) DEFAULT NULL,
  `EmployeeID` varchar(100) DEFAULT NULL,
  `ContactNumber` varchar(20) DEFAULT NULL,
  `Gender` varchar(10) DEFAULT NULL,
  `Addr` varchar(1000) DEFAULT NULL,
  `EmailAdd` varchar(250) DEFAULT NULL,
  `InCase_Name` varchar(250) DEFAULT NULL,
  `InCase_Addr` varchar(1000) DEFAULT NULL,
  `InCase_Contact` varchar(50) DEFAULT NULL,
  `RecoveryQuestion` varchar(250) NOT NULL,
  `RecoveryAnswer` varchar(250) NOT NULL,
  `Timestamp` timestamp NULL DEFAULT NULL,
  `EmpType` varchar(200) DEFAULT NULL,
  `VacationLeave` int(11) DEFAULT NULL,
  `SickLeave` int(11) DEFAULT NULL,
  `MaternityLeave` int(11) DEFAULT NULL,
  `PaternityLeave` int(11) DEFAULT NULL,
  `ReportingID` int(11) DEFAULT NULL,
  `TimeFlag` varchar(50) DEFAULT NULL,
  `Status_` varchar(250) NOT NULL DEFAULT 'Activate'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`ID`, `Name`, `UserName`, `Password`, `UserType`, `ImageUser`, `EmployeeID`, `ContactNumber`, `Gender`, `Addr`, `EmailAdd`, `InCase_Name`, `InCase_Addr`, `InCase_Contact`, `RecoveryQuestion`, `RecoveryAnswer`, `Timestamp`, `EmpType`, `VacationLeave`, `SickLeave`, `MaternityLeave`, `PaternityLeave`, `ReportingID`, `TimeFlag`, `Status_`) VALUES
(1, 'Juan Dela Cruzz', 'admin', 'admin', 'Administrator', 'sova-avatar.jpg', '0000001', '10906771278', 'Male', '1Novaliches Quezon City', '1asd.lucero@gmail.com', 'Juanoto Dela Cruz1', '09123245011', '09123145345', 'What is your first pet name', 'blue', NULL, 'Regular', -1, 12, NULL, NULL, 0, 'OUT', 'Activate'),
(16, 'Roy Rayos', 'roy', 'royrayos', 'Administrator', 'jett.jfif', '000005', '12345678901', 'Male', 'Novaliches Quezon City', 'test@gmail.com', 'Royroy Rayos', 'Novaliches Quezon City', '12345678901', 'NAME OF YOUR FIRST DOG', 'NAVIDOG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Activate'),
(19, 'test', 'test', 'testTest123', 'Administrator', 'simple-coffee-logo-vector-24731410.jpg', '000017', '23123123', 'Male', 'test', 'test@gmail.com', 'test', 'test', '23123', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Active'),
(20, 'asdadada', 'test', 'TESts123123123', 'Co-Admin', '0648e0aec021a8317c7a3600fe3a9a38.jpg', '000020', '1234123', 'Male', 'asdas', 'te33st@gmail.com', '123', '1313adasd', '213123', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Deactivate');

-- --------------------------------------------------------

--
-- Table structure for table `forums`
--

CREATE TABLE `forums` (
  `ID` bigint(20) NOT NULL,
  `Topic_` varchar(1000) DEFAULT NULL,
  `Desc_` varchar(1000) DEFAULT NULL,
  `PostedBy` varchar(500) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `forums`
--

INSERT INTO `forums` (`ID`, `Topic_`, `Desc_`, `PostedBy`, `timestamp`) VALUES
(1, 'TEST TOPIC', 'THIS IS TEST TOPIC DESCRIPTION ONLY', 'Juan Dela Cruz', '2022-05-31 03:29:49'),
(2, 'test topic ulit', 'test data', 'tennnnnng', '2022-05-31 03:52:11'),
(3, 'test topic 3', 'data', 'tennnnnng', '2022-05-31 03:56:43'),
(4, 'test', 'test', '', '2022-07-20 14:36:46'),
(5, 'tesst', 'test', 'Anonymous', '2022-07-20 14:38:21'),
(6, 'hello test october 14, 2022', 'tst description', 'Anonymous', '2022-10-13 21:27:28');

-- --------------------------------------------------------

--
-- Table structure for table `forum_detais`
--

CREATE TABLE `forum_detais` (
  `ID` bigint(20) NOT NULL,
  `PostedBy` varchar(500) DEFAULT NULL,
  `Desc_` varchar(1000) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `ForumID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `forum_detais`
--

INSERT INTO `forum_detais` (`ID`, `PostedBy`, `Desc_`, `timestamp`, `ForumID`) VALUES
(1, 'Teng', 'this is my sample comments', '2022-05-31 04:20:31', 1),
(2, 'tennnnnng', 'test comment', '2022-05-31 04:37:23', 1),
(3, 'tennnnnng', 'OH', '2022-05-31 04:39:40', 3),
(4, 'Juan Dela Cruzz', 'TEST', '2022-05-31 04:40:09', 3),
(5, 'Anonymous', 'test', '2022-07-20 14:04:10', 3),
(6, 'tengtengteng', 'test', '2022-09-14 20:41:04', 5),
(7, 'tengtengteng', 'test', '2022-09-14 20:59:50', 5),
(8, 'Anonymous', 'hi there', '2022-10-13 21:27:42', 6),
(9, 'tengtengteng', 'helllo', '2022-10-13 21:32:30', 6),
(10, 'Roy Rayos', 'hoooooooo', '2022-10-13 21:32:57', 6),
(11, 'Roy Rayos', 'hellooo', '2022-10-20 04:29:59', 6),
(12, 'Anonymous', 'test here anoo', '2022-10-20 04:30:35', 6),
(13, 'Roy Rayos', 'HELLO ROY.', '2022-10-20 04:54:14', 6),
(14, 'Anonymous', 'HI ROY', '2022-10-20 04:55:25', 6);

-- --------------------------------------------------------

--
-- Table structure for table `freelancers`
--

CREATE TABLE `freelancers` (
  `ID` bigint(20) NOT NULL,
  `F_Name` varchar(250) DEFAULT NULL,
  `F_Contact` varchar(50) DEFAULT NULL,
  `F_EmailAddr` varchar(250) DEFAULT NULL,
  `F_Position` varchar(250) DEFAULT NULL,
  `F_About` varchar(250) DEFAULT NULL,
  `F_Skills` varchar(250) DEFAULT NULL,
  `F_WorkExpi` varchar(1000) DEFAULT NULL,
  `F_School` varchar(1000) DEFAULT NULL,
  `F_Img` varchar(250) DEFAULT NULL,
  `F_Port1` varchar(250) DEFAULT NULL,
  `F_Port2` varchar(250) DEFAULT NULL,
  `F_Port3` varchar(250) DEFAULT NULL,
  `F_Category` varchar(250) DEFAULT NULL,
  `F_AutoID` varchar(250) DEFAULT NULL,
  `F_Username` varchar(250) DEFAULT NULL,
  `F_Password` varchar(250) DEFAULT NULL,
  `F_Rate` decimal(10,0) DEFAULT NULL,
  `Status_` varchar(250) DEFAULT 'In-Progress',
  `Govt_1` varchar(250) DEFAULT NULL,
  `Govt_2` varchar(250) DEFAULT NULL,
  `RecoveryQuestion` varchar(250) DEFAULT NULL,
  `RecoveryAnswer` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `freelancers`
--

INSERT INTO `freelancers` (`ID`, `F_Name`, `F_Contact`, `F_EmailAddr`, `F_Position`, `F_About`, `F_Skills`, `F_WorkExpi`, `F_School`, `F_Img`, `F_Port1`, `F_Port2`, `F_Port3`, `F_Category`, `F_AutoID`, `F_Username`, `F_Password`, `F_Rate`, `Status_`, `Govt_1`, `Govt_2`, `RecoveryQuestion`, `RecoveryAnswer`) VALUES
(1, 'Roy Rayos', '09113123841', 'justinpaulbernas.lucero@gmail.com', 'Web Developer', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.1', 'PHP1,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', '* Oracle Company - (2007 to 2010)1\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )1\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'sova-avatar.jpg', NULL, NULL, NULL, 'Programmer', '000001', 'Roy', 'Roy12345', '300001', 'Active', 'aso.jpg', 'aso.jpg', 'NAME OF YOUR FIRST DOG', 'NAVIDOG'),
(2, 'Philip Manreal', '123123123', 'Manreal@gmail.com', 'Associate Full Stack Engineer', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', 'ASP, JAVASCRIPT, ANDROID STUDIO', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'images (1).jfif', NULL, NULL, NULL, 'Digital Arts', '000002', 'MANREAL', 'MANREAL123', '90000', 'Active', NULL, NULL, NULL, ''),
(3, 'Tharance', '123123', 'Tharance@gmail.com', 'Visual Basic Developer', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', 'VB 6.0, VB.NET, JAVA, LARAVEL, RUBY', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'download (1).jfif', NULL, NULL, NULL, 'Voice Over', '000003', 'Tharance', 'Tharance123', '50000', 'Active', NULL, NULL, NULL, ''),
(4, 'Jonathan Lugasan', '123123', 'Lugasan@gmail.com', 'Graphic Artist II', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', 'ADOBE PHOTOSHOP ', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'images (2).jfif', NULL, NULL, NULL, 'Programmer', '000004', 'lugasan', 'lugasan123', '70000', 'Active', NULL, NULL, NULL, ''),
(5, 'Freelancer 1', '123123123', 'freelancer@gmail.com', 'Position Name', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', 'Skill 1, Skill 2, Skill 3, Skill 4', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'skye.jfif', NULL, NULL, NULL, 'Promotions', '000005', 'FREE1', 'FREE1234', '50000', 'Active', NULL, NULL, NULL, ''),
(6, 'Freelancer 2', '1234567', 'freelancer@gmail.com', 'Position Name', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', '1PHP,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'ironman.jfif', NULL, NULL, NULL, 'Digital Arts', '000006', 'free2', 'free1234', '30000', 'Active', NULL, NULL, NULL, ''),
(7, 'Freelancer 3', '1234567', 'freelancer@gmail.com', 'Position Name', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', '1PHP,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'thanos.jfif', NULL, NULL, NULL, 'Data Encoder', '000007', 'free3', 'free1234', '70000', 'Active', NULL, NULL, NULL, ''),
(8, 'Freelancer 4', '1234123', 'freelancer@gmail.com', 'Position Name', 'I am the one who design, create and maintain websites, providing in the process a cohesive and user-friendly online portal for the use of clients, customers, work colleagues and other interested parties.', 'sPHP,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', '* Oracle Company - (2007 to 2010)\r\n* Web developers who can create and maintain attractive and user-friendly websites are in high demand, and those with proven ability have higher earning power, as expected\r\n* Tight deadlines are common when designing or updating websites. Developers need to be able to handle the pressure of having work done when needed.\r\n*\r\n* IBM Solution- (2010 to 2022)\r\n* In addition to the technical skills necessary for the job, there are several soft skills that can be very beneficial to anyone looking for a career as a web developer\r\n* Projects aren’t always handled one at a time, and one client’s emergency sometimes can push another project to the backburner. Web developers need to be able to juggle multiple projects without missing deadlines.', '* Elementary  ( 2000 to 20006 )\r\n* University of Santo Tomas - Manila\r\n*\r\n*  Mid School ( 2006 to 2010)\r\n* University of Santo Tomas - Manila\r\n*\r\n* College ( 2010 to 2014 )\r\n* University of Santo Tomas - Manila\r\n', 'reyna.jfif', NULL, NULL, NULL, 'Voice Over', '000008', 'free4', 'free1234', '70000', 'Active', NULL, NULL, NULL, ''),
(14, 'Roy Rayos', '12312', 'te33st@gmail.com', 'Web Developer', 'test', 'PHP,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', 'test', 'test', 'sova-avatar.jpg', NULL, NULL, NULL, 'Digital Arts', '000018', 'mariemarie', 'frFee1234', '50000', 'Active', 'ID1.png', 'ID1.png', NULL, ''),
(15, 'TENG', '1234123', 'te33st@gmail.com', 'Web Developer', 'ADSA', 'PHP,AJAX,HTML,CSS,JAVASCRIPT,ANGULAR JS', 'ASD', 'ASD', 'sova-avatar.jpg', NULL, NULL, NULL, 'Digital Arts', '000015', 'ASDA', 'freF234f', '70000', 'Active', 'ID1.png', 'ID1.png', NULL, ''),
(17, 'tttttttinggggggggt', '213', 'te33st@gmail.com', NULL, NULL, NULL, NULL, NULL, 'default-avatar.jpg', NULL, NULL, NULL, NULL, NULL, 'test', 'test', NULL, 'In-Progress', NULL, NULL, NULL, ''),
(18, 'teng', '1', 'test@gm', NULL, NULL, NULL, NULL, NULL, 'default-avatar.jpg', NULL, NULL, NULL, NULL, NULL, 'test', 'test', NULL, 'In-Progress', NULL, NULL, NULL, ''),
(19, 'Marie Claire Mendoza', '123456', 'teng@gmail.com', NULL, NULL, NULL, NULL, NULL, 'default-avatar.jpg', NULL, NULL, NULL, NULL, NULL, 'mariemarie', '', NULL, 'In-Progress', NULL, NULL, NULL, ''),
(20, 'Marie Claire Mendoza111', '1234123', 'justinpaulbernas.lucero@gmail.com', NULL, NULL, NULL, NULL, NULL, 'default-avatar.jpg', NULL, NULL, NULL, NULL, NULL, 'mariemarie', '', NULL, 'In-Progress', NULL, NULL, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `freelancers_project`
--

CREATE TABLE `freelancers_project` (
  `ID` bigint(20) NOT NULL,
  `ProjectName` varchar(250) DEFAULT NULL,
  `CompanyName` varchar(250) DEFAULT NULL,
  `DateReleased` varchar(250) DEFAULT NULL,
  `FreeLancer_ID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `ProdImg` varchar(250) DEFAULT NULL,
  `ProjDesc` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `freelancers_project`
--

INSERT INTO `freelancers_project` (`ID`, `ProjectName`, `CompanyName`, `DateReleased`, `FreeLancer_ID`, `timestamp`, `ProdImg`, `ProjDesc`) VALUES
(11, 'Project 2 Name', 'test', '2022-03-18', 1, '2022-03-29 11:38:17', 'aso.jpg', 'MVC\r\nCMV'),
(13, 'Project 1 Name', 'test', '2022-03-31', 1, '2022-04-24 11:25:10', '6-curb-dchaussee-how-to-master-the-cafe-instagram.webp', 'TEST RECORD'),
(16, 'PROJECT 3', '  TEST COMPANY', '2022-10-19', 1, '2022-10-16 15:11:04', 'no-file.png', '  DESCRIPTION RECORD');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_login`
-- (See below for the actual view)
--
CREATE TABLE `vw_login` (
`ID` bigint(20)
,`Name` varchar(250)
,`UserName` varchar(250)
,`Password` varchar(250)
,`UserType` varchar(100)
,`ImageUser` varchar(250)
,`Status_` varchar(250)
,`RecoveryQuestion` varchar(250)
,`RecoveryAnswer` varchar(250)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_login_1`
-- (See below for the actual view)
--
CREATE TABLE `vw_login_1` (
`ID` bigint(20)
,`Name` varchar(250)
,`UserName` varchar(250)
,`Password` varchar(250)
,`UserType` varchar(100)
,`ImageUser` varchar(250)
,`Status_` varchar(250)
,`RecoveryQuestion` varchar(250)
,`RecoveryAnswer` varchar(250)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_login_2`
-- (See below for the actual view)
--
CREATE TABLE `vw_login_2` (
`ID` bigint(20)
,`Name` varchar(250)
,`UserName` varchar(250)
,`Password` varchar(250)
,`UserType` varchar(100)
,`ImageUser` varchar(250)
,`Status_` varchar(250)
,`RecoveryQuestion` varchar(250)
,`RecoveryAnswer` varchar(250)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_login_3`
-- (See below for the actual view)
--
CREATE TABLE `vw_login_3` (
`ID` bigint(20)
,`Name` varchar(250)
,`UserName` varchar(250)
,`Password` varchar(250)
,`UserType` varchar(100)
,`ImageUser` varchar(250)
,`Status_` varchar(250)
,`RecoveryQuestion` varchar(250)
,`RecoveryAnswer` varchar(250)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_login`
--
DROP TABLE IF EXISTS `vw_login`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_login`  AS SELECT `employee`.`ID` AS `ID`, `employee`.`Name` AS `Name`, `employee`.`UserName` AS `UserName`, `employee`.`Password` AS `Password`, `employee`.`UserType` AS `UserType`, `employee`.`ImageUser` AS `ImageUser`, `employee`.`Status_` AS `Status_`, `employee`.`RecoveryQuestion` AS `RecoveryQuestion`, `employee`.`RecoveryAnswer` AS `RecoveryAnswer` FROM `employee` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_login_1`
--
DROP TABLE IF EXISTS `vw_login_1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_login_1`  AS SELECT `employee`.`ID` AS `ID`, `employee`.`Name` AS `Name`, `employee`.`UserName` AS `UserName`, `employee`.`Password` AS `Password`, `employee`.`UserType` AS `UserType`, `employee`.`ImageUser` AS `ImageUser`, `employee`.`Status_` AS `Status_`, `employee`.`RecoveryQuestion` AS `RecoveryQuestion`, `employee`.`RecoveryAnswer` AS `RecoveryAnswer` FROM `employee` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_login_2`
--
DROP TABLE IF EXISTS `vw_login_2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_login_2`  AS SELECT `employee`.`ID` AS `ID`, `employee`.`Name` AS `Name`, `employee`.`UserName` AS `UserName`, `employee`.`Password` AS `Password`, `employee`.`UserType` AS `UserType`, `employee`.`ImageUser` AS `ImageUser`, `employee`.`Status_` AS `Status_`, `employee`.`RecoveryQuestion` AS `RecoveryQuestion`, `employee`.`RecoveryAnswer` AS `RecoveryAnswer` FROM `employee` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_login_3`
--
DROP TABLE IF EXISTS `vw_login_3`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_login_3`  AS SELECT `employee`.`ID` AS `ID`, `employee`.`Name` AS `Name`, `employee`.`UserName` AS `UserName`, `employee`.`Password` AS `Password`, `employee`.`UserType` AS `UserType`, `employee`.`ImageUser` AS `ImageUser`, `employee`.`Status_` AS `Status_`, `employee`.`RecoveryQuestion` AS `RecoveryQuestion`, `employee`.`RecoveryAnswer` AS `RecoveryAnswer` FROM `employee` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audittrail`
--
ALTER TABLE `audittrail`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `chatmessages`
--
ALTER TABLE `chatmessages`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `clients_freelancerrating`
--
ALTER TABLE `clients_freelancerrating`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `client_projectinvited`
--
ALTER TABLE `client_projectinvited`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `forums`
--
ALTER TABLE `forums`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `forum_detais`
--
ALTER TABLE `forum_detais`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `freelancers`
--
ALTER TABLE `freelancers`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `freelancers_project`
--
ALTER TABLE `freelancers_project`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audittrail`
--
ALTER TABLE `audittrail`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=492;

--
-- AUTO_INCREMENT for table `chatmessages`
--
ALTER TABLE `chatmessages`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `clients`
--
ALTER TABLE `clients`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `clients_freelancerrating`
--
ALTER TABLE `clients_freelancerrating`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `client_projectinvited`
--
ALTER TABLE `client_projectinvited`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `forums`
--
ALTER TABLE `forums`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `forum_detais`
--
ALTER TABLE `forum_detais`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `freelancers`
--
ALTER TABLE `freelancers`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `freelancers_project`
--
ALTER TABLE `freelancers_project`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
