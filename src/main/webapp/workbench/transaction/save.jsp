<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <base href="<%=basePath%>">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <%--自动补全插件--%>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
</head>
<script type="text/javascript">
    $(function () {
        //日历控件
        $(".time1").datetimepicker({
            minView: "month",
            language: 'zh-CN',
            format: 'yyyy-mm-dd',
            aotuclose: true,
            todayBtn: true,
            pickerPosition: "bottom-left"
        });
        $(".time2").datetimepicker({
            minView: "month",
            language: 'zh-CN',
            format: 'yyyy-mm-dd',
            aotuclose: true,
            todayBtn: true,
            pickerPosition: "top-left"
        });
        //自动补全插件
        $("#create-customerName").typeahead({
            source: function (query, process) {
                $.post(
                    "workbench/transaction/getCustomerNameList.do",
                    {"name": query},
                    function (data) {
                        //alert(data);
                        /*
                        data
                            [{字符串1},{2},...]
                        */
                        process(data);
                    },
                    "json"
                );
            },
            //delay表示延迟加载的时间，过了1.5s之后再加载出来
            delay: 1000
        });

        //给打开搜索市场活动的放大镜绑定单击事件
        $("#openActivityModalBtn").click(function () {
            //清空搜索框和活动列表内容
            $("#searchActivity").val("");
            $("#activityBody").html("");
            //打开模态窗口
            $("#findMarketActivityModal").modal("show");
        });
        //给activity的搜索框绑定键盘事件
        $("#searchActivity").keydown(function (event) {
            if (event.keyCode === 13) {
                //取出搜索框中的值
                let activityName = $.trim($("#searchActivity").val());
                if (activityName === "") {
                    alert("请输入市场活动名称！");
                    return false;
                }
                //发送ajax请求拿到activityList
                $.ajax({
                    url: "workbench/transaction/getActivityListByName.do",
                    data: {
                        "activityName": activityName
                    },
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                         [{activity1},{2},...]
                         */
                        let html = "";
                        $.each(data, function (i, n) {
                            <%--<tr>
                               <td><input type="radio" name="activity"/></td>
                               <td>发传单</td>
                               <td>2020-10-10</td>
                               <td>2020-10-20</td>
                               <td>zhangsan</td>
                           </tr>--%>
                            html += '<tr>';
                            html += '<td><input type="radio" name="activity" value="' + n.id + '"/></td>';
                            html += '<td id="' + n.id + '">' + n.name + '</td>';
                            html += '<td>' + n.startDate + '</td>';
                            html += '<td>' + n.endDate + '</td>';
                            html += '</tr>';
                        });
                        $("#activityBody").html(html);
                    }
                });
                return false;
            }
        });
        //给查找市场活动模态窗口的选中按钮绑定单击事件
        $("#submitActivityBtn").click(function () {
            //找到选中的activity
            let activityId = $("#activityBody input:checked").val();
            let activityName = $("#" + activityId).html();
            //将id和name赋值给隐藏域和显示框
            $("#create-activityName").val(activityName);
            $("#create-activityId").val(activityId);
            //关闭模态窗口
            $("#findMarketActivityModal").modal("hide");
        });
        //给查找联系人的放大镜绑定单击事件
        $("#openContactsModalBtn").click(function () {
            //清空搜索框和联系人列表内容
            $("#searchContacts").val("");
            $("#contactsBody").html("");
            //打开模态窗口
            $("#findContactsModal").modal("show");
        });
        //给contacts的搜索框绑定键盘事件
        $("#searchContacts").keydown(function (event) {
            if (event.keyCode === 13) {
                //取出搜索框中的值
                let contactsName = $.trim($("#searchContacts").val());
                if (contactsName === "") {
                    alert("请输入联系人名称！");
                    return false;
                }
                //发送ajax请求拿到contactsList
                $.ajax({
                    url: "workbench/transaction/getContactsListByName.do",
                    data: {
                        "contactsName": contactsName
                    },
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                         [{contacts1},{2},...]
                         */
                        /* <tr>
                             <td><input type="radio" name="activity"/></td>
                             <td>李四</td>
                             <td>lisi@bjpowernode.com</td>
                             <td>12345678901</td>
                         </tr>*/
                        let html = "";
                        $.each(data, function (i, n) {
                            html += '<tr>';
                            html += '<td><input type="radio" name="contacts" value="' + n.id + '"/></td>';
                            html += '<td id="' + n.id + '">' + n.fullname + '</td>';
                            html += '<td>' + n.email + '</td>';
                            html += '<td>' + n.mphone + '</td>';
                            html += '</tr>';
                        });
                        $("#contactsBody").html(html);
                    }
                });
                return false;
            }
        });
        //给查找联系人模态窗口的选中按钮绑定单击事件
        $("#submitContactsBtn").click(function () {
            //找到选中的contacts
            let contactsId = $("#contactsBody input:checked").val();
            let fullname = $("#" + contactsId).html();
            //将id和fullname赋值给隐藏域和显示框
            $("#create-contactsName").val(fullname);
            $("#create-contactsId").val(contactsId);
            //关闭模态窗口
            $("#findContactsModal").modal("hide");
        });

        //为阶段的下拉框绑定选中下拉框事件，根据选中的阶段填写可能性
        $("#create-stage").change(function () {
            //取得选中的阶段
            let stage = this.value;
            //取出可能性
            let map = {
                <%
                Map<String,String> stageMap=(Map<String, String>) application.getAttribute("stageMap");
                Set<String> keySet = stageMap.keySet();
                for(String key:keySet){
                    String value=stageMap.get(key);
                %>
                /*json会自动将最后一个逗号忽略的*/
                "<%=key%>":<%=value%>,

                <%
                }
                %>
            };
            //给可能性赋值
            $("#create-possibility").val(map[stage]);
        });

        //为保存按钮绑定单击事件，执行表单post请求操作
        $("#saveBtn").click(function (){
            //表单提交
            $("form").submit();
        });
    });
