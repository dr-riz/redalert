# redalert
Reporting only "true" workflow alerts from Oozie
Reporting only "true" workflow alerts from Oozie

Oozie treats a non-zero action value as a failure. When this happens, one possible action is to fail the workflow and notify the user by email as a failure alert. If the data arrives late and the subsequent workflow execution processes the late data, then the last alert becomes informational only or a "false positive". No action is required.

The number of informational alerts become a problem when the number of running workflow becomes large and they have differenceion frequencies ranging from tens of minutes to months. One possible heuristic is to ignore X number of alerts of a particular workflow. With this, it is easy to ignore a low frequency worklfow such as once a week as a "false positive". We need a method to detect "true positives". I propose a simple method to curb the number of alerts by setting up a trigger on the Oozie database. The trigger activates when a certain threshold is met, which is 3 in the example below for MySQL database. It puts an entry into a support.alert table.

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

A supplmentary script, called redalert.sh reads support.alerts since last touch point and then emails the alerts for each workflow type. The email body looks like:

RUNID=20170824170605
workdir=w0575oslshcea01.bell.corp.bce.ca:/Hadoopshare/home/rizwmian/datascience

Address the following alerts (also attached as tab separated realalerts.txt)
putHDFSTesting,rm,put,ls	1

history.csv from last 7 checks history.txt:
RUNID,alertTypes(#)
20170824145138,0
20170824152018,0
20170824152754,0
20170824153028,1
20170824153215,0
20170824170418,0
20170824170605,1
