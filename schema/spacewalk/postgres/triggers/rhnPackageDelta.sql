-- oracle equivalent source sha1 59d54050ceffbcb4476a248028d90e73ec853aa1


create or replace function rhn_packagedelta_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_packagedelta_mod_trig
before insert or update on rhnPackageDelta
for each row
execute procedure rhn_packagedelta_mod_trig_fun();

