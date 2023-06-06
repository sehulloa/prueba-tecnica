CREATE DATABASE dbtest;

USE dbtest;

CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `position` varchar(45) DEFAULT NULL,
  `age` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO `dbtest`.`employees` (`id`, `name`, `position`, `age`) VALUES ('1', 'Adriana Amaya', 'Creative', '17');
INSERT INTO `dbtest`.`employees` (`id`, `name`, `position`, `age`) VALUES ('2', 'Ana Lopez', 'Developer', '27');
INSERT INTO `dbtest`.`employees` (`id`, `name`, `position`, `age`) VALUES ('3', 'Franco Aras', 'Scrum master', '30');
