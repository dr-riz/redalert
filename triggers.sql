DELIMITER $$
CREATE TRIGGER  oozie.takeaction 
    AFTER UPDATE ON  oozie.WF_JOBS
    FOR EACH ROW 
BEGIN
   DECLARE failure_count INT;
   IF (NEW.app_name="etlPipeline") AND (NEW.STATUS like "%FAILED%" OR NEW.STATUS like "%ERROR%" OR NEW.STATUS like "%KILLED%") THEN      
 	 SELECT count(0) from (select id,status,app_name,last_modified_time from oozie.WF_JOBS where app_name="etlPipeline" AND last_modified_time <= NEW.last_modified_time  order by last_modified_time desc limit 3) f where status like "%KILLED%" into failure_count;	
     IF (failure_count >= 3) THEN
	   INSERT INTO support.realalerts VALUES (new.id, new.app_name, new.last_modified_time, new.status);
     END IF;
   END IF;
END $$
DELIMITER ;