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
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <%--分页插件：必须放在bootstrap.min.js插件引入的下面，要先加载bootstrap--%>
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">

        $(function () {
            //日历控件
            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                aotuclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });

            //为创建按钮绑定事件，打开添加操作的模态窗口
            $("#addBtn").click(function () {
                //走后台，目的是取得用户信息列表，展示在所有者下拉框中
                $.ajax({
                    url: "workbench/activity/getUserList.do",
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        /*
                        List<User> list
                            [{用户1},{2},...]
                         */
                        let html = "<option></option>";
                        //回调函数的第二个参数是当前遍历的对象
                        $.each(data, function (i, user) {
                            //这里用拼串方式，当然也可以调用jquery的append方法
                            //以id作为选项的值，以name作为显示内容
                            html += "<option value='" + user.id + "'>" + user.name + "</option>";
                        });
                        $("#create-marketActivityOwner").html(html);
                        //将当前登录的用户设置为下拉框默认选项
                        //注意：在js中使用el表达式，必须套在字符串中，不然会出错
                        $("#create-marketActivityOwner").val("${user.id}");


                        //所有者下拉框处理完毕之后，展现模态窗口
                        /*
                        操作模态窗口的方式：
                            找到需要操作模态窗口的jQuery对象，
                            调用modal方法，传入show：打开 或  hide：关闭参数
                         */
                        $("#createActivityModal").modal("show");
                    }
                });
            });

            //为保存按钮绑定单击事件，执行添加操作
            $("#saveBtn").click(function () {
                $.ajax({
                    url: "workbench/activity/saveActivity.do",
                    data: {
                        // 习惯性的要去除左右字符串的空格，因为用户输入喜欢按空格
                        "owner": $.trim($("#create-marketActivityOwner").val()),
                        "name": $.trim($("#create-marketActivityName").val()),
                        "startDate": $.trim($("#create-startDate").val()),
                        "endDate": $.trim($("#create-endDate").val()),
                        "cost": $.trim($("#create-cost").val()),
                        "description": $.trim($("#create-description").val()),
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                         data {"success":true/false}
                         */
                        if (data.success) {
                            //入口2.1：添加成功，局部刷新市场活动列表
                            pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                            //清空添加操作模态窗口中的数据
                            //提交表单
                            // $("#activityAddForm").submit();
                            //清空表单（重置表单）
                            /*
                            这里要注意：
                                表单的jQuery对象提供了submit方法，
                                但是没有提供reset方法去重置表单(坑处在于IDEA却显示有reset方法)

                                虽然jQuery没有提供，但原生js对象提供了reset方法的
                                所以此处要将jQuery对象转为原生dom对象
                                    jQuery对象[下标]
                             */
                            $("#activityAddForm")[0].reset();
                            //关闭添加市场活动的模态窗口
                            $("#createActivityModal").modal("hide");
                        } else {
                            alert("添加市场活动失败！");
                        }
                    }
                });
            });

            //入口1：页面加载完成后触发加载市场活动信息列表的方法
            //默认展开第一页，每页两条记录
            pageList(1, 2);

            //入口3：为查询按钮绑定事件，触发pageList方法
            $("#searchBtn").click(function () {
                /*
                每次我们点击搜索的时候，应该将搜索框中的信息保存起来，保存到隐藏域之中
                 */
                $("#hidden-name").val($.trim($("#search-name").val()));
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-startDate").val($.trim($("#search-startDate").val()));
                $("#hidden-endDate").val($.trim($("#search-endDate").val()));
                pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
            });


            //为全选复选框框绑定单击事件
            $("#checkAll").click(function () {
                $("input[name='check']").prop("checked", this.checked);
            });
            //为复选框绑定单击事件，判断是否触发全选
            //但是这种做法是不行的，因为动态生成的元素不能以普通方式进行绑定事件
            /*$("input[name='check']").click(function (){
                alert(123);
            });*/
            /*
            动态绑定使用on方法
             */
            $("#activityBody").on("click", "input[name='check']", function () {
                $("#checkAll").prop("checked", $("input[name='check']").length === $("input[name='check']:checked").length);
            })


            //为删除按钮绑定事件，执行市场活动删除操作
            $("#deleteBtn").click(function () {
                //首先要找到复选框中打√的jQuery对象
                let $checked = $("input[name='check']:checked");
                if ($checked.length === 0) {
                    alert("请选择要删除的市场活动！")
                } else {
                    //友好的提示是否确认删除
                    if (!window.confirm("确认要删除吗？")) {
                        return false;
                    }
                    //选了一条或者多条
                    //url:workbench/activity/delete.do?id=xxx&id=xxx&id=xxx
                    //首先要拼接参数
                    let param = "";
                    //遍历$checked,取出每个input的value=activity.id
                    for (let i = 0; i < $checked.length; i++) {
                        if (i === 0) {
                            param += "id=" + $checked[i].value;
                        } else {
                            param += "&id=" + $checked[i].value;
                        }
                    }


                    //发送删除的ajax请求
                    $.ajax({
                        url: "workbench/activity/deleteActivity.do",
                        data: param,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            /*
                            data
                                {"success":true/false}
                             */
                            if (data.success) {
                                //入口2.3：删除成功后，刷新市场活动列表,调用pageList方法
                                pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
                            } else {
                                alert("删除失败！")
                            }
                        }
                    });
                }
            });

            //为修改按钮绑定单击事件,打开修改操作模态窗口
            $("#editBtn").click(function () {
                //首先要找到复选框中打√的jQuery对象
                let $checked = $("input[name='check']:checked");
                if ($checked.length === 0) {
                    alert("请选择需要修改的市场活动。");
                } else if ($checked.length > 1) {
                    alert("只能选择修改一条记录。");
                } else {
                    //选中的市场活动id
                    let id = $checked.val();
                    //发送ajax请求
                    $.ajax({
                        url: "workbench/activity/getUserListAndActivity.do",
                        data: {
                            "id": id
                        },
                        dataType: "json",
                        type: "get",
                        success: function (data) {
                            /*
                            data
                                {"userList":[{user1},{2},{3}],"activity":{}}
                             */

                            //处理所有者下拉框
                            let html = "<option></option>";
                            $.each(data.userList, function (i, n) {
                                html += "<option value='" + n.id + "'>" + n.name + "</option>";
                            });
                            $("#edit-marketActivityOwner").html(html);

                            //处理单条activity
                            /*
                                id保存在修改市场活动模态窗口的隐藏域中
                             */
                            $("#edit-id").val(data.activity.id);
                            $("#edit-marketActivityName").val(data.activity.name);
                            $("#edit-marketActivityOwner").val(data.activity.owner);
                            $("#edit-startDate").val(data.activity.startDate);
                            $("#edit-endDate").val(data.activity.endDate);
                            $("#edit-cost").val(data.activity.cost);
                            $("#edit-description").val(data.activity.description);
                            //所有值填写后之后，打开修改操作模态窗口
                            $("#editActivityModal").modal("show");
                        }
                    });
                }
            });

            //为更新按钮绑定单击事件，执行市场活动的修改操作
            /*
            实际项目中，一般都是先添加再修改，所以为了节省时间，
            修改操作一般都是copy添加操作
             */
            $("#updateBtn").click(function () {
                $.ajax({
                    url: "workbench/activity/updateActivity.do",
                    data: {
                        // 习惯性的要去除左右字符串的空格，因为用户输入喜欢按空格
                        //将隐藏域中的activity.id也发过去
                        "id": $("#edit-id").val(),
                        "owner": $.trim($("#edit-marketActivityOwner").val()),
                        "name": $.trim($("#edit-marketActivityName").val()),
                        "startDate": $.trim($("#edit-startDate").val()),
                        "endDate": $.trim($("#edit-endDate").val()),
                        "cost": $.trim($("#edit-cost").val()),
                        "description": $.trim($("#edit-description").val()),
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                         data {"success":true/false}
                         */
                        if (data.success) {
                            //入口2.2：修改成功，局部刷新市场活动列表
                            //回到修改的页面和每页展示条数
                            pageList($("#activityPage").bs_pagination('getOption', 'currentPage'),$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                            //这里和添加不同的是，这里可以不清空表单内容，因为每次打开都会覆盖

                            //关闭添加市场活动的模态窗口
                            $("#editActivityModal").modal("hide");
                        } else {
                            alert("修改市场活动失败！");
                        }
                    }
                });
            });

        });


        /*
            对于所有的关系型数据库，做前端的分页相关操作的基础组件
            就是pageNo和pageSize
            pageNo：页码
            pageSize：每页展示的记录数

            在下列情况下需要刷新列表：
                1. 点击左侧菜单中的“市场活动”超链接
                2. 添加，修改和删除后都需要刷新
                3. 点击查询按钮的时候
                4. 点击分页组件的时候
            以上6个入口都将要调用此方法
         */
        function pageList(pageNo, pageSize) {
            //将复选框的全选框的√取消
            $("#checkAll").prop("checked", false);

            //查询前，将隐藏域中保存的信息取出来赋值给4个查询条件框
            $("#search-name").val($.trim($("#hidden-name").val()));
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-startDate").val($.trim($("#hidden-startDate").val()));
            $("#search-endDate").val($.trim($("#hidden-endDate").val()));
            $.ajax({
                url: "workbench/activity/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "name": $.trim($("#search-name").val()),
                    "owner": $.trim($("#search-owner").val()),
                    "startDate": $.trim($("#search-startDate").val()),
                    "endDate": $.trim($("#search-endDate").val())
                },
                type: "get",
                dataType: "json",
                success: function (data) {

                    /*
                    data    json串
                        我们需要的：
                        [{市场活动1},{2},{3}...] List<Activity> dataList
                        分页插件需要的：查询出来的总记录数
                        {"total":100}  int total

                        则json串
                        {"total":100,"dataList":[{市场活动1},{2},{3}...]}
                     */
                    let html = "";
                    $.each(data.dataList, function (i, n) {
                        <%--模板如下：
                        <tr class="active">
                            <td><input type="checkbox"/></td>
                            <td><a style="text-decoration: none; cursor: pointer;"
                                   onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                         </tr>
                         --%>
                        html += "<tr class=\"active\">" +
                            "<td><input type=\"checkbox\" name=\"check\" value=\"" + n.id + "\"/></td>" +
                            "<td><a style=\"text-decoration: none; cursor: pointer;\"" +
                            "onclick=\"window.location.href=\'workbench/activity/detail.do?id="+n.id+"\';\">" +
                            n.name + "</a></td>" +
                            "<td>" + n.owner + "</td>" +
                            "<td>" + n.startDate + "</td>" +
                            "<td>" + n.endDate + "</td></tr>";
                    });
                    //显示市场活动列表
                    $("#activityBody").html(html);

                    //计算总页数
                    let totalPages = Math.ceil(data.total / pageSize);
                    //数据处理完毕之后，结合分页查询，对前端展现分页信息
                    $("#activityPage").bs_pagination({
                        currentPage: pageNo, // 页码
                        rowsPerPage: pageSize, // 每页显示的记录条数
                        maxRowsPerPage: 20, // 每页最多显示的记录条数
                        totalPages: totalPages, // 总页数
                        totalRows: data.total, // 总记录条数

                        visiblePageLinks: 3, // 显示几个卡片

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        //入口4：这里要调用自己写的这个查询方法进行分页查询
                        onChangePage: function (event, data) {
                            pageList(data.currentPage, data.rowsPerPage);
                        }
                    });
                }
            });
        }
    </script>
