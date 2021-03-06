<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
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

            //页面加载完毕后，展现该市场活动关联的备注信息列表
            showRemarkList();
            //使用 on操控动态生成的备注的修改和删除按钮，鼠标划入划出操作。
            $("#remarkBody").on("mouseover", ".remarkDiv", function () {
                $(this).children("div").children("div").show();
            });
            $("#remarkBody").on("mouseout", ".remarkDiv", function () {
                $(this).children("div").children("div").hide();
            });

            //为保存按钮绑定单击事件，执行添加备注操作
            $("#saveRemarkBtn").click(function () {
                //验证备注信息不能为空
                if ($.trim($("#remark").val()) === "") {
                    alert("备注信息不能为空！");
                    return false;
                }
                /*
                <textarea></textarea>标签虽然是标签对形式，但是取值只能用val()
                因为它属于表单元素
                 */
                $.ajax({
                    url: "workbench/activity/saveRemark.do",
                    data: {
                        "noteContent": $.trim($("#remark").val()),
                        "activityId": "${requestScope.activity.id}"
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                            {"success":true/false,"remark":{备注}}
                         */
                        if (data.success) {
                            //清空用户填写的备注信息
                            $("#remark").val("");

                            let html = "";
                            let n = data.remark;
                            html += '<div id=' + n.id + ' class="remarkDiv" style="height: 60px;">';
                            html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            html += '<div style="position: relative; top: -40px; left: 40px;">';
                            html += '<h5>' + n.noteContent + '</h5>';
                            html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.activity.name}</b> <small style="color: gray;">' + n.createTime + ' 由 ' + n.createBy + " 创建" + '</small>';
                            html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>&nbsp;&nbsp;&nbsp;&nbsp;';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
                            html += '</div></div></div>';
                            $("#remarkDiv").before(html);
                        } else {
                            alert("保存失败！");
                        }

                    }
                });
            });

            //为更新按钮绑定单击事件，执行修改备注的操作
            $("#updateRemarkBtn").click(function (){
                let remarkId = $("#remarkId").val();
                let noteContent = $.trim($("#noteContent").val());
                if(noteContent===""){
                    alert("备注不能为空！");
                    return false;
                }
               //发送ajax请求
               $.ajax({
                   url:"workbench/activity/updateRemark.do",
                   data:{
                       "remarkId":remarkId,
                       "noteContent":noteContent,
                   },
                   type:"post",
                   dataType:"json",
                   success:function (data){
                       /*
                       data
                        {"success":true/false,"remark":{备注}}
                        */
                       if(data.success){
                           //关闭修改备注的模态窗口
                           $("#editRemarkModal").modal("hide");
                           //更新备注展示列表的内容,先删掉原来的，再追加修改后的
                           $("#"+remarkId).remove();
                           let html = "";
                           let n = data.remark;
                           html += '<div id=' + n.id + ' class="remarkDiv" style="height: 60px;">';
                           html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                           html += '<div style="position: relative; top: -40px; left: 40px;">';
                           html += '<h5>' + n.noteContent + '</h5>';
                           html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.activity.name}</b> <small style="color: gray;">' + n.editTime + ' 由 ' + n.editBy + " 修改" + '</small>';
                           html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                           html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>&nbsp;&nbsp;&nbsp;&nbsp;';
                           html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
                           html += '</div></div></div>';
                           $("#remarkDiv").before(html);
                       }else{
                           alert("修改备注失败！");
                       }
                   }
               });
            });
        });

        /*注意：
        * 在js中使用EL表达式必须套在字符串""中
        */
        function showRemarkList() {
            $.ajax({
                url: "workbench/activity/getRemarkListByActivityId.do",
                data: {
                    "activityId": "${requestScope.activity.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    /*
                    data
                         [{remark1},{2},{3}]
                     */
                    let html = "";
                    $.each(data, function (i, n) {
                        /*
                        javascript:void(0)
                          将超链接禁用，只能以触发事件的形式来操作
                         */
                        html += '<div id=' + n.id + ' class="remarkDiv" style="height: 60px;">';
                        html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                        html += '<div style="position: relative; top: -40px; left: 40px;">';
                        html += '<h5>' + n.noteContent + '</h5>';
                        html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.activity.name}</b> <small style="color: gray;">' + (n.editFlag === "0" ? n.createTime : n.editTime) + ' 由 ' + (n.editFlag === "0" ? n.createBy + " 创建" : n.editBy + " 修改") + '</small>';
                        html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                        html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>&nbsp;&nbsp;&nbsp;&nbsp;';
                        html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
                        html += '</div></div></div>';
                    });
                    //因为要加入的div中有内容，所以可以选择新建空的div，再往里面加html
                    //也可以使用jQuery的外部插入before()
                    $("#remarkDiv").before(html);
                }
            });
        }

        function deleteRemark(remarkId) {
            //友好的提示是否要删除
            if(!window.confirm("确认删除选中的备注吗？")){
                return false;
            }
            $.ajax({
                url: "workbench/activity/deleteRemark.do",
                data: {
                    "remarkId": remarkId
                },
                type: "post",
                dataType: "json",
                success: function (data) {
                    /*
                    data
                     {"success":true/false}
                     */
                    if (!data.success) {
                        alert("删除失败！");
                    } else {
                        //删除成功，不要用刷新备注信息列表方式更新
                        //而要将该备注信息相关div组件移除
                        //因为showRemarkList函数是将备注追加进去，而不是重置进去
                        $("#" + remarkId).remove();
                    }
                }
            })
        }

        function editRemark(remarkId) {
            //将remarkId赋值给隐藏域中
            $("#remarkId").val(remarkId);
            //找到指定的存放备注的h5标签里的内容，放在模态窗口的文本域中
            //jQuery层级选择器
            let html=$("#" + remarkId + " h5").html();
            $("#noteContent").val(html);
            //打开修改备注的模态窗口
            $("#editRemarkModal").modal("show");
        }
    </script>

</head>
<body>

<!-- 修改市场活动备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
    <%-- 备注的id --%>
    <input type="hidden" id="remarkId">
    <div class="modal-dialog" role="document" style="width: 40%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改备注</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="noteContent"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost" value="5,000">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>市场活动-${requestScope.activity.name} <small>${requestScope.activity.startDate}
            ~ ${requestScope.activity.endDate}</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span
                class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.activity.owner}</b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.activity.name}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>

    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">开始日期</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.activity.startDate}</b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.activity.endDate}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">成本</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.activity.cost}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.activity.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${requestScope.activity.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.activity.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${requestScope.activity.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>${requestScope.activity.description}</b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <%--<div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;">
            2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>--%>

    <!-- 备注2 -->
    <%--<div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;">
            2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>--%>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button id="saveRemarkBtn" type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>
<div style="height: 200px;"></div>
</body>
</html>