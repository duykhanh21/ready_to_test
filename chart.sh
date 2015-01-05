#! /bin/bash
function ready_to_test() {
  if [[ $# -eq 0 ]]; then
    command test
  else
    echo "Enter your Jira's username:"
    read user
    echo "Enter your password:"
    read -s password
    echo "LOADING........"
    OUTPUT=$(command ruby ~/Desktop/data.rb $1 $2 $3 $4 $user $password)
    IFS=$'*' read -a result <<<"$OUTPUT"
    arr="["
    count=0
    echo "Total Tickets READY TO TEST by Day"
    echo "______________________________________"
    echo "| Date          | Number of tickets   |"
    echo "--------------------------------------"
    for i in "${result[@]}"
    do
      let "count += 1"
      IFS=$',' read -a li <<<"$i"
      arr="$arr['"
      arr="$arr${li[0]}"
      arr="$arr'"
      arr="$arr ,${li[1]}] ,"
      echo  "| ${li[0]}    |         ${li[1]}          |"
      echo "--------------------------------------"
    done
    arr="$arr ]"
    let "w = count*150"
    TEMP=$(mktemp -t chart.XXXXX)
    cat > $TEMP <<EOF
    <html>
      <head>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
        google.load('visualization', '1.0', {'packages':['corechart']});
        google.setOnLoadCallback(drawChart);
        function drawChart() {

        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Days');
        data.addColumn('number', 'Number of Ticket');
        data.addRows($arr);

        var options = {'title':'Total Tickets READY TO TEST by Day',
                       'width':$w,
                       'height':600};

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>

  <body>
    <div id="chart_div"></div>
  </body>
</html>
EOF

# open browser
case $(uname) in
   Darwin)
      open -a /Applications/Google\ Chrome.app $TEMP
      ;;

   Linux|SunOS)
     firefox $TEMP
      ;;
 esac
  fi
}
