-- phpMyAdmin SQL Dump
-- version 4.2.12deb2+deb8u3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 27, 2019 at 10:08 AM
-- Server version: 10.0.37-MariaDB-0+deb8u1
-- PHP Version: 5.6.39-0+deb8u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `User4141135325`
--

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
`BanID` int(10) NOT NULL,
  `PlayerName` varchar(24) NOT NULL,
  `BannedBy` varchar(24) NOT NULL,
  `BanReason` varchar(128) NOT NULL,
  `IpAddress` varchar(17) NOT NULL,
  `Date` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `houses`
--

CREATE TABLE IF NOT EXISTS `houses` (
`id` int(11) NOT NULL,
  `OwnerSQL` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(40) NOT NULL DEFAULT 'None',
  `ExtX` float NOT NULL,
  `ExtY` float NOT NULL,
  `ExtZ` float NOT NULL,
  `ExtA` float NOT NULL,
  `IntX` float NOT NULL,
  `IntY` float NOT NULL,
  `IntZ` float NOT NULL,
  `IntA` float NOT NULL,
  `IntID` int(11) NOT NULL,
  `Price` int(11) NOT NULL DEFAULT '10000'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
`id` int(11) NOT NULL,
  `Name` varchar(30) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `RegIP` varchar(20) NOT NULL,
  `RegDate` varchar(16) NOT NULL,
  `AdminLevel` int(11) NOT NULL DEFAULT '0',
  `Helper` int(11) NOT NULL DEFAULT '0',
  `Tester` int(11) NOT NULL DEFAULT '0',
  `Money` int(11) NOT NULL DEFAULT '0',
  `Level` int(11) NOT NULL DEFAULT '1',
  `Respect` int(11) NOT NULL DEFAULT '0',
  `LastX` float NOT NULL DEFAULT '-88.9697',
  `LastY` float NOT NULL DEFAULT '1225.39',
  `LastZ` float NOT NULL DEFAULT '19.7422',
  `LastRot` float NOT NULL DEFAULT '178.881',
  `Interior` int(11) NOT NULL DEFAULT '0',
  `World` int(11) NOT NULL DEFAULT '0',
  `Skin` int(5) NOT NULL DEFAULT '299',
  `Health` float NOT NULL DEFAULT '100',
  `Armour` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `Name`, `Password`, `RegIP`, `RegDate`, `AdminLevel`, `Helper`, `Tester`, `Money`, `Level`, `Respect`, `LastX`, `LastY`, `LastZ`, `LastRot`, `Interior`, `World`, `Skin`, `Health`, `Armour`) VALUES
(1, 'Shady_Collins', '7c4a8d09ca3762af61e59520943dc26494f8941b', '41.47.105.191', '24/01/2019', 4, 0, 0, 0, 2, 0, -957.034, 9333.46, 13.381, 219.551, 0, 0, 303, 100, 48),
(2, 'Ilias_Whey_Dreezy', '4de69ee6b12b7fc91070873b71ba6e2929b90619', '94.65.180.229', '24/01/2019', 0, 0, 0, 0, 1, 0, -116.832, 1208.26, 19.594, 145.925, 0, 0, 299, 100, 0),
(3, 'Mickey_Pacinotti', '94990327a636b8f5b272fd0108edd01a488078b2', '77.85.255.12', '24/01/2019', 0, 0, 0, 0, 1, 0, -94.054, 1214.35, 19.742, 304.758, 0, 0, 299, 100, 0),
(6, 'Veolious', 'da487a201657381efac8da16851cb1b253e25aba', '89.254.147.223', '24/01/2019', 0, 0, 0, 0, 1, 0, -120.074, 1294.31, 19.461, 234.318, 0, 0, 299, 100, 0),
(7, 'Frenkie_De_Jong', '7c4a8d09ca3762af61e59520943dc26494f8941b', '41.47.143.2', '24/01/2019', 0, 0, 0, 0, 1, 0, -253.174, 2222.65, 56.748, 226.901, 0, 0, 299, 100, 0),
(9, 'Test_Test', '7c4a8d09ca3762af61e59520943dc26494f8941b', '41.47.143.2', '24/01/2019', 0, 0, 0, 0, 1, 0, -98.865, 1203.7, 19.742, 140.004, 0, 0, 299, 100, 0),
(10, 'Diaa_Daequan', '30c0a8ee90ac28989058ed777f48be833d5e36ed', '41.43.251.217', '24/01/2019', 0, 0, 0, 0, 1, 0, -959.679, 9382.15, 13.322, 129.922, 0, 0, 299, 100, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bans`
--
ALTER TABLE `bans`
 ADD PRIMARY KEY (`BanID`);

--
-- Indexes for table `houses`
--
ALTER TABLE `houses`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
 ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bans`
--
ALTER TABLE `bans`
MODIFY `BanID` int(10) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `houses`
--
ALTER TABLE `houses`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
