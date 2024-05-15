use cinema;
-- -------------------------- NEW TABLE use for below -------------------------------- --
create table danhgia (
		ID int,
        soluong int,
		score float(2, 1),
        primary key(ID)
);

create table thongke (
		ID int,
		soluong int,
        primary key(ID)
);

-------------------------------- STORE PROCEDURE ----------------------------
/* ======================= suat chieu hop le (time only) ============================ */
DELIMITER //
CREATE PROCEDURE set_showtimes(IN idval INT)
BEGIN
    DECLARE start_time TIME DEFAULT '08:00:00';
    declare end_time time default '22:00:00';
    DECLARE cur_time TIME;
    DECLARE movie_duration TIME;

    -- Create a temporary table to store showtimes
    CREATE TEMPORARY TABLE IF NOT EXISTS showtimes_table (
		ID INT,
        MNAME VARCHAR(255),
        MOVIETIME datetime,
        MDURATION TIME,
        showtime TIME
    );
    -- Copy movie information to the temporary table
    INSERT INTO showtimes_table (ID,  MDURATION )
    SELECT ID,  MDURATION 
    FROM movie 
    WHERE ID = idval;
	UPDATE showtimes_table SET showtime = start_time WHERE ID = idval;
		-- UPDATE showtimes_table SET room = 'A' WHERE ID = id;
        
    SELECT MDURATION INTO movie_duration FROM showtimes_table;
    CREATE TEMPORARY TABLE IF NOT EXISTS showtimes_only (
            stime time
        );
    while start_time < end_time do
    SET cur_time = ADDTIME(start_time, movie_duration);
    IF start_time < '22:00:00' THEN
        INSERT INTO showtimes_only (stime)
        values (start_time);
	end if;
    SET start_time = ADDTIME(cur_time, '00:10:00');
    -- select start_time;
    end while;
	
    -- Select the generated showtimes
    SELECT * FROM showtimes_only;
    drop table showtimes_table ;
	drop table showtimes_only ;
END //
DELIMITER ;
/* ======================= SAP XEP DUA TREN DANH GIA (RATING) ============================ */
DELIMITER //
CREATE PROCEDURE rating()
begin
		select * from danhgia 
        join movie on movie.ID = danhgia.ID
        order by score desc;
end//
DELIMITER ;
/* ======================= SAP XEP DUA TREN MUA NHIEU (MOST SOLD) ============================ */
DELIMITER //
CREATE PROCEDURE mostSold()
begin
		select * from thongke
        join movie on movie.ID = thongke.ID
        order by soluong desc;
end//
DELIMITER ;
/* ======================= GENERATE TICKET  ============================ */
DELIMITER //
CREATE procedure gen_ticket(IN idval int, 
							IN phong char(4), 
                            IN thoigian datetime)
begin
	declare rnum int default 1;
    declare cnum int default 1;
	declare a int default 0;
    while rnum < 6 do 
		while cnum < 7 do
			insert into ticket(TID, ID, RNUMBER, MOVIETIME, T_PRICE, S_RNUMBER , ROWNUM, COLUMNNUM)
            values(
				CONCAT(
						FLOOR(RAND() * 10),  -- Random uppercase letter
						FLOOR(RAND() * 10),  -- Random lowercase letter
						FLOOR(RAND() * 10),             -- Random digit
						FLOOR(RAND() * 10),  -- Another random uppercase letter
						FLOOR(RAND() * 10),  -- Another random lowercase letter
						CHAR(97 + FLOOR(RAND() * 20)),             -- Another random digit
						CHAR(65 + FLOOR(RAND() * 26)),  -- Another random uppercase letter
						CHAR(97 + FLOOR(RAND() * 26))   -- Another random lowercase letter
					),
				idval,
				phong,
                thoigian,
                50,
                phong,
                CHAR(65 + a),
                concat('0',cnum));
            set cnum = cnum + 1; 
            end while;
		set cnum = 1;
        set rnum = rnum + 1;
        set a = a + 1;
    end while;
    select*from ticket
    where ticket.ID = idval
    order by ROWNUM desc;
end//
 DELIMITER ;
-- -------------------------------- FUNCTION --------------------------------- --
/* ====================== tính tiền dựa trên tuổi ================ */
DELIMITER //
	create function cal (id char(9))
    returns decimal(10,2)
    DETERMINISTIC
begin
		DECLARE ticket_price DECIMAL(10, 2);
        DECLARE age int;
		SELECT 
		DATEDIFF(CURDATE(), DATE_BIRTH ) / 365 into age
		FROM customer
        where CID = id;
        if age < 15 then 
			set ticket_price = 50;
		elseif age >= 15 AND age < 22 THEN
			set ticket_price = 75;
		else 
			set ticket_price = 100;
		end if;
        return ticket_price;
end //
DELIMITER ;
/* ====================== qua cua khach hang ======================*/
DELIMITER //
create function gift (item int)
	returns varchar(255)
	DETERMINISTIC
begin			
		DECLARE gift VARCHAR(255);
		DECLARE gift1 VARCHAR(255);
		DECLARE gift2 VARCHAR(255);
		DECLARE val int default 0;
		DECLARE val2 int default 0;
		set val2 = item;
        while item >= 2 do
			set val = val + 1;
			if val = 1 then
                set gift2 = concat('You recieve',' ', val,' ', 'coupon' );
            elseif val >= 2 then 
				set gift2 = concat('You recieve',' ', val,' ', 'coupons' );
			end if;
			set item = item - 2;
        end while;
        if val2 < 2 then
			set gift1='';
		elseif val2 >= 2 and val2 < 4 then 
			set gift1 = '2 drinks';
		elseif val2 >= 4 AND val2 < 6 THEN
			set gift1 = 'a free ticket';
		elseif val2 >= 6 then
			set gift1 = '2 free tickets';
		end if;
        if val2 = 0 then 
			set gift = 'You have not bought any tickets.';
		elseif val2 = 1 then
			set gift = 'You do not meet the requirements to receive the gift.'; 
        elseif val2 >= 2 then 
			set gift = concat(gift2,' ','and',' ',gift1,' ','for purchasing',' ',val2,' ', 'tickets.'); 
		end if;
        return gift;
end //
DELIMITER ;
-- --------------------------------- TRIGGER --------------------------------- --
/* ====================== thống kê vé của thep ID phim  ======================*/

DELIMITER //
CREATE TRIGGER countticket
after INSERT 
ON buy_ticket FOR EACH ROW
BEGIN
	INSERT INTO thongke (ID, soluong)
    VALUES (NEW.ID, 1)
    ON DUPLICATE KEY UPDATE soluong = soluong + 1;
END;
//
DELIMITER ;
/* ======================  tinh diem trung binh theo ID phim  ======================*/
DELIMITER //
CREATE TRIGGER average_score
after INSERT 
ON review FOR EACH ROW
BEGIN
	INSERT INTO danhgia (ID, soluong, score)
    VALUES (NEW.ID, 1, NEW.E_POINT)
    ON DUPLICATE KEY UPDATE
        score = (score * soluong + NEW.E_POINT) / (soluong + 1),
        soluong = soluong + 1;
END;
//
DELIMITER ;

-- Create a trigger for customers under 13
DELIMITER //
CREATE TRIGGER calculate_age_15
after INSERT ON customer
FOR EACH ROW
BEGIN
	declare tuoi int default 0;
    SET tuoi = YEAR(CURDATE()) - year(NEW.DATE_BIRTH);
    IF tuoi < 13 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customers under 13 years old need parents.';
    END IF;
END //
DELIMITER ;