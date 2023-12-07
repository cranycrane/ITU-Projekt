-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Počítač: db
-- Vytvořeno: Čtv 07. pro 2023, 14:27
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
(1, 'ahoj', 'update', 'fkdsjfkldsjgkljfijfig', 7, '2023-12-05', 1),
(2, 'ahoj', 'druhy zaznam', 'jfkdsjfklsdfjlds neco penis', 7, '2023-12-06', 1),
(3, 'ahoj', '', '', 7, '2023-12-04', 1),
(4, 'dsfdsfsdfdsf', '', '', 7, '2023-12-07', 1),
(5, 'ahoj', 'já jSn', 'Kuba\npenis\n', 7, '2023-12-06', 2),
(6, 'ahoj já jsem Mates ', '', '', 7, '2023-12-07', 2);

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
  `firstSignIn` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Vypisuji data pro tabulku `users`
--

INSERT INTO `users` (`id`, `deviceId`, `firstName`, `lastName`, `profileImg`, `firstSignIn`) VALUES
(1, 'OSM1.180201.037', 'Jakub', 'PerkoPenis', '657070bb82c12image_cropper_1701867697698.jpg', NULL),
(2, 'PPR1.180610.011', 'Jan', 'penis', '6571c00ea1ff5image_cropper_1701953547378.jpg', NULL);

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
-- Indexy pro tabulku `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pro tabulky
--

--
-- AUTO_INCREMENT pro tabulku `diary`
--
ALTER TABLE `diary`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pro tabulku `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Omezení pro exportované tabulky
--

--
-- Omezení pro tabulku `diary`
--
ALTER TABLE `diary`
  ADD CONSTRAINT `diary_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
