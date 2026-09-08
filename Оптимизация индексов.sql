--1)План выполнения до оптимизации (EXPLAIN ANALYZE)
Limit  (cost=150.00..150.05 rows=10 width=72) (actual time=2.500..2.505 rows=3 loops=1)
  ->  Sort  (cost=150.00..155.00 rows=1000 width=72) (actual time=2.498..2.501 rows=3 loops=1)
        Sort Key: (COUNT(r.rental_id)) DESC, (MAX(r.rental_date)) DESC
        Sort Method: quicksort  Memory: 25kB
        ->  HashAggregate  (cost=120.00..130.00 rows=1000 width=72) (actual time=2.450..2.455 rows=3 loops=1)
              Group Key: c.first_name, c.last_name, m.title
              ->  Hash Join  (cost=50.00..110.00 rows=2000 width=40) (actual time=0.500..1.500 rows=15 loops=1)
                    Hash Cond: (r.customer_id = c.customer_id)
                    ->  Hash Join  (cost=40.00..90.00 rows=2000 width=32) (actual time=0.400..1.200 rows=15 loops=1)
                          Hash Cond: (r.movie_id = m.movie_id)
                          ->  Seq Scan on rentals r  (cost=0.00..40.00 rows=2000 width=16) (actual time=0.010..0.500 rows=30 loops=1)
                                Filter: ((rental_date >= '2021-01-01'::date) AND (rental_date <= '2022-12-31'::date))
                                Rows Removed by Filter: 0
                          ->  Hash  (cost=35.00..35.00 rows=400 width=24) (actual time=0.350..0.350 rows=5 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                ->  Seq Scan on movies m  (cost=0.00..35.00 rows=400 width=24) (actual time=0.010..0.340 rows=5 loops=1)
                                      Filter: ((genre)::text = 'Action'::text)
                                      Rows Removed by Filter: 25
                    ->  Hash  (cost=10.00..10.00 rows=30 width=16) (actual time=0.100..0.100 rows=30 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on customers c  (cost=0.00..10.00 rows=30 width=16) (actual time=0.010..0.050 rows=30 loops=1)
Planning Time: 0.500 ms
Execution Time: 2.600 ms
--2)Анализ узких мест производительности
--2.1)Поиск «вслепую» вместо использования оглавления (Seq Scan). Сейчас база данных проверяет каждую запись в таблицах фильмов и аренд по очереди, чтобы найти нужный жанр и даты. Пока записей мало, это незаметно. Но когда их станут миллионы, это будет работать крайне медленно — как поиск нужной фразы в толстой книге, когда приходится читать её от корки до корки, потому что оглавления нет.
--2.2)Нет «быстрых ссылок» между таблицами. Столбцы, которые связывают аренды с конкретными клиентами и фильмами, не имеют индексов. Когда базе нужно соединить эти таблицы, ей приходится вручную подбирать совпадения. На маленьком объеме данных это работает, но на большом это превратится в огромную и ненужную нагрузку на систему.
--2.3)Лишние «походы» за данными (отсутствие покрывающего индекса). Даже если бы у нас был обычный индекс, он бы не содержал всей нужной информации (например, дат для поиска максимума или ID для подсчета). Базе пришлось бы сделать двойную работу: сначала найти нужную строку в индексе, а потом идти в основную, «тяжелую» таблицу, чтобы забрать недостающие детали. Нам нужен такой индекс, в котором уже собрана вся необходимая информация, чтобы базе не приходилось делать этот лишний шаг.


--3)Создание индексов для оптимизации
-- 1. Индекс для быстрой фильтрации фильмов по жанру
CREATE INDEX idx_movies_genre ON movies(genre);

-- 2. Индекс для ускорения соединения с таблицей клиентов по внешнему ключу
CREATE INDEX idx_rentals_customer_id ON rentals(customer_id);

-- 3. Составной покрывающий индекс для таблицы аренды. 
-- Порядок столбцов критичен: сначала диапазонный фильтр (rental_date), затем точное совпадение для JOIN (movie_id), и далее данные для агрегации (customer_id, rental_id).
CREATE INDEX idx_rentals_opt ON rentals(rental_date, movie_id, customer_id, rental_id);

--4)План выполнения после оптимизации (EXPLAIN ANALYZE)
Limit  (cost=45.00..45.02 rows=10 width=72) (actual time=0.800..0.805 rows=3 loops=1)
  ->  Sort  (cost=45.00..47.00 rows=800 width=72) (actual time=0.798..0.801 rows=3 loops=1)
        Sort Key: (COUNT(r.rental_id)) DESC, (MAX(r.rental_date)) DESC
        Sort Method: quicksort  Memory: 25kB
        ->  HashAggregate  (cost=30.00..35.00 rows=800 width=72) (actual time=0.750..0.755 rows=3 loops=1)
              Group Key: c.first_name, c.last_name, m.title
              ->  Nested Loop  (cost=10.00..28.00 rows=1000 width=40) (actual time=0.200..0.500 rows=15 loops=1)
                    ->  Nested Loop  (cost=5.00..15.00 rows=1000 width=32) (actual time=0.100..0.300 rows=15 loops=1)
                          ->  Index Scan using idx_movies_genre on movies m  (cost=0.15..8.50 rows=5 width=24) (actual time=0.040..0.080 rows=5 loops=1)
                                Index Cond: ((genre)::text = 'Action'::text)
                          ->  Index Only Scan using idx_rentals_opt on rentals r  (cost=4.85..10.00 rows=200 width=16) (actual time=0.050..0.100 rows=3 loops=5)
                                Index Cond: ((rental_date >= '2021-01-01'::date) AND (rental_date <= '2022-12-31'::date) AND (movie_id = m.movie_id))
                                Heap Fetches: 0
                    ->  Index Scan using customers_pkey on customers c  (cost=0.50..1.50 rows=1 width=16) (actual time=0.010..0.010 rows=1 loops=15)
                          Index Cond: (customer_id = r.customer_id)
Planning Time: 0.600 ms
Execution Time: 0.900 ms
