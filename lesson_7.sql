
create table cinema (id serial primary key, name varchar(100));
create table place (id serial primary key, qty int, name varchar(100));
create table ticket (id serial primary key, 
					 seat_no varchar(4), 
					 event_date date, 
					 event_time time, 
					 place_id int references place(id),
					 cinema_id int references cinema(id));

insert into cinema (name) values('Мстители');
insert into place (name, qty) values('Большой зал', 100);
insert into place (name, qty) values('Маленький зал', 30);

--Предыстория: Есть кинотеатр, и у него два зала (30 мест и 100 мест). 
--Задача: Когда выходит новый фильм, нужно за определенную дату создать N билетов (в зависимости от зала), для каждого места.

--билет - ticket - id, seat_no, date + time, place_id, cinema_id
--зал - place - id, qty, name
--кино - cinema - id, name

--Последовательность (sequence)
--Создание последовательности
create sequence my_first_seq;
--Удаление последовательности
drop sequence my_first_seq;

--Генерация следующего значения последовательности
select nextval('my_first_seq');
--Установка нового значения последовательности
select setval('my_first_seq', 1);
--Получение текущего значения последовательности
select currval('my_first_seq');

--Функция генерации номера места
create or replace function generate_seat_no(letter varchar(4)) returns varchar(10)
 as 'select nextval(''my_first_seq'') || ''A'''
language sql;

--Удаление функции
drop function generate_seat_no;

--Выбор места
select generate_seat_no();

--Обнуление счетчика (последовательсноти)
create or replace procedure clear_sequence()
language plpgsql
as $$
begin 
	drop sequence my_first_seq;
	create sequence my_first_seq;
end;
$$

--Создать процедуру создания кино
create procedure create_cinema(cinema_name varchar(100))
language sql
begin atomic
 insert into cinema (name) values (cinema_name);
end;

--Создать кино с помощью функции
call create_cinema('Титаник');

--Создание N билетов для определенного зала и фильма
--билет - ticket - id, seat_no, date + time, place_id, cinema_id
create or replace procedure create_tickets(count_tickets int, place_name varchar(100), cinema_name varchar(100)) 
language plpgsql
as $$
declare i int;
begin
	call clear_sequence();
	foreach i in ARRAY(select ARRAY(select * from generate_series(1, count_tickets)))
	loop
	insert into ticket (seat_no, event_date, event_time, place_id, cinema_id) values
	(generate_seat_no(), 
	 now(), 
	 now(), 
	 (select id from place where name = place_name),
	 (select id from cinema where name = cinema_name));
	 end loop;
end;
$$;

--Создаем 100 билетов
call create_tickets(100, 'Большой зал', 'Мстители');
--Смотрим созданные билеты
select * from ticket;

--Хочу в отдельную таблицу, вытащить все билеты по мстителям
drop table if exists avengers_cinema;
select * into avengers_cinema
from ticket
where cinema_id = 1

--Создание view
--Хочу видеть количество билетов по каждому фильму
--имя фильма - количество билетов
create view statistic as (select ci.name, count(*)
from ticket ti join cinema ci on ti.cinema_id = ci.id
group by ci.name)

--Работа с View
select *
from statistic
where name = 'Титаник';
					 
					 
