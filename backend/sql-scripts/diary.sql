-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Počítač: db
-- Vytvořeno: Ned 10. pro 2023, 09:10
-- Verze serveru: 8.2.0
-- Verze PHP: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databáze: `diary`
--

-- --------------------------------------------------------

--
-- Struktura tabulky `diary`
--

CREATE TABLE `diary` (
  `id` int NOT NULL,
  `record1` text,
  `record2` text,
  `record3` text,
  `score` int NOT NULL,
  `date` date NOT NULL,
  `userId` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Vypisuji data pro tabulku `diary`
--

INSERT INTO `diary` (`id`, `record1`, `record2`, `record3`, `score`, `date`, `userId`) VALUES
(5, 'ahoj', 'já jSn', 'Kuba\npenis\n', 7, '2023-12-06', 2),
(6, 'ahoj já jsem Mates ', '', '', 7, '2023-12-07', 2);

-- --------------------------------------------------------

--
-- Struktura tabulky `messages`
--

CREATE TABLE `messages` (
  `messageID` int NOT NULL,
  `fromUserID` int NOT NULL,
  `toUserID` int NOT NULL,
  `messageText` text NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `isRead` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `deviceId` text NOT NULL,
  `firstName` text,
  `lastName` text,
  `profileImg` varchar(255) DEFAULT NULL,
  `firstSignIn` date DEFAULT NULL,
  `assignedPsycho` int DEFAULT NULL,
  `pairingCode` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Vypisuji data pro tabulku `users`
--

INSERT INTO `users` (`id`, `deviceId`, `firstName`, `lastName`, `profileImg`, `firstSignIn`, `assignedPsycho`, `pairingCode`) VALUES
(2, 'PPR1.180610.011', 'Jan', 'Janovsky', '6571c00ea1ff5image_cropper_1701953547378.jpg', NULL, 5, '7OD6O'),
(3, 'pupikJupik', NULL, NULL, NULL, '2023-12-08', 2, '3N9IT'),
(4, 'kubikJupik', NULL, NULL, NULL, '2023-12-08', NULL, '64ELC'),
(5, 'OSM1.180201.037', 'Jakoubek', '', '6574cd58b8897image_cropper_1702153543932.jpg', '2023-12-09', 2, '9DBAM'),
(6, 'PPR1.180610.013', 'Jan', 'Starák', '6571c00ea1ff5image_cropper_1701953547378.jpg', NULL, 5, '7OD6O'),
(7, 'PPR1.180610.014', 'Jakubíček', '', '6571c00ea1ff5image_cropper_1701953547378.jpg', NULL, 5, '7OD6O');

--
-- Indexy pro exportované tabulky
--

--
-- Indexy pro tabulku `diary`
--
ALTER TABLE `diary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`);

--
-- Indexy pro tabulku `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`messageID`),
  ADD KEY `fromUserID` (`fromUserID`),
  ADD KEY `toUserID` (`toUserID`);

--
-- Indexy pro tabulku `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assignedPsycho` (`assignedPsycho`);

--
-- AUTO_INCREMENT pro tabulky
--

--
-- AUTO_INCREMENT pro tabulku `diary`
--
ALTER TABLE `diary`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pro tabulku `messages`
--
ALTER TABLE `messages`
  MODIFY `messageID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Omezení pro exportované tabulky
--

--
-- Omezení pro tabulku `diary`
--
ALTER TABLE `diary`
  ADD CONSTRAINT `diary_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`);

--
-- Omezení pro tabulku `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`fromUserID`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`toUserID`) REFERENCES `users` (`id`);

--
-- Omezení pro tabulku `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`assignedPsycho`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