</script>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;"
                                   id="searchActivity" placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable3" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="activityBody">
                    <%--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="submitActivityBtn">选中</button>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="searchContacts" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入联系人名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody id="contactsBody">
                    <%--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="submitContactsBtn">选中</button>
            </div>
        </div>
    </div>
</div>


<div style="position:  relative; left: 30px;">
    <h3>创建交易</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
        <button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/index.jsp'">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<form class="form-horizontal" role="form" style="position: relative; top: -30px;" action="workbench/transaction/saveTran.do" method="post">
    <div class="form-group">
        <label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-transactionOwner" name="owner">
                <option></option>
                <c:forEach items="${userList}" var="i">
                    <option value="${i.id}" ${user.id eq i.id ? "selected" : ""}>${i.name}</option>
                </c:forEach>
                <%-- <option>zhangsan</option>
                 <option>lisi</option>
                 <option>wangwu</option>--%>
            </select>
        </div>
        <label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-amountOfMoney" name="money">
        </div>
    </div>

    <div class="form-group">
        <label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-transactionName" name="name">
        </div>
        <label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time1" id="create-expectedClosingDate" name="expectedDate">
        </div>
    </div>

    <div class="form-group">
        <label for="create-customerName" class="col-sm-2 control-label">客户名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" name="customerName" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
        </div>
        <label for="create-stage" class="col-sm-2 control-label">阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-stage" name="stage">
                <option></option>
                <c:forEach items="${stage}" var="i">
                    <option value="${i.value}">${i.text}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="create-transactionType" class="col-sm-2 control-label">类型</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-transactionType" name="type">
                <option></option>
                <c:forEach items="${transactionType}" var="i">
                    <option value="${i.value}">${i.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-possibility" class="col-sm-2 control-label">可能性</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-possibility">
        </div>
    </div>

    <div class="form-group">
        <label for="create-clueSource" class="col-sm-2 control-label">来源</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-clueSource" name="source">
                <option></option>
                <c:forEach items="${source}" var="i">
                    <option value="${i.value}">${i.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-activityName" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                            id="openActivityModalBtn"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-activityName" readonly>
            <%--隐藏域：保存了activityId--%>
            <input type="hidden" id="create-activityId" name="activityId">
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                            id="openContactsModalBtn"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-contactsName" readonly>
            <%--隐藏域：保存了contactsId--%>
            <input type="hidden" id="create-contactsId" name="contactsId">
        </div>
    </div>

    <div class="form-group">
        <label for="create-describe" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-describe" name="description"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time2" id="create-nextContactTime" name="nextContactTime">
        </div>
    </div>

</form>
</body>
</html>