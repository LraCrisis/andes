<?
$dbuser= "rrangan";
$dbserver= "gideon.eas.asu.edu";
$dbpass= "sin(0)=0";
$dbname= "andes";
//******** BEGIN LISTING THE CONTENTS OF  testTable*********                                                                                                            
//CONNECTION STRING                                                                                                                                                     
mysql_connect($dbserver, $dbuser, $dbpass)
     or die ("UNABLE TO CONNECT TO DATABASE");
mysql_select_db($dbname)
     or die ("UNABLE TO SELECT DATABASE");                                                                                                                                  
$adminName = $_POST['adminName'];
$orderBy = $_POST['item'];
$order = $_POST['order'];

echo "<h2>Comments given by the Andes Users, sorted in $order order of $orderBy, are as follows:</h2><BR>";
if($order=='Descending')
  $order = "DESC";
 else
   $order = "";

$sql = "SELECT * FROM PROBLEM_ATTEMPT AS P1,PROBLEM_ATTEMPT_TRANSACTION AS P2 WHERE P1.clientID = P2.clientID AND P2.initiatingParty = 'client' AND P2.command LIKE '%\"action\":\"get-help\",\"text\":%' ORDER BY $orderBy $order";

$result = mysql_query($sql);
if ($myrow = mysql_fetch_array($result)) {
  echo "<table border=1>";
  echo "<tr><th>User Name</th><th>Problem</th><th>Section</th><th>Starting Time</th><th>Comment</th><th>Additional</th></tr>";
do
  {
    $tID=$myrow["tID"];
    $tempSql = "SELECT * FROM PROBLEM_ATTEMPT_TRANSACTION WHERE tID = ($tID+1) and command LIKE '%your comment has been recorded%'";
    $tempResult = mysql_query($tempSql);    
    if(mysql_fetch_array($tempResult))
      {
       $tempResult = NULL;
       $tempSql = NULL;
       $userName=$myrow["userName"];
       $userProblem=$myrow["userProblem"];
       $userSection=$myrow["userSection"];
       $startTime=$myrow["startTime"];
       $tempCommand1=$myrow["command"];
       $tempCommand2 =explode("get-help\",\"text\":\"",$tempCommand1);
       $command=explode("\"}",$tempCommand2[1]);
       
       echo "<tr><td>$userName</td><td>$userProblem</td><td>$userSection</td><td>$startTime</td><td>$command[0]</td><td><form action=\"Save.php\" method=\"post\"><input type = \"submit\" value=\"View-Solution\"/><input name=\"adminName\" value=$adminName type=\"hidden\"/><input name=\"userName\" value=$userName type=\"hidden\" /><input name=\"userProblem\" value=$userProblem type=\"hidden\" /><input name=\"userSection\" value=$userSection type=\"hidden\" /><input name=\"tID\" value=$tID type=\"hidden\" /></form></td></tr>";
      }
  }
 while ($myrow = mysql_fetch_array($result));
 echo "</table>";
 }
mysql_close();
?>