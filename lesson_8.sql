--ОГРАНИЧЕНИЯ (CONSTRAINT)
--Создание таблицы работники
create table employee (id serial primary key, 
					   first_name varchar(100) NOT NULL,
					   surname varchar(100) NOT NULL) ;

--Невозможно вставить сотрудника с null именем и фамилией
insert into employee (first_name, surname) values(null, null);

--добавление ограничений
alter table employee add column email varchar(100);
alter table employee add constraint email_unique unique (email);
--удаление ограничений
alter table employee drop constraint email_unique;

--Вставка двух сотрудников
insert into employee (first_name, surname, email) values ('ivan', 'ivanov', '123@yandex.ru');
insert into employee (first_name, surname, email) values ('petr', 'petrov', '123@yandex.ru');

--Добавить колонку зарплата у сотрудников
alter table employee add column salary numeric(9,2);

--Добавить ограничение на колонку - зарплата только положительная
alter table employee add constraint salary_positive check(salary>0);

--Невозможно выполнить этот update
update employee set salary = -100
where name = 'ivan';

--Добавление колонки - ид компании
alter table employee add column company_id int;

--Создание таблицы компании
create table company (id serial primary key, name varchar(100));

--Добавление внешнего ключа у таблицы сотрудник (ограничение)
alter table employee add constraint company_id_fk foreign key (company_id) references company(id);

--Невозможно выполнить этот скрипт
update employee set company_id = 1
where name = 'ivan';

--Невозможно вставить null в primary key
insert into employee(id) values (null);



--ДАТЫ
--Создать хранилище под поздравление человека по email
--колонки email, дата + время, текст
create table event (id serial primary key, 
					email varchar(100) NOT NULL,
				    "date" timestamp NOT NULL,
				    "text" text NOT NULL);
					
--Вставка событий
insert into event (email, date, text) values 
('123@ya.ru', '2024-10-10 12:00:00', 'Поздравляю'),
('123@ya.ru', '2025-10-10 12:00:00', 'Поздравляю'),
('123@ya.ru', '2023-10-10 12:00:00', 'Поздравляю');

--Обрезка даты
select cast(date_trunc('month', now()) as timestamp);

--Получение событий по определенному году
select *
from event
where extract(year from date) = 2024

--События позже определенной даты
select *
from event
where date > '2023-10-10 13:00:00'

--События между двух дат
select *
from event
where date between '2023-10-10 13:00:00' and '2024-10-10 12:00:00'


--Работа с пользователями
--Создание и заполнение заказов
create table orders (id serial primary key, price numeric(9,2), number varchar(100));
insert into orders (price, number) values (100, '21a');

--Создание пользователя менеджер
create user manager with password '1234';

--Выдача прав на просмотр заказов менеджеру
grant select on orders to manager;
--Выдача прав на любые операции с заказми менеджеру
grant ALL on orders to manager;

--Создание view для отображения только ивановых
create or replace view employee_view as (
	select *
	from employee
	where surname = 'ivanov'
);

--Создание бухгалтера
create user accounter with password '5678';
--Выдача прав на просмотр view
grant select on employee_view to accounter;
--Удаление прав на просмотр view
revoke select on employee_view from accounter;
