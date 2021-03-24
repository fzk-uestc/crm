<%--
  Created by IntelliJ IDEA.
  User: HUAWEI
  Date: 2021/3/22
  Time: 21:53
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <title>Title</title>
    <%--引入echarts--%>
    <script src="ECharts/echarts.min.js"></script>
    <%--引入jQuery--%>
    <script src="jquery/jquery-1.11.1-min.js"></script>
    <script>
        $(function () {
            $.ajax({
                url: "workbench/clue/getCharts.do",
                data: {},
                dataType:"json",
                type:"get",
                success:function (data){
                    /*
                    data
                        {"total":10,"dataList":[{value: 60, name: '访问'},{},...]}
                    */
                    //页面加载完毕后，绘制统计图表
                    getCharts(data);
                }
            });
        });

        function getCharts(data) {
            // 基于准备好的dom，初始化echarts实例
            var myChart = echarts.init(document.getElementById('main'));

            // 指定图表的配置项和数据
            var option = {
                title: {
                    text: '线索饼状图',
                    subtext: '基于线索来源的饼状图',
                    left: 'center'
                },
                tooltip: {
                    trigger: 'item'
                },
                legend: {
                    orient: 'vertical',
                    left: 'left',
                },
                series: [
                    {
                        name: '线索饼状图',
                        type: 'pie',
                        radius: '50%',
                        data: data.dataList,
                        emphasis: {
                            itemStyle: {
                                shadowBlur: data.total,
                                shadowOffsetX: 0,
                                shadowColor: 'rgba(0, 0, 0, 0.5)'
                            }
                        }
                    }
                ]
            };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
        }
    </script>
</head>
<body>
<!-- 为 ECharts 准备一个具备大小（宽高）的 DOM -->
<div id="main" style="width: 80%;height:60%;"></div>
</body>
</html>
