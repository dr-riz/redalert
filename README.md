# redalert
Reporting only "true" workflow alerts from Oozie

Oozie treats a non-zero action value as a failure. When this happens, one possible action is to fail the workflow and notify the user by email as a failure alert. If the data arrives late and the subsequent workflow execution processes the late data, then the last alert becomes informational only or a "false positive". No action is required.

The number of informational alerts become a problem when the number of running workflow becomes large and they have differenceion frequencies ranging from tens of minutes to months. One possible heuristic is to ignore X number of alerts of a particular workflow. With this, it is easy to ignore a low frequency worklfow such as once a week as a "false positive". We need a method to detect "true positives". I propose a simple method to curb the number of alerts by setting up a trigger on the Oozie database. The trigger activates when a certain threshold is met, which is 3 in the example below for MySQL database. It puts an entry into a support.alert table. Examples of trigger and database/table schema are provided in trigger.sql and alerts.sql, respectively.

A supplmentary script, called redalert.sh (attached) reads support.alerts since last touch point and then emails the alerts for each workflow type. 
