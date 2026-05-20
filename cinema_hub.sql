--Удаление таблиц
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS films_actors CASCADE;
DROP TABLE IF EXISTS films_directors CASCADE;
DROP TABLE IF EXISTS films CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS actors CASCADE;
DROP TABLE IF EXISTS directors CASCADE;

--Фильмы: информация о фильмах включает название, год выпуска, жанр, рейтинг, длительность и описание.
create table if not exists Films
(
Film_ID SERIAL PRIMARY KEY,
Film_name VARCHAR(50) NOT NULL,
Year_of_release INT,
Genre VARCHAR(30) NOT NULL,
Rating INT,
Duration INT,
Description TEXT NOT NULL
)

--Режиссеры: информация о режиссерах включает имя, фамилию, дату рождения и национальность.
Create table if not exists Directors
(
Directors_ID SERIAL PRIMARY KEY,
Directors_First_name VARCHAR(30) NOT NULL,
Directors_Last_name VARCHAR(30) NOT NULL,
Directors_Date_of_birth DATE,
Directors_Nationality VARCHAR(30) NOT NULL
)

--Актеры: информация об актерах включает имя, фамилию, дату рождения и национальность.
Create table if not exists Actors
(
Actor_ID SERIAL PRIMARY KEY,
Actor_First_name VARCHAR(30) NOT NULL,
Actor_Last_name VARCHAR(30) NOT NULL,
Actor_Date_of_birth DATE NOT NULL,
Actor_Nationality VARCHAR(30)NOT NULL
)

--Клиенты: информация о клиентах включает имя, фамилию, email, номер телефона и адрес.
Create table if not exists Customers
(
Customer_ID SERIAL PRIMARY KEY,
Customer_First_name VARCHAR(30) NOT NULL,
Customer_Last_name VARCHAR(30)NOT NULL,
Customer_email VARCHAR (50)NOT NULL UNIQUE,
Customer_phone_number VARCHAR(30)NOT NULL,
Customer_Address VARCHAR (50) NOT NULL
)

--Заказы: клиенты могут арендовать фильмы. Информация о заказах включает клиента, фильм, дату аренды и дату возврата.
Create table if not exists Orders
(
Order_id SERIAL PRIMARY KEY,
Customer_ID INT REFERENCES Customers (Customer_ID),
Film_ID INT REFERENCES Films (Film_ID),
Rental_Date date,
Return_Date date
)
--Cоздаем две таблицы для связей фильмов, режисеров и актеров
CREATE TABLE IF NOT EXISTS Films_Directors --для фильмов и режисеров
(
Film_ID SERIAL REFERENCES Films (Film_ID) ON DELETE CASCADE,
Directors_ID SERIAL REFERENCES Directors (Directors_ID) ON DELETE CASCADE,
PRIMARY KEY (Film_ID, Directors_ID)
)

CREATE TABLE IF NOT EXISTS Films_Actors -- для фильмов и актеров
(
Film_ID SERIAL REFERENCES Films (Film_ID) ON DELETE CASCADE,
Actor_ID SERIAL REFERENCES Actors (Actor_ID) ON DELETE CASCADE,
PRIMARY KEY (Film_ID, Actor_ID)
)

--Запросы для вставки данных
-- 1. Режиссёры
INSERT INTO directors (directors_id, directors_first_name, directors_last_name, directors_date_of_birth, directors_nationality) VALUES
(1, 'Christopher', 'Nolan', '1970-07-30', 'British'),
(2, 'Quentin', 'Tarantino', '1963-03-27', 'American'),
(3, 'Greta', 'Gerwig', '1983-08-05', 'American'),
(4, 'Noah', 'Baumbach', '1969-09-03', 'American'),
(5, 'David', 'Fincher', '1962-08-28', 'American'),
(6, 'Wes', 'Anderson', '1969-05-01', 'American'),
(7, 'Damien', 'Chazelle', '1985-01-19', 'American'),
(8, 'Denis', 'Villeneuve', '1967-10-03', 'Canadian');

--2. Актеры
INSERT INTO actors (actor_id, actor_first_name, actor_last_name, actor_date_of_birth, actor_nationality) VALUES
(1, 'Leonardo', 'DiCaprio', '1974-11-11', 'American'),
(2, 'Margot', 'Robbie', '1990-07-02', 'Australian'),
(3, 'Tom', 'Hardy', '1977-09-15', 'British'),
(4, 'John', 'Travolta', '1954-02-18', 'American'),
(5, 'Ryan', 'Gosling', '1980-11-12', 'Canadian');
(6, 'Brad', 'Pitt', '1963-12-18', 'American'),
(7, 'Cillian', 'Murphy', '1976-05-25', 'Irish'),
(8, 'Edward', 'Norton', '1969-08-18', 'American'),
(9, 'Timothée', 'Chalamet', '1995-12-27', 'American'),
(10, 'Saoirse', 'Ronan', '1994-04-12', 'Irish');

--3. Клиенты
INSERT INTO customers (customer_id, customer_first_name, customer_last_name, customer_email, customer_phone_number, customer_address) VALUES
(1, 'Иван', 'Иванов', 'ivan@example.com', '+79001112233', 'Москва, Ленина 10'),
(2, 'Анна', 'Петрова', 'anna@example.com', '+79002223344', 'СПб, Невский 5'),
(3, 'Дмитрий', 'Сидоров', 'dima@example.com', '+79003334455', 'Казань, Баумана 20');

