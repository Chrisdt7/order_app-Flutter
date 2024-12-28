-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 15, 2024 at 05:37 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mobile_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `menus`
--

CREATE TABLE `menus` (
  `id_menus` int(3) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category` enum('Foods','Drinks','Dessert','Others') DEFAULT NULL,
  `image` varchar(255) DEFAULT 'default.jpg'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `menus`
--

INSERT INTO `menus` (`id_menus`, `name`, `price`, `description`, `category`, `image`) VALUES
(1, 'Nasi Goreng', 15000.00, 'Nasi Goreng Spesial', 'Foods', '1000090516.jpg'),
(8, 'Nasi Putih', 4000.00, 'Nasi Putih 1 porsi', 'Others', '1000090895.jpg'),
(9, 'Es Teh', 5000.00, 'Es teh manis', 'Drinks', '1000090896.jpg'),
(10, 'Nila Goreng', 30000.00, 'Nila Goreng', 'Foods', '1000090898.jpg'),
(11, 'Es Goodday Freeze', 5000.00, 'Goodday freeze es', 'Drinks', '1000090899.jpg'),
(12, 'Es Goodday Cappuccino', 6000.00, 'Goodday Cappuccino Es', 'Drinks', '1000090900.jpg'),
(13, 'Es Nutrisari', 5000.00, 'Nutrisari Es', 'Drinks', '1000090901.jpg'),
(16, 'Tahu Isi', 5000.00, 'Tahu isi 4pcs', 'Others', '1000090903.jpg'),
(17, 'Tempe Goreng', 5000.00, 'Tempe goreng 5pcs', 'Others', '1000090902.jpg'),
(20, 'Ice Cream with Caramel', 15000.00, 'Ice Cream dengan topping caramel', 'Dessert', '1000090904.jpg'),
(21, 'Oreo Pancakes', 15000.00, 'Pancakes dengan topping oreo', 'Dessert', '1000090905.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id_orders` int(3) NOT NULL,
  `id_tables` int(3) NOT NULL,
  `id_users` int(3) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `status` enum('Pending','Completed','Canceled','In-progress') NOT NULL DEFAULT 'Pending',
  `payment` enum('Cash','Debit/Credit','QR') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id_orders`, `id_tables`, `id_users`, `total`, `status`, `payment`, `created_at`, `updated_at`) VALUES
(14, 1, 19, 15000.00, 'Pending', 'Cash', '2024-07-03 09:57:10', '2024-07-03 09:57:10');

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `id_order_details` int(3) NOT NULL,
  `id_orders` int(3) NOT NULL,
  `id_menus` int(3) NOT NULL,
  `quantity` int(5) NOT NULL,
  `note` text DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tables`
--

CREATE TABLE `tables` (
  `id_tables` int(3) NOT NULL,
  `table_number` int(4) NOT NULL,
  `table_qr` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tables`
--

INSERT INTO `tables` (`id_tables`, `table_number`, `table_qr`) VALUES
(51, 1, 'assets/table_qr/table_1.png'),
(52, 2, 'assets/table_qr/table_2.png'),
(53, 3, 'assets/table_qr/table_3.png'),
(54, 4, 'assets/table_qr/table_4.png'),
(55, 5, 'assets/table_qr/table_5.png');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_users` int(3) NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('customer','admin') DEFAULT 'customer',
  `phone` varchar(15) NOT NULL,
  `address` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_users`, `name`, `username`, `email`, `password`, `role`, `phone`, `address`) VALUES
(18, 'Christy Dany Tallane', 'ChrisDT', 'christytallane@gmail.com', '$2b$10$NjN9gnfCg.oi9boRZ9DQbeNuLEeaZKZ86htUr3FpZeamV8q1MUkN.', 'admin', '081328438393', 'Jl. setu - serang'),
(19, 'unknown', 'Xynz0', 'itsxynz0@gmail.com', '$2b$10$eEFda2.ZzNiitoZno1z1vez.Vjb.1Pt/svHvc.fmzcW4fmhyk8hLm', 'customer', '081328438393', 'jl. setu serang'),
(25, 'vian', 'vian12', 'vian@gmail.com', '$2b$10$zNtPwSAKZDbCyGWQBmhEPOqz8K5jb1oRFD7Pf6Otv3GWE3q1uX2SW', 'customer', '081328438393', 'sempu'),
(26, 'hilmi', 'hilmi12', 'hilmi@gmail.com', '$2b$10$7UCKyIYOoJboXeyzNu45su95DEJM.UCgPnFisuiVDKUAtaSI41rPC', 'customer', '081328438393', 'cibituhg');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `menus`
--
ALTER TABLE `menus`
  ADD PRIMARY KEY (`id_menus`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id_orders`),
  ADD UNIQUE KEY `id_tables` (`id_tables`),
  ADD KEY `id_users` (`id_users`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id_order_details`),
  ADD KEY `id_orders` (`id_orders`),
  ADD KEY `id_menus` (`id_menus`);

--
-- Indexes for table `tables`
--
ALTER TABLE `tables`
  ADD PRIMARY KEY (`id_tables`),
  ADD UNIQUE KEY `unique_table_number` (`table_number`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_users`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `menus`
--
ALTER TABLE `menus`
  MODIFY `id_menus` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id_orders` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id_order_details` int(3) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tables`
--
ALTER TABLE `tables`
  MODIFY `id_tables` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_users` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`id_users`) REFERENCES `users` (`id_users`);

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`id_orders`) REFERENCES `orders` (`id_orders`),
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`id_menus`) REFERENCES `menus` (`id_menus`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
