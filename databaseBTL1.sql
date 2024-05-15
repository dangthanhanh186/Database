use cinema;

create table
    movie(
        ID int,
        MNAME varchar(99) not null,
        GENRE char(99),
        RELEASEDAT year(4),
        AGE_RESTRIC INT,
        MLANGUAGE char(99),
        DIRECTOR char(99),
        PERFORMER text,
        NATION char(99),
        MDURATION time,
        M_ID int,
        MDESCRIPTION text,
        primary key (ID),
        foreign key (M_ID) references movie(ID) ON DELETE
        SET
            NULL ON UPDATE CASCADE
    );

create table
    room(
        RNUMBER char(4),
        SEATNUM int,
        primary key (RNUMBER)
    );

create table
    seat(
        RNUMBER char(4),
        ROWNUM char(1),
        COLUMNNUM char(2),
        primary key (RNUMBER, ROWNUM, COLUMNNUM),
        foreign key (RNUMBER) references room(RNUMBER)
    );

create table
    customer(
        CID char(9),
        C_NAME varchar(99) not null,
        DATE_BIRTH date,
        PHONENUM char(10),
        HOMENUM char(30),
        STREETNANE varchar(99),
        DISTRICT varchar(40),
        CITY varchar(40),
        primary key (CID)
    );

create table
    customer_over15(
        CID char(9),
        CCCD char(12),
        primary key (CID, CCCD),
        UNIQUE (CCCD),
        foreign key (CID) references customer(CID)
    );

create table
    customer_under15(
        CID char(9),
        primary key (CID),
        foreign key (CID) references customer(CID)
    );

create table
    employee(
        EID char(8),
        WAGE INT,
        CONTRACTDAY date,
        ENAME varchar(99) not null,
        DATE_BIRTH date,
        PHONENUM char(10),
        HOMENUM char(99),
        STREETNANE varchar(99),
        DISTRICT varchar(99),
        CITY varchar(99),
        primary key (EID)
    );

create table
    ticketChecker(
        EID char(8),
        primary key (EID),
        foreign key (EID) references employee(EID)
    );

create table
    movieProjectionist(
        EID char(8),
        primary key (EID),
        foreign key (EID) references employee(EID)
    );

create table
    ticketSeller(
        EID char(8),
        primary key (EID),
        foreign key (EID) references employee(EID)
    );

create table
    movieScreening(
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        primary key (ID, RNUMBER, MOVIETIME),
        foreign key (ID) references movie(ID),
        foreign key (RNUMBER) references room(RNUMBER)
    );

create table
    ticket(
        TID char(9),
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        T_PRICE int,
        S_RNUMBER char(4),
        ROWNUM char(1),
        COLUMNNUM char(2),
        primary key (TID, ID, RNUMBER, MOVIETIME),
        foreign key (ID, RNUMBER, MOVIETIME) references movieScreening(ID, RNUMBER, MOVIETIME),
		foreign key (S_RNUMBER,ROWNUM,COLUMNNUM) references seat(RNUMBER,ROWNUM,COLUMNNUM)
    );

create table
    buy_ticket(
        TID char(9),
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        CID char(9),
        primary key (TID, ID, RNUMBER, MOVIETIME),
        foreign key (TID, ID, RNUMBER, MOVIETIME) references ticket(TID, ID, RNUMBER, MOVIETIME),
        foreign key (CID) references customer(CID) ON DELETE
        SET
            NULL ON UPDATE CASCADE
    );

create table
    ticketCheckerWork(
        EID char(8),
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        primary key (ID, RNUMBER, MOVIETIME),
        foreign key (EID) references ticketChecker(EID) ON DELETE
        SET
            NULL ON UPDATE CASCADE,
		foreign key (ID, RNUMBER, MOVIETIME) references movieScreening(ID, RNUMBER, MOVIETIME)
    );

create table
    projectionistWork(
        EID char(8),
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        primary key (EID),
        foreign key (EID) references movieProjectionist(EID),
        foreign key (ID, RNUMBER, MOVIETIME) references movieScreening(ID, RNUMBER, MOVIETIME) ON DELETE
        SET
            NULL ON UPDATE CASCADE
    );

create table
    shift(
        STARTIME time,
        ENDTIME time,
        primary key (STARTIME, ENDTIME)
    );

create table
    ticketSellerShift(
        EID char(8),
        STARTIME time,
        ENDTIME time,
        primary key (EID, STARTIME, ENDTIME),
        foreign key (EID) references ticketSeller(EID),
        foreign key (STARTIME, ENDTIME) references shift(STARTIME, ENDTIME)
    );

create table
    has(
        ID int,
        RNUMBER char(4),
        MOVIETIME datetime,
        STARTIME time,
        ENDTIME time,
        primary key (ID, RNUMBER, MOVIETIME),
        foreign key (ID, RNUMBER, MOVIETIME) references movieScreening(ID, RNUMBER, MOVIETIME),
        foreign key (STARTIME, ENDTIME) references shift(STARTIME, ENDTIME) ON DELETE
        SET
            NULL ON UPDATE CASCADE
    );

create table
    review(
        CID char(9),
        ID int,
        T_TID char(9),
        T_ID int,
        T_RNUMBER char(4),
        T_MOVIETIME datetime,
        E_POINT float(10, 2),
        primary key (CID, ID),
        foreign key (CID) references customer(CID),
        foreign key (ID) references movie(ID),
        foreign key (
            T_TID,
            T_ID,
            T_RNUMBER,
            T_MOVIETIME
        ) references ticket(TID, ID, RNUMBER, MOVIETIME)
    );
    
alter table review 
add constraint check_Point
CHECK (E_POINT<= 10 and  E_POINT >=1);

alter table movie
add constraint check_ID
CHECK (ID <= 999999999 and  ID >= 100000000);

