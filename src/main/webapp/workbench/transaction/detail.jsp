<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.fzk.crm.settings.domain.DicValue" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fzk.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

    //准备字典类型为stage的字典值列表
    List<DicValue> stageList = (List<DicValue>) application.getAttribute("stage");
    //准备阶段和可能性之间的对应关系
    Map<String, String> stageMap = (Map<String, String>) application.getAttribute("stageMap");
    Set<String> keySet = stageMap.keySet();

    //准备：前面正常阶段和后面丢失阶段的分界点下标
    int point = 0;
    for (int i = 0; i < stageList.size(); i++) {
        //取得每一个字典值
        DicValue dicValue = stageList.get(i);
        String stage = dicValue.getValue();
        //根据stage取得possibility
        String possibility = stageMap.get(stage);
        //如果可能性为0，说明找到了前面正常阶段和后面丢失阶段的分界点
        if ("0".equals(possibility)) {
            point = i;
            break;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <base href="<%=basePath%>">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>

    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }
    </style>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });


            //阶段提示框
            $(".mystage").popover({
                trigger: 'manual',
                placement: 'bottom',
                html: 'true',
                animation: false
            }).on("mouseenter", function () {
                var _this = this;
                $(this).popover("show");
                $(this).siblings(".popover").on("mouseleave", function () {
                    $(_this).popover('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".popover:hover").length) {
                        $(_this).popover("hide")
                    }
                }, 100);
            });

            //页面加载完毕之后，展现交易历史列表
            showTranHistoryList();
        });

        //展现交易历史列表
        function showTranHistoryList() {
            $.ajax({
                url: "workbench/transaction/getTranHistoryListByTranId.do",
                data: {
                    "tranId": "${tran.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    /*
                    data
                        [{tranHistory1},{2},...]
                     */
                    //取出可能性
                    let map = {
                        <%
                        for(String key:keySet){
                            String value=stageMap.get(key);
                        %>
                        /*json会自动将最后一个逗号忽略的*/
                        "<%=key%>":<%=value%>,

                        <%
                        }
                        %>
                    };
                    let html = "";
                    $.each(data, function (i, n) {
                        /*<tr>
                            <td>资质审查</td>
                            <td>5,000</td>
                            <td>10</td>
                            <td>2017-02-07</td>
                            <td>2016-10-10 10:10:10</td>
                            <td>zhangsan</td>
                        </tr>*/
                        html += '<tr><td>' + n.stage + '</td>';
                        html += '<td>' + n.money + '</td>';
                        html += '<td>' + map[n.stage] + '</td>';
                        html += '<td>' + n.expectedDate + '</td>';
                        html += '<td>' + n.createTime + '</td>';
                        html += '<td>' + n.createBy + '</td></tr>';
                    });
                    $("#tranHistoryBody").html(html);
                }
            })
        }

        /*
        改变交易阶段的方法
            stage：需要改变的阶段
            i：    需要改变的阶段的下标
         */
        function changeStage(stage, i) {
            $.ajax({
                url: "workbench/transaction/changeStage.do",
                data: {
                    "tranId": "${tran.id}",
                    "stage": stage,
                    "money": "${tran.money}",//生成交易历史用
                    "expectedDate": "${tran.expectedDate}"//生成交易历史用
                },
                type: "post",
                dataType: "json",
                success: function (data) {
                    /*
                    data
                        {"success":true/false,"tran":{改变后的tran}}
                     */
                    if (data.success) {
                        //页面局部刷新
                        //(1)刷新阶段和可能性,修改人和修改时间
                        $("#stage").html(stage);
                        //取出可能性
                        let map = {
                            <%
                            for(String key:keySet){
                                String value=stageMap.get(key);
                            %>
                            /*json会自动将最后一个逗号忽略的*/
                            "<%=key%>":<%=value%>,

                            <%
                            }
                            %>
                        };
                        $("#possibility").html(map[stage]);
                        $("#editBy").html(data.tran.editBy + " ");
                        $("#editTime").html(data.tran.editTime + " ");

                        //(2)将所有阶段图标重新判断，重新赋予样式和颜色
                        changeIcon(stage, i);

                        //(3)交易阶段历史列表刷新
                        showTranHistoryList();
                    } else {
                        alert("更改失败！");
                    }
                }
            });
        }

        /*
        修改阶段图标的方法
            stage:改变的阶段，即当前阶段
            index：改变的阶段的下标，即为阶段图标span的id哦
         */
        function changeIcon(stage, index) {
            alert("阶段：" + stage + ";下标：" + index + ";参数类型：" + typeof index);
            //当前阶段
            let currentStage = stage;
            //当前阶段可能性。
            let currentPossibility = $("#possibility").html();
            //当前阶段的下标: index

            //前面正常阶段和后面丢失阶段的分界点下标
            let point = "<%=point%>";

            //如果当前阶段的可能性为0 前7个都是黑圈，后两个一个红x，一个黑x
            if (currentPossibility == "0") {
                //遍历分界点之前
                for (let i = 0; i < point; i++) {
                    //黑圈
                    //移除原有样式并添加新样式
                    $("#" + i).removeClass().addClass("glyphicon glyphicon-record mystage");
                    //为新样式赋予颜色
                    $("#" + i).css("color", "#000000");
                }
                //遍历分界点之后的
                for (let i = point; i <<%=stageList.size()%>; i++) {
                    if (i == index) {
                        //红x
                        //移除原有样式并添加新样式
                        $("#" + i).removeClass().addClass("glyphicon glyphicon-remove mystage");
                        //为新样式赋予颜色
                        $("#" + i).css("color", "#FF0000");
                    } else {
                        //黑x
                        //移除原有样式并添加新样式
                        $("#" + i).removeClass().addClass("glyphicon glyphicon-remove mystage");
                        //为新样式赋予颜色
                        $("#" + i).css("color", "#000000");
                    }
                }
            }
            //当前阶段可能性不为0， 前7个：一些绿圈，一个绿色标记，一些黑圈，后两个都为黑x
            else {
                //遍历分界点之前
                for (let i = 0; i < point; i++) {
                    if (i < index) {
                        //绿圈
                        //移除原有样式并添加新样式
                        $("#" + i).removeClass().addClass("glyphicon glyphicon-ok-circle mystage");
                        //为新样式赋予颜色
                        $("#" + i).css("color", "#90F790");
                    } else if (i == index) {
                        //绿色标记
                        //移除原有样式并添加新样式
                        $("#" + i).removeClass().addClass("glyphicon glyphicon-map-marker mystage");
                        //为新样式赋予颜色
                        $("#" + i).css("color", "#90F790");
                    } else {
                        //黑圈
                        //移除原有样式并添加新样式
                        $("#" + i).removeClass().addClass("glyphicon glyphicon-record mystage");
                        //为新样式赋予颜色
                        $("#" + i).css("color", "#000000");
                    }
                }
                //遍历分界点之后的
                for (let i = point; i <<%=stageList.size()%>; i++) {
                    //黑x
                    //移除原有样式并添加新样式
                    $("#" + i).removeClass().addClass("glyphicon glyphicon-remove mystage");
                    //为新样式赋予颜色
                    $("#" + i).css("color", "#000000");
                }
            }
        }
    </script>