--4.Фильмы
INSERT INTO films (film_id, film_name, year_of_release, genre, rating, duration, description) VALUES
(1, 'Начало', 2010, 'Sci-Fi', 8.8, 148, 'Вор крадёт секреты через технологию внедрения в сны.'),
(2, 'Криминальное чтиво', 1994, 'Crime', 8.9, 154, 'Переплетённые истории бандитов и боксёра.'),
(3, 'Барби', 2023, 'Comedy', 7.0, 114, 'Кукла отправляется из идеального мира в реальный.');
(4,  'The Dark Knight', 2008, 'Action',    9.0, 152, 'Бэтмен вступает в противостояние с Джокером...'),
(5,  'Django Unchained',2012, 'Western',   8.4, 165, 'Бывший раб становится охотником за головами...'),
(6,  'Oppenheimer', 2023, 'Biography', 8.5, 180, 'История создателя атомной бомбы...'),
(7,  'The Grand Budapest Hotel',2014,'Comedy',   8.1, 99,  'Приключения легендарного консьержа...'),
(8,  'Fight Club', 1999, 'Drama',     8.8, 139, 'Товарищ по работе и бродяга создают подпольный клуб...'),
(9,  'Interstellar', 2014, 'Sci-Fi',    8.6, 169, 'Группа исследователей путешествует через червоточину...'),
(10, 'Little Women', 2019, 'Drama',     7.8, 135, 'Четыре сестры преодолевают жизненные трудности...'),
(11, 'La La Land', 2016, 'Musical',   8.0, 128, 'Джазовый музыкант и начинающая актриса влюбляются...'),
(12, 'The Social Network', 2010, 'Biography', 7.7, 120, 'История создания Facebook...'),
(13, 'Dune', 2021, 'Sci-Fi',    8.0, 155, 'Молодой наследник отправляется на опасную планету...');
SELECT * FROM FILMS
--5. Заказы
INSERT INTO orders (order_id, customer_id, film_id, rental_date, return_date) VALUES
(1, 1, 1, '2024-01-10', '2024-01-13'), -- Иван арендовал "Начало"
(2, 1, 3, '2024-02-05', NULL),         -- Иван арендовал "Барби" (ещё не вернул)
(3, 2, 2, '2024-01-20', '2024-01-22'), -- Анна арендовала "Криминальное чтиво"
(4, 3, 1, '2024-03-01', '2024-03-04'), -- Дмитрий арендовал "Начало"
(5, 3, 2, '2024-03-10', NULL);         -- Дмитрий арендовал "Криминальное чтиво"
(6,  1, 4,  '2024-04-01', '2024-04-04'), -- Иван → Dark Knight
(7,  2, 8,  '2024-04-05', NULL),         -- Анна → Fight Club (в аренде)
(8,  3, 13, '2024-04-10', '2024-04-12'), -- Дмитрий → Dune
(9,  1, 11, '2024-04-15', NULL),         -- Иван → La La Land (в аренде)
(10, 2, 6,  '2024-04-20', '2024-04-23'); -- Анна → Oppenheimer

--6.Связи между фильмами, режисерами и актерами
INSERT INTO films_directors (film_id, directors_id) VALUES
(1, 1),          -- Начало → Нолан
(2, 2),          -- Криминальное чтиво → Тарантино
(3, 3), (3, 4);  -- Барби → Гервиг, Баумбах
(4, 1),  -- Нолан → Dark Knight
(5, 2),  -- Тарантино → Django
(6, 1),  -- Нолан → Oppenheimer
(7, 6),  -- Андерсон → Budapest
(8, 5),  -- Финчер → Fight Club
(9, 1),  -- Нолан → Interstellar
(10,3),  -- Гервиг → Little Women
(11,7),  -- Шазелл → La La Land
(12,5),  -- Финчер → Social Network
(13,8);  -- Вильнёв → Dune

INSERT INTO films_actors (film_id, actor_id) VALUES
(1, 1), (1, 3),  -- Начало → ДиКаприо, Харди
(2, 4),          -- Криминальное чтиво → Траволта
(3, 2), (3, 5);  -- Барби → Робби, Гослинг
(4, 1), (4, 3),  -- DiCaprio, Hardy
(5, 4), (5, 6),  -- Travolta, Pitt
(6, 7), (6, 3),  -- Murphy, Hardy
(7, 2), (7, 10), -- Robbie, Ronan
(8, 6), (8, 8),  -- Pitt, Norton
(9, 1), (9, 5),  -- DiCaprio, Gosling
(10,10),(10,2),  -- Ronan, Robbie
(11,5), (11,9),  -- Gosling, Chalamet
(12,8), (12,1),  -- Norton, DiCaprio
(13,9), (13,7);  -- Chalamet, Murphy

--Написание sql запросов
--Запрос, выводящий всех актеров
SELECT
actor_ID,
actor_first_name,
actor_last_name 
from Actors

--Напишите запрос, который выводит список актеров, отсортированных по фамилии в алфавитном порядке.
SELECT
actor_ID,
actor_first_name,
actor_last_name from Actors
order by actor_last_name asc

--Напишите запрос, который выводит топ 5 фильмов с самым высоким рейтингом.
SELECT
Film_ID,
Film_Name,
Rating
FROM Films
WHERE Rating is not NULL
ORDER BY Rating desc, Film_ID asc
LIMIT 5

--Напишите запрос, который выводит все фильмы жанра ""Драма"", выпущенные после 2010 года.
SELECT 
Film_ID,
Year_of_release,
Film_Name,
Genre,
Rating,
Description
FROM Films
Where Genre = 'Drama'
 and Year_of_release >2010
ORDER BY Year_of_release DESC

--Напишите запрос, который выводит следующую страницу (фильмы с 6 по 10) из отсортированного по рейтингу списка фильмов.
SELECT
Film_ID,
Film_Name,
Rating
FROM Films
WHERE Rating is not NULL
ORDER BY Rating desc, Film_ID asc
LIMIT 5
OFFSET 5 
