<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
  <LINK REL=StyleSheet HREF="log.css" TYPE="text/css">

  <script type="text/javascript" src='xml-scripts.js'></script>
  <script type="text/javascript">
    function openTrace(url){  
        window.open(url);
   }
  </script>

</head>
<body>

<?
$dbuser= $_POST['dbuser'];
$dbserver= "localhost";
$dbpass= $_POST['passwd'];
$dbname= "andes3";

function_exists('mysql_connect') or die ("Missing mysql extension");
mysql_connect($dbserver, $dbuser, $dbpass)
     or die ("UNABLE TO CONNECT TO DATABASE at $dbserver");
mysql_select_db($dbname)
     or die ("UNABLE TO SELECT DATABASE $dbname");         

$adminName=$_POST['adminName'];
$startDate = $_POST['startDate'];
$endDate = $_POST['endDate'];
$errorType=$_POST['errorType'];

  if($startDate){
    $startDatec = "P1.startTime >= '$startDate' AND";
  } else {
    $startDatec = "";
  }
  if($endDate){
    $endDatec = "P1.startTime <= '$endDate' AND";
  } else {
    $endDatec = "";
  }
  if($errorType){
    $errorTypec = "\"$errorType\"";
  } else {
    $errorTypec = "";
  }

echo "<h2>The Errors and Warnings are as given below:</h2>";
echo "<table border=1>\n";
echo "<tr><th>Starting Time</th><th>Input</th><th>Error Type</th><th>Message</th><th>Tag</th><th>View</th></tr>\n";


// Newer versions of php have json decoder built-in.  Should
// eventually have test for php version and use built-in, when possible.
include 'JSON.php';
$json = new Services_JSON();

$sqlOld="SELECT startTime,userName,userProblem,userSection,tID,command,P1.clientID from PROBLEM_ATTEMPT AS P1,PROBLEM_ATTEMPT_TRANSACTION AS P2 WHERE $startDatec $endDatec P2.initiatingParty='server' AND P2.command like '%\"error-type\":$errorTypec%' AND P2.command like '%\"error\":%' AND P2.clientID=P1.clientID AND P1.extra=0 order by P2.tID";
$sql="SELECT startTime,userName,userProblem,userSection,tID,client,server,P1.clientID from PROBLEM_ATTEMPT AS P1,STEP_TRANSACTION AS P2 WHERE $startDatec $endDatec P2.server like '%\"log\":\"server\"%' AND P2.clientID=P1.clientID AND P1.extra=0 order by P2.tID";
$resultOld=mysql_query($sqlOld);
$result=mysql_query($sql);

  
while (($myrow = mysql_fetch_array($resultOld)) ||
       ($myrow = mysql_fetch_array($result))) {
  $tID=$myrow["tID"];  
  $userClientID=$myrow["clientID"];
  $userName=$myrow["userName"];
  $userProblem=$myrow["userProblem"];
  $userSection=$myrow["userSection"];
  $startTime=$myrow["startTime"];
  if(isset($myrow["command"])){
    $usertID=$tID-3;
    $cc=$myrow["command"];
    $userSql="SELECT command,tID from PROBLEM_ATTEMPT_TRANSACTION WHERE clientID='$userClientID' AND tID<$tID ORDER BY tID DESC LIMIT 1";
    $userResult=mysql_query($userSql);
    $myResult=mysql_fetch_array($userResult);
    $ttID=$myResult["tID"];  // tID associated with row, for focusing.
    $userCommand=$myResult["command"];
  } else {
    $usertID=$tID-1;
    $ttID=$tID;
    $cc=$myrow["server"];
    $userCommand=$myrow["client"];
  }
  $command=$json->decode($cc);
  $a=$json->decode($userCommand);

  $yy=array();
  if($command){
    // Don't know why I can't just use $command->result in the foreach
    $zz=$command->result; 
    foreach($zz as $bb) {
      if($bb->action == "log" && 
	 // New or old style logging
	 (strcmp($bb->log,"server")==0 || $bb->error)){
        $key1="error-type";  // work-around for the dash
        $errorType=$bb->$key1;
	// New or old style logging
        $errorMsg=isset($bb->text)?$bb->text:$bb->error;
	$tag=isset($bb->entry)?$bb->entry:'';
        array_push($yy,"<td>$errorType</td><td>$errorMsg</td><td>$tag</td>");
      }
    }
  }
  // If there is no match, then something has gone wrong 
  // with the json decoding.  These are usually associated with very
  // long backtraces that have somehow gotten truncated.
  if(count($yy)==0) {
    $bb=$cc;
    // add space after commas, for better line wrapping
    $bb=str_replace("\",\"","\", \"",$bb);
    // forward slashes are escaped in json, which looks funny
    $bb=str_replace("\\/","/",$bb);
    $bb=substr($bb,0,200);
    array_push($yy,"<td colspan=\"2\">$bb &#8230;</td>");
  }
  $nr=count($yy); // should always be nonzero

  //  $lastID=$tID-1;
  //  $userSql="select command from PROBLEM_ATTEMPT_TRANSACTION where tID=$lastID";
  $method=$a->method;
  $aa=$json->encode($a->params);
  // Escape html codes so actual text is seen.
  $aa=str_replace("&","&amp;",$aa);
  $aa=str_replace(">","&gt;",$aa);
  $aa=str_replace("<","&lt;",$aa);
  // add space after commas, for better line wrapping
  $aa=str_replace("\",\"","\", \"",$aa);
  // forward slashes are escaped in json, which looks funny
  $aa=str_replace("\\/","/",$aa);

  echo "<tr class=\"$method\"><td rowspan=\"$nr\">$startTime</td>";
  echo "<td rowspan=\"$nr\">$aa</td>";
  echo array_shift($yy);

  echo "<td rowspan=\"$nr\"><a href=\"javascript:;\" onclick=\"openTrace('OpenTrace.php?x=$dbuser&amp;sv=$dbserver&amp;pwd=$dbpass&amp;d=$dbname&amp;u=$userName&amp;p=$userProblem&amp;s=$userSection&amp;t=$ttID');\">Session&nbsp;log</a><br><a href=\"javascript:;\" onclick=\"copyRecord('\Save.php?x=$dbuser&amp;sv=$dbserver&amp;pwd=$dbpass&amp;d=$dbname&amp;a=$adminName&amp;a=$adminName&amp;u=$userName&amp;p=$userProblem&amp;s=$userSection&amp;t=$usertID');\">Solution</a></td></tr>\n";

  foreach ($yy as $bb) {
    echo "<tr class=\"$method\">$bb</tr>\n";
  }

 }

echo "</table>\n";

mysql_close();
?>
</body>
</html>
