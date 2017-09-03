# redalert
Reporting only "true" workflow alerts from Oozie

Oozie treats a non-zero action value as a failure. When this happens, one possible action is to fail the workflow and notify the user or support by email as a failure alert. If the data arrives late and the subsequent workflow execution processes the late data, then the last alert becomes informational only or a "false positive". No action is required.

The type of email that Oozie sends out for alerting is fairly generic -- an example is attached as "etlPipeline failed.txt". As it can be seen, the subject and the content of the email does not calrify if this is a real failure or not. Upon getting such an email, the support inspects the logs of that particular workflow to determine the cause. Note, the alert email remains the same for true or false failure of etlPipeline. On the first look, this may look like a classification problem. My experience shows that machine learning (ML) is not that much of help. This is because Supervised ML requires labeling of data, however, the email remains the same for failure or non-failure of etlPipeline. That is, the input vector remains the same for different labels. 

The next natural step might be make the content of email more meaningful. That requires passing the context of execution and where the failure occured in the Oozie worfklow to the "kill" action that generates failure email. It requires addition of non-trivial extensions to Oozie workflow, namely decision points and kill action for each failure. At the very least, it would require retrofitting of existing workflows in execution.  

Why not just inspect all failure and ignore the false positives. The number of false alerts become a problem when the number of running workflow becomes large and they have different frequencies ranging from tens of minutes to months. One possible heuristic is to ignore X number of alerts of a particular workflow. With this, it is easy to ignore a low frequency worklfow such as once a week as a "false positive". We need a method to detect "true positives". I propose a simple method to curb the number of alerts by setting up a trigger on the Oozie database. The trigger activates when a certain threshold is met, which is 3 in the example below for MySQL database. It puts an entry into a support.alert table. Examples of trigger and database/table schema are provided in trigger.sql and alerts.sql, respectively.

A supplmentary script, called redalert.sh (attached) reads support.alerts since last touch point and then emails the alerts for each workflow type. 


[1] https://www.infoq.com/articles/oozieexample
