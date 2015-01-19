#! /bin/bash
function ready_to_test() {
  if [[ $# -eq 0 ]]; then
    command test
  elif [[ $# -eq 1 && $0 -eq -h || $0 -eq --help ]]; then
    echo "ready_to_test - Get number of tickets became 'Ready To Test' within period"
    echo "ARGUMENTS:"
    echo "  -p          Name of project"
    echo "  -s          Sprint"
    echo "  -f          Start date"
    echo "  -t          End date"
    echo "EXAMPLE:"
    echo "  ready_to_test -p rakuten -s 4.1 -f 2014/12/1 -t 2014/12/7"
  else
    DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    echo "Enter your Jira's username:"
    read user
    echo "Enter your password:"
    read -s password
    echo "LOADING........"
    while [[ $# > 1 ]]
    do
    key="$1"

    case $key in
        -p|--project)
        PROJECT="$2"
        shift
        ;;
        -s|--sprint)
        SPRINT="$2"
        shift
        ;;
        -f|--from)
        FROM="$2"
        shift
        ;;
        -t|--to)
        TO="$2"
        shift
        ;;
        *)
                # unknown option
        ;;
    esac
    shift
    done
    OUTPUT=$(command ruby ${DIR}/data.rb ${PROJECT} ${SPRINT} ${FROM} ${TO} $user $password)
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
