CREATE TABLE League
(
    id_league   INT
        CONSTRAINT LEAGUE_PK
            PRIMARY KEY,
    league_size INT
);
CREATE TABLE Sponsor
(
    id_sponsor   INT
        CONSTRAINT SPONSOR_PK
            PRIMARY KEY,
    sponsor_name varchar2(20)
);
CREATE TABLE City
(
    id_city   INT
        CONSTRAINT CITY_PK
            PRIMARY KEY,
    city_name varchar2(20)
);
CREATE TABLE Owner
(
    id_owner   INT
        CONSTRAINT OWNER_PK
            PRIMARY KEY,
    owner_name varchar2(20)
);
DROP TABLE Referee;
CREATE TABLE Referee
(
    id_referee   INT
        CONSTRAINT REFEREE_PK
            PRIMARY KEY,
    id_league    INT,
    referee_name varchar2(20),
    CONSTRAINT id_league FOREIGN KEY (id_league) references League(id_league)
);
CREATE TABLE Staff
(
    id_staff   INT
        CONSTRAINT STAFF_PK
            PRIMARY KEY,
    staff_size INT
);
CREATE TABLE Coach
(
    id_coach   INT
        CONSTRAINT COACH_PK
            PRIMARY KEY,
    coach_name varchar2(20),
    id_staff   INT,
    CONSTRAINT id_staff FOREIGN KEY (id_staff) references Staff(id_staff)
);
CREATE TABLE Team
(
    id_team     INT
        CONSTRAINT TEAM_PK
            PRIMARY KEY,
    team_name   varchar2(20),
    squad_size  INT,
    team_budget INT,
    id_coach    INT,
    id_owner    INT,
    id_league   INT,
    id_sponsor  INT,
    CONSTRAINT id_coach FOREIGN KEY (id_coach) references Coach(id_coach),
    CONSTRAINT id_owner FOREIGN KEY (id_owner) references Owner(id_owner),
    CONSTRAINT id_league2 FOREIGN KEY (id_league) references League(id_league),
    CONSTRAINT id_sponsor FOREIGN KEY (id_sponsor) references Sponsor(id_sponsor)
);
CREATE TABLE Stadium
(
    id_stadium       INT
        CONSTRAINT STADIUM_PK
            PRIMARY KEY,
    id_team          INT,
    id_city          INT,
    stadium_capacity INT,
    CONSTRAINT id_team FOREIGN KEY (id_team) references Team(id_team),
    CONSTRAINT id_city FOREIGN KEY (id_city) references City(id_city)
);
CREATE TABLE Training
(
    id_training       INT
        CONSTRAINT TRAINING_PK
            PRIMARY KEY,
    training_duration INT
);
CREATE TABLE Player
(
    id_player       INT
        CONSTRAINT PLAYER_PK
            PRIMARY KEY,
    player_name varchar2(30),
    player_position varchar2(5),
    player_age      INT,
    id_team         INT,
    CONSTRAINT id_team2 FOREIGN KEY (id_team) references Team(id_team)
);
CREATE TABLE Contract
(
    id_contract     INT
        CONSTRAINT CONTRACT_PK
            PRIMARY KEY,
    contract_length INT
);
CREATE TABLE Deal
(
    id_player    INT not null,
    id_contract  INT not null,
    id_team      INT not null,
    CONSTRAINT DEAL_PK
        PRIMARY KEY (id_player, id_contract, id_team),
    CONSTRAINT deal_player_fk
        FOREIGN KEY (id_player)
            references Player(id_player),
    CONSTRAINT deal_contract_fk
        FOREIGN KEY (id_contract)
            references Contract(id_contract),
    CONSTRAINT deal_team_fk
        FOREIGN KEY (id_team)
            references Team(id_team)
);
CREATE TABLE Trains
(
    id_player    INT not null,
    id_training  INT not null,
    id_staff      INT not null,
    CONSTRAINT TRAINS_PK
        PRIMARY KEY (id_player, id_training, id_staff),
    CONSTRAINT trains_player_fk
        FOREIGN KEY (id_player)
            references Player(id_player),
    CONSTRAINT trains_trainig_fk
        FOREIGN KEY (id_training)
            references Training(id_training),
    CONSTRAINT trains_staff_fk
        FOREIGN KEY (id_staff)
            references Staff(id_staff)
);