</head>
<body>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${tran.customerId}-${tran.name} <small>￥${tran.money}</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" onclick="window.location.href='edit.jsp';"><span
                class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 阶段状态 -->
<div style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <%
        //准备当前阶段
        Tran tran = (Tran) request.getAttribute("tran");
        String currentStage = tran.getStage();
        //准备当前阶段的可能性
        String currentPossibility = stageMap.get(currentStage);
        //判断当前阶段可能性
        /*
        如果可能性为0 则前7个为黑圈，后两个有一个为红x，一个为黑x
         */
        if ("0".equals(currentPossibility)) {
            for (int i = 0; i < stageList.size(); i++) {
                //取得每一个阶段,并取得每一个阶段的可能性
                DicValue dicValue = stageList.get(i);
                String stage = dicValue.getValue();
                String possibility = stageMap.get(stage);
                //如果遍历出来的阶段可能性为0,说明是后两个，一个红叉一个黑x
                if (i >= point) {
                    if (stage.equals(currentStage)) {
                        //如果是当前阶段，则为红x
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-remove mystage" style="color: #FF0000;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
    } else {
        //如果不是当前阶段，则为黑x
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-remove mystage" style="color: #000000;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
        }
    }
    //如果不为0
    else {
        //则为黑圈
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-record mystage" style="color: #000000;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
            }
        }
    } else {
            /*
            当前阶段可能性不为0 前7个为一些绿圈，1个绿色标记,一些黑圈
            然后剩下2个为黑x
             */
        //准备当前阶段的分界点下标
        int index = 0;
        for (int i = 0; i < stageList.size(); i++) {
            DicValue dicValue = stageList.get(i);
            if (currentStage.equals(dicValue.getValue())) {
                index = i;
                break;
            }
        }
        for (int i = 0; i < stageList.size(); i++) {
            //取得每一个阶段,并取得每一个阶段的可能性
            DicValue dicValue = stageList.get(i);
            String stage = dicValue.getValue();
            String possibility = stageMap.get(stage);
            if (i < index) {
                //绿圈
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-ok-circle mystage" style="color: #90F790;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
    } else if (i == index) {
        //绿色标记
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-map-marker mystage" style="color: #90F790;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
    } else if (!"0".equals(possibility)) {
        //黑圈
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-record mystage" style="color: #000000;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
    } else {
        //黑x
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>');"
          class="glyphicon glyphicon-remove mystage" style="color: #000000;"
          data-toggle="popover" data-placement="bottom"
          data-content="<%=dicValue.getText()%>"></span>
    -----------
    <%
                }
            }
        }
    %>
    <%--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="资质审查" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="需求分析" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="价值建议" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="确定决策者" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom"
          data-content="提案/报价" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="谈判/复审"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="成交"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="丢失的线索"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="因竞争丢失关闭"></span>
    -------------%>
    <span class="closingDate">${tran.expectedDate}</span>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.money}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}-${tran.name}</b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.type}&nbsp;</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b
                id="possibility">${possibility}&nbsp;</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.source}&nbsp;</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.activityId}&nbsp;</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.contactsId}&nbsp;</b></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b
                id="editBy">${tran.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;" id="editTime">${tran.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${tran.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                &nbsp;${tran.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.nextContactTime}&nbsp;</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;">
            2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <!-- 备注2 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;">
            2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>创建时间</td>
                    <td>创建人</td>
                </tr>
                </thead>
                <tbody id="tranHistoryBody">
                <tr>
                    <td>资质审查</td>
                    <td>5,000</td>
                    <td>10</td>
                    <td>2017-02-07</td>
                    <td>2016-10-10 10:10:10</td>
                    <td>zhangsan</td>
                </tr>
                <tr>
                    <td>需求分析</td>
                    <td>5,000</td>
                    <td>20</td>
                    <td>2017-02-07</td>
                    <td>2016-10-20 10:10:10</td>
                    <td>zhangsan</td>
                </tr>
                <tr>
                    <td>谈判/复审</td>
                    <td>5,000</td>
                    <td>90</td>
                    <td>2017-02-07</td>
                    <td>2017-02-09 10:10:10</td>
                    <td>zhangsan</td>
                </tr>
                </tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>

</body>
</html>