</head>
<body>

<%--隐藏域：将查询条件保存在隐藏域中--%>
<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-startDate"/>
<input type="hidden" id="hidden-endDate"/>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form id="activityAddForm" class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                                <%--<option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>--%>
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-startDate">
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-endDate">
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-description"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <%--
                    data-dismiss="modal" 表示关闭模态窗口

                    --%>
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
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
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="activityEditForm">

                    <%--隐藏域：保存了修改市场活动的id--%>
                    <input type="hidden" id="edit-id">
                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <%--<option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>--%>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-startDate">
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-endDate">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <%--关于文本域textarea标签：
                                (1)一定要以标签对形式呈现，中间别没事加个空格啥的
                                (2)textarea 虽然是标签对形式，但是它属于表单元素范畴
                                    对于textarea这类表单元素的取值和赋值操作，应该统一使用val()
                                    html()方法也不是不能用
                                --%>
                            <textarea class="form-control" rows="3" id="edit-description"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="search-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="search-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control time" type="text" id="search-startDate"/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control time" type="text" id="search-endDate">
                    </div>
                </div>

                <button type="button" id="searchBtn" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <%--点击创建按钮，观察两个属性和属性值
                        data-toggle="modal"
                            表示触发该按钮，将要打开一个模态窗口
                        data-target="#createActivityModal"
                            表示要打开哪个模态窗口#id的形式找到该窗口

                        这是一种通过属性和属性值的写在button按钮中来打开模态窗口
                        但是这样做是有问题的：
                            问题在于没有办法对按钮的功能进行扩充
                        所以未来的项目开发，对于触发模态窗口操作，不能写死在元素当中
                        应该由我们自己写js代码来操作
                        --%>
                <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span>
                    创建
                </button>
                <%--<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>--%>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="activityBody">
                <%--<tr class="active">
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                    <td>zhangsan</td>
                    <td>2020-10-10</td>
                    <td>2020-10-20</td>
                </tr>
                <tr class="active">
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                    <td>zhangsan</td>
                    <td>2020-10-10</td>
                    <td>2020-10-20</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 30px;">
            <div id="activityPage"></div>
            <%--<div>
                <button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
            </div>
            <div class="btn-group" style="position: relative;top: -34px; left: 110px;">
                <button type="button" class="btn btn-default" style="cursor: default;">显示</button>
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                        10
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#">20</a></li>
                        <li><a href="#">30</a></li>
                    </ul>
                </div>
                <button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
            </div>
            <div style="position: relative;top: -88px; left: 285px;">
                <nav>
                    <ul class="pagination">
                        <li class="disabled"><a href="#">首页</a></li>
                        <li class="disabled"><a href="#">上一页</a></li>
                        <li class="active"><a href="#">1</a></li>
                        <li><a href="#">2</a></li>
                        <li><a href="#">3</a></li>
                        <li><a href="#">4</a></li>
                        <li><a href="#">5</a></li>
                        <li><a href="#">下一页</a></li>
                        <li class="disabled"><a href="#">末页</a></li>
                    </ul>
                </nav>
            </div>--%>
        </div>

    </div>

</div>
</body>
</